#!/bin/bash
# Trivance Platform - Punto de entrada único
# Script inteligente que detecta el contexto y sugiere acciones

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Directorios - Corregir para ejecución desde workspace
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "${SCRIPT_DIR}")" == "scripts" ]]; then
    # Ejecutándose desde ubicación real
    CONFIG_DIR="$(cd "${SCRIPT_DIR}/../" && pwd)"
    WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"
else
    # Ejecutándose desde symlink en workspace
    WORKSPACE_DIR="$(cd "${SCRIPT_DIR}" && pwd)"
    CONFIG_DIR="${WORKSPACE_DIR}/trivance-dev-config"
fi

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🚀 TRIVANCE PLATFORM                               ║
║                         Sistema de Gestión Unificado                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Detectar estado del sistema
detect_system_state() {
    local state="not_setup"
    
    # Debug: mostrar directorios calculados
    # echo "DEBUG: WORKSPACE_DIR='${WORKSPACE_DIR}'" >&2
    
    # Verificar si está configurado
    if [[ -d "${WORKSPACE_DIR}/ms_level_up_management" ]] && \
       [[ -d "${WORKSPACE_DIR}/ms_trivance_auth" ]] && \
       [[ -d "${WORKSPACE_DIR}/level_up_backoffice" ]] && \
       [[ -d "${WORKSPACE_DIR}/trivance-mobile" ]]; then
        
        # Verificar configuración completa
        if [[ -f "${WORKSPACE_DIR}/.trivance-secrets" ]] && \
           [[ -f "${WORKSPACE_DIR}/envs/.current_environment" ]]; then
            state="configured"
            
            # Verificar si hay servicios corriendo
            # Verificar PM2
            local pm2_running=false
            if command -v pm2 &> /dev/null && pm2 list 2>/dev/null | grep -q "online"; then
                pm2_running=true
            fi
            
            # Verificar Docker
            local docker_running=false
            if command -v docker &> /dev/null && docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "trivance_"; then
                docker_running=true
            fi
            
            # Si algún servicio está corriendo, cambiar estado
            if [[ "$pm2_running" == true ]] || [[ "$docker_running" == true ]]; then
                state="running"
            fi
        fi
    fi
    
    echo "$state"
}

# Obtener environment actual
get_current_env() {
    if [[ -f "${WORKSPACE_DIR}/envs/.current_environment" ]]; then
        cat "${WORKSPACE_DIR}/envs/.current_environment"
    else
        echo "local"
    fi
}

# Verificar Docker (obligatorio)
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        echo -e "${YELLOW}Docker es OBLIGATORIO. Instálalo desde: https://www.docker.com/products/docker-desktop/${NC}"
        return 1
    fi
    
    if ! docker ps &>/dev/null 2>&1; then
        echo -e "${RED}❌ Docker no está corriendo${NC}"
        echo -e "${YELLOW}Por favor inicia Docker Desktop${NC}"
        return 1
    fi
    
    return 0
}

# Detectar si servicios están corriendo
services_running() {
    if docker ps --format "table {{.Names}}" | grep -q "trivance_"; then
        return 0
    fi
    return 1
}

# Menú principal
show_main_menu() {
    local state="$1"
    local current_env=$(get_current_env)
    
    echo -e "${CYAN}Estado del sistema:${NC} "
    
    # Verificar Docker primero
    local docker_status=""
    if check_docker; then
        docker_status="${GREEN}🐳 Docker OK${NC}"
    else
        docker_status="${RED}🐳 Docker NO disponible${NC}"
    fi
    
    case "$state" in
        "not_setup")
            echo -e "  ${YELLOW}⚠️  No configurado${NC}"
            echo -e "  ${docker_status}"
            if ! check_docker; then
                echo -e "  ${RED}   ⚠️ Debes tener Docker corriendo antes de continuar${NC}"
            else
                echo -e "  ${YELLOW}   Ejecuta la opción 1 para configurar${NC}"
            fi
            ;;
        "configured")
            echo -e "  ${GREEN}✅ Configurado${NC}"
            echo -e "  ${BLUE}📍 Environment: ${current_env}${NC}"
            echo -e "  ${docker_status}"
            ;;
        "running")
            echo -e "  ${GREEN}✅ Servicios ejecutándose${NC}"
            echo -e "  ${BLUE}📍 Environment: ${current_env}${NC}"
            echo -e "  ${GREEN}🐳 Docker + PM2 (arquitectura híbrida)${NC}"
            ;;
    esac
    
    echo
    echo -e "${CYAN}Opciones disponibles:${NC}"
    echo
    
    if [[ "$state" == "not_setup" ]]; then
        echo -e "  ${GREEN}1)${NC} 🔧 Configurar entorno completo (setup inicial)"
        echo -e "  ${YELLOW}   Las demás opciones estarán disponibles después del setup${NC}"
    else
        echo -e "  ${GREEN}1)${NC} 🚀 Iniciar servicios"
        echo -e "  ${GREEN}2)${NC} 📊 Ver estado de servicios"
        echo -e "  ${GREEN}3)${NC} 🔄 Cambiar environment (actual: ${current_env})"
        echo -e "  ${GREEN}4)${NC} 🛑 Detener servicios"
        echo -e "  ${GREEN}5)${NC} 🔍 Verificar salud del sistema"
        echo -e "  ${GREEN}6)${NC} 🐳 Gestión Docker"
        echo -e "  ${GREEN}7)${NC} � Monitor de Logs (Dozzle)"
        echo -e "  ${GREEN}8)${NC} �📚 Ver documentación"
        echo -e "  ${GREEN}9)${NC} 🗑️  Limpiar y reconfigurar"
    fi
    
    echo -e "  ${GREEN}0)${NC} 🚪 Salir"
    echo
}

# Ejecutar opción
execute_option() {
    local option="$1"
    local state="$2"
    
    # Si no está configurado, solo permitir setup
    if [[ "$state" == "not_setup" && "$option" != "1" && "$option" != "0" ]]; then
        echo -e "${RED}❌ Primero debes configurar el entorno (opción 1)${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    case "$option" in
        "1")
            if [[ "$state" == "not_setup" ]]; then
                # Verificar Docker antes del setup
                if ! check_docker; then
                    echo -e "${RED}❌ No puedes continuar sin Docker${NC}"
                    read -p "Presiona Enter para continuar..."
                    return
                fi
                echo -e "${BLUE}🔧 Iniciando configuración completa...${NC}"
                "${CONFIG_DIR}/setup.sh"
            else
                # Verificar Docker antes de iniciar
                if ! check_docker; then
                    echo -e "${RED}❌ No puedes iniciar servicios sin Docker${NC}"
                    read -p "Presiona Enter para continuar..."
                    return
                fi
                echo -e "${BLUE}🚀 Iniciando servicios...${NC}"
                # Llamar script en subshell para evitar problemas de timeout
                (
                    # Ejecutar en subshell para aislar el proceso
                    "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" start
                )
                # El menú seguirá funcionando después
            fi
            ;;
        "2")
            echo -e "${BLUE}📊 Estado de servicios:${NC}"
            if [[ -x "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" ]]; then
                "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" status
            else
                pm2 status
            fi
            ;;
        "3")
            echo -e "${BLUE}🔄 Cambiar environment:${NC}"
            echo "  1) local"
            echo "  2) qa"
            echo "  3) production"
            read -p "Selecciona environment: " env_option
            case "$env_option" in
                "1") env="local" ;;
                "2") env="qa" ;;
                "3") env="production" ;;
                *) echo -e "${RED}Opción inválida${NC}"; return ;;
            esac
            "${CONFIG_DIR}/scripts/envs.sh" switch "$env"
            ;;
        "4")
            echo -e "${BLUE}🛑 Deteniendo servicios...${NC}"
            if [[ -x "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" ]]; then
                "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" stop
            else
                pm2 stop all
            fi
            ;;
        "5")
            echo -e "${BLUE}🔍 Verificando salud del sistema...${NC}"
            echo
            
            # Usar el script smart para el estado si está disponible
            if [[ -x "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" ]]; then
                "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" status
            else
                echo "Estado de servicios PM2:"
                pm2 status
                echo
                echo "Verificando endpoints:"
                echo -n "• Auth Service (3001): "
                curl -s http://localhost:3001/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
                echo -n "• Management API (3000): "
                curl -s http://localhost:3000/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
                echo -n "• Frontend (5173): "
                curl -s http://localhost:5173 >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
            fi
            echo
            ;;
        "6")
            # Verificar Docker primero
            if ! check_docker; then
                echo -e "${RED}❌ Docker no está disponible${NC}"
                echo -e "${YELLOW}Debes tener Docker corriendo para usar esta opción${NC}"
                read -p "Presiona Enter para continuar..."
                return
            fi
            
            # Submenú Docker
            echo -e "${BLUE}🐳 Gestión Docker:${NC}"
                echo "  1) Ver logs de contenedores"
                echo "  2) Reconstruir imágenes"
                echo "  3) Resetear bases de datos (⚠️  DESTRUCTIVO)"
                echo "  4) Acceder a shell de contenedor"
                echo "  5) Ver uso de recursos"
                echo "  0) Volver al menú principal"
                echo
                read -p "Selecciona opción: " docker_option
                
                case "$docker_option" in
                    "1")
                        echo -e "${CYAN}Selecciona servicio:${NC}"
                        echo "  1) Management API"
                        echo "  2) Auth Service"
                        echo "  3) PostgreSQL"
                        echo "  4) MongoDB"
                        echo "  5) Todos"
                        read -p "Servicio: " service_option
                        
                        cd "${CONFIG_DIR}/docker"
                        case "$service_option" in
                            "1") docker logs -f trivance_management ;;
                            "2") docker logs -f trivance_auth ;;
                            "3") docker logs -f trivance_postgres ;;
                            "4") docker logs -f trivance_mongodb ;;
                            "5") docker compose logs -f ;;
                            *) echo -e "${RED}Opción inválida${NC}" ;;
                        esac
                        ;;
                    "2")
                        echo -e "${YELLOW}🔄 Reconstruyendo imágenes Docker...${NC}"
                        cd "${CONFIG_DIR}/docker"
                        docker compose build --no-cache
                        echo -e "${GREEN}✅ Imágenes reconstruidas${NC}"
                        ;;
                    "3")
                        echo -e "${RED}⚠️  ADVERTENCIA: Esto eliminará TODOS los datos${NC}"
                        read -p "¿Estás seguro? (yes/no): " confirm
                        if [[ "$confirm" == "yes" ]]; then
                            cd "${CONFIG_DIR}/docker"
                            docker compose down -v
                            docker compose up -d postgres mongodb
                            echo -e "${GREEN}✅ Bases de datos reseteadas${NC}"
                        fi
                        ;;
                    "4")
                        echo -e "${CYAN}Selecciona contenedor:${NC}"
                        echo "  1) Management API"
                        echo "  2) Auth Service"
                        read -p "Contenedor: " container_option
                        
                        case "$container_option" in
                            "1") docker exec -it trivance_management sh ;;
                            "2") docker exec -it trivance_auth sh ;;
                            *) echo -e "${RED}Opción inválida${NC}" ;;
                        esac
                        ;;
                    "5")
                        docker stats
                        ;;
                esac
                
                # No hacer return aquí para volver al menú principal
                if [[ "$docker_option" != "0" ]]; then
                    read -p "Presiona Enter para continuar..."
                fi
            ;;
        "7")
            # Monitor de Logs Dozzle
            echo -e "${BLUE}📊 Monitor de Logs (Dozzle):${NC}"
            echo "  1) Iniciar Dozzle"
            echo "  2) Ver estado de Dozzle"
            echo "  3) Abrir en navegador"
            echo "  4) Ver logs de Dozzle"
            echo "  5) Detener Dozzle"
            echo "  0) Volver al menú principal"
            echo
            read -p "Selecciona opción: " dozzle_option
            
            case "$dozzle_option" in
                "1") "${CONFIG_DIR}/scripts/docker/dozzle.sh" start ;;
                "2") "${CONFIG_DIR}/scripts/docker/dozzle.sh" status ;;
                "3") "${CONFIG_DIR}/scripts/docker/dozzle.sh" open ;;
                "4") "${CONFIG_DIR}/scripts/docker/dozzle.sh" logs ;;
                "5") "${CONFIG_DIR}/scripts/docker/dozzle.sh" stop ;;
                "0") return ;;
                *) echo -e "${RED}Opción inválida${NC}" ;;
            esac
            
            if [[ "$dozzle_option" != "0" ]]; then
                read -p "Presiona Enter para continuar..."
            fi
            ;;
        "8")
            # Documentación
            echo -e "${BLUE}📚 Documentación disponible:${NC}"
            echo
            echo "  📖 README principal: ${WORKSPACE_DIR}/README.md"
            echo "  🤖 Claude Config: Ejecuta manualmente /init después del setup"
            echo "  🎛️  Environments: ${WORKSPACE_DIR}/envs/ENVIRONMENTS.md"
            echo "  🚀 Comandos: ${CONFIG_DIR}/docs/COMMANDS.md"
            echo "  🐳 Docker: ${CONFIG_DIR}/docs/DOCKER.md"
            echo
            ;;
        "9")
            echo -e "${YELLOW}⚠️  Esto eliminará toda la configuración actual${NC}"
            read -p "¿Estás seguro? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                "${CONFIG_DIR}/scripts/utils/clean-workspace.sh"
                echo -e "${GREEN}✅ Workspace limpio. Ejecuta opción 1 para reconfigurar${NC}"
            fi
            ;;
        "0")
            echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    if [[ "$option" != "0" ]]; then
        echo
        read -p "Presiona Enter para continuar..."
    fi
}

# Main
main() {
    while true; do
        show_banner
        local state=$(detect_system_state)
        show_main_menu "$state"
        
        read -p "Selecciona una opción: " option
        execute_option "$option" "$state"
    done
}

# Si se pasa un argumento, ejecutarlo directamente
if [[ $# -gt 0 ]]; then
    case "$1" in
        "start")
            # Usar inicio inteligente con Docker
            if [[ -x "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" ]]; then
                "${CONFIG_DIR}/scripts/utils/start-services-smart.sh" start
            else
                # Fallback al método tradicional
                if ! command -v pm2 &> /dev/null; then
                    echo "Instalando PM2..."
                    npm install -g pm2
                fi
                pm2 start "${CONFIG_DIR}/../ecosystem.config.js" 2>/dev/null || {
                    "${CONFIG_DIR}/start-all.sh"
                }
            fi
            ;;
        "stop")
            pm2 stop all
            ;;
        "status")
            pm2 status
            ;;
        "setup")
            "${CONFIG_DIR}/setup.sh"
            ;;
        *)
            echo "Uso: $0 [start|stop|status|setup]"
            exit 1
            ;;
    esac
else
    # Modo interactivo
    main
fi