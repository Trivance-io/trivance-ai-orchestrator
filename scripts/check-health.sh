#!/bin/bash

# 🔍 Script de Verificación de Salud del Workspace
# Verifica el estado de todos los servicios y configuraciones

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

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║                 🔍 HEALTH CHECK WORKSPACE 🔍                 ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log "Iniciando verificación de salud del workspace Trivance..."

# Contadores para el reporte final
CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Función para realizar check
perform_check() {
    local check_name="$1"
    local check_function="$2"
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    echo ""
    info "🔍 Verificando: $check_name"
    
    if $check_function; then
        success "✅ $check_name: OK"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        error "❌ $check_name: FAILED"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

# Función para warning check
perform_warning_check() {
    local check_name="$1"
    local check_function="$2"
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    echo ""
    info "🔍 Verificando: $check_name"
    
    if $check_function; then
        success "✅ $check_name: OK"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        warning "⚠️  $check_name: WARNING"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
        return 1
    fi
}

# ========== CHECKS DE ESTRUCTURA ==========

check_workspace_structure() {
    local required_dirs=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile" "scripts" ".claude")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        return 0
    else
        error "Directorios faltantes: ${missing_dirs[*]}"
        return 1
    fi
}

check_scripts_permissions() {
    local scripts_dir="scripts"
    local failed_scripts=()
    
    if [ ! -d "$scripts_dir" ]; then
        error "Directorio scripts no encontrado"
        return 1
    fi
    
    for script in "$scripts_dir"/*.sh; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            failed_scripts+=("$(basename "$script")")
        fi
    done
    
    if [ ${#failed_scripts[@]} -eq 0 ]; then
        return 0
    else
        error "Scripts sin permisos de ejecución: ${failed_scripts[*]}"
        info "Ejecuta: chmod +x scripts/*.sh"
        return 1
    fi
}

# ========== CHECKS DE CONFIGURACIÓN ==========

check_claude_config() {
    local config_files=(".claude/settings.json" ".claude/context.md" ".claude/commands.md" ".claude/prompts.md")
    local missing_files=()
    
    for file in "${config_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        return 0
    else
        error "Archivos de configuración Claude faltantes: ${missing_files[*]}"
        return 1
    fi
}

check_ai_config() {
    local config_files=(".ai-config/settings.json" ".ai-config/context.md" ".ai-config/patterns.md")
    local missing_files=()
    
    for file in "${config_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        return 0
    else
        error "Archivos de configuración AI faltantes: ${missing_files[*]}"
        return 1
    fi
}

check_workspace_file() {
    if [ -f "TrivancePlatform.code-workspace" ]; then
        # Verificar que el archivo JSON es válido
        if python3 -m json.tool TrivancePlatform.code-workspace >/dev/null 2>&1; then
            return 0
        else
            error "TrivancePlatform.code-workspace tiene JSON inválido"
            return 1
        fi
    else
        error "TrivancePlatform.code-workspace no encontrado"
        return 1
    fi
}

# ========== CHECKS DE DEPENDENCIAS ==========

check_node_modules() {
    local repos=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    local missing_deps=()
    
    for repo in "${repos[@]}"; do
        if [ -d "$repo" ] && [ -f "$repo/package.json" ] && [ ! -d "$repo/node_modules" ]; then
            missing_deps+=("$repo")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        return 0
    else
        warning "Dependencias no instaladas en: ${missing_deps[*]}"
        info "Ejecuta en cada directorio: npm install"
        return 1
    fi
}

check_git_config() {
    local git_name=$(git config --global user.name 2>/dev/null || echo "")
    local git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        info "Git configurado para: $git_name <$git_email>"
        return 0
    else
        warning "Configuración Git incompleta"
        info "Configura con: git config --global user.name \"Tu Nombre\""
        info "Configura con: git config --global user.email \"tu@email.com\""
        return 1
    fi
}

# ========== CHECKS DE SERVICIOS ==========

check_port() {
    local port=$1
    if command -v lsof &> /dev/null; then
        lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1
    else
        # Fallback usando netstat
        netstat -ln | grep ":$port " >/dev/null 2>&1
    fi
}

check_services_running() {
    local services=(
        "3001:Auth Service"
        "3000:Management API"
        "5173:Frontend Dev Server"
    )
    
    local running_services=0
    local total_services=${#services[@]}
    
    for service in "${services[@]}"; do
        local port=$(echo "$service" | cut -d':' -f1)
        local name=$(echo "$service" | cut -d':' -f2)
        
        if check_port "$port"; then
            info "✅ $name corriendo en puerto $port"
            running_services=$((running_services + 1))
        else
            info "⭕ $name no está corriendo en puerto $port"
        fi
    done
    
    if [ $running_services -gt 0 ]; then
        info "$running_services de $total_services servicios están corriendo"
        return 0
    else
        warning "Ningún servicio está corriendo"
        info "Inicia servicios con: ./scripts/start-all-services.sh"
        return 1
    fi
}

check_health_endpoints() {
    local endpoints=(
        "http://localhost:3001/health:Auth Service"
        "http://localhost:3000/health:Management API"
    )
    
    local healthy_endpoints=0
    local total_endpoints=${#endpoints[@]}
    
    for endpoint in "${endpoints[@]}"; do
        local url=$(echo "$endpoint" | cut -d':' -f1-2)
        local name=$(echo "$endpoint" | cut -d':' -f3)
        
        if command -v curl &> /dev/null; then
            if curl -s -f "$url" >/dev/null 2>&1; then
                info "✅ $name health check: OK"
                healthy_endpoints=$((healthy_endpoints + 1))
            else
                info "❌ $name health check: FAILED"
            fi
        else
            info "⚠️  curl no disponible, saltando health checks"
            return 0
        fi
    done
    
    if [ $healthy_endpoints -eq $total_endpoints ]; then
        return 0
    else
        warning "$healthy_endpoints de $total_endpoints endpoints están saludables"
        return 1
    fi
}

# ========== CHECKS DE HERRAMIENTAS ==========

check_required_tools() {
    local tools=("node" "npm" "git")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        info "Node: $(node -v), NPM: $(npm -v), Git: $(git --version | cut -d' ' -f3)"
        return 0
    else
        error "Herramientas faltantes: ${missing_tools[*]}"
        return 1
    fi
}

check_node_version() {
    local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    local min_version=18
    
    if [ "$node_version" -ge "$min_version" ]; then
        info "Node.js $(node -v) es compatible (mínimo: v$min_version)"
        return 0
    else
        error "Node.js $(node -v) es muy antiguo (mínimo: v$min_version)"
        return 1
    fi
}

# ========== EJECUTAR TODOS LOS CHECKS ==========

log "Iniciando verificaciones del workspace..."

# Checks críticos
perform_check "Estructura del workspace" check_workspace_structure
perform_check "Herramientas requeridas" check_required_tools
perform_check "Versión de Node.js" check_node_version
perform_check "Configuración Claude Code" check_claude_config
perform_check "Configuración AI agnóstica" check_ai_config
perform_check "Archivo workspace VS Code" check_workspace_file
perform_check "Permisos de scripts" check_scripts_permissions

# Checks de warning
perform_warning_check "Dependencias instaladas" check_node_modules
perform_warning_check "Configuración Git" check_git_config
perform_warning_check "Servicios corriendo" check_services_running

# Checks opcionales (solo si hay servicios corriendo)
if check_port 3000 || check_port 3001; then
    perform_warning_check "Health endpoints" check_health_endpoints
fi

# ========== REPORTE FINAL ==========

echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                                                               ║${NC}"
echo -e "${PURPLE}║                     📊 REPORTE FINAL 📊                      ║${NC}"
echo -e "${PURPLE}║                                                               ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}📈 Resumen de verificaciones:${NC}"
echo "   ✅ Exitosas: $CHECKS_PASSED"
echo "   ❌ Fallidas: $CHECKS_FAILED"
echo "   ⚠️  Warnings: $CHECKS_WARNING"
echo "   📊 Total: $CHECKS_TOTAL"

# Determinar estado general
if [ $CHECKS_FAILED -eq 0 ]; then
    if [ $CHECKS_WARNING -eq 0 ]; then
        echo ""
        success "🎉 ¡Workspace en perfecto estado!"
        echo -e "${GREEN}   Todo está configurado correctamente.${NC}"
    else
        echo ""
        warning "⚠️  Workspace funcional con advertencias"
        echo -e "${YELLOW}   El workspace funciona pero hay mejoras recomendadas.${NC}"
    fi
else
    echo ""
    error "❌ Workspace requiere atención"
    echo -e "${RED}   Hay problemas críticos que deben solucionarse.${NC}"
fi

# Sugerencias basadas en el estado
echo ""
echo -e "${BLUE}🔧 Próximos pasos recomendados:${NC}"

if [ $CHECKS_FAILED -gt 0 ]; then
    echo "   1. Solucionar problemas críticos mostrados arriba"
    echo "   2. Ejecutar: ./scripts/sync-configs.sh"
    echo "   3. Volver a ejecutar: ./scripts/check-health.sh"
elif [ $CHECKS_WARNING -gt 0 ]; then
    echo "   1. Revisar advertencias para mejorar la experiencia"
    echo "   2. Instalar dependencias faltantes: npm install"
    echo "   3. Iniciar servicios: ./scripts/start-all-services.sh"
else
    echo "   1. ¡Continuar desarrollando! 🚀"
    echo "   2. Iniciar servicios: ./scripts/start-all-services.sh"
    echo "   3. Abrir editor: code TrivancePlatform.code-workspace"
fi

echo ""
echo -e "${GREEN}📚 Documentación útil:${NC}"
echo "   - Setup: trivance-dev-config/README.md"
echo "   - Troubleshooting: trivance-dev-config/docs/TROUBLESHOOTING.md"
echo "   - Workflows: trivance-dev-config/docs/WORKFLOWS.md"

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    success "Health check completado exitosamente! ✨"
    exit 0
else
    error "Health check encontró problemas que requieren atención."
    exit 1
fi