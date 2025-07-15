#!/bin/bash

# 🎛️ TRIVANCE ENVIRONMENTS - VERSIÓN MEJORADA CON SINCRONIZACIÓN
# Script maestro que sincroniza automáticamente con environments.json
# 
# Mejoras implementadas:
#   - Sincronización automática con environments.json
#   - Validación completa de variables requeridas
#   - Comando diff para comparar environments
#   - Comando sync para actualizar templates
#   - Mejor documentación de variables

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
readonly ENV_CONFIG="$CONFIG_DIR/config/environments.json"

# 📝 Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${PURPLE}$1${NC}"; echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# 🔍 Verificar dependencias
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq no está instalado. Instalando..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            log_warning "Se requiere instalar jq. Se necesitarán permisos de administrador."
            read -p "¿Deseas continuar con la instalación? (s/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Ss]$ ]]; then
                sudo apt-get install -y jq
            else
                log_error "Instalación cancelada. jq es requerido para continuar."
                exit 1
            fi
        fi
    fi
    
    if [[ ! -f "$ENV_CONFIG" ]]; then
        log_error "Archivo environments.json no encontrado: $ENV_CONFIG"
        exit 1
    fi
}

# 🏗️ Setup inicial del sistema
setup_environment_system() {
    log_header "🏗️ Configurando sistema de environments mejorado..."
    
    check_dependencies
    
    # Crear directorio envs si no existe
    mkdir -p "$ENVS_DIR"
    
    # Copiar ENVIRONMENTS.md desde docs/ a envs/
    local env_docs="${CONFIG_DIR}/docs/ENVIRONMENTS.md"
    if [[ -f "$env_docs" ]]; then
        cp "$env_docs" "$ENVS_DIR/ENVIRONMENTS.md"
        log_info "📖 Documentación ENVIRONMENTS.md copiada a envs/"
    else
        log_warning "⚠️  No se encontró docs/ENVIRONMENTS.md"
    fi

    # Generar templates desde environments.json
    generate_templates_from_json
    
    log_success "✅ Sistema de environments configurado"
    log_info "📁 Directorio: $ENVS_DIR"
    log_info "📖 Documentación: $ENVS_DIR/ENVIRONMENTS.md"
    log_info "🔄 Templates sincronizados con environments.json"
}

# 📝 Generar templates desde environments.json
generate_templates_from_json() {
    log_info "📝 Generando templates desde environments.json..."
    
    # Cargar o generar secrets si no existen
    local secrets_file="$WORKSPACE_DIR/.trivance-secrets"
    if [[ ! -f "$secrets_file" ]]; then
        log_info "🔑 Generando secrets seguros..."
        "$SCRIPT_DIR/utils/generate-secrets.sh" "$secrets_file"
    fi
    
    # Cargar secrets en el entorno
    set -a
    source "$secrets_file"
    set +a
    
    # Función helper para procesar valores
    process_env_value() {
        local key="$1"
        local value="$2"
        
        case "$value" in
            "__GENERATE_SECURE__")
                # Mapear a la variable de secrets correspondiente
                case "$key" in
                    "JWTSECRET") echo "${MGMT_JWT_SECRET:-$(openssl rand -hex 32)}" ;;
                    "PASSWORDSECRET") echo "${MGMT_PASSWORD_SECRET:-$(openssl rand -hex 32)}" ;;
                    "ENCRYPTSECRET") echo "${MGMT_ENCRYPT_SECRET:-$(openssl rand -hex 32)}" ;;
                    "ENCRYPTSECRETBACKOFFICE") echo "${BACKOFFICE_ENCRYPT_SECRET:-$(openssl rand -hex 32)}" ;;
                    "ENCRYPTCARD") echo "${CARD_ENCRYPT_KEY:-$(openssl rand -hex 32)}" ;;
                    "SECRETEMAIL") echo "${MGMT_SECRET_EMAIL:-$(openssl rand -hex 24)}" ;;
                    "EMAILAPIKEY") echo "${EMAIL_API_KEY:-$(openssl rand -hex 24)}" ;;
                    *) echo "$(openssl rand -hex 32)" ;;
                esac
                ;;
            "__OPTIONAL__")
                echo ""
                ;;
            "__DEV_SAFE_FIREBASE__")
                echo "${DEV_FIREBASE_API_KEY:-AIzaSyDEV-safe-key}"
                ;;
            "__DEV_SAFE_RECAPTCHA__")
                echo "${DEV_RECAPTCHA_KEY:-6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI}"
                ;;
            *)
                echo "$value"
                ;;
        esac
    }
    
    # ms_level_up_management
    log_info "  - Generando local.management.env"
    {
        echo "# 🖥️ LOCAL - ms_level_up_management"
        echo "# Generado automáticamente desde environments.json"
        echo "# $(date)"
        echo "# ⚠️ Para QA/Prod: copiar este archivo y actualizar valores"
        echo ""
        
        # Procesar cada variable
        jq -r '.environments.ms_level_up_management | to_entries[] | "\(.key)|\(.value)"' "$ENV_CONFIG" | while IFS='|' read -r key value; do
            processed_value=$(process_env_value "$key" "$value")
            echo "# $(echo "$key" | tr '_' ' ' | tr '[:upper:]' '[:lower:]')"
            echo "$key=$processed_value"
            echo ""
        done
        
        # Agregar NODE_ENV
        echo "# Environment mode"
        echo "NODE_ENV=development"
    } > "$ENVS_DIR/local.management.env"
    
    # ms_trivance_auth
    log_info "  - Generando local.auth.env"
    {
        echo "# 🖥️ LOCAL - ms_trivance_auth"
        echo "# Generado automáticamente desde environments.json"
        echo "# $(date)"
        echo "# ⚠️ Para QA/Prod: copiar este archivo y actualizar valores"
        echo ""
        
        # Procesar cada variable para auth
        jq -r '.environments.ms_trivance_auth | to_entries[] | "\(.key)|\(.value)"' "$ENV_CONFIG" | while IFS='|' read -r key value; do
            # Mapeo especial para auth service
            case "$value" in
                "__GENERATE_SECURE__")
                    case "$key" in
                        "JWTSECRET") processed_value="${AUTH_JWT_SECRET:-$(openssl rand -hex 32)}" ;;
                        "PASSWORDSECRET") processed_value="${AUTH_PASSWORD_SECRET:-$(openssl rand -hex 32)}" ;;
                        "ENCRYPTSECRET") processed_value="${AUTH_ENCRYPT_SECRET:-$(openssl rand -hex 32)}" ;;
                        "SECRETEMAIL") processed_value="${AUTH_SECRET_EMAIL:-$(openssl rand -hex 24)}" ;;
                        *) processed_value=$(process_env_value "$key" "$value") ;;
                    esac
                    ;;
                *)
                    processed_value=$(process_env_value "$key" "$value")
                    ;;
            esac
            echo "# $(echo "$key" | tr '_' ' ' | tr '[:upper:]' '[:lower:]')"
            echo "$key=$processed_value"
            echo ""
        done
        
        echo "# Environment mode"
        echo "NODE_ENV=development"
    } > "$ENVS_DIR/local.auth.env"
    
    # level_up_backoffice
    log_info "  - Generando local.backoffice.env"
    {
        echo "# 🖥️ LOCAL - level_up_backoffice"
        echo "# Generado automáticamente"
        echo "# $(date)"
        echo "# ⚠️ Para QA/Prod: copiar este archivo y actualizar valores"
        echo ""
        
        # Si hay configuración específica en JSON, usarla
        if jq -e '.environments.level_up_backoffice' "$ENV_CONFIG" > /dev/null 2>&1; then
            # Procesar cada variable para frontend
            jq -r '.environments.level_up_backoffice | to_entries[] | "\(.key)|\(.value)"' "$ENV_CONFIG" | while IFS='|' read -r key value; do
                # Mapeo especial para frontend
                case "$value" in
                    "__GENERATE_SECURE__")
                        case "$key" in
                            "VITE_APP_SECRET_KEY") processed_value="${FRONTEND_APP_SECRET:-$(openssl rand -hex 32)}" ;;
                            *) processed_value=$(process_env_value "$key" "$value") ;;
                        esac
                        ;;
                    *)
                        processed_value=$(process_env_value "$key" "$value")
                        ;;
                esac
                echo "# $(echo "$key" | tr '_' ' ' | tr '[:upper:]' '[:lower:]')"
                echo "$key=$processed_value"
                echo ""
            done
        else
            # Valores por defecto para frontend
            cat << 'EOF'
# API endpoints
VITE_API_URL=http://localhost:3000
VITE_AUTH_API_URL=http://localhost:3001
VITE_GRAPHQL_URL=http://localhost:3000/graphql

# App configuration
VITE_APP_NAME=Trivance Admin Panel
VITE_APP_VERSION=1.0.0
VITE_APP_ENV=development

# Features
VITE_DEBUG_MODE=true
VITE_MOCK_API=false

# Optional services
# VITE_SENTRY_DSN=
# VITE_GOOGLE_MAPS_API_KEY=
EOF
        fi
    } > "$ENVS_DIR/local.backoffice.env"
    
    # trivance-mobile
    log_info "  - Generando local.mobile.env"
    {
        echo "# 🖥️ LOCAL - trivance-mobile"
        echo "# Generado automáticamente"
        echo "# $(date)"
        echo "# ⚠️ Para QA/Prod: copiar este archivo y actualizar valores"
        echo ""
        
        if jq -e '.environments["trivance-mobile"]' "$ENV_CONFIG" > /dev/null 2>&1; then
            # Procesar cada variable para mobile
            jq -r '.environments["trivance-mobile"] | to_entries[] | "\(.key)|\(.value)"' "$ENV_CONFIG" | while IFS='|' read -r key value; do
                processed_value=$(process_env_value "$key" "$value")
                echo "# $(echo "$key" | tr '_' ' ' | tr '[:upper:]' '[:lower:]')"
                echo "$key=$processed_value"
                echo ""
            done
        else
            cat << 'EOF'
# API endpoints
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_AUTH_API_URL=http://localhost:3001

# App configuration
EXPO_PUBLIC_ENVIRONMENT=development
EXPO_PUBLIC_APP_NAME=Trivance Mobile
EXPO_PUBLIC_APP_VERSION=1.0.0

# Features
EXPO_PUBLIC_DEBUG_MODE=true
EXPO_PUBLIC_MOCK_API=false

# Optional services
# EXPO_PUBLIC_SENTRY_DSN=
# EXPO_PUBLIC_FIREBASE_CONFIG=
EOF
        fi
    } > "$ENVS_DIR/local.mobile.env"
    
    # Crear templates vacíos para QA y Production como guía
    create_environment_templates "qa"
    create_environment_templates "production"
}

# 📱 Generar env.local.ts para aplicación mobile
generate_mobile_env_local() {
    local env="$1"
    
    # Obtener configuración del archivo .env de mobile
    local mobile_env_file="$WORKSPACE_DIR/trivance-mobile/.env"
    
    if [[ ! -f "$mobile_env_file" ]]; then
        log_warning "⚠️  No se encontró archivo .env de mobile app"
        return 1
    fi
    
    # Directorio de environments de mobile
    local mobile_env_dir="$WORKSPACE_DIR/trivance-mobile/src/environments"
    mkdir -p "$mobile_env_dir"
    
    # Generar env.local.ts
    local env_local_file="$mobile_env_dir/env.local.ts"
    
    log_info "  - Generando env.local.ts desde configuración de $env"
    
    # Leer variables del archivo .env
    local api_url=$(grep "^EXPO_PUBLIC_API_URL=" "$mobile_env_file" | cut -d'=' -f2-)
    local auth_api_url=$(grep "^EXPO_PUBLIC_AUTH_API_URL=" "$mobile_env_file" | cut -d'=' -f2-)
    local tenant=$(grep "^EXPO_PUBLIC_TENANT=" "$mobile_env_file" | cut -d'=' -f2-)
    local environment=$(grep "^EXPO_PUBLIC_ENVIRONMENT=" "$mobile_env_file" | cut -d'=' -f2-)
    local debug=$(grep "^EXPO_PUBLIC_DEBUG=" "$mobile_env_file" | cut -d'=' -f2-)
    local env_local=$(grep "^ENV_LOCAL=" "$mobile_env_file" | cut -d'=' -f2-)
    local env_qa=$(grep "^ENV_QA=" "$mobile_env_file" | cut -d'=' -f2-)
    local env_production=$(grep "^ENV_PRODUCTION=" "$mobile_env_file" | cut -d'=' -f2-)
    
    # Generar el archivo TypeScript
    {
        echo "export const environment = {"
        echo "  API_URL: '${api_url:-http://localhost:3000}',"
        echo "  API_URL_AUTH: '${auth_api_url:-http://localhost:3001}',"
        echo "  TENANT_TRIVANCE: '${tenant:-U2FsdGVkX1/mRzvnBo5dtb/ArZnjxiU2KdRzHb2s7kw=}',"
        echo "  // Local development configuration"
        echo "  development: ${debug:-true},"
        echo "  local: ${env_local:-true},"
        echo "  production: ${env_production:-false},"
        echo "  // Additional local config"
        echo "  API_TIMEOUT: 30000,"
        echo "  ENABLE_API_LOGS: ${debug:-true},"
        echo "  ENABLE_REDUX_LOGS: ${debug:-true},"
        echo "  SHOW_DEV_BANNER: ${debug:-true},"
        echo "  ENABLE_CRASHLYTICS: ${env_production:-false},"
        echo "  ENABLE_ANALYTICS: ${env_production:-false}"
        echo "};"
    } > "$env_local_file"
    
    log_success "✅ env.local.ts generado exitosamente"
    log_info "     📍 Ubicación: $env_local_file"
}

# 📋 Crear templates de environment como guía
create_environment_templates() {
    local env="$1"
    
    if [[ ! -f "$ENVS_DIR/$env.management.env" ]]; then
        log_info "  - Creando template $env.management.env"
        local env_upper=$(echo "$env" | tr '[:lower:]' '[:upper:]')
        sed "s/LOCAL/$env/g; s/localhost/\$${env_upper}_HOST/g; s/development/$env/g" \
            "$ENVS_DIR/local.management.env" > "$ENVS_DIR/$env.management.env.template"
    fi
}

# 🐳 Generar archivo de variables para Docker Compose
generate_docker_environment_file() {
    local env="$1"
    local docker_dir="$2"
    local docker_env_file="$docker_dir/.env"
    
    log_info "🐳 Generando variables Docker para environment: $env"
    
    # Determinar configuración específica por environment
    local node_env run_mode app_env docker_env_file_suffix docker_auth_env_file_suffix
    case "$env" in
        "local")
            node_env="production"
            run_mode="local"
            app_env="development"
            docker_env_file_suffix=".env.docker-local"
            docker_auth_env_file_suffix=".env.docker-auth-local"
            ;;
        "qa")
            node_env="production"
            run_mode="qa"
            app_env="qa"
            docker_env_file_suffix=".env.docker-qa"
            docker_auth_env_file_suffix=".env.docker-auth-qa"
            ;;
        "production")
            node_env="production"
            run_mode="production"
            app_env="production"
            docker_env_file_suffix=".env.docker-production"
            docker_auth_env_file_suffix=".env.docker-auth-production"
            ;;
        *)
            log_error "Environment no soportado: $env"
            return 1
            ;;
    esac
    
    # Generar archivo .env para docker-compose
    {
        echo "# 🐳 Docker Environment Variables for $env"
        echo "# Generado automáticamente - $(date)"
        echo "# Variables para docker-compose.yaml"
        echo ""
        echo "# Environment Configuration"
        echo "NODE_ENV=$node_env"
        echo "RUN_MODE=$run_mode"
        echo "APP_ENV=$app_env"
        echo ""
        echo "# Docker Environment Files"
        echo "DOCKER_ENV_FILE=$docker_env_file_suffix"
        echo "DOCKER_AUTH_ENV_FILE=$docker_auth_env_file_suffix"
        echo ""
        echo "# Database Configuration (for Docker hostnames)"
        case "$env" in
            "local")
                echo "POSTGRES_DB=trivance_development"
                echo "POSTGRES_USER=trivance_dev"
                echo "POSTGRES_PASSWORD=trivance_dev_pass"
                ;;
            "qa")
                echo "POSTGRES_DB=trivance_qa"
                echo "POSTGRES_USER=trivance_qa_user"
                echo "POSTGRES_PASSWORD=\${QA_DB_PASSWORD:-trivance_qa_pass}"
                ;;
            "production")
                echo "POSTGRES_DB=trivance_production"
                echo "POSTGRES_USER=\${PROD_DB_USER:-trivance_prod}"
                echo "POSTGRES_PASSWORD=\${PROD_DB_PASSWORD:-CHANGE_ME}"
                ;;
        esac
    } > "$docker_env_file"
    
    # Aplicar permisos seguros
    chmod 600 "$docker_env_file"
    
    log_success "✅ Generado $docker_env_file"
    log_info "   - NODE_ENV: $node_env"
    log_info "   - RUN_MODE: $run_mode"  
    log_info "   - APP_ENV: $app_env"
    log_info "   - Docker env files configurados para $env"
}

# 🔄 Cambiar environment
switch_environment() {
    local env="$1"
    
    if [[ -z "$env" ]]; then
        log_error "Especifica un environment: local, qa, production"
        exit 1
    fi
    
    if [[ ! "$env" =~ ^(local|qa|production)$ ]]; then
        log_error "Environment inválido: $env"
        exit 1
    fi
    
    log_header "🔄 Cambiando a environment: $env"
    
    # Verificar archivos necesarios
    local missing_files=()
    for service in "management" "auth" "backoffice" "mobile"; do
        if [[ ! -f "$ENVS_DIR/$env.$service.env" ]]; then
            missing_files+=("$env.$service.env")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Faltan archivos de configuración para $env:"
        for file in "${missing_files[@]}"; do
            echo "  ❌ $file"
        done
        
        if [[ "$env" != "local" ]]; then
            log_info ""
            log_info "Para crear configuraciones de $env:"
            log_info "   1. Copiar archivos locales como base:"
            for file in "${missing_files[@]}"; do
                local local_file="${file/$env/local}"
                log_info "      cp envs/$local_file envs/$file"
            done
            log_info "   2. Editar archivos con configuraciones reales de $env"
            log_info "   3. Ejecutar nuevamente: ./change-env.sh switch $env"
        fi
        exit 1
    fi
    
    # Confirmar production
    if [[ "$env" = "production" ]]; then
        log_warning "⚠️  ADVERTENCIA: Cambiando a PRODUCTION environment"
        log_warning "⚠️  Esto configurará todos los servicios para PRODUCCIÓN REAL"
        read -p "¿Estás seguro? Escribe 'yes' para confirmar: " -r
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
    
    # Generar env.local.ts para la aplicación mobile
    log_info "📱 Generando env.local.ts para aplicación mobile..."
    generate_mobile_env_local "$env"
    
    # Generar archivos Docker adaptados
    log_info "🐳 Generando configuraciones Docker para $env..."
    
    # Crear directorio docker si no existe
    local docker_dir="$CONFIG_DIR/docker"
    mkdir -p "$docker_dir"
    
    # Generar .env.docker-local para management
    if [[ -f "$ENVS_DIR/$env.management.env" ]]; then
        cp "$ENVS_DIR/$env.management.env" "$docker_dir/.env.docker-local"
        # Ajustar DATABASE_URL para usar hostname de Docker
        sed -i.bak 's|DATABASE_URL=postgresql://[^@]*@localhost:|DATABASE_URL=postgresql://trivance_dev:trivance_dev_pass@postgres:|g' "$docker_dir/.env.docker-local"
        # Ajustar DB_MONGO para usar hostname de Docker
        sed -i.bak 's|DB_MONGO=mongodb://localhost:|DB_MONGO=mongodb://mongodb:|g' "$docker_dir/.env.docker-local"
        rm -f "$docker_dir/.env.docker-local.bak"
        log_success "✅ Generado .env.docker-local"
    fi
    
    # Generar .env.docker-auth-local para auth
    if [[ -f "$ENVS_DIR/$env.auth.env" ]]; then
        cp "$ENVS_DIR/$env.auth.env" "$docker_dir/.env.docker-auth-local"
        # Ajustar DB_MONGO para usar hostname de Docker
        sed -i.bak 's|DB_MONGO=mongodb://localhost:|DB_MONGO=mongodb://mongodb:|g' "$docker_dir/.env.docker-auth-local"
        rm -f "$docker_dir/.env.docker-auth-local.bak"
        log_success "✅ Generado .env.docker-auth-local"
    fi
    
    # Generar variables de environment para docker-compose.yaml
    generate_docker_environment_file "$env" "$docker_dir"
    
    # Guardar environment actual
    echo "$env" > "$ENVS_DIR/.current_environment"
    
    # Aplicar permisos seguros a archivos .env
    log_info "🔒 Aplicando permisos seguros a archivos .env..."
    chmod 600 "$WORKSPACE_DIR/ms_level_up_management/.env" 2>/dev/null || true
    chmod 600 "$WORKSPACE_DIR/ms_trivance_auth/.env" 2>/dev/null || true
    chmod 600 "$WORKSPACE_DIR/level_up_backoffice/.env" 2>/dev/null || true
    chmod 600 "$WORKSPACE_DIR/trivance-mobile/.env" 2>/dev/null || true
    chmod 600 "$docker_dir/.env.docker-local" 2>/dev/null || true
    chmod 600 "$docker_dir/.env.docker-auth-local" 2>/dev/null || true
    
    # Validación completa
    validate_environment_config "$env"
    
    log_success "✅ Environment cambiado exitosamente a: $env"
    log_info "🚀 Para iniciar servicios: ./start-services.sh"
}

# 🔍 Validación completa de configuración
validate_environment_config() {
    local env="$1"
    
    log_info "🔍 Validando configuración completa..."
    
    # Variables críticas por servicio
    # Use regular variables for POSIX compatibility
    local critical_vars_management="PORT DATABASE_URL JWTSECRET PASSWORDSECRET ENCRYPTSECRET"
    local critical_vars_auth="PORT DB_MONGO JWTSECRET PASSWORDSECRET ENCRYPTSECRET"
    local critical_vars_backoffice="VITE_API_URL VITE_AUTH_API_URL"
    local critical_vars_mobile="EXPO_PUBLIC_API_URL EXPO_PUBLIC_AUTH_API_URL"
    # Variable assignment removed - using direct variables above
    
    local has_warnings=false
    
    # Validar cada servicio
    for service in ms_level_up_management ms_trivance_auth level_up_backoffice trivance-mobile; do
        local env_file="$WORKSPACE_DIR/$service/.env"
        
        if [[ ! -f "$env_file" ]]; then
            log_error "❌ Archivo .env no encontrado: $env_file"
            exit 1
        fi
        
        # Get critical vars for this service
        local vars_to_check=""
        case "$service" in
            "ms_level_up_management")
                vars_to_check="$critical_vars_management"
                ;;
            "ms_trivance_auth")
                vars_to_check="$critical_vars_auth"
                ;;
            "level_up_backoffice")
                vars_to_check="$critical_vars_backoffice"
                ;;
            "trivance-mobile")
                vars_to_check="$critical_vars_mobile"
                ;;
        esac
        
        # Verificar variables críticas
        for var in $vars_to_check; do
            if ! grep -q "^$var=" "$env_file"; then
                log_warning "  ⚠️  Variable crítica faltante en $service: $var"
                has_warnings=true
            elif grep -q "^$var=$" "$env_file"; then
                log_warning "  ⚠️  Variable crítica vacía en $service: $var"
                has_warnings=true
            fi
        done
    done
    
    # Validaciones específicas por environment
    case "$env" in
        "local")
            if ! grep -q "localhost" "$WORKSPACE_DIR/ms_level_up_management/.env"; then
                log_warning "  ⚠️  Local environment no está usando localhost"
                has_warnings=true
            fi
            ;;
        "production")
            if grep -q "localhost" "$WORKSPACE_DIR/ms_level_up_management/.env"; then
                log_error "🚨 Production environment no puede usar localhost"
                exit 1
            fi
            if grep -q "dev_" "$WORKSPACE_DIR/ms_level_up_management/.env"; then
                log_warning "  ⚠️  Production parece tener valores de desarrollo"
                has_warnings=true
            fi
            ;;
    esac
    
    if [[ "$has_warnings" = false ]]; then
        log_success "✅ Validación completa exitosa - sin problemas"
    else
        log_warning "⚠️  Validación completa con advertencias"
    fi
}

# 📊 Mostrar status detallado
show_status() {
    log_header "📊 Trivance Environments - Status Detallado"
    
    # Environment actual
    local current_env="unknown"
    if [[ -f "$ENVS_DIR/.current_environment" ]]; then
        current_env=$(cat "$ENVS_DIR/.current_environment")
    fi
    
    echo -e "🎛️  Environment Actual: ${GREEN}$current_env${NC}"
    echo ""
    
    # Estado de archivos .env
    echo "📄 Estado de archivos .env:"
    local services=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    for service in "${services[@]}"; do
        local env_file="$WORKSPACE_DIR/$service/.env"
        if [[ -f "$env_file" ]]; then
            local size=$(wc -c < "$env_file" | tr -d ' ')
            local lines=$(wc -l < "$env_file" | tr -d ' ')
            local modified=$(stat -f "%Sm" "$env_file" 2>/dev/null || stat -c "%y" "$env_file" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
            echo -e "  ${GREEN}✅${NC} $service"
            echo -e "     Tamaño: ${size} bytes | Líneas: ${lines} | Modificado: $modified"
        else
            echo -e "  ${RED}❌${NC} $service (sin .env)"
        fi
    done
    echo ""
    
    # Servicios corriendo
    echo "🚀 Servicios corriendo:"
    local ports=("3000:Management API" "3001:Auth Service" "5173:Frontend" "8081:Metro Bundler")
    
    for port_info in "${ports[@]}"; do
        local port="${port_info%%:*}"
        local name="${port_info#*:}"
        local pid=$(lsof -ti:$port 2>/dev/null || true)
        
        if [[ -n "$pid" ]]; then
            echo -e "  ${GREEN}✅${NC} Puerto $port ($name) - PID: $pid"
        else
            echo -e "  ${RED}❌${NC} Puerto $port ($name)"
        fi
    done
    echo ""
    
    # Configuraciones disponibles
    echo "📁 Configuraciones disponibles en envs/:"
    if [[ -d "$ENVS_DIR" ]]; then
        local envs=("local" "qa" "production")
        for env in "${envs[@]}"; do
            echo -e "\n  ${BLUE}Environment: $env${NC}"
            local all_exist=true
            for service in "management" "auth" "backoffice" "mobile"; do
                local env_file="$ENVS_DIR/$env.$service.env"
                if [[ -f "$env_file" ]]; then
                    echo -e "    ${GREEN}✅${NC} $env.$service.env"
                else
                    echo -e "    ${RED}❌${NC} $env.$service.env (no existe)"
                    all_exist=false
                fi
            done
            if [[ "$all_exist" = true ]]; then
                echo -e "    ${GREEN}Estado: Completo${NC}"
            else
                echo -e "    ${YELLOW}Estado: Incompleto${NC}"
            fi
        done
    else
        echo -e "  ${RED}❌${NC} Directorio envs/ no encontrado"
    fi
    
    # Información de sincronización
    echo ""
    echo "🔄 Sincronización con environments.json:"
    if [[ -f "$ENV_CONFIG" ]]; then
        local json_modified=$(stat -f "%Sm" "$ENV_CONFIG" 2>/dev/null || stat -c "%y" "$ENV_CONFIG" 2>/dev/null | cut -d' ' -f1)
        echo -e "  ${GREEN}✅${NC} environments.json encontrado"
        echo -e "     Modificado: $json_modified"
        
        # Verificar si templates están actualizados
        if [[ -f "$ENVS_DIR/local.management.env" ]]; then
            local template_modified=$(stat -f "%Sm" "$ENVS_DIR/local.management.env" 2>/dev/null || stat -c "%y" "$ENVS_DIR/local.management.env" 2>/dev/null | cut -d' ' -f1)
            echo -e "     Templates locales: $template_modified"
            
            # Comparar fechas (simplificado)
            if [[ "$json_modified" > "$template_modified" ]]; then
                echo -e "     ${YELLOW}⚠️  environments.json es más reciente - ejecutar: ./change-env.sh sync${NC}"
            fi
        fi
    else
        echo -e "  ${RED}❌${NC} environments.json no encontrado"
    fi
}

# 📋 Validar environment específico
validate_specific_environment() {
    local env="${1:-$current_env}"
    
    if [[ -z "$env" || "$env" = "unknown" ]]; then
        log_error "Especifica un environment para validar"
        exit 1
    fi
    
    log_header "🔍 Validando environment: $env"
    
    # Cambiar temporalmente
    local original_env=""
    if [[ -f "$ENVS_DIR/.current_environment" ]]; then
        original_env=$(cat "$ENVS_DIR/.current_environment")
    fi
    
    switch_environment "$env"
    
    # Restaurar environment original si es diferente
    if [[ -n "$original_env" && "$original_env" != "$env" ]]; then
        echo "$original_env" > "$ENVS_DIR/.current_environment"
    fi
}

# 📊 Comparar dos environments
compare_environments() {
    local env1="$1"
    local env2="$2"
    
    if [[ -z "$env1" ]] || [[ -z "$env2" ]]; then
        log_error "Uso: $0 diff <env1> <env2>"
        exit 1
    fi
    
    log_header "📊 Comparando $env1 vs $env2"
    
    local services=("management" "auth" "backoffice" "mobile")
    
    for service in "${services[@]}"; do
        local file1="$ENVS_DIR/$env1.$service.env"
        local file2="$ENVS_DIR/$env2.$service.env"
        
        if [[ ! -f "$file1" ]]; then
            log_warning "⚠️  No existe: $file1"
            continue
        fi
        
        if [[ ! -f "$file2" ]]; then
            log_warning "⚠️  No existe: $file2"
            continue
        fi
        
        echo ""
        log_info "🔍 Diferencias en $service:"
        echo ""
        
        # Extraer todas las variables únicas
        local all_vars=$(cat "$file1" "$file2" | grep -E "^[A-Z_]+=" | cut -d'=' -f1 | sort -u)
        
        local has_diff=false
        while IFS= read -r var; do
            if [[ -z "$var" ]]; then continue; fi
            
            local val1=$(grep "^$var=" "$file1" 2>/dev/null | cut -d'=' -f2- || echo "[NO EXISTE]")
            local val2=$(grep "^$var=" "$file2" 2>/dev/null | cut -d'=' -f2- || echo "[NO EXISTE]")
            
            if [[ "$val1" != "$val2" ]]; then
                has_diff=true
                echo -e "  ${YELLOW}$var:${NC}"
                
                # Ocultar valores sensibles en producción
                if [[ "$env1" = "production" || "$env2" = "production" ]] && [[ "$var" =~ (SECRET|KEY|PASSWORD|TOKEN) ]]; then
                    if [[ "$val1" != "[NO EXISTE]" ]]; then val1="[OCULTO]"; fi
                    if [[ "$val2" != "[NO EXISTE]" ]]; then val2="[OCULTO]"; fi
                fi
                
                echo -e "    $env1: ${GREEN}$val1${NC}"
                echo -e "    $env2: ${BLUE}$val2${NC}"
                echo ""
            fi
        done <<< "$all_vars"
        
        if [[ "$has_diff" = false ]]; then
            echo -e "  ${GREEN}✅ Sin diferencias${NC}"
        fi
    done
}

# 🔄 Sincronizar templates con environments.json
sync_templates() {
    log_header "🔄 Sincronizando templates con environments.json"
    
    check_dependencies
    
    # Respaldar configuraciones actuales
    local backup_dir="$ENVS_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    log_info "📦 Respaldando configuraciones actuales..."
    local backed_up=false
    for file in "$ENVS_DIR"/*.env; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            backed_up=true
        fi
    done
    
    if [[ "$backed_up" = true ]]; then
        log_success "✅ Respaldo creado en: $backup_dir"
    fi
    
    # Regenerar templates
    generate_templates_from_json
    
    log_success "✅ Templates sincronizados exitosamente"
    log_info ""
    log_info "📋 Próximos pasos:"
    log_info "   1. Revisar cambios en templates locales"
    log_info "   2. Ejecutar: ./change-env.sh switch local"
    log_info "   3. Para restaurar respaldo: cp $backup_dir/* $ENVS_DIR/"
}

# 📋 Mostrar ayuda mejorada
show_help() {
    cat << EOF
${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${PURPLE}🎛️  Trivance Environments - Sistema Mejorado${NC}
${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}COMANDOS DISPONIBLES:${NC}
  ${GREEN}setup${NC}               Configurar sistema por primera vez
  ${GREEN}switch <env>${NC}        Cambiar a environment específico  
  ${GREEN}status${NC}              Mostrar estado detallado del sistema
  ${GREEN}validate [env]${NC}      Validar configuración de environment
  ${GREEN}diff <env1> <env2>${NC}  Comparar dos environments
  ${GREEN}sync${NC}                Sincronizar templates con environments.json
  ${GREEN}help${NC}                Mostrar esta ayuda

${BLUE}ENVIRONMENTS:${NC}
  ${GREEN}local${NC}               Desarrollo local (localhost)
  ${GREEN}qa${NC}                  Testing y validación
  ${GREEN}production${NC}          Producción (requiere confirmación)

${BLUE}EJEMPLOS DE USO:${NC}
  $0 setup                    # Primera configuración
  $0 switch local             # Cambiar a desarrollo
  $0 switch qa                # Cambiar a QA
  $0 status                   # Ver estado completo
  $0 validate production      # Validar config de producción
  $0 diff local qa            # Comparar local vs QA
  $0 sync                     # Actualizar desde environments.json

${BLUE}ARCHIVOS DE CONFIGURACIÓN:${NC}
  ${YELLOW}envs/local.*.env${NC}           Auto-generados desde JSON
  ${YELLOW}envs/qa.*.env${NC}              Crear manualmente con secrets
  ${YELLOW}envs/production.*.env${NC}      Crear manualmente con secrets
  
${BLUE}FUENTE DE VERDAD:${NC}
  ${YELLOW}config/environments.json${NC}   Configuraciones para desarrollo

${BLUE}CARACTERÍSTICAS MEJORADAS:${NC}
  ✅ Sincronización automática con environments.json
  ✅ Validación completa de variables críticas
  ✅ Comparación visual entre environments
  ✅ Respaldo automático antes de cambios
  ✅ Documentación integrada de variables
  ✅ Detección de configuraciones desactualizadas

${BLUE}SEGURIDAD:${NC}
  🔒 El directorio envs/ está en .gitignore
  🔒 Nunca commitear archivos .env
  🔒 Valores sensibles ocultos en comparaciones
  🔒 Confirmación requerida para producción

${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
EOF
}

# 🚀 Lógica principal
main() {
    case "${1:-}" in
        "setup")
            setup_environment_system
            ;;
        "switch")
            switch_environment "${2:-}"
            ;;
        "status")
            show_status
            ;;
        "validate")
            validate_specific_environment "${2:-}"
            ;;
        "diff")
            compare_environments "${2:-}" "${3:-}"
            ;;
        "sync")
            sync_templates
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            log_error "Comando no reconocido: ${1:-}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"