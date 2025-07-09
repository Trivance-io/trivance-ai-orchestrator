#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

show_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                           🚀 TRIVANCE DEV CONFIG                            ║
║                     Configuración Automatizada de Desarrollo                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

main() {
    local start_time
    start_time=$(date +%s)
    
    show_banner
    
    log "Iniciando configuración automatizada del entorno de desarrollo Trivance"
    log "Workspace: ${WORKSPACE_DIR}"
    
    # Paso 1: Validar configuración
    log "PASO 1/7: Validando configuración del entorno"
    validate_configuration
    
    # Paso 2: Clonar repositorios
    log "PASO 2/7: Clonando repositorios"
    clone_repositories
    
    # Paso 3: Configurar entornos
    log "PASO 3/7: Configurando variables de entorno"
    generate_secure_secrets
    setup_environments
    
    # Paso 4: Instalar dependencias
    log "PASO 4/7: Instalando dependencias en paralelo (MAX 3 min total)"
    install_dependencies
    
    # Paso 5: Configurar herramientas
    log "PASO 5/7: Configurando herramientas de desarrollo"
    setup_tools
    
    # Paso 6: Aplicar fixes automáticos
    log "PASO 6/7: Aplicando fixes automáticos para desarrollo"
    apply_post_setup_fixes
    
    # Paso 7: Verificar compilación
    log "PASO 7/7: OBLIGATORIO - Verificando compilación de todos los repositorios"
    verify_compilation
    
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    success "🎉 ¡Configuración completada en ${minutes}m ${seconds}s!"
    echo
    success "✅ Todos los repositorios han sido clonados y configurados"
    success "✅ Variables de entorno generadas automáticamente"
    success "✅ Dependencias instaladas en paralelo (3min total)"
    success "✅ Herramientas de desarrollo configuradas"
    success "✅ Compilación verificada para todos los repositorios"
    echo
    info "📂 Workspace de VS Code: ${WORKSPACE_DIR}/TrivancePlatform.code-workspace"
    info "📋 Documentación Claude: ${WORKSPACE_DIR}/CLAUDE.md"
    info "📖 Documentación Environments: ${WORKSPACE_DIR}/envs/ENVIRONMENTS.md"
    info "🚀 Referencia de comandos: ${WORKSPACE_DIR}/trivance-dev-config/docs/COMMANDS.md"
    echo
    info "🔧 Para comenzar:"
    echo "   ./start.sh"
    echo
    
    # Run validation tests
    if [[ -f "${SCRIPT_DIR}/../utils/validate-setup.sh" ]]; then
        echo
        log "Ejecutando validación del setup..."
        if "${SCRIPT_DIR}/../utils/validate-setup.sh"; then
            success "✅ Validación completa exitosa"
        else
            warn "⚠️  Algunas validaciones fallaron, revisa los logs"
        fi
    fi
}

validate_configuration() {
    log "Validando archivos de configuración y prerequisitos..."
    
    # Check configuration files
    if [[ ! -f "${SCRIPT_DIR}/../../config/repositories.json" ]]; then
        error "Archivo repositories.json no encontrado"
        exit 1
    fi
    
    if [[ ! -f "${SCRIPT_DIR}/../../config/environments.json" ]]; then
        error "Archivo environments.json no encontrado"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        error "Git no está instalado"
        exit 1
    fi
    
    # Check Node.js version
    if ! command -v node &> /dev/null; then
        error "Node.js no está instalado"
        exit 1
    fi
    
    local node_version=$(node --version | sed 's/v//')
    local required_version="18.0.0"
    if [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" != "$required_version" ]; then
        error "Node.js version $node_version is below minimum required version $required_version"
        exit 1
    fi
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        warn "⚠️  PostgreSQL no encontrado - Management API requerirá configuración manual"
    fi
    
    # Check MongoDB
    if ! command -v mongod &> /dev/null && ! command -v mongosh &> /dev/null; then
        warn "⚠️  MongoDB no encontrado - Auth Service requerirá configuración manual"
    fi
    
    if ! command -v npm &> /dev/null; then
        error "npm no está instalado"
        exit 1
    fi
    
    success "✅ Configuración validada correctamente"
}

clone_repositories() {
    log "Clonando repositorios desde configuración..."
    
    local repos_config="${SCRIPT_DIR}/../../config/repositories.json"
    
    # Leer cada repositorio del JSON
    while IFS= read -r repo_data; do
        if [[ -n "$repo_data" && "$repo_data" != "null" ]]; then
            local repo_name repo_url repo_branch
            repo_name=$(echo "$repo_data" | jq -r '.name')
            repo_url=$(echo "$repo_data" | jq -r '.url')
            repo_branch=$(echo "$repo_data" | jq -r '.branch // "experiments"')
            
            if [[ ! -d "${WORKSPACE_DIR}/${repo_name}" ]]; then
                info "📥 Clonando ${repo_name} (rama: ${repo_branch})..."
                if git clone -b "$repo_branch" "$repo_url" "${WORKSPACE_DIR}/${repo_name}" --quiet; then
                    success "✅ ${repo_name} clonado exitosamente"
                else
                    error "❌ Error al clonar ${repo_name}"
                    exit 1
                fi
            else
                info "📁 ${repo_name} ya existe, omitiendo..."
            fi
        fi
    done < <(jq -c '.repositories[]' "$repos_config")
}

setup_environments() {
    log "Configurando sistema de environments automáticamente..."
    
    # 1. Configurar sistema de environments (nuevo)
    info "🎛️ Configurando sistema de gestión de environments..."
    if "${SCRIPT_DIR}/../envs.sh" setup; then
        success "✅ Sistema de environments configurado"
    else
        warn "⚠️ Error configurando sistema de environments"
    fi
    
    # 2. Cambiar a environment local por defecto
    info "🔧 Configurando environment local por defecto..."
    if "${SCRIPT_DIR}/../envs.sh" switch local; then
        success "✅ Environment local configurado"
    else
        # Fallback al método anterior si hay problemas
        warn "⚠️ Usando método de configuración legacy..."
        setup_environments_legacy
    fi
}

setup_environments_legacy() {
    local env_config="${SCRIPT_DIR}/../../config/environments.json"
    
    # Configurar cada repositorio (método anterior)
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    
    for repo in "${repos[@]}"; do
        local repo_path="${WORKSPACE_DIR}/${repo}"
        
        if [[ -d "$repo_path" ]]; then
            info "🔧 Configurando entorno para ${repo}..."
            
            local env_file="${repo_path}/.env"
            
            # Obtener variables específicas del repositorio
            local env_vars
            env_vars=$(jq -r --arg repo "$repo" '.environments[$repo] // .environments.default' "$env_config")
            
            if [[ "$env_vars" != "null" ]]; then
                echo "# Archivo .env generado automáticamente por trivance-dev-config" > "$env_file"
                echo "# $(date)" >> "$env_file"
                echo "" >> "$env_file"
                
                # Replace hardcoded secrets with generated ones
                echo "$env_vars" | jq -r 'to_entries[] | "\(.key)=\(.value)"' | while IFS='=' read -r key value; do
                    case "$key" in
                        JWTSECRET)
                            if [[ "$repo" == "ms_trivance_auth" ]]; then
                                echo "$key=${AUTH_JWT_SECRET:-$value}" >> "$env_file"
                            else
                                echo "$key=${MGMT_JWT_SECRET:-$value}" >> "$env_file"
                            fi
                            ;;
                        PASSWORDSECRET)
                            if [[ "$repo" == "ms_trivance_auth" ]]; then
                                echo "$key=${AUTH_PASSWORD_SECRET:-$value}" >> "$env_file"
                            else
                                echo "$key=${MGMT_PASSWORD_SECRET:-$value}" >> "$env_file"
                            fi
                            ;;
                        ENCRYPTSECRET)
                            if [[ "$repo" == "ms_trivance_auth" ]]; then
                                echo "$key=${AUTH_ENCRYPT_SECRET:-$value}" >> "$env_file"
                            else
                                echo "$key=${MGMT_ENCRYPT_SECRET:-$value}" >> "$env_file"
                            fi
                            ;;
                        EMAILAPIKEY)
                            echo "$key=${EMAIL_API_KEY:-$value}" >> "$env_file"
                            ;;
                        S3AWSAPIKEY)
                            echo "$key=${AWS_ACCESS_KEY:-$value}" >> "$env_file"
                            ;;
                        S3AWSSECRETKEY)
                            echo "$key=${AWS_SECRET_KEY:-$value}" >> "$env_file"
                            ;;
                        FIREBASE_PRIVATE_KEY)
                            echo "$key=\"${FIREBASE_PRIVATE_KEY:-$value}\"" >> "$env_file"
                            ;;
                        *)
                            echo "$key=$value" >> "$env_file"
                            ;;
                    esac
                done
                
                success "✅ Archivo .env creado para ${repo}"
            else
                warn "⚠️  No se encontraron variables de entorno para ${repo}"
            fi
        fi
    done
}

generate_secure_secrets() {
    log "Generando secrets seguros para desarrollo..."
    
    local secrets_file="${WORKSPACE_DIR}/.trivance-secrets"
    
    # Check if secrets already exist
    if [[ -f "$secrets_file" ]]; then
        info "Secrets ya existen, usando existentes..."
        source "$secrets_file"
        return 0
    fi
    
    # Generate secrets using the utility script
    if [[ -f "${SCRIPT_DIR}/../utils/generate-secrets.sh" ]]; then
        source "${SCRIPT_DIR}/../utils/generate-secrets.sh"
        generate_all_secrets "$secrets_file"
        
        # Load generated secrets
        set -a
        source "$secrets_file"
        set +a
        
        success "✅ Secrets de desarrollo generados de forma segura"
        info "📄 Secrets guardados en: $secrets_file"
        warn "⚠️  NO comitas este archivo a git"
    else
        warn "⚠️  Script de generación de secrets no encontrado, usando valores por defecto"
    fi
}

install_dependencies() {
    log "Instalando dependencias en paralelo para mayor velocidad..."
    
    # Usar instalación paralela para reducir tiempo total
    if "${SCRIPT_DIR}/../utils/parallel-install.sh"; then
        success "✅ Instalación paralela completada"
    else
        warn "⚠️  Instalación paralela falló, intentando método secuencial..."
        
        # Fallback: instalación secuencial tradicional
        local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
        
        for repo in "${repos[@]}"; do
            local repo_path="${WORKSPACE_DIR}/${repo}"
            
            if [[ -d "$repo_path" ]] && [[ -f "${repo_path}/package.json" ]]; then
                install_dependencies_for_repo "$repo" "$repo_path"
            fi
        done
    fi
}

setup_tools() {
    log "Configurando herramientas de desarrollo..."
    
    # Crear workspace de VS Code
    local workspace_template="${SCRIPT_DIR}/../../templates/TrivancePlatform.code-workspace.template"
    local workspace_file="${WORKSPACE_DIR}/TrivancePlatform.code-workspace"
    
    if [[ -f "$workspace_template" ]]; then
        cp "$workspace_template" "$workspace_file"
        success "✅ Workspace de VS Code configurado"
    fi
    
    # Crear .gitignore del workspace
    local gitignore_template="${SCRIPT_DIR}/../../templates/.gitignore.workspace"
    local gitignore_file="${WORKSPACE_DIR}/.gitignore"
    
    if [[ -f "$gitignore_template" ]] && [[ ! -f "$gitignore_file" ]]; then
        cp "$gitignore_template" "$gitignore_file"
        success "✅ .gitignore del workspace configurado"
    fi
    
    # Crear archivo CLAUDE.md
    local claude_template="${SCRIPT_DIR}/../../templates/CLAUDE.md.template"
    local claude_file="${WORKSPACE_DIR}/CLAUDE.md"
    
    if [[ -f "$claude_template" ]]; then
        cp "$claude_template" "$claude_file"
        success "✅ Archivo CLAUDE.md configurado"
    fi
    
    # Crear README.md principal desde template
    local readme_template="${SCRIPT_DIR}/../../templates/README.md.template"
    local readme_file="${WORKSPACE_DIR}/README.md"
    
    if [[ -f "$readme_template" ]]; then
        cp "$readme_template" "$readme_file"
        success "✅ Archivo README.md configurado"
    else
        # Fallback al README dinámico si existe
        local readme_dynamic="${SCRIPT_DIR}/../../templates/dynamic/README.workspace.template"
        if [[ -f "$readme_dynamic" ]]; then
            envsubst < "$readme_dynamic" > "$readme_file"
            success "✅ README del workspace configurado (dinámico)"
        fi
    fi
    
    # Copiar documentación de environments a la carpeta envs/
    local envs_doc_source="${SCRIPT_DIR}/../../docs/ENVIRONMENTS.md"
    local envs_doc_target="${WORKSPACE_DIR}/envs/ENVIRONMENTS.md"
    
    if [[ -f "$envs_doc_source" ]]; then
        # Asegurar que existe el directorio envs/
        mkdir -p "${WORKSPACE_DIR}/envs"
        cp "$envs_doc_source" "$envs_doc_target"
        success "✅ Documentación ENVIRONMENTS.md copiada a envs/"
    fi
    
    # Crear UN SOLO comando en la raíz
    info "🔗 Creando comando principal..."
    
    # Solo UN comando: start.sh
    ln -sf "trivance-dev-config/scripts/start.sh" "${WORKSPACE_DIR}/start.sh"
    
    # Hacer ejecutable
    chmod +x "${WORKSPACE_DIR}/start.sh" 2>/dev/null || true
    
    success "✅ Comando principal disponible"
    info "   - ./start.sh : Sistema de gestión unificado"
    info "   - Ejecuta ./start.sh para ver todas las opciones"
    
    # Crear estructura .claude mínima para Claude Code
    info "🤖 Configurando Claude Code..."
    local claude_dir="${SCRIPT_DIR}/../../.claude"
    mkdir -p "$claude_dir"
    
    # Crear settings.json para Claude
    cat > "${claude_dir}/settings.json" << 'EOF'
{
  "language": "es",
  "workspace": "multi-repo",
  "autoApprove": [
    "npm run",
    "npm install",
    "git status",
    "git diff",
    "cd",
    "ls",
    "pwd",
    "node --version",
    "npm --version"
  ],
  "repositories": [
    "ms_level_up_management",
    "ms_trivance_auth", 
    "level_up_backoffice",
    "trivance-mobile"
  ],
  "developmentMode": true,
  "aiFirst": true
}
EOF
    
    # Crear context.md básico
    cat > "${claude_dir}/context.md" << 'EOF'
# Contexto del Proyecto Trivance Platform

## Arquitectura Multi-Repositorio
- **ms_level_up_management**: Backend principal (NestJS + GraphQL)
- **ms_trivance_auth**: Servicio de autenticación (NestJS + MongoDB)
- **level_up_backoffice**: Frontend administrativo (React + Vite)
- **trivance-mobile**: Aplicación móvil (React Native + Expo)

## Tecnologías Principales
- Backend: NestJS, TypeScript, PostgreSQL, MongoDB
- Frontend: React, Vite, Redux Toolkit, Material-UI
- Mobile: React Native, Expo, TypeScript
- Herramientas: Docker, Jest, ESLint, Prettier

## Convenciones
- Código en inglés, comentarios y documentación en español
- Conventional Commits en español
- Pruebas unitarias obligatorias para nuevas features
EOF
    
    success "✅ Configuración de Claude Code creada"
    
    # Crear COMMANDS.md en la carpeta de documentación de trivance-dev-config
    cat > "${SCRIPT_DIR}/../../docs/COMMANDS.md" << 'EOF'
# 🚀 COMANDOS RÁPIDOS TRIVANCE

## ⚡ Comandos Simplificados

```bash
# Iniciar todos los servicios con validación
./start-services.sh

# Verificar estado de todos los servicios
./check-health.sh

# Cambiar de environment
./change-env.sh switch local
./change-env.sh switch qa
./change-env.sh switch production

# Ver estado actual del environment
./change-env.sh status

# Ejecutar setup completo
./setup.sh
```

## 📁 Comandos Originales (Rutas Completas)

```bash
# Smart Start con diagnóstico
./trivance-dev-config/scripts/utils/smart-start.sh

# Health Check con auto-fix
./trivance-dev-config/scripts/utils/health-check.sh
./trivance-dev-config/scripts/utils/health-check.sh fix

# Gestión de Environments
./trivance-dev-config/scripts/envs.sh setup
./trivance-dev-config/scripts/envs.sh switch [local|qa|production]
./trivance-dev-config/scripts/envs.sh status

# Limpieza del workspace
./trivance-dev-config/scripts/utils/clean-workspace.sh

# Verificar compilación
./trivance-dev-config/scripts/utils/verify-compilation.sh
```

## 🔧 Comandos por Servicio

### Backend Management API
```bash
cd ms_level_up_management
npm run start:dev      # Desarrollo con hot-reload
npm run build          # Compilar para producción
npm run test           # Ejecutar tests
npm run lint           # Verificar código
```

### Auth Service
```bash
cd ms_trivance_auth
npm run start:dev      # Desarrollo con hot-reload
npm run build          # Compilar para producción
npm run test           # Ejecutar tests
```

### Frontend Admin
```bash
cd level_up_backoffice
npm run dev            # Desarrollo con Vite
npm run build          # Build para producción
npm run preview        # Preview del build
npm run lint           # Verificar código
```

### Mobile App
```bash
cd trivance-mobile
npm start              # Iniciar Expo
npm run android        # Ejecutar en Android
npm run ios            # Ejecutar en iOS
npm run build          # Build con EAS
```

## 🌐 URLs de Desarrollo

- **Management API**: http://localhost:3000
- **GraphQL Playground**: http://localhost:3000/graphql
- **Auth Service**: http://localhost:3001
- **Auth Swagger**: http://localhost:3001/api-docs
- **Frontend Admin**: http://localhost:5173
- **Mobile Metro**: http://localhost:8081

## 💡 Tips

- Usa `./check-health.sh fix` para resolver problemas automáticamente
- Cambia environments con `./change-env.sh switch [env]` antes de iniciar
- Los logs se guardan en `./logs/` para debugging
- Ejecuta `./setup.sh` si necesitas reconfigurar todo desde cero
EOF
    
    success "✅ Archivo COMMANDS.md creado en docs/"
}

apply_post_setup_fixes() {
    log "Aplicando fixes automáticos para problemas conocidos..."
    
    if "${SCRIPT_DIR}/../utils/post-setup-fixes.sh"; then
        success "✅ Fixes automáticos aplicados exitosamente"
    else
        warn "⚠️  Algunos fixes automáticos fallaron, pero continuando..."
    fi
    
    # Copiar guía de environments a cada repositorio
    local env_guide="${SCRIPT_DIR}/../../templates/REPO_ENV_GUIDE.md"
    if [[ -f "$env_guide" ]]; then
        log "📖 Distribuyendo guía de environments a los repositorios..."
        for repo in ms_level_up_management ms_trivance_auth level_up_backoffice trivance-mobile; do
            if [[ -d "${WORKSPACE_DIR}/${repo}" ]]; then
                cp "$env_guide" "${WORKSPACE_DIR}/${repo}/ENVIRONMENTS.md"
            fi
        done
        success "✅ Guía de environments distribuida"
    fi
}

verify_compilation() {
    log "OBLIGATORIO: Verificando compilación para todos los repositorios"
    
    cd "${WORKSPACE_DIR}"
    
    if "${SCRIPT_DIR}/../utils/verify-compilation.sh"; then
        success "✅ Todos los repositorios compilaron exitosamente!"
    else
        error "❌ La verificación de compilación falló!"
        error "Este es un paso obligatorio. Por favor revise los errores e intente nuevamente."
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi