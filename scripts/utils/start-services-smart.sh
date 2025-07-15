#!/bin/bash
# Script para gestionar servicios Trivance con Docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

# Importar funciones comunes (incluye colores)
source "${SCRIPT_DIR}/common.sh"

# Verificar Docker obligatorio
check_docker_required() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        echo -e "${RED}Docker es OBLIGATORIO para ejecutar los servicios${NC}"
        echo -e "${YELLOW}Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop/${NC}"
        exit 1
    fi
    
    if ! docker ps &>/dev/null 2>&1; then
        echo -e "${RED}❌ Docker no está corriendo${NC}"
        echo -e "${YELLOW}Por favor inicia Docker Desktop y vuelve a intentar${NC}"
        exit 1
    fi
}

# Obtener environment actual
get_current_env() {
    if [[ -f "${WORKSPACE_DIR}/envs/.current_environment" ]]; then
        cat "${WORKSPACE_DIR}/envs/.current_environment"
    else
        echo "local"
    fi
}

# Verificar salud de servicio con retry
check_service_health() {
    local service_name="$1"
    local url="$2"
    local max_attempts=30
    local attempt=1
    
    echo -n "  • Esperando ${service_name}..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e " ${GREEN}✅ OK${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    echo -e " ${RED}❌ Timeout${NC}"
    return 1
}

# Iniciar servicios
start_services() {
    # Verificar Docker primero
    check_docker_required
    
    local current_env=$(get_current_env)
    
    echo -e "${BLUE}🚀 Iniciando servicios Trivance con Docker...${NC}"
    echo -e "${CYAN}📍 Environment actual: ${current_env}${NC}"
    echo
    
    # Verificar si los archivos .env de Docker existen
    if [[ ! -f "${CONFIG_DIR}/docker/.env.docker-local" ]] || [[ ! -f "${CONFIG_DIR}/docker/.env.docker-auth-local" ]]; then
        echo -e "${YELLOW}⚠️  Archivos .env para Docker no encontrados${NC}"
        echo -e "${CYAN}Ejecutando envs.sh para generar configuraciones...${NC}"
        
        # Ejecutar envs.sh switch para generar archivos Docker
        "${SCRIPT_DIR}/../envs.sh" switch "${current_env}"
    fi
    
    # Verificar nuevamente después de generar
    if [[ ! -f "${CONFIG_DIR}/docker/.env.docker-local" ]] || [[ ! -f "${CONFIG_DIR}/docker/.env.docker-auth-local" ]]; then
        echo -e "${RED}❌ Error: No se pudieron generar los archivos .env para Docker${NC}"
        echo -e "${YELLOW}Ejecuta manualmente: ./trivance-dev-config/scripts/envs.sh switch ${current_env}${NC}"
        exit 1
    fi
    
    # Iniciar servicios Docker
    echo -e "${CYAN}🐳 Iniciando contenedores Docker...${NC}"
    cd "${CONFIG_DIR}/docker"
    
    # Detectar si las imágenes ya existen
    local images_exist=true
    for image in "docker-ms_level_up_management" "docker-ms_trivance_auth"; do
        if ! docker images --format "{{.Repository}}" | grep -q "^${image}$"; then
            images_exist=false
            break
        fi
    done
    
    # Si las imágenes no existen, informar que tomará más tiempo
    if [[ "$images_exist" == "false" ]]; then
        echo -e "${YELLOW}⚠️  Primera ejecución detectada: construyendo imágenes Docker...${NC}"
        echo -e "${CYAN}   Esto puede tomar 3-5 minutos la primera vez${NC}"
        echo
    fi
    
    # Usar docker compose (v2) si está disponible, sino docker-compose
    if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
        docker compose up -d postgres mongodb ms_level_up_management ms_trivance_auth dozzle
    else
        docker-compose up -d postgres mongodb ms_level_up_management ms_trivance_auth dozzle
    fi
    
    # Verificar salud de servicios
    echo -e "${YELLOW}⏳ Esperando a que los servicios estén listos...${NC}"
    
    local all_healthy=true
    check_service_health "PostgreSQL" "localhost:5432" || all_healthy=false
    check_service_health "MongoDB" "localhost:27017" || all_healthy=false
    check_service_health "Auth API" "http://localhost:3001/health" || all_healthy=false
    check_service_health "Management API" "http://localhost:3000/health" || all_healthy=false
    
    if [[ "$all_healthy" == "false" ]]; then
        echo -e "${YELLOW}⚠️  Algunos servicios no responden, verificando logs...${NC}"
        docker logs trivance_auth --tail 20
        docker logs trivance_management --tail 20
    fi
    
    # Iniciar frontend con PM2
    echo -e "${CYAN}🖥️  Iniciando frontend con PM2 (hot-reload)...${NC}"
    
    # Verificar si PM2 está instalado
    if ! command -v pm2 &> /dev/null; then
        echo -e "${YELLOW}Instalando PM2...${NC}"
        npm install -g pm2
    fi
    
    # Crear directorio de logs si no existe
    local logs_dir="${WORKSPACE_DIR}/level_up_backoffice/logs"
    if [[ ! -d "$logs_dir" ]]; then
        echo -e "${CYAN}📁 Creando directorio de logs...${NC}"
        mkdir -p "$logs_dir"
    fi
    
    # Iniciar frontend
    if ! pm2 list | grep -q "backoffice.*online"; then
        # Usar --no-autorestart para evitar reintentos infinitos si hay errores
        pm2 start "${WORKSPACE_DIR}/ecosystem.config.js" --only backoffice
        
        # Verificar que se inició correctamente
        sleep 2
        if ! pm2 list | grep -q "backoffice.*online"; then
            echo -e "${YELLOW}⚠️  Frontend tuvo problemas al iniciar, verificando logs...${NC}"
            pm2 logs backoffice --lines 10 --nostream
        fi
    else
        echo -e "${GREEN}✅ Frontend ya está corriendo${NC}"
    fi
    
    echo
    echo -e "${GREEN}✅ Todos los servicios iniciados:${NC}"
    echo "  • PostgreSQL: localhost:5432 (Docker)"
    echo "  • MongoDB: localhost:27017 (Docker)"
    echo "  • Auth API: http://localhost:3001 (Docker)"
    echo "  • Management API: http://localhost:3000 (Docker)"
    echo "  • GraphQL Playground: http://localhost:3000/graphql"
    echo "  • Frontend Admin: http://localhost:5173 (PM2 con hot-reload)"
    echo "  • Dozzle (Monitor de logs): http://localhost:9999 (Docker)"
    echo
    echo -e "${BLUE}📱 Para Mobile App:${NC}"
    echo "  1. Abre una nueva terminal"
    echo "  2. cd ${WORKSPACE_DIR}/trivance-mobile"
    echo "  3. npm run start:docker  # O usa .env.local con ENV_LOCAL=true"
    echo "  4. Escanea el QR con Expo Go"
    echo
    echo -e "${YELLOW}💡 Nota:${NC} La app móvil ahora soporta Docker local automáticamente"
}

# Detener servicios
stop_services() {
    echo -e "${BLUE}🛑 Deteniendo servicios...${NC}"
    
    # Detener PM2
    if command -v pm2 &> /dev/null && pm2 list 2>/dev/null | grep -q "online"; then
        echo -e "${CYAN}Deteniendo frontend PM2...${NC}"
        pm2 stop backoffice
    fi
    
    # Detener Docker
    if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
        echo -e "${CYAN}Deteniendo contenedores Docker...${NC}"
        cd "${CONFIG_DIR}/docker"
        
        if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
            docker compose down
        else
            docker-compose down
        fi
    else
        echo -e "${YELLOW}⚠️  Docker no está corriendo${NC}"
    fi
    
    echo -e "${GREEN}✅ Todos los servicios detenidos${NC}"
}

# Ver estado de servicios
status_services() {
    echo -e "${BLUE}📊 Estado de servicios Trivance${NC}"
    echo
    
    # Verificar Docker primero
    if ! command -v docker &>/dev/null || ! docker ps &>/dev/null 2>&1; then
        echo -e "${RED}❌ Docker no está disponible o no está corriendo${NC}"
        echo -e "${YELLOW}Los servicios requieren Docker para funcionar${NC}"
        return 1
    fi
    
    # Estado Docker
    echo -e "${CYAN}🐳 Contenedores Docker:${NC}"
    cd "${CONFIG_DIR}/docker"
    if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
        docker compose ps
    else
        docker-compose ps
    fi
    echo
    
    # Estado PM2
    if command -v pm2 &> /dev/null; then
        echo -e "${CYAN}📦 Frontend PM2:${NC}"
        pm2 list | grep backoffice || echo "  No hay servicios PM2 corriendo"
        echo
    fi
    
    # Verificar endpoints
    echo -e "${CYAN}🔍 Estado de endpoints:${NC}"
    echo -n "  • PostgreSQL (5432): "
    nc -z localhost 5432 2>/dev/null && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    echo -n "  • MongoDB (27017): "
    nc -z localhost 27017 2>/dev/null && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    echo -n "  • Auth Service (3001): "
    curl -s http://localhost:3001/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    echo -n "  • Management API (3000): "
    curl -s http://localhost:3000/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    echo -n "  • GraphQL Playground: "
    curl -s http://localhost:3000/graphql >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    echo -n "  • Frontend (5173): "
    curl -s http://localhost:5173 >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
    
    # Environment actual
    echo
    echo -e "${CYAN}📍 Environment actual: $(get_current_env)${NC}"
}

# Main
case "${1:-start}" in
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        stop_services
        sleep 2
        start_services
        ;;
    "status")
        status_services
        ;;
    *)
        echo "Uso: $0 [start|stop|restart|status]"
        exit 1
        ;;
esac