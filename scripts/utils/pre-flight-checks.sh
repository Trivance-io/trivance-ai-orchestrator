#!/bin/bash
# 🚀 PRE-FLIGHT CHECKS - Validación temprana para evitar timeouts
# Detecta problemas ANTES de iniciar Docker, ahorrando tiempo

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

# Variables de estado
ERRORS_FOUND=false
WARNINGS_FOUND=false

# Log functions
log_check() { echo -e "${CYAN}🔍 Verificando:${NC} $1"; }
log_ok() { echo -e "${GREEN}   ✅${NC} $1"; }
log_warn() { echo -e "${YELLOW}   ⚠️${NC} $1"; WARNINGS_FOUND=true; }
log_error() { echo -e "${RED}   ❌${NC} $1"; ERRORS_FOUND=true; }
log_fix() { echo -e "${BLUE}   🔧${NC} $1"; }

# Check 1: Docker daemon
check_docker() {
    log_check "Docker daemon"
    
    if ! command -v docker &>/dev/null; then
        log_error "Docker no está instalado"
        return 1
    fi
    
    if ! docker ps &>/dev/null 2>&1; then
        log_error "Docker daemon no está corriendo"
        log_fix "Inicia Docker Desktop y vuelve a intentar"
        return 1
    fi
    
    log_ok "Docker funcionando correctamente"
    return 0
}

# Check 2: Puertos disponibles
check_ports() {
    log_check "Puertos requeridos"
    
    local ports=(3000 3001 5173 5432 27017 4000 9999)
    local all_clear=true
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t &>/dev/null; then
            local process=$(lsof -Pi :$port -sTCP:LISTEN | grep LISTEN | head -1)
            
            # Detección inteligente de servicios Trivance ya corriendo
            if echo "$process" | grep -q "com.docke"; then
                # Servicios Trivance (Docker) - solo warning
                log_warn "Puerto $port ocupado por servicio Trivance existente"
            elif [[ "$port" == "5173" ]] && echo "$process" | grep -q "node"; then
                # Frontend Trivance (PM2) - solo warning
                log_warn "Puerto $port ocupado por frontend Trivance (PM2)"
            else
                # Servicios externos - error real
                log_error "Puerto $port ocupado por: $process"
                all_clear=false
            fi
        fi
    done
    
    if [[ "$all_clear" == "true" ]]; then
        log_ok "Todos los puertos disponibles"
    else
        log_fix "Detén los servicios que usan esos puertos o usa 'docker compose down'"
    fi
}

# Check 3: Archivos de configuración
check_env_files() {
    log_check "Archivos de configuración"
    
    # Verificar archivos .env principales
    local env_files=(
        "envs/local.management.env"
        "envs/local.auth.env"
    )
    
    for env_file in "${env_files[@]}"; do
        if [[ ! -f "${WORKSPACE_DIR}/$env_file" ]]; then
            log_error "Falta archivo: $env_file"
            log_fix "Ejecuta: ./trivance-dev-config/scripts/envs.sh switch local"
        else
            log_ok "$env_file existe"
        fi
    done
    
    # Verificar archivos Docker .env
    if [[ ! -f "${CONFIG_DIR}/docker/.env.docker-local" ]]; then
        log_warn "Falta .env.docker-local - se generará automáticamente"
    fi
}

# Check 4: Dockerfiles y contextos
check_docker_contexts() {
    log_check "Dockerfiles y build contexts"
    
    local services=("ms_level_up_management" "ms_trivance_auth")
    
    for service in "${services[@]}"; do
        local dockerfile="${WORKSPACE_DIR}/${service}/Dockerfile"
        local package_json="${WORKSPACE_DIR}/${service}/package.json"
        
        if [[ ! -f "$dockerfile" ]]; then
            log_error "Falta Dockerfile: $dockerfile"
        else
            log_ok "Dockerfile $service encontrado"
            
            # Verificar si el script build:dev existe
            if [[ -f "$package_json" ]]; then
                if ! grep -q '"build:dev"' "$package_json" 2>/dev/null; then
                    if grep -q '"build"' "$package_json" 2>/dev/null; then
                        log_warn "$service no tiene script 'build:dev', pero sí 'build'"
                    else
                        log_error "$service no tiene scripts de build en package.json"
                    fi
                fi
            fi
        fi
    done
}

# Check 5: Espacio en disco
check_disk_space() {
    log_check "Espacio en disco"
    
    # Versión compatible con macOS
    local available
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS usa df diferente
        available=$(df -g . | awk 'NR==2 {print $4}')
    else
        # Linux
        available=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    fi
    
    if [[ $available -lt 5 ]]; then
        log_error "Solo ${available}GB disponibles (mínimo 5GB recomendado)"
        log_fix "Libera espacio o usa 'docker system prune'"
    else
        log_ok "${available}GB disponibles"
    fi
}

# Check 6: Imágenes Docker existentes
check_docker_images() {
    log_check "Imágenes Docker existentes"
    
    local images_exist=false
    if docker images | grep -q "docker-ms_level_up_management\|docker-ms_trivance_auth"; then
        images_exist=true
        log_ok "Imágenes ya construidas - inicio será rápido"
    else
        log_warn "Primera ejecución - construcción tomará 3-5 minutos"
    fi
    
    echo "$images_exist"
}

# Check 7: Contenedores huérfanos
check_orphan_containers() {
    log_check "Contenedores huérfanos"
    
    local orphans=$(docker ps -a --filter "name=trivance_" --filter "status=exited" -q | wc -l)
    
    if [[ $orphans -gt 0 ]]; then
        log_warn "Hay $orphans contenedores detenidos"
        log_fix "Limpia con: docker compose down"
    else
        log_ok "No hay contenedores huérfanos"
    fi
}

# Función principal
run_all_checks() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              🚀 PRE-FLIGHT CHECKS - TRIVANCE                 ║${NC}"
    echo -e "${BLUE}║         Validación rápida antes de iniciar servicios         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Ejecutar todos los checks
    check_docker || true
    check_ports || true
    check_env_files || true
    check_docker_contexts || true
    check_disk_space || true
    local first_run=$(check_docker_images)
    check_orphan_containers || true
    
    echo
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    
    # Resumen
    if [[ "$ERRORS_FOUND" == "true" ]]; then
        echo -e "${RED}❌ Se encontraron errores críticos${NC}"
        echo -e "${YELLOW}Por favor corrige los errores antes de continuar${NC}"
        return 1
    elif [[ "$WARNINGS_FOUND" == "true" ]]; then
        echo -e "${YELLOW}⚠️  Hay advertencias pero puedes continuar${NC}"
        echo -e "${CYAN}El sistema intentará corregir automáticamente${NC}"
    else
        echo -e "${GREEN}✅ Todo listo para iniciar${NC}"
    fi
    
    # Estimación de tiempo
    echo
    if [[ "$first_run" == "false" ]]; then
        echo -e "${YELLOW}⏱️  Tiempo estimado: 3-5 minutos (primera ejecución)${NC}"
    else
        echo -e "${GREEN}⏱️  Tiempo estimado: 30-60 segundos (imágenes en cache)${NC}"
    fi
    
    return 0
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_checks
fi