#!/bin/bash

# 🔧 TRIVANCE COMMAND VALIDATOR
# Script centralizado para validar comandos externos y sus dependencias
# Manejo robusto de diferencias entre sistemas (macOS, Linux, etc.)

set -euo pipefail

# 🎨 Colores (con verificación de variables ya definidas)
if [[ -z "${RED:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'
fi

# 📝 Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 🔍 Verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ⏱️ Función de timeout multiplataforma
safe_timeout() {
    local timeout_seconds="$1"
    shift
    
    # Detectar sistema y usar timeout apropiado
    if command_exists gtimeout; then
        # GNU timeout (instalado via brew en macOS)
        gtimeout "$timeout_seconds" "$@"
    elif command_exists timeout; then
        # Timeout nativo de Linux
        timeout "$timeout_seconds" "$@"
    else
        # Fallback usando bash y kill
        log_warning "Timeout no disponible, usando fallback bash"
        bash_timeout "$timeout_seconds" "$@"
    fi
}

# 🔄 Implementación de timeout en bash puro
bash_timeout() {
    local timeout_seconds="$1"
    shift
    
    # Ejecutar comando en background
    "$@" &
    local cmd_pid=$!
    
    # Esperar con timeout
    local count=0
    while kill -0 "$cmd_pid" 2>/dev/null; do
        if (( count >= timeout_seconds )); then
            kill "$cmd_pid" 2>/dev/null
            wait "$cmd_pid" 2>/dev/null || true
            return 124  # Exit code 124 indica timeout
        fi
        sleep 1
        ((count++))
    done
    
    # Obtener exit code del comando
    wait "$cmd_pid"
}

# 🐳 Verificar Docker
validate_docker() {
    local context="${1:-setup}"
    
    if ! command_exists docker; then
        log_error "Docker no está instalado"
        log_error "Descarga e instala Docker Desktop desde: https://www.docker.com/products/docker-desktop/"
        return 1
    fi
    
    # Verificar que Docker daemon esté corriendo
    if ! docker ps >/dev/null 2>&1; then
        log_error "Docker daemon no está corriendo"
        log_error "Inicia Docker Desktop y vuelve a intentar"
        return 1
    fi
    
    # Verificar Docker Compose
    if ! docker compose version >/dev/null 2>&1; then
        if ! command_exists docker-compose; then
            log_error "Docker Compose no está disponible"
            log_error "Instala Docker Compose o actualiza Docker Desktop"
            return 1
        else
            log_warning "Usando docker-compose v1 (considera actualizar a docker compose v2)"
        fi
    fi
    
    log_success "Docker disponible y funcionando"
    return 0
}

# 📦 Verificar Node.js y npm
validate_node() {
    if ! command_exists node; then
        log_error "Node.js no está instalado"
        log_error "Descarga e instala Node.js desde: https://nodejs.org/"
        return 1
    fi
    
    if ! command_exists npm; then
        log_error "npm no está instalado"
        log_error "npm debería venir con Node.js"
        return 1
    fi
    
    # Verificar versión mínima de Node.js
    local node_version
    node_version=$(node --version | sed 's/v//')
    local required_version="18.0.0"
    
    if ! version_ge "$node_version" "$required_version"; then
        log_error "Node.js versión $node_version es menor que la requerida $required_version"
        log_error "Actualiza Node.js desde: https://nodejs.org/"
        return 1
    fi
    
    log_success "Node.js $node_version disponible"
    return 0
}

# 🔗 Verificar Git
validate_git() {
    if ! command_exists git; then
        log_error "Git no está instalado"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log_error "Instala Xcode Command Line Tools: xcode-select --install"
        else
            log_error "Instala Git: sudo apt-get install git"
        fi
        return 1
    fi
    
    log_success "Git disponible"
    return 0
}

# 📊 Verificar PM2
validate_pm2() {
    local install_if_missing="${1:-false}"
    
    if ! command_exists pm2; then
        if [[ "$install_if_missing" == "true" ]]; then
            log_info "PM2 no está instalado, instalando globalmente..."
            if npm install -g pm2; then
                log_success "PM2 instalado correctamente"
                return 0
            else
                log_error "Error al instalar PM2"
                return 1
            fi
        else
            log_warning "PM2 no está instalado (se puede instalar automáticamente)"
            return 1
        fi
    fi
    
    log_success "PM2 disponible"
    return 0
}

# 🌐 Verificar curl
validate_curl() {
    if ! command_exists curl; then
        log_error "curl no está instalado"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log_error "curl debería estar disponible en macOS"
        else
            log_error "Instala curl: sudo apt-get install curl"
        fi
        return 1
    fi
    
    log_success "curl disponible"
    return 0
}

# 🔍 Verificar jq
validate_jq() {
    local install_if_missing="${1:-false}"
    
    if ! command_exists jq; then
        if [[ "$install_if_missing" == "true" ]]; then
            log_info "jq no está instalado, instalando..."
            if [[ "$OSTYPE" == "darwin"* ]]; then
                if command_exists brew; then
                    brew install jq
                else
                    log_error "Homebrew no está instalado. Instala jq manualmente"
                    return 1
                fi
            else
                log_warning "Se requiere instalar jq con permisos de administrador"
                read -p "¿Deseas continuar con la instalación? (s/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Ss]$ ]]; then
                    sudo apt-get update && sudo apt-get install -y jq
                else
                    log_error "jq es requerido para continuar"
                    return 1
                fi
            fi
            log_success "jq instalado correctamente"
            return 0
        else
            log_warning "jq no está instalado (se puede instalar automáticamente)"
            return 1
        fi
    fi
    
    log_success "jq disponible"
    return 0
}

# 🔢 Comparar versiones
version_ge() {
    local version1="$1"
    local version2="$2"
    
    # Convertir versiones a números comparables
    local v1_major v1_minor v1_patch
    local v2_major v2_minor v2_patch
    
    IFS='.' read -r v1_major v1_minor v1_patch <<< "$version1"
    IFS='.' read -r v2_major v2_minor v2_patch <<< "$version2"
    
    # Valores por defecto si algún campo está vacío
    v1_major=${v1_major:-0}
    v1_minor=${v1_minor:-0}
    v1_patch=${v1_patch:-0}
    v2_major=${v2_major:-0}
    v2_minor=${v2_minor:-0}
    v2_patch=${v2_patch:-0}
    
    # Comparar
    if (( v1_major > v2_major )); then
        return 0
    elif (( v1_major < v2_major )); then
        return 1
    elif (( v1_minor > v2_minor )); then
        return 0
    elif (( v1_minor < v2_minor )); then
        return 1
    elif (( v1_patch >= v2_patch )); then
        return 0
    else
        return 1
    fi
}

# 🚀 Validación completa para setup
validate_setup_requirements() {
    log_info "Validando requisitos para setup..."
    
    local errors=0
    
    # Validaciones obligatorias
    if ! validate_git; then ((errors++)); fi
    if ! validate_node; then ((errors++)); fi
    if ! validate_docker; then ((errors++)); fi
    if ! validate_curl; then ((errors++)); fi
    
    # Validaciones con instalación automática
    if ! validate_jq true; then ((errors++)); fi
    
    # Validaciones opcionales
    validate_pm2 false || log_warning "PM2 se instalará automáticamente si es necesario"
    
    if (( errors > 0 )); then
        log_error "$errors errores críticos encontrados"
        return 1
    fi
    
    log_success "Todos los requisitos para setup están disponibles"
    return 0
}

# 🎯 Validación para operaciones
validate_runtime_requirements() {
    log_info "Validando requisitos para operaciones..."
    
    local errors=0
    
    # Validaciones obligatorias para runtime
    if ! validate_docker; then ((errors++)); fi
    if ! validate_curl; then ((errors++)); fi
    
    # PM2 se instala automáticamente si es necesario
    validate_pm2 true || ((errors++))
    
    if (( errors > 0 )); then
        log_error "$errors errores críticos encontrados"
        return 1
    fi
    
    log_success "Todos los requisitos para operaciones están disponibles"
    return 0
}

# 💊 Instalar dependencias de macOS si es necesario
install_macos_dependencies() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 0
    fi
    
    log_info "Verificando dependencias específicas de macOS..."
    
    # Instalar GNU timeout si no está disponible
    if ! command_exists gtimeout && command_exists brew; then
        log_info "Instalando GNU coreutils para timeout..."
        brew install coreutils
    fi
    
    return 0
}

# 🔄 Función principal
main() {
    case "${1:-setup}" in
        "setup")
            validate_setup_requirements
            ;;
        "runtime")
            validate_runtime_requirements
            ;;
        "macos")
            install_macos_dependencies
            ;;
        "docker")
            validate_docker
            ;;
        "node")
            validate_node
            ;;
        "git")
            validate_git
            ;;
        "pm2")
            validate_pm2 true
            ;;
        "curl")
            validate_curl
            ;;
        "jq")
            validate_jq true
            ;;
        *)
            echo "Uso: $0 {setup|runtime|macos|docker|node|git|pm2|curl|jq}"
            echo
            echo "setup   - Validar todos los requisitos para setup inicial"
            echo "runtime - Validar requisitos para operaciones"
            echo "macos   - Instalar dependencias específicas de macOS"
            echo "docker  - Validar solo Docker"
            echo "node    - Validar solo Node.js"
            echo "git     - Validar solo Git"
            echo "pm2     - Validar/instalar PM2"
            echo "curl    - Validar solo curl"
            echo "jq      - Validar/instalar jq"
            exit 1
            ;;
    esac
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi