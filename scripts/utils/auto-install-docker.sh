#!/bin/bash

# Auto Docker Installation for AI-First Workflows
# Supports macOS and Linux automatic installation

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unsupported" ;;
    esac
}

# Check if running in CI/AI mode (non-interactive)
is_non_interactive() {
    [[ "${CI_MODE:-false}" == "true" || "${AI_EXECUTION_MODE:-false}" == "true" || "${INTERACTIVE_MODE:-true}" == "false" ]]
}

# Install Docker on macOS
install_docker_macos() {
    log "🍎 Instalando Docker Desktop en macOS..."
    
    # Check if Homebrew is available
    if command -v brew >/dev/null 2>&1; then
        info "🍺 Usando Homebrew para instalación automatizada"
        brew install --cask docker --no-quarantine
        success "✅ Docker Desktop instalado via Homebrew"
    else
        warn "⚠️  Homebrew no disponible. Descargando Docker Desktop..."
        
        # Download and install Docker Desktop
        local temp_dir=$(mktemp -d)
        local dmg_path="${temp_dir}/Docker.dmg"
        
        info "📥 Descargando Docker Desktop para Mac (Apple Silicon)..."
        curl -L "https://desktop.docker.com/mac/main/arm64/Docker.dmg" -o "$dmg_path"
        
        info "💿 Montando imagen de instalación..."
        hdiutil attach "$dmg_path" -nobrowse -quiet
        
        info "📦 Copiando Docker.app a Applications..."
        cp -R "/Volumes/Docker/Docker.app" "/Applications/"
        
        info "💿 Desmontando imagen..."
        hdiutil detach "/Volumes/Docker" -quiet
        
        # Cleanup
        rm -rf "$temp_dir"
        
        success "✅ Docker Desktop instalado en /Applications/"
    fi
}

# Install Docker on Linux
install_docker_linux() {
    log "🐧 Instalando Docker Engine en Linux..."
    
    # Detect Linux distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local distro="$ID"
    else
        error "❌ No se puede detectar la distribución de Linux"
        return 1
    fi
    
    case "$distro" in
        ubuntu|debian)
            install_docker_debian_ubuntu
            ;;
        centos|rhel|fedora)
            install_docker_rhel_family
            ;;
        *)
            warn "⚠️  Distribución $distro no soportada para auto-instalación"
            info "💡 Por favor instala Docker manualmente: https://docs.docker.com/engine/install/"
            return 1
            ;;
    esac
}

# Install Docker on Debian/Ubuntu
install_docker_debian_ubuntu() {
    info "📦 Instalando Docker en sistema Debian/Ubuntu..."
    
    # Update package index
    sudo apt-get update -qq
    
    # Install prerequisites
    sudo apt-get install -y -qq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group (for non-root access)
    sudo usermod -aG docker "$USER"
    
    success "✅ Docker Engine instalado en Ubuntu/Debian"
    info "🔄 Nota: Puede necesitar reiniciar sesión para usar Docker sin sudo"
}

# Install Docker on RHEL family (CentOS, RHEL, Fedora)
install_docker_rhel_family() {
    info "📦 Instalando Docker en sistema RHEL/CentOS/Fedora..."
    
    # Install using dnf/yum
    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y docker docker-compose
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y docker docker-compose
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
    else
        error "❌ No se encontró dnf ni yum para la instalación"
        return 1
    fi
    
    success "✅ Docker Engine instalado en RHEL/CentOS/Fedora"
}

# Start Docker service/application
start_docker() {
    local platform=$(detect_platform)
    
    case "$platform" in
        macos)
            info "🚀 Iniciando Docker Desktop..."
            open -a Docker
            
            # Wait for Docker to start (up to 2 minutes)
            local timeout=120
            local counter=0
            
            while ! docker info >/dev/null 2>&1; do
                if [[ $counter -ge $timeout ]]; then
                    error "❌ Timeout esperando que Docker inicie"
                    return 1
                fi
                
                info "⏳ Esperando que Docker inicie... (${counter}s/${timeout}s)"
                sleep 5
                counter=$((counter + 5))
            done
            
            success "✅ Docker Desktop iniciado correctamente"
            ;;
            
        linux)
            info "🚀 Iniciando servicio Docker..."
            sudo systemctl start docker
            sudo systemctl enable docker
            
            # Verify Docker is running
            if docker info >/dev/null 2>&1; then
                success "✅ Docker Engine iniciado correctamente"
            else
                error "❌ Error al iniciar Docker Engine"
                return 1
            fi
            ;;
    esac
}

# Main installation function
auto_install_docker() {
    local platform=$(detect_platform)
    
    info "🔍 Detectada plataforma: $platform"
    
    # Check if Docker is already installed
    if command -v docker >/dev/null 2>&1; then
        info "✅ Docker ya está instalado"
        
        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            success "✅ Docker está funcionando correctamente"
            return 0
        else
            warn "⚠️  Docker instalado pero no está ejecutándose"
            start_docker
            return $?
        fi
    fi
    
    # Auto-install for AI/CI mode, prompt for interactive mode
    if ! is_non_interactive; then
        warn "⚠️  Docker no está instalado"
        read -p "¿Instalar Docker automáticamente? (y/n): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "💡 Por favor instala Docker manualmente: https://docs.docker.com/get-docker/"
            return 1
        fi
    else
        # AI/CI mode - auto-install without prompts
        info "🤖 Modo AI/CI detectado - instalando Docker automáticamente..."
    fi
    
    # Install Docker based on platform
    case "$platform" in
        macos)
            install_docker_macos && start_docker
            ;;
        linux)
            install_docker_linux && start_docker
            ;;
        unsupported)
            error "❌ Plataforma no soportada para auto-instalación"
            info "💡 Por favor instala Docker manualmente: https://docs.docker.com/get-docker/"
            return 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log "🐳 Auto-instalador de Docker para Trivance Platform"
    auto_install_docker
fi