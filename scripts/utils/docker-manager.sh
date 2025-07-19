#!/bin/bash

# 🐳 TRIVANCE DOCKER MANAGER
# Sistema robusto para manejar operaciones Docker sin bloqueos
# Garantiza que ninguna operación Docker pueda interrumpir el flujo principal

set -euo pipefail

# 🎨 Colores (compatible con otros scripts)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m'
fi

# 📝 Logging
log_info() { echo -e "${BLUE}[DOCKER-MGR]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 🔧 Configuración por defecto
DEFAULT_COMPOSE_TIMEOUT=120  # 2 minutos para docker compose up
DEFAULT_BUILD_TIMEOUT=300    # 5 minutos para docker build
DEFAULT_HEALTH_TIMEOUT=60    # 1 minuto para health checks
DEFAULT_MAX_RETRIES=3        # Reintentos por defecto

# 📁 Archivos de estado
STATE_DIR="/tmp/trivance-docker-manager"
mkdir -p "$STATE_DIR"

# 🔒 Cleanup automático al salir
cleanup_on_exit() {
    local exit_code=$?
    
    # Limpiar archivos de estado
    rm -rf "$STATE_DIR" 2>/dev/null || true
    
    # Limpiar procesos background si existen
    if [[ -n "${DOCKER_PROCESS_PID:-}" ]]; then
        kill "$DOCKER_PROCESS_PID" 2>/dev/null || true
    fi
    
    exit $exit_code
}

trap cleanup_on_exit EXIT

# ⏱️ Función de timeout robusta y multiplataforma
robust_timeout() {
    local timeout_seconds="$1"
    local description="$2"
    shift 2
    
    log_info "Ejecutando: $description (timeout: ${timeout_seconds}s)"
    
    # Crear archivo de estado
    local state_file="$STATE_DIR/docker_op_$$"
    echo "running" > "$state_file"
    
    # Ejecutar comando en background con redirección completa
    {
        "$@" 2>&1
        echo $? > "${state_file}.exit_code"
    } > "${state_file}.log" &
    
    local cmd_pid=$!
    DOCKER_PROCESS_PID=$cmd_pid
    
    # Monitor con timeout
    local elapsed=0
    local last_dot=0
    
    while kill -0 "$cmd_pid" 2>/dev/null; do
        if (( elapsed >= timeout_seconds )); then
            log_error "⏰ TIMEOUT después de ${timeout_seconds}s"
            
            # Matar proceso y todos sus hijos
            pkill -P "$cmd_pid" 2>/dev/null || true
            kill "$cmd_pid" 2>/dev/null || true
            sleep 2
            kill -9 "$cmd_pid" 2>/dev/null || true
            
            # Mostrar logs para debugging
            if [[ -f "${state_file}.log" ]]; then
                log_error "Últimas líneas del log:"
                tail -10 "${state_file}.log" | sed 's/^/  /'
            fi
            
            echo "timeout" > "$state_file"
            return 124
        fi
        
        # Mostrar progreso cada 5 segundos
        if (( elapsed - last_dot >= 5 )); then
            printf "."
            last_dot=$elapsed
        fi
        
        sleep 1
        ((elapsed++))
    done
    
    # Limpiar referencia al proceso
    unset DOCKER_PROCESS_PID
    
    # Obtener resultado
    wait "$cmd_pid" 2>/dev/null
    local exit_code=$?
    
    if [[ -f "${state_file}.exit_code" ]]; then
        exit_code=$(cat "${state_file}.exit_code")
    fi
    
    echo # Nueva línea después de los puntos
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "✅ $description completado exitosamente"
        echo "completed" > "$state_file"
    else
        log_error "❌ $description falló con código $exit_code"
        echo "failed" > "$state_file"
    fi
    
    return $exit_code
}

# 🏗️ Docker Compose Up con timeout robusto
docker_compose_up() {
    local compose_file="$1"
    local services="${2:-}"
    local timeout="${3:-$DEFAULT_COMPOSE_TIMEOUT}"
    local flags="${4:--d}"
    
    log_info "Iniciando servicios Docker Compose"
    log_info "Archivo: $compose_file"
    log_info "Servicios: ${services:-todos}"
    log_info "Timeout: ${timeout}s"
    
    # Verificar que el archivo existe
    if [[ ! -f "$compose_file" ]]; then
        log_error "Archivo docker-compose no encontrado: $compose_file"
        return 1
    fi
    
    # Cambiar al directorio del archivo compose
    local original_dir=$(pwd)
    local compose_dir=$(dirname "$compose_file")
    
    if ! cd "$compose_dir"; then
        log_error "No se puede acceder al directorio: $compose_dir"
        return 1
    fi
    
    # Construir comando
    local cmd=("docker" "compose" "up" $flags)
    if [[ -n "$services" ]]; then
        cmd+=($services)
    fi
    
    # Ejecutar con timeout robusto
    local result=0
    if robust_timeout "$timeout" "Docker Compose Up" "${cmd[@]}"; then
        log_success "Servicios iniciados correctamente"
        result=0
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_error "Docker Compose tardó más de ${timeout}s - CANCELADO"
            log_warning "Esto puede indicar problemas de red o imágenes muy grandes"
        else
            log_error "Docker Compose falló con código $exit_code"
        fi
        result=$exit_code
    fi
    
    # Volver al directorio original
    cd "$original_dir"
    
    return $result
}

# 🏥 Health check con timeout
docker_health_check() {
    local service_name="$1"
    local health_url="$2"
    local timeout="${3:-$DEFAULT_HEALTH_TIMEOUT}"
    local max_retries="${4:-$DEFAULT_MAX_RETRIES}"
    
    log_info "Verificando salud de $service_name"
    log_info "URL: $health_url"
    
    local retries=0
    local start_time=$(date +%s)
    
    while (( retries < max_retries )); do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if (( elapsed >= timeout )); then
            log_error "Health check timeout después de ${timeout}s"
            return 124
        fi
        
        if curl -f -s --max-time 5 "$health_url" >/dev/null 2>&1; then
            log_success "✅ $service_name está saludable"
            return 0
        fi
        
        ((retries++))
        log_info "Intento $retries/$max_retries - esperando 3s..."
        sleep 3
    done
    
    log_error "Health check falló después de $max_retries intentos"
    return 1
}

# 🔄 Restart service con timeout
docker_restart_service() {
    local compose_file="$1"
    local service_name="$2"
    local timeout="${3:-60}"
    
    log_info "Reiniciando servicio: $service_name"
    
    local original_dir=$(pwd)
    local compose_dir=$(dirname "$compose_file")
    
    cd "$compose_dir"
    
    if robust_timeout "$timeout" "Docker Restart $service_name" docker compose restart "$service_name"; then
        log_success "Servicio $service_name reiniciado correctamente"
        cd "$original_dir"
        return 0
    else
        log_error "Error al reiniciar $service_name"
        cd "$original_dir"
        return 1
    fi
}

# 📊 Status check sin timeout (rápido)
docker_quick_status() {
    local service_name="$1"
    
    # Verificar si el contenedor está corriendo (operación rápida)
    if docker ps --format "table {{.Names}}" | grep -q "$service_name"; then
        echo "running"
        return 0
    elif docker ps -a --format "table {{.Names}}" | grep -q "$service_name"; then
        echo "stopped"
        return 1
    else
        echo "not_found"
        return 2
    fi
}

# 🛑 Stop service con timeout
docker_stop_service() {
    local compose_file="$1"
    local service_name="$2"
    local timeout="${3:-30}"
    
    log_info "Deteniendo servicio: $service_name"
    
    local original_dir=$(pwd)
    local compose_dir=$(dirname "$compose_file")
    
    cd "$compose_dir"
    
    if robust_timeout "$timeout" "Docker Stop $service_name" docker compose stop "$service_name"; then
        log_success "Servicio $service_name detenido correctamente"
        cd "$original_dir"
        return 0
    else
        log_error "Error al detener $service_name"
        cd "$original_dir"
        return 1
    fi
}

# 🔧 Función principal para operaciones complejas
docker_operation() {
    local operation="$1"
    shift
    
    case "$operation" in
        "up")
            docker_compose_up "$@"
            ;;
        "restart")
            docker_restart_service "$@"
            ;;
        "stop")
            docker_stop_service "$@"
            ;;
        "health")
            docker_health_check "$@"
            ;;
        "status")
            docker_quick_status "$@"
            ;;
        *)
            log_error "Operación no válida: $operation"
            echo "Operaciones disponibles: up, restart, stop, health, status"
            return 1
            ;;
    esac
}

# 🎯 Función principal
main() {
    if [[ $# -eq 0 ]]; then
        echo "Uso: $0 OPERATION [args...]"
        echo
        echo "Operaciones disponibles:"
        echo "  up COMPOSE_FILE [SERVICES] [TIMEOUT] [FLAGS]"
        echo "  restart COMPOSE_FILE SERVICE [TIMEOUT]"
        echo "  stop COMPOSE_FILE SERVICE [TIMEOUT]"
        echo "  health SERVICE_NAME URL [TIMEOUT] [MAX_RETRIES]"
        echo "  status SERVICE_NAME"
        echo
        echo "Ejemplos:"
        echo "  $0 up docker-compose.yaml log-viewer 120"
        echo "  $0 health trivance_log_viewer http://localhost:4000/health 60"
        echo "  $0 status trivance_log_viewer"
        exit 1
    fi
    
    docker_operation "$@"
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi