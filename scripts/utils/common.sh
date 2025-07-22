#!/bin/bash

# Load timeout configuration for AI-first workflows
load_timeout_config() {
    local config_file="${SCRIPT_DIR}/../../config/timeouts.conf"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        
        # Apply context-aware timeout multipliers
        if [[ "${AI_EXECUTION_MODE:-false}" == "true" ]]; then
            # Double timeouts for AI workflows
            DOCKER_FIRST_BUILD_TIMEOUT=$((DOCKER_FIRST_BUILD_TIMEOUT * 2))
            NPM_INSTALL_TIMEOUT=$((NPM_INSTALL_TIMEOUT * 2))
        elif [[ "${CI_MODE:-false}" == "true" ]]; then
            # 1.5x timeouts for CI
            DOCKER_FIRST_BUILD_TIMEOUT=$((DOCKER_FIRST_BUILD_TIMEOUT * 3 / 2))
            NPM_INSTALL_TIMEOUT=$((NPM_INSTALL_TIMEOUT * 3 / 2))
        fi
    fi
}

# Auto-load timeout config when common.sh is sourced
load_timeout_config

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging general
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Función para éxito
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Función para errores
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Función para advertencias
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para información
info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Función para depuración
debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Función para mostrar progreso
show_progress() {
    local message="$1"
    local current="$2"
    local total="$3"
    
    local percentage=$((current * 100 / total))
    
    echo -ne "\r${CYAN}[PROGRESO]${NC} ${message} [${current}/${total}] ${percentage}%"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Función para instalar dependencias con timeout y progreso
install_dependencies_for_repo() {
    local repo_name="$1"
    local repo_path="$2"
    
    info "📦 Instalando dependencias para ${repo_name}..."
    info "📍 Ruta: ${repo_path}"
    
    # Cambiar al directorio del repositorio
    local original_dir
    original_dir=$(pwd)
    
    if ! cd "$repo_path"; then
        error "No se puede acceder al directorio ${repo_path}"
        return 1
    fi
    
    # Verificar que existe package.json
    if [[ ! -f "package.json" ]]; then
        warn "⚠️  No se encontró package.json en ${repo_name}"
        cd "$original_dir"
        return 0
    fi
    
    # Crear directorio de logs si no existe
    local log_dir="${WORKSPACE_DIR}/logs"
    mkdir -p "$log_dir"
    
    # Instalar con timeout reducido y progreso visible
    info "⏱️  Tiempo máximo: 3 minutos por repo"
    info "🔄 Instalando dependencias con progreso visible..."
    
    # Función de timeout con progreso visible usando safe_timeout
    run_with_timeout_and_progress() {
        local timeout_duration=$1
        shift
        local command=("$@")
        
        # Cargar command validator para usar safe_timeout
        if [[ -f "${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/command-validator.sh" ]]; then
            source "${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/command-validator.sh"
        fi
        
        # Ejecutar comando en background
        "${command[@]}" > "${log_dir}/${repo_name}_install.log" 2>&1 &
        local cmd_pid=$!
        
        # Monitor con progreso cada 10 segundos
        local elapsed=0
        local dot_count=0
        
        while kill -0 "$cmd_pid" 2>/dev/null; do
            if [[ $elapsed -ge $timeout_duration ]]; then
                kill "$cmd_pid" 2>/dev/null
                echo
                error "❌ TIMEOUT: Instalación cancelada después de ${timeout_duration}s"
                return 124
            fi
            
            # Mostrar progreso cada 10 segundos
            if [[ $((elapsed % 10)) -eq 0 ]]; then
                local dots=$(printf "%*s" $((dot_count % 4)) "" | tr ' ' '.')
                printf "\r${CYAN}⏳ Instalando${dots}${NC} [${elapsed}s/${timeout_duration}s]    "
                ((dot_count++))
            fi
            
            sleep 1
            ((elapsed++))
        done
        
        # Obtener código de salida
        wait "$cmd_pid"
        local exit_code=$?
        
        printf "\r${NC}"  # Limpiar línea de progreso
        return $exit_code
    }
    
    if run_with_timeout_and_progress 180 npm install --silent --no-audit --no-fund; then
        success "✅ Dependencias instaladas para ${repo_name}"
        cd "$original_dir"
        return 0
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            error "❌ TIMEOUT: ${repo_name} tardó más de 3 minutos - CANCELADO"
            error "   📈 Log: ${log_dir}/${repo_name}_install.log"
            error "   💡 Solución: npm cache clean --force && rm -rf node_modules"
        else
            error "❌ ERROR: Instalación fallida para ${repo_name}"
            error "   📈 Log: ${log_dir}/${repo_name}_install.log"
        fi
        cd "$original_dir"
        return 1
    fi
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para validar directorio workspace
validate_workspace() {
    if [[ -z "${WORKSPACE_DIR:-}" ]]; then
        error "Variable WORKSPACE_DIR no está definida"
        exit 1
    fi
    
    if [[ ! -d "$WORKSPACE_DIR" ]]; then
        error "El directorio workspace no existe: $WORKSPACE_DIR"
        exit 1
    fi
    
    if [[ ! -w "$WORKSPACE_DIR" ]]; then
        error "No tienes permisos de escritura en: $WORKSPACE_DIR"
        exit 1
    fi
}

# Función para limpiar workspace (usar con cuidado)
clean_workspace() {
    local workspace="${WORKSPACE_DIR}"
    
    warn "⚠️  LIMPIANDO WORKSPACE: ${workspace}"
    
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    
    for repo in "${repos[@]}"; do
        local repo_path="${workspace}/${repo}"
        if [[ -d "$repo_path" ]]; then
            info "🗑️  Eliminando ${repo}..."
            rm -rf "$repo_path"
        fi
    done
    
    # Limpiar otros archivos generados
    local files_to_clean=(
        "${workspace}/logs"
        "${workspace}/.init_trigger"
        "${workspace}/TrivancePlatform.code-workspace"
        "${workspace}/README.md"
    )
    
    for file in "${files_to_clean[@]}"; do
        if [[ -e "$file" ]]; then
            info "🗑️  Eliminando $(basename "$file")..."
            rm -rf "$file"
        fi
    done
    
    success "✅ Workspace limpiado"
}

# Función para verificar estado de git
check_git_status() {
    local repo_path="$1"
    local repo_name="$2"
    
    if [[ -d "${repo_path}/.git" ]]; then
        cd "$repo_path"
        local status
        status=$(git status --porcelain)
        
        if [[ -n "$status" ]]; then
            warn "⚠️  ${repo_name} tiene cambios sin confirmar"
        else
            success "✅ ${repo_name} está limpio"
        fi
    fi
}

# Función para verificar servicios de salud
health_check() {
    log "Verificando servicios de salud..."
    
    # URLs de health check
    local auth_health="http://localhost:3001/health"
    local mgmt_health="http://localhost:3000/health"
    
    # Verificar Auth Service
    if curl -s "$auth_health" >/dev/null 2>&1; then
        success "✅ Auth Service (3001) - Saludable"
    else
        warn "⚠️  Auth Service (3001) - No responde"
    fi
    
    # Verificar Management API
    if curl -s "$mgmt_health" >/dev/null 2>&1; then
        success "✅ Management API (3000) - Saludable"
    else
        warn "⚠️  Management API (3000) - No responde"
    fi
}

# Configurar variables globales usando el path resolver
setup_globals() {
    # Usar el path resolver centralizado
    if [[ -f "${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/path-resolver.sh" ]]; then
        source "${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/path-resolver.sh"
        resolve_paths
    else
        # Fallback al método anterior si path-resolver no está disponible
        if [[ -z "${WORKSPACE_DIR:-}" ]]; then
            WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
            WORKSPACE_DIR="$(dirname "$WORKSPACE_DIR")"
        fi
        
        export WORKSPACE_DIR
        validate_workspace
    fi
}

# 🔒 Verificaciones de seguridad
verify_development_environment() {
    # Verificar NODE_ENV
    if [[ "${NODE_ENV:-}" == "production" ]]; then
        error "❌ NODE_ENV está configurado como 'production'"
        error "   Este script es SOLO para desarrollo local"
        exit 1
    fi
    
    # Verificar archivo marcador de producción
    if [[ -f "${WORKSPACE_DIR}/.production" ]] || [[ -f "/etc/trivance/production" ]]; then
        error "❌ Detectado marcador de entorno de producción"
        error "   Este script es SOLO para desarrollo local"
        exit 1
    fi
    
    # Verificar que no estamos en servidor conocido de producción
    local hostname=$(hostname)
    if [[ "$hostname" =~ (prod|production|live) ]]; then
        warn "⚠️  ADVERTENCIA: El hostname sugiere un entorno de producción: $hostname"
        read -p "¿Estás SEGURO que esto es desarrollo local? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            error "❌ Abortando por seguridad"
            exit 1
        fi
    fi
    
    # Verificar que Docker está en modo desarrollo
    if command -v docker &>/dev/null; then
        local docker_context=$(docker context show 2>/dev/null || echo "default")
        if [[ "$docker_context" =~ (prod|production) ]]; then
            error "❌ Docker context sugiere producción: $docker_context"
            exit 1
        fi
    fi
    
    return 0
}

# Inicializar automáticamente cuando se carga el script
setup_globals