#!/bin/bash

# 🚀 Script de Setup Simplificado para Trivance Platform (Estructura Integrada)
# Configura workspace desde cero para nuevos desarrolladores

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Funciones de logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# Banner de bienvenida
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║                🚀 TRIVANCE WORKSPACE SETUP 🚀                ║"
echo "║                                                               ║"
echo "║        Configuración automática del entorno de desarrollo    ║"
echo "║                      (Estructura Integrada)                  ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log "Iniciando configuración del workspace de Trivance Platform..."

# Verificar que estamos en el directorio correcto
if [ ! -f "dev-config/README.md" ] || [ ! -d "dev-config/.claude" ]; then
    error "Este script debe ejecutarse desde el directorio raíz de Trivance-platform"
    error "Asegúrate de estar en: Trivance-platform/"
    error "Estructura esperada:"
    error "  Trivance-platform/"
    error "  ├── dev-config/     <- Configuraciones"
    error "  ├── level_up_backoffice/"
    error "  └── ..."
    exit 1
fi

# Verificar herramientas necesarias
log "Verificando herramientas necesarias..."

check_tool() {
    if ! command -v $1 &> /dev/null; then
        error "$1 no está instalado. Por favor instálalo antes de continuar."
        exit 1
    else
        info "✅ $1 encontrado"
    fi
}

check_tool "node"
check_tool "npm"
check_tool "git"

# Verificar versión de Node
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js 18+ es requerido. Versión actual: $(node -v)"
    exit 1
else
    info "✅ Node.js $(node -v) es compatible"
fi

# Copiar configuraciones desde dev-config
log "Aplicando configuraciones del workspace..."

# Copiar configuraciones de Claude Code
if [ ! -d ".claude" ]; then
    cp -r dev-config/.claude .
    success "✅ Configuración Claude Code aplicada"
else
    warning "⚠️  Configuración Claude Code ya existe"
    read -p "¿Sobrescribir? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp -r dev-config/.claude .
        success "✅ Configuración Claude Code sobrescrita"
    fi
fi

# Copiar configuraciones AI agnósticas
if [ ! -d ".ai-config" ]; then
    cp -r dev-config/.ai-config .
    success "✅ Configuración AI agnóstica aplicada"
else
    warning "⚠️  Configuración AI agnóstica ya existe"
fi

# Copiar scripts
if [ ! -d "scripts" ]; then
    cp -r dev-config/scripts .
    success "✅ Scripts copiados"
else
    warning "⚠️  Directorio scripts ya existe"
fi

# Copiar workspace configuration
if [ ! -f "TrivancePlatform.code-workspace" ]; then
    cp dev-config/templates/TrivancePlatform.code-workspace.template TrivancePlatform.code-workspace
    success "✅ Workspace VS Code configurado"
else
    warning "⚠️  Workspace VS Code ya existe"
fi

# Dar permisos de ejecución a scripts
log "Configurando permisos de scripts..."
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x dev-config/scripts/*.sh 2>/dev/null || true
success "✅ Permisos de scripts configurados"

# Función para instalar dependencias
install_dependencies() {
    local dir=$1
    if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
        log "Instalando dependencias en $dir..."
        cd "$dir"
        
        if npm install; then
            success "✅ Dependencias instaladas en $dir"
        else
            error "❌ Error instalando dependencias en $dir"
            return 1
        fi
        
        cd ..
    else
        warning "⚠️  $dir no encontrado o no tiene package.json"
    fi
}

# Instalar dependencias en todos los repos
log "Instalando dependencias de Node.js en todos los repositorios..."

install_dependencies "ms_level_up_management"
install_dependencies "ms_trivance_auth"
install_dependencies "level_up_backoffice"
install_dependencies "trivance-mobile"

# Crear archivos .env.example si no existen
log "Verificando archivos de configuración de entorno..."

create_env_example() {
    local dir=$1
    local env_file="$dir/.env.example"
    
    if [ -d "$dir" ] && [ ! -f "$env_file" ]; then
        warning "Creando $env_file básico..."
        cat > "$env_file" << EOF
# Environment Configuration
NODE_ENV=development
PORT=3000

# Database Configuration
DATABASE_URL=mongodb://localhost:27017/trivance

# JWT Configuration
JWT_SECRET=your-jwt-secret-here

# AWS Configuration (opcional)
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_REGION=

# External APIs (opcional)
# SENTRY_DSN=
# FIREBASE_CONFIG=
EOF
        info "✅ Archivo $env_file creado"
    fi
}

create_env_example "ms_level_up_management"
create_env_example "ms_trivance_auth"

# Verificar configuración Git
log "Verificando configuración Git..."

if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
    warning "Configuración Git incompleta"
    echo ""
    echo "Por favor configura Git con tus datos:"
    echo "git config --global user.name \"Tu Nombre\""
    echo "git config --global user.email \"tu-email@trivance.com\""
    echo ""
else
    success "✅ Configuración Git completa"
fi

# Crear directorio de logs
mkdir -p logs
log "✅ Directorio de logs creado"

# Resumen final
echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                                                               ║${NC}"
echo -e "${PURPLE}║                    🎉 SETUP COMPLETADO 🎉                    ║${NC}"
echo -e "${PURPLE}║                                                               ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"

echo ""
log "Workspace de Trivance Platform configurado exitosamente!"

echo ""
echo -e "${BLUE}📁 Estructura del workspace:${NC}"
ls -la | grep -E "(ms_|level_|trivance-|scripts|\.claude|dev-config)" | sed 's/^/   /'

echo ""
echo -e "${BLUE}🚀 Próximos pasos:${NC}"
echo "   1. Configurar variables de entorno en cada repositorio:"
echo "      cd ms_level_up_management && cp .env.example .env"
echo "      cd ms_trivance_auth && cp .env.example .env"
echo ""
echo "   2. Iniciar todos los servicios:"
echo "      ./scripts/start-all-services.sh"
echo ""
echo "   3. Abrir en tu editor favorito:"
echo "      code TrivancePlatform.code-workspace  # VS Code"
echo "      cursor TrivancePlatform.code-workspace  # Cursor"
echo ""
echo "   4. Verificar que todo funciona:"
echo "      ./scripts/check-health.sh"

echo ""
echo -e "${YELLOW}📚 Documentación útil:${NC}"
echo "   - Workspace overview: dev-config/README.md"
echo "   - Onboarding completo: dev-config/docs/ONBOARDING.md"
echo "   - Workflows: dev-config/docs/WORKFLOWS.md"

echo ""
echo -e "${GREEN}🆘 ¿Necesitas ayuda?${NC}"
echo "   - Slack: #dev-support"
echo "   - Email: dev-team@trivance.com"
echo "   - Issues: GitHub Issues en este repositorio"

echo ""
success "¡Bienvenido al equipo de desarrollo de Trivance Platform! 🚀"