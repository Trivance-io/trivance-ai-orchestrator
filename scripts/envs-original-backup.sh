#!/bin/bash

# 🎛️ TRIVANCE ENVIRONMENTS - SCRIPT MAESTRO SIMPLIFICADO
# Un solo script para manejar todos los environments de forma segura y simple
# 
# Uso:
#   ./envs.sh switch local       # Cambiar a desarrollo local
#   ./envs.sh switch qa          # Cambiar a QA  
#   ./envs.sh switch production  # Cambiar a producción
#   ./envs.sh status             # Ver estado actual
#   ./envs.sh help               # Ver ayuda

set -euo pipefail

# 🎨 Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# 📁 Directorios
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
readonly WORKSPACE_DIR="$(dirname "$CONFIG_DIR")"
readonly ENVS_DIR="$WORKSPACE_DIR/envs"

# 📝 Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}$1${NC}"; }

# 🔍 Verificar dependencias
check_dependencies() {
    if [[ ! -d "$ENVS_DIR" ]]; then
        log_error "Directorio envs/ no encontrado: $ENVS_DIR"
        log_info "Ejecutar primero: mkdir -p envs && ./envs.sh setup"
        exit 1
    fi
}

# 🏗️ Setup inicial del sistema
setup_environment_system() {
    log_header "🏗️ Configurando sistema de environments..."
    
    # Crear directorio envs si no existe
    mkdir -p "$ENVS_DIR"
    
    # Crear archivo README en envs/
    cat > "$ENVS_DIR/README.md" << 'EOF'
# 📁 ENVS - Configuraciones de Environment

Este directorio contiene las configuraciones reales para cada environment:

## 📋 Archivos por Environment

### 🖥️ LOCAL (Desarrollo)
- `local.management.env` - ms_level_up_management
- `local.auth.env` - ms_trivance_auth  
- `local.backoffice.env` - level_up_backoffice
- `local.mobile.env` - trivance-mobile

### 🧪 QA (Testing)
- `qa.management.env` - ms_level_up_management (QA)
- `qa.auth.env` - ms_trivance_auth (QA)
- `qa.backoffice.env` - level_up_backoffice (QA)  
- `qa.mobile.env` - trivance-mobile (QA)

### 🚀 PRODUCTION (Producción)
- `production.management.env` - ms_level_up_management (PROD)
- `production.auth.env` - ms_trivance_auth (PROD)
- `production.backoffice.env` - level_up_backoffice (PROD)
- `production.mobile.env` - trivance-mobile (PROD)

## 🔐 Seguridad

⚠️ **IMPORTANTE**: Este directorio contiene secrets reales
- ✅ Está en .gitignore (no se commitea)
- ✅ Debe configurarse manualmente en cada máquina
- ✅ Para compartir: usar método seguro (no email/slack)

## 🚀 Uso

```bash
# Cambiar environment
./trivance-dev-config/scripts/envs.sh switch local
./trivance-dev-config/scripts/envs.sh switch qa
./trivance-dev-config/scripts/envs.sh switch production

# Ver estado
./trivance-dev-config/scripts/envs.sh status
```
EOF

    # Crear templates básicos si no existen
    create_local_templates
    
    log_success "✅ Sistema de environments configurado"
    log_info "📁 Directorio: $ENVS_DIR"
    log_info "📖 Ver: $ENVS_DIR/README.md"
}

# 📝 Crear templates locales básicos
create_local_templates() {
    # Template Management
    if [[ ! -f "$ENVS_DIR/local.management.env" ]]; then
        cat > "$ENVS_DIR/local.management.env" << 'EOF'
# 🖥️ LOCAL - ms_level_up_management
PORT=3000
DATABASE_URL=postgresql://trivance_dev:trivance_dev_pass@localhost:5432/trivance_development
DB_MONGO=mongodb://localhost:27017/trivance_mgmt_development
JWTSECRET=dev_jwt_secret_mgmt_2024_secure_key_trivance
PASSWORDSECRET=dev_password_secret_mgmt_2024_trivance
ENCRYPTSECRET=dev_encrypt_secret_mgmt_2024_trivance
URLBACKOFFICE=http://localhost:5173
URLBACKEND=http://localhost:3000
# Agregar más variables según necesidad...
EOF
    fi
    
    # Template Auth
    if [[ ! -f "$ENVS_DIR/local.auth.env" ]]; then
        cat > "$ENVS_DIR/local.auth.env" << 'EOF'
# 🖥️ LOCAL - ms_trivance_auth
PORT=3001
DB_MONGO=mongodb://localhost:27017/trivance_auth_development
JWTSECRET=dev_jwt_secret_auth_2024_secure_key_trivance
PASSWORDSECRET=dev_password_secret_auth_2024_trivance
ENCRYPTSECRET=dev_encrypt_secret_auth_2024_trivance
# Agregar más variables según necesidad...
EOF
    fi
    
    # Template Backoffice
    if [[ ! -f "$ENVS_DIR/local.backoffice.env" ]]; then
        cat > "$ENVS_DIR/local.backoffice.env" << 'EOF'
# 🖥️ LOCAL - level_up_backoffice
VITE_API_URL=http://localhost:3000
VITE_AUTH_API_URL=http://localhost:3001
VITE_GRAPHQL_URL=http://localhost:3000/graphql
VITE_ENVIRONMENT=development
VITE_APP_NAME="Trivance Backoffice"
VITE_DEBUG=true
EOF
    fi
    
    # Template Mobile
    if [[ ! -f "$ENVS_DIR/local.mobile.env" ]]; then
        cat > "$ENVS_DIR/local.mobile.env" << 'EOF'
# 🖥️ LOCAL - trivance-mobile
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_AUTH_API_URL=http://localhost:3001
EXPO_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
EXPO_PUBLIC_ENVIRONMENT=development
EXPO_PUBLIC_APP_NAME="Trivance Mobile"
EXPO_PUBLIC_DEBUG=true
EOF
    fi
}

# 🔄 Cambiar environment
switch_environment() {
    local env="$1"
    
    log_header "🎛️ Cambiando a environment: $env"
    
    # Validar environment
    case "$env" in
        "local"|"qa"|"production")
            ;;
        *)
            log_error "Environment inválido: $env"
            log_info "Environments válidos: local, qa, production"
            exit 1
            ;;
    esac
    
    # Verificar archivos de configuración
    local missing_files=()
    
    local files=("$env.management.env" "$env.auth.env" "$env.backoffice.env" "$env.mobile.env")
    for file in "${files[@]}"; do
        if [[ ! -f "$ENVS_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Archivos de configuración faltantes en envs/:"
        for file in "${missing_files[@]}"; do
            log_error "  ❌ $file"
        done
        log_info ""
        log_info "💡 Para configurar $env environment:"
        log_info "   1. Copiar templates desde local:"
        for file in "${missing_files[@]}"; do
            local local_file="${file/$env/local}"
            log_info "      cp envs/$local_file envs/$file"
        done
        log_info "   2. Editar archivos con configuraciones de $env"
        log_info "   3. Ejecutar nuevamente: ./envs.sh switch $env"
        exit 1
    fi
    
    # Confirmar production
    if [[ "$env" = "production" ]]; then
        log_warning "⚠️  ADVERTENCIA: Cambiando a PRODUCTION environment"
        log_warning "⚠️  Esto configurará todos los servicios para PRODUCCIÓN REAL"
        read -p "¿Continuar? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Operación cancelada"
            exit 0
        fi
    fi
    
    # Copiar archivos .env
    log_info "📄 Copiando configuraciones de $env..."
    
    cp "$ENVS_DIR/$env.management.env" "$WORKSPACE_DIR/ms_level_up_management/.env"
    cp "$ENVS_DIR/$env.auth.env" "$WORKSPACE_DIR/ms_trivance_auth/.env"
    cp "$ENVS_DIR/$env.backoffice.env" "$WORKSPACE_DIR/level_up_backoffice/.env"
    cp "$ENVS_DIR/$env.mobile.env" "$WORKSPACE_DIR/trivance-mobile/.env"
    
    # Guardar environment actual
    echo "$env" > "$CONFIG_DIR/.current_environment"
    
    # Validación básica
    validate_basic "$env"
    
    log_success "✅ Environment cambiado exitosamente a: $env"
    log_info "🚀 Para iniciar servicios: ./scripts/start-all-services.sh"
}

# 🔍 Validación básica
validate_basic() {
    local env="$1"
    
    log_info "🔍 Validando configuración básica..."
    
    # Verificar que archivos .env existen
    local services=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    for service in "${services[@]}"; do
        local env_file="$WORKSPACE_DIR/$service/.env"
        if [[ ! -f "$env_file" ]]; then
            log_error "❌ Archivo .env no encontrado: $env_file"
            exit 1
        fi
    done
    
    # Validaciones específicas por environment
    case "$env" in
        "local")
            # Verificar que usa localhost
            if ! grep -q "localhost" "$WORKSPACE_DIR/ms_level_up_management/.env"; then
                log_warning "⚠️  Local environment no parece usar localhost"
            fi
            ;;
        "production")
            # Verificar que NO usa localhost
            if grep -q "localhost" "$WORKSPACE_DIR/ms_level_up_management/.env"; then
                log_error "🚨 Production environment no puede usar localhost"
                exit 1
            fi
            ;;
    esac
    
    log_success "✅ Validación básica completada"
}

# 📊 Mostrar status
show_status() {
    log_header "📊 Trivance Environments - Status"
    
    # Environment actual
    local current_env="unknown"
    if [[ -f "$CONFIG_DIR/.current_environment" ]]; then
        current_env=$(cat "$CONFIG_DIR/.current_environment")
    fi
    
    echo -e "🎛️  Environment Actual: ${GREEN}$current_env${NC}"
    echo ""
    
    # Estado de archivos .env
    echo "📄 Estado de archivos .env:"
    local services=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    for service in "${services[@]}"; do
        local env_file="$WORKSPACE_DIR/$service/.env"
        if [[ -f "$env_file" ]]; then
            local modified=$(stat -f "%Sm" "$env_file" 2>/dev/null || stat -c "%y" "$env_file" 2>/dev/null || echo "unknown")
            echo -e "  ${GREEN}✅${NC} $service (modificado: $modified)"
        else
            echo -e "  ${RED}❌${NC} $service (sin .env)"
        fi
    done
    echo ""
    
    # Servicios corriendo
    echo "🚀 Servicios corriendo:"
    local port_3000=$(lsof -ti:3000 2>/dev/null || true)
    local port_3001=$(lsof -ti:3001 2>/dev/null || true)
    local port_5173=$(lsof -ti:5173 2>/dev/null || true)
    
    echo -e "  Puerto 3000 (Management): $([ -n "$port_3000" ] && echo -e "${GREEN}✅ Corriendo${NC}" || echo -e "${RED}❌ Detenido${NC}")"
    echo -e "  Puerto 3001 (Auth): $([ -n "$port_3001" ] && echo -e "${GREEN}✅ Corriendo${NC}" || echo -e "${RED}❌ Detenido${NC}")"
    echo -e "  Puerto 5173 (Frontend): $([ -n "$port_5173" ] && echo -e "${GREEN}✅ Corriendo${NC}" || echo -e "${RED}❌ Detenido${NC}")"
    echo ""
    
    # Configuraciones disponibles
    echo "📁 Configuraciones disponibles en envs/:"
    if [[ -d "$ENVS_DIR" ]]; then
        for env_file in "$ENVS_DIR"/*.env; do
            if [[ -f "$env_file" ]]; then
                local filename=$(basename "$env_file")
                echo -e "  ${GREEN}✅${NC} $filename"
            fi
        done
    else
        echo -e "  ${RED}❌${NC} Directorio envs/ no encontrado (ejecutar: ./envs.sh setup)"
    fi
}

# 📋 Mostrar ayuda
show_help() {
    cat << EOF
🎛️ Trivance Environments - Script Maestro

COMANDOS:
  setup               Configurar sistema de environments por primera vez
  switch <env>        Cambiar a environment específico
  status              Mostrar estado actual del sistema
  help                Mostrar esta ayuda

ENVIRONMENTS:
  local              Desarrollo local (localhost)
  qa                 Testing y validación
  production         Producción (requiere confirmación)

EJEMPLOS:
  $0 setup                    # Configuración inicial
  $0 switch local             # Cambiar a desarrollo local
  $0 switch qa                # Cambiar a QA
  $0 switch production        # Cambiar a producción
  $0 status                   # Ver estado actual

ARCHIVOS DE CONFIGURACIÓN:
  envs/local.*.env           Configuraciones locales
  envs/qa.*.env              Configuraciones QA (crear manualmente)  
  envs/production.*.env      Configuraciones producción (crear manualmente)

SEGURIDAD:
  • Directorio envs/ está en .gitignore (no se commitea)
  • Configuraciones QA/Production deben crearse manualmente
  • Usar método seguro para compartir secrets (no email/slack)

DOCUMENTACIÓN:
  📖 Ver: envs/README.md después de ejecutar setup
EOF
}

# 🚀 Función principal
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "setup")
            setup_environment_system
            ;;
        "switch")
            if [[ $# -eq 0 ]]; then
                log_error "Environment requerido para comando switch"
                log_info "Uso: $0 switch <environment>"
                exit 1
            fi
            check_dependencies
            switch_environment "$1"
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "Comando desconocido: $command"
            show_help
            exit 1
            ;;
    esac
}

# 🚀 Ejecutar
main "$@"