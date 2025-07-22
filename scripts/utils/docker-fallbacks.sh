#!/bin/bash
# 🛡️ DOCKER FALLBACKS - Auto-corrección de problemas comunes
# Detecta y corrige automáticamente problemas sin intervención del usuario

set -euo pipefail

# Colores (compatible con otros scripts)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m'
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

# Log functions
log_info() { echo -e "${CYAN}[FALLBACK]${NC} $1"; }
log_fix() { echo -e "${GREEN}[AUTO-FIX]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Fallback 1: Corregir scripts de build faltantes
fix_missing_build_scripts() {
    local service="$1"
    local package_json="${WORKSPACE_DIR}/${service}/package.json"
    
    if [[ -f "$package_json" ]]; then
        # Verificar si falta build:dev pero existe build
        if ! grep -q '"build:dev"' "$package_json" && grep -q '"build"' "$package_json"; then
            log_info "Detectado: $service no tiene script build:dev"
            
            # Crear backup
            cp "$package_json" "${package_json}.backup"
            
            # Añadir build:dev que llama a build
            if command -v jq &>/dev/null; then
                jq '.scripts."build:dev" = "npm run build"' "$package_json" > "${package_json}.tmp" && \
                mv "${package_json}.tmp" "$package_json"
                log_fix "Añadido script build:dev a $service"
            else
                # Fallback sin jq
                sed -i.bak '/"scripts": {/,/}/ s/"build": "\(.*\)"/"build": "\1",\n    "build:dev": "npm run build"/' "$package_json"
                log_fix "Añadido script build:dev a $service (método sed)"
            fi
        fi
    fi
}

# Fallback 2: Limpiar contenedores problemáticos
clean_problematic_containers() {
    log_info "Verificando contenedores problemáticos..."
    
    # Buscar contenedores en estado "Restarting" o "Dead"
    local problematic=$(docker ps -a --filter "name=trivance_" --filter "status=restarting" --filter "status=dead" -q)
    
    if [[ -n "$problematic" ]]; then
        log_warn "Encontrados contenedores problemáticos"
        docker rm -f $problematic &>/dev/null
        log_fix "Contenedores problemáticos eliminados"
    fi
}

# Fallback 3: Corregir permisos de volúmenes
fix_volume_permissions() {
    local logs_dir="${WORKSPACE_DIR}/logs"
    
    if [[ -d "$logs_dir" ]]; then
        # Si el directorio existe pero no tiene permisos correctos
        if ! touch "${logs_dir}/.test" 2>/dev/null; then
            log_warn "Problemas de permisos en directorio logs"
            chmod -R 755 "$logs_dir" 2>/dev/null || sudo chmod -R 755 "$logs_dir"
            log_fix "Permisos de logs corregidos"
        else
            rm -f "${logs_dir}/.test"
        fi
    else
        # Crear directorio si no existe
        mkdir -p "$logs_dir"
        log_fix "Directorio logs creado"
    fi
}

# Fallback 4: Regenerar archivos .env faltantes
regenerate_missing_env_files() {
    # Verificar archivos Docker .env
    if [[ ! -f "${CONFIG_DIR}/docker/.env.docker-local" ]] || [[ ! -f "${CONFIG_DIR}/docker/.env.docker-auth-local" ]]; then
        log_warn "Archivos .env Docker faltantes"
        log_info "Regenerando configuración..."
        
        # Ejecutar envs.sh para regenerar
        if [[ -x "${SCRIPT_DIR}/../envs.sh" ]]; then
            "${SCRIPT_DIR}/../envs.sh" switch local &>/dev/null
            log_fix "Archivos .env regenerados automáticamente"
        fi
    fi
}

# Fallback 5: Liberar puertos ocupados (con confirmación)
free_occupied_ports() {
    local ports=(3000 3001 5173 5432 27017)
    local occupied=false
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t &>/dev/null; then
            occupied=true
            local pid=$(lsof -Pi :$port -sTCP:LISTEN -t | head -1)
            local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
            
            # Solo matar si es un proceso Docker o node
            if [[ "$process" =~ (docker|node|npm) ]]; then
                log_warn "Puerto $port ocupado por $process (PID: $pid)"
                kill -TERM $pid 2>/dev/null || true
                sleep 1
                kill -KILL $pid 2>/dev/null || true
                log_fix "Puerto $port liberado"
            fi
        fi
    done
}

# Fallback 6: Corregir DATABASE_URL para Docker
fix_database_urls() {
    local mgmt_env="${WORKSPACE_DIR}/envs/local.management.env"
    local auth_env="${WORKSPACE_DIR}/envs/local.auth.env"
    
    # Solo aplicar si estamos en contexto Docker
    if [[ "${DOCKER_CONTEXT:-false}" == "true" ]]; then
        # Management service
        if [[ -f "$mgmt_env" ]] && grep -q "DATABASE_URL=.*localhost" "$mgmt_env"; then
            log_info "Ajustando DATABASE_URL para Docker networking"
            # No modificar el archivo original, el override se hace en docker-compose
            log_fix "DATABASE_URL será sobrescrito por docker-compose.yml"
        fi
    fi
}

# Fallback 7: Reintentar servicios fallidos
retry_failed_services() {
    local service="$1"
    local container_name="trivance_${service}_dev"
    
    # Verificar si el contenedor existe pero no está running
    if docker ps -a --filter "name=${container_name}" --filter "status=exited" -q | grep -q .; then
        log_warn "Servicio $service falló al iniciar"
        
        # Obtener últimas líneas de log para diagnóstico
        local last_logs=$(docker logs "$container_name" --tail 10 2>&1)
        
        # Intentar reiniciar
        docker start "$container_name" &>/dev/null
        sleep 3
        
        if docker ps --filter "name=${container_name}" --filter "status=running" -q | grep -q .; then
            log_fix "Servicio $service reiniciado exitosamente"
        else
            log_warn "No se pudo reiniciar $service automáticamente"
        fi
    fi
}

# Nueva función: Verificar contenedores existentes sin destruir
check_existing_containers() {
    local containers=(
        "trivance_mgmt_dev"
        "trivance_auth_dev" 
        "trivance_log_viewer_dev"
        "trivance_postgres_dev"
        "trivance_mongodb_dev"
    )
    
    local running_containers=0
    for container in "${containers[@]}"; do
        if docker ps --filter "name=${container}" --filter "status=running" -q | grep -q .; then
            ((running_containers++))
            log_info "Detectado: $container ya está corriendo"
        fi
    done
    
    if [[ $running_containers -gt 0 ]]; then
        log_fix "✅ Correcciones automáticas aplicadas"
        return 0
    fi
}

# Función principal - ejecutar todos los fallbacks
apply_all_fallbacks() {
    log_info "🛡️ Aplicando correcciones automáticas..."
    
    # Verificar contenedores problemáticos sin forzar destrucción
    check_existing_containers
    
    # Corregir permisos
    fix_volume_permissions
    
    # Regenerar .env si es necesario
    regenerate_missing_env_files
    
    # Corregir scripts de build
    fix_missing_build_scripts "ms_level_up_management"
    fix_missing_build_scripts "ms_trivance_auth"
    
    # No liberar puertos automáticamente sin confirmación
    # free_occupied_ports
    
    log_info "✅ Correcciones automáticas aplicadas"
}

# Función para aplicar fallbacks post-error
apply_post_error_fallbacks() {
    local error_context="$1"
    
    case "$error_context" in
        "build_failed")
            fix_missing_build_scripts "ms_level_up_management"
            fix_missing_build_scripts "ms_trivance_auth"
            ;;
        "startup_failed")
            retry_failed_services "mgmt"
            retry_failed_services "auth"
            ;;
        "ports_occupied")
            free_occupied_ports
            ;;
        *)
            apply_all_fallbacks
            ;;
    esac
}

# Exportar funciones para uso en otros scripts
export -f fix_missing_build_scripts
export -f clean_problematic_containers
export -f fix_volume_permissions
export -f regenerate_missing_env_files
export -f apply_all_fallbacks
export -f apply_post_error_fallbacks

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_all_fallbacks
fi