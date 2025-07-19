#!/bin/bash

# 🧠 SMART DOCKER MANAGER - TRIVANCE
# Sistema inteligente que elimina timeouts falsos y proporciona feedback visual claro
# Nunca más falsas sensaciones de error - el usuario siempre sabe qué está pasando

set -euo pipefail

# 🎨 Colores (compatible con otros scripts)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly PURPLE='\033[0;35m'
    readonly NC='\033[0m'
fi

# 📊 Configuración de timeouts adaptativos
TIMEOUT_FIRST_BUILD=600     # 10 minutos primera compilación
TIMEOUT_REBUILD=300         # 5 minutos rebuild con cache
TIMEOUT_STARTUP=180         # 3 minutos para startup
TIMEOUT_HEALTH_CHECK=120    # 2 minutos para health checks
TIMEOUT_QUICK_OPS=60        # 1 minuto operaciones rápidas

# 📁 Directorio de estado
STATE_DIR="/tmp/trivance-smart-docker"
mkdir -p "$STATE_DIR"

# 🧹 Limpieza automática
cleanup() {
    local exit_code=$?
    rm -rf "$STATE_DIR" 2>/dev/null || true
    exit $exit_code
}
trap cleanup EXIT

# 🔨 Docker Development Mode (NUEVA FUNCIÓN)
docker_dev_mode() {
    local compose_file="$1"
    local timeout="${2:-$TIMEOUT_FIRST_BUILD}"
    
    log "INFO" "🚀 Iniciando modo desarrollo Docker con hot-reload"
    log "INFO" "📁 Compose file: $compose_file"
    
    # Verificar que existe el archivo compose
    if [[ ! -f "$compose_file" ]]; then
        log "ERROR" "❌ Archivo compose no encontrado: $compose_file"
        return 1
    fi
    
    local original_dir=$(pwd)
    local compose_dir=$(dirname "$compose_file")
    cd "$compose_dir"
    
    # Build con feedback visual claro
    log "BUILD" "🔨 Construyendo imágenes de desarrollo..."
    log "INFO" "⏱️  Esto puede tomar 2-10 minutos en primera ejecución"
    log "INFO" "📝 Los warnings de Prisma sobre OpenSSL son NORMALES y no afectan funcionalidad"
    
    if ! docker compose -f "$(basename "$compose_file")" build --parallel 2>&1 | while IFS= read -r line; do
        # Filtrar warnings conocidos de Prisma para no confundir al usuario
        if [[ ! "$line" =~ "Prisma failed to detect the libssl/openssl version" ]] && 
           [[ ! "$line" =~ "Please manually install OpenSSL" ]] && 
           [[ ! "$line" =~ "Defaulting to \"openssl-1.1.x\"" ]]; then
            echo "$line"
        fi
    done; then
        log "ERROR" "❌ Build falló - revisar Dockerfiles"
        cd "$original_dir"
        return 1
    fi
    
    log "SUCCESS" "✅ Build completado exitosamente"
    log "INFO" "🚀 Iniciando servicios con hot-reload..."
    
    # Start con watch mode y feedback claro
    smart_docker_operation "up" "$compose_file" "" "$timeout" "--watch --remove-orphans"
    
    cd "$original_dir"
}

# 📝 Logging mejorado
log() {
    local level="$1"
    shift
    local timestamp=$(date '+%H:%M:%S')
    
    case "$level" in
        "INFO")    echo -e "${BLUE}[${timestamp}]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[${timestamp}] ✅${NC} $*" ;;
        "WARNING") echo -e "${YELLOW}[${timestamp}] ⚠️${NC} $*" ;;
        "ERROR")   echo -e "${RED}[${timestamp}] ❌${NC} $*" ;;
        "PROGRESS") echo -e "${CYAN}[${timestamp}] 🔄${NC} $*" ;;
        "BUILD")   echo -e "${PURPLE}[${timestamp}] 🔨${NC} $*" ;;
    esac
}

# 🎯 Detector de contexto inteligente
detect_operation_context() {
    local operation="$1"
    local services="$2"
    
    case "$operation" in
        "up")
            # Verificar si las imágenes ya existen
            local images_exist=true
            for service in $services; do
                if [[ "$service" == "ms_level_up_management" || "$service" == "ms_trivance_auth" ]]; then
                    if ! docker images --format "{{.Repository}}" | grep -q "docker-${service}"; then
                        images_exist=false
                        break
                    fi
                fi
            done
            
            if [[ "$images_exist" == "false" ]]; then
                echo "first_build"
            else
                echo "rebuild"
            fi
            ;;
        "restart")
            echo "restart"
            ;;
        "health")
            echo "health"
            ;;
        *)
            echo "quick"
            ;;
    esac
}

# ⏱️ Obtener timeout apropiado
get_timeout_for_context() {
    local context="$1"
    
    case "$context" in
        "first_build") echo $TIMEOUT_FIRST_BUILD ;;
        "rebuild")     echo $TIMEOUT_REBUILD ;;
        "startup")     echo $TIMEOUT_STARTUP ;;
        "health")      echo $TIMEOUT_HEALTH_CHECK ;;
        "restart")     echo $TIMEOUT_QUICK_OPS ;;
        *)             echo $TIMEOUT_QUICK_OPS ;;
    esac
}

# 🎪 Mostrar mensaje de contexto al usuario
show_context_message() {
    local context="$1"
    local services="$2"
    
    case "$context" in
        "first_build")
            log "INFO" "🎯 Primera compilación detectada"
            log "INFO" "📦 Esto incluye:"
            log "INFO" "   • Descarga de imágenes base (Node.js, PostgreSQL, MongoDB)"
            log "INFO" "   • Instalación de dependencias npm"
            log "INFO" "   • Compilación de código TypeScript"
            log "INFO" "   • Construcción de imágenes Docker"
            log "WARNING" "⏱️  Tiempo estimado: 5-10 minutos (solo la primera vez)"
            log "INFO" "☕ Perfecto momento para un café - el sistema está trabajando"
            ;;
        "rebuild")
            log "INFO" "🔄 Reconstrucción con cache detectada"
            log "INFO" "📦 Servicios: $services"
            log "WARNING" "⏱️  Tiempo estimado: 2-5 minutos"
            log "INFO" "🚀 Mucho más rápido gracias al cache Docker"
            ;;
        "startup")
            log "INFO" "🚀 Iniciando servicios existentes"
            log "WARNING" "⏱️  Tiempo estimado: 30-180 segundos"
            log "INFO" "🔧 Los servicios necesitan tiempo para inicializarse"
            ;;
        "health")
            log "INFO" "🏥 Verificando salud de servicios"
            log "WARNING" "⏱️  Tiempo estimado: 30-120 segundos"
            log "INFO" "📊 Esperando que las APIs respondan correctamente"
            ;;
    esac
    
    echo
}

# 🎮 Indicador de progreso visual
show_progress_indicator() {
    local current_seconds="$1"
    local total_seconds="$2"
    local description="$3"
    
    local percentage=$((current_seconds * 100 / total_seconds))
    local bars=$((percentage / 5))  # Cada 5% = 1 barra
    local spaces=$((20 - bars))
    
    # Crear barra visual
    local progress_bar=""
    for ((i=0; i<bars; i++)); do
        progress_bar+="█"
    done
    for ((i=0; i<spaces; i++)); do
        progress_bar+="░"
    done
    
    # Formatear tiempo
    local mins=$((current_seconds / 60))
    local secs=$((current_seconds % 60))
    local total_mins=$((total_seconds / 60))
    local total_secs=$((total_seconds % 60))
    
    printf "\r${CYAN}🔄 %s [%s] %d%% (%dm %02ds / %dm %02ds)${NC}" \
           "$description" "$progress_bar" "$percentage" \
           "$mins" "$secs" "$total_mins" "$total_secs"
}

# 📋 Verificar si Docker está compilando
check_docker_build_progress() {
    local compose_file="$1"
    local service_name="$2"
    
    # Verificar logs de Docker para indicadores de progreso
    local container_name="trivance_${service_name}"
    
    if docker ps --format "{{.Names}}" | grep -q "$container_name"; then
        local recent_logs=$(docker logs "$container_name" --tail 5 2>/dev/null || echo "")
        
        if echo "$recent_logs" | grep -q -i "installing\|downloading\|compiling\|building"; then
            return 0  # Está compilando
        fi
    fi
    
    return 1  # No está compilando
}

# 🔍 Mostrar información útil durante la espera
show_helpful_info() {
    local elapsed="$1"
    local context="$2"
    
    # Mostrar tips útiles cada 30 segundos
    if (( elapsed > 0 && elapsed % 30 == 0 )); then
        case "$context" in
            "first_build")
                if (( elapsed == 30 )); then
                    log "INFO" "💡 Tip: Las próximas ejecuciones serán mucho más rápidas"
                elif (( elapsed == 60 )); then
                    log "INFO" "💡 Tip: Puedes ver logs detallados con 'docker logs trivance_management'"
                elif (( elapsed == 120 )); then
                    log "INFO" "💡 Tip: El sistema está descargando dependencias npm (puede ser lento)"
                elif (( elapsed == 180 )); then
                    log "INFO" "💡 Tip: Compilando código TypeScript - casi terminando"
                fi
                ;;
            "rebuild")
                if (( elapsed == 30 )); then
                    log "INFO" "💡 Tip: Aprovechando cache Docker para mayor velocidad"
                elif (( elapsed == 60 )); then
                    log "INFO" "💡 Tip: Recompilando solo los archivos modificados"
                fi
                ;;
            "health")
                if (( elapsed == 30 )); then
                    log "INFO" "💡 Tip: Las bases de datos están inicializándose"
                elif (( elapsed == 60 )); then
                    log "INFO" "💡 Tip: Las APIs están cargando configuración"
                fi
                ;;
        esac
    fi
}

# 🚀 Función principal con timeout inteligente
smart_docker_operation() {
    local operation="$1"
    local compose_file="$2"
    local services="$3"
    local custom_timeout="${4:-}"
    
    log "INFO" "🎯 Iniciando operación: $operation"
    log "INFO" "📄 Archivo: $(basename "$compose_file")"
    log "INFO" "🔧 Servicios: ${services:-todos}"
    
    # Detectar contexto
    local context=$(detect_operation_context "$operation" "$services")
    local timeout_seconds
    
    if [[ -n "$custom_timeout" ]]; then
        timeout_seconds=$custom_timeout
        log "INFO" "⏱️  Timeout personalizado: ${timeout_seconds}s"
    else
        timeout_seconds=$(get_timeout_for_context "$context")
        log "INFO" "⏱️  Timeout adaptativo: ${timeout_seconds}s (contexto: $context)"
    fi
    
    # Mostrar mensaje de contexto
    show_context_message "$context" "$services"
    
    # Preparar comando
    local compose_dir=$(dirname "$compose_file")
    local original_dir=$(pwd)
    
    cd "$compose_dir"
    
    # Construir comando Docker
    local cmd=("docker" "compose" "$operation")
    case "$operation" in
        "up")
            cmd+=("-d")
            if [[ -n "$services" ]]; then
                cmd+=($services)
            fi
            ;;
        "restart"|"stop")
            if [[ -n "$services" ]]; then
                cmd+=($services)
            fi
            ;;
    esac
    
    # Ejecutar comando en background
    log "BUILD" "Ejecutando: ${cmd[*]}"
    "${cmd[@]}" > "$STATE_DIR/docker_output.log" 2>&1 &
    local docker_pid=$!
    
    # Monitor inteligente con feedback visual
    local elapsed=0
    local last_progress=0
    
    while kill -0 "$docker_pid" 2>/dev/null; do
        # Verificar timeout
        if (( elapsed >= timeout_seconds )); then
            # Antes de cancelar, verificar si realmente hay un problema
            if check_docker_build_progress "$compose_file" "$services"; then
                log "WARNING" "⏱️  Timeout alcanzado, pero Docker está progresando"
                log "INFO" "🔄 Extendiendo timeout por 2 minutos adicionales"
                timeout_seconds=$((timeout_seconds + 120))
            else
                log "ERROR" "❌ Timeout real - cancelando operación"
                kill "$docker_pid" 2>/dev/null || true
                cd "$original_dir"
                return 124
            fi
        fi
        
        # Mostrar progreso cada 5 segundos
        if (( elapsed - last_progress >= 5 )); then
            show_progress_indicator "$elapsed" "$timeout_seconds" "Operación Docker"
            last_progress=$elapsed
        fi
        
        # Mostrar información útil
        show_helpful_info "$elapsed" "$context"
        
        sleep 1
        ((elapsed++))
    done
    
    # Limpiar línea de progreso
    echo
    
    # Verificar resultado
    wait "$docker_pid"
    local exit_code=$?
    
    cd "$original_dir"
    
    if [[ $exit_code -eq 0 ]]; then
        log "SUCCESS" "Operación completada exitosamente en ${elapsed}s"
        
        # Mostrar mensaje de éxito contextual
        case "$context" in
            "first_build")
                log "SUCCESS" "🎉 Primera compilación completa - próximas ejecuciones serán más rápidas"
                ;;
            "rebuild")
                log "SUCCESS" "🚀 Servicios actualizados correctamente"
                ;;
        esac
    else
        log "ERROR" "Operación falló con código $exit_code"
        
        # Mostrar logs útiles para debugging
        if [[ -f "$STATE_DIR/docker_output.log" ]]; then
            log "ERROR" "Últimas líneas del log:"
            tail -10 "$STATE_DIR/docker_output.log" | sed 's/^/  /'
        fi
    fi
    
    return $exit_code
}

# 🏥 Health check inteligente
smart_health_check() {
    local service_name="$1"
    local url="$2"
    local timeout="${3:-$TIMEOUT_HEALTH_CHECK}"
    
    log "INFO" "🏥 Verificando salud de $service_name"
    log "INFO" "🔗 URL: $url"
    
    local start_time=$(date +%s)
    local elapsed=0
    local last_check=0
    
    while (( elapsed < timeout )); do
        if curl -f -s --max-time 5 "$url" >/dev/null 2>&1; then
            log "SUCCESS" "$service_name está saludable (${elapsed}s)"
            return 0
        fi
        
        # Mostrar progreso cada 10 segundos
        if (( elapsed - last_check >= 10 )); then
            show_progress_indicator "$elapsed" "$timeout" "Health Check $service_name"
            last_check=$elapsed
        fi
        
        # Información útil durante health check
        if (( elapsed == 30 )); then
            log "INFO" "💡 $service_name todavía está iniciándose - esto es normal"
        elif (( elapsed == 60 )); then
            log "INFO" "💡 Verificando si hay problemas en los logs..."
            if docker logs "trivance_$(echo "$service_name" | tr '[:upper:]' '[:lower:]')" --tail 3 2>/dev/null | grep -i error; then
                log "WARNING" "⚠️  Se detectaron errores en los logs - revisa después"
            fi
        fi
        
        sleep 5
        local current_time=$(date +%s)
        elapsed=$((current_time - start_time))
    done
    
    echo
    log "ERROR" "$service_name no respondió después de ${timeout}s"
    return 1
}

# 🎯 Función principal
main() {
    case "${1:-}" in
        "up")
            smart_docker_operation "up" "$2" "${3:-}" "${4:-}"
            ;;
        "dev")
            docker_dev_mode "$2" "${3:-$TIMEOUT_FIRST_BUILD}"
            ;;
        "restart")
            smart_docker_operation "restart" "$2" "${3:-}" "${4:-}"
            ;;
        "stop")
            smart_docker_operation "stop" "$2" "${3:-}" "${4:-}"
            ;;
        "health")
            smart_health_check "$2" "$3" "${4:-}"
            ;;
        *)
            echo "🧠 Smart Docker Manager - Trivance Docker Evolution"
            echo "Uso: $0 OPERATION [args...]"
            echo
            echo "Operaciones disponibles:"
            echo "  🚀 dev COMPOSE_FILE [TIMEOUT]             - Modo desarrollo con hot-reload"
            echo "  up COMPOSE_FILE [SERVICES] [TIMEOUT]     - Iniciar servicios"
            echo "  restart COMPOSE_FILE [SERVICES] [TIMEOUT] - Reiniciar servicios"
            echo "  stop COMPOSE_FILE [SERVICES] [TIMEOUT]    - Detener servicios"
            echo "  health SERVICE_NAME URL [TIMEOUT]         - Verificar salud"
            echo
            echo "Ejemplos:"
            echo "  🔥 $0 dev docker-compose.dev.yml          - HOT RELOAD DEVELOPMENT"
            echo "  $0 up docker-compose.yaml 'ms_level_up_management ms_trivance_auth'"
            echo "  $0 health 'Management API' http://localhost:3000/health"
            exit 1
            ;;
    esac
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi