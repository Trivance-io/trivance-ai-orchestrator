#!/bin/bash

# Script para gestionar el Log Viewer de forma robusta
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[LOG]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar Docker
check_docker() {
    if ! command -v docker &>/dev/null; then
        error "Docker no está instalado"
        return 1
    fi
    
    if ! docker ps &>/dev/null 2>&1; then
        error "Docker no está corriendo"
        return 1
    fi
    
    return 0
}

# Verificar si el servicio está en docker-compose
check_log_viewer_service() {
    # Priorizar docker-compose.dev.yml (ESTÁNDAR para desarrollo)
    local docker_compose_file="${CONFIG_DIR}/docker/docker-compose.dev.yml"
    
    # Fallback a docker-compose.yaml si no existe dev
    if [[ ! -f "$docker_compose_file" ]]; then
        docker_compose_file="${CONFIG_DIR}/docker/docker-compose.yaml"
    fi
    
    if [[ ! -f "$docker_compose_file" ]]; then
        error "docker-compose.dev.yml o docker-compose.yaml no encontrado en ${CONFIG_DIR}/docker/"
        return 1
    fi
    
    if ! grep -q "log-viewer:" "$docker_compose_file"; then
        error "Servicio log-viewer no encontrado en $docker_compose_file"
        return 1
    fi
    
    return 0
}

# Iniciar Log Viewer
start_log_viewer() {
    log "Iniciando Log Viewer..."
    
    # Verificar prerequisitos
    if ! check_docker; then
        return 1
    fi
    
    if ! check_log_viewer_service; then
        return 1
    fi
    
    # Asegurar que el directorio de logs existe
    mkdir -p "${WORKSPACE_DIR}/logs"
    info "Directorio de logs verificado: ${WORKSPACE_DIR}/logs"
    
    # Cambiar al directorio de Docker
    cd "${CONFIG_DIR}/docker"
    
    # Usar Smart Docker Manager si está disponible
    if [[ -f "${SCRIPT_DIR}/smart-docker-manager.sh" ]]; then
        info "🧠 Usando Smart Docker Manager para iniciar log-viewer..."
        # Determinar qué archivo docker-compose usar (priorizar dev)
        local compose_file="${CONFIG_DIR}/docker/docker-compose.dev.yml"
        if [[ ! -f "$compose_file" ]]; then
            compose_file="${CONFIG_DIR}/docker/docker-compose.yaml"
        fi
        if "${SCRIPT_DIR}/smart-docker-manager.sh" up "$compose_file" "log-viewer"; then
            timeout_success=true
        else
            timeout_success=false
        fi
    else
        # Fallback con timeout básico
        info "Iniciando servicio log-viewer (método tradicional)..."
        if [[ -f "${SCRIPT_DIR}/command-validator.sh" ]]; then
            source "${SCRIPT_DIR}/command-validator.sh"
            if safe_timeout 30 docker compose up -d log-viewer; then
                timeout_success=true
            else
                timeout_success=false
            fi
        else
            # Fallback sin timeout
            if docker compose up -d log-viewer; then
                timeout_success=true
            else
                timeout_success=false
            fi
        fi
    fi
    
    if [[ "$timeout_success" == "true" ]]; then
        success "Servicio log-viewer iniciado correctamente"
        
        # Verificar que el servicio esté funcionando usando Smart Docker Manager
        if [[ -f "${SCRIPT_DIR}/smart-docker-manager.sh" ]]; then
            "${SCRIPT_DIR}/smart-docker-manager.sh" health "Log Viewer" "http://localhost:4000/health" 60
        else
            # Fallback a verificación manual
            info "Verificando disponibilidad del servicio..."
            local retries=10
            local wait_time=2
            
            while [ $retries -gt 0 ]; do
                if curl -s "http://localhost:4000/health" &>/dev/null; then
                    success "✅ Log Viewer disponible en http://localhost:4000"
                    return 0
                else
                    info "Esperando que el servicio esté disponible... (${retries} intentos restantes)"
                    sleep $wait_time
                    retries=$((retries - 1))
                fi
            done
            
            warn "⚠️  Log Viewer tardó en estar disponible, pero el contenedor está corriendo"
            info "Verifica manualmente en: http://localhost:4000"
        fi
        return 0
    else
        error "Error al iniciar el servicio log-viewer"
        return 1
    fi
}

# Detener Log Viewer
stop_log_viewer() {
    log "Deteniendo Log Viewer..."
    
    if ! check_docker; then
        return 1
    fi
    
    cd "${CONFIG_DIR}/docker"
    
    if docker compose stop log-viewer; then
        success "Log Viewer detenido correctamente"
        return 0
    else
        error "Error al detener Log Viewer"
        return 1
    fi
}

# Reiniciar Log Viewer
restart_log_viewer() {
    log "Reiniciando Log Viewer..."
    
    if ! check_docker; then
        return 1
    fi
    
    cd "${CONFIG_DIR}/docker"
    
    if docker compose restart log-viewer; then
        success "Log Viewer reiniciado correctamente"
        
        # Verificar que esté funcionando
        info "Verificando disponibilidad..."
        sleep 3
        if curl -s "http://localhost:4000/health" &>/dev/null; then
            success "✅ Log Viewer disponible en http://localhost:4000"
        else
            warn "⚠️  Log Viewer puede tardar unos momentos en estar disponible"
        fi
        return 0
    else
        error "Error al reiniciar Log Viewer"
        return 1
    fi
}

# Ver estado del Log Viewer
status_log_viewer() {
    log "Estado del Log Viewer:"
    
    if ! check_docker; then
        return 1
    fi
    
    echo -n "• Contenedor: "
    # Buscar tanto el nombre dev como el regular
    if docker ps --format "table {{.Names}}" | grep -qE "trivance_log_viewer(_dev)?"; then
        echo -e "${GREEN}✅ Ejecutándose${NC}"
    else
        echo -e "${RED}❌ No ejecutándose${NC}"
        return 1
    fi
    
    echo -n "• Servicio HTTP: "
    if curl -s "http://localhost:4000/health" &>/dev/null; then
        echo -e "${GREEN}✅ Disponible en puerto 4000${NC}"
    else
        echo -e "${RED}❌ No responde en puerto 4000${NC}"
        return 1
    fi
    
    echo -n "• Archivo de logs: "
    if [[ -f "${WORKSPACE_DIR}/logs/trivance-unified.json" ]]; then
        echo -e "${GREEN}✅ Existe${NC}"
    else
        echo -e "${YELLOW}⚠️  No existe aún${NC}"
    fi
    
    return 0
}

# Ver logs del contenedor
logs_log_viewer() {
    log "Logs del Log Viewer:"
    
    if ! check_docker; then
        return 1
    fi
    
    # Intentar con nombre dev primero, luego regular
    local container_name=""
    if docker ps --format "{{.Names}}" | grep -q "trivance_log_viewer_dev"; then
        container_name="trivance_log_viewer_dev"
    elif docker ps --format "{{.Names}}" | grep -q "trivance_log_viewer"; then
        container_name="trivance_log_viewer"
    else
        error "No se encontró el contenedor log-viewer"
        return 1
    fi
    
    docker logs --tail 50 "$container_name" || {
        error "Error al obtener logs del contenedor"
        return 1
    }
}

# Abrir en navegador
open_log_viewer() {
    log "Abriendo Log Viewer en navegador..."
    
    # Verificar que esté disponible
    if ! curl -s "http://localhost:4000/health" &>/dev/null; then
        error "Log Viewer no está disponible en http://localhost:4000"
        return 1
    fi
    
    if command -v open &>/dev/null; then
        open "http://localhost:4000"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "http://localhost:4000"
    else
        info "Accede manualmente a: http://localhost:4000"
    fi
}

# Función principal
main() {
    case "${1:-}" in
        "start")
            start_log_viewer
            ;;
        "stop")
            stop_log_viewer
            ;;
        "restart")
            restart_log_viewer
            ;;
        "status")
            status_log_viewer
            ;;
        "logs")
            logs_log_viewer
            ;;
        "open")
            open_log_viewer
            ;;
        *)
            echo "Uso: $0 {start|stop|restart|status|logs|open}"
            echo
            echo "Comandos disponibles:"
            echo "  start   - Iniciar Log Viewer"
            echo "  stop    - Detener Log Viewer"
            echo "  restart - Reiniciar Log Viewer"
            echo "  status  - Ver estado del Log Viewer"
            echo "  logs    - Ver logs del contenedor"
            echo "  open    - Abrir en navegador"
            exit 1
            ;;
    esac
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi