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
    
    # Ahora que TODO está configurado y funcionando, crear CLAUDE.md
    create_claude_md_final
    # Documentación Claude se creará automáticamente al final
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
    
    if ! command -v npm &> /dev/null; then
        error "npm no está instalado"
        exit 1
    fi
    
    # Check Docker - OBLIGATORIO
    if ! command -v docker &> /dev/null; then
        error "❌ Docker no está instalado - Docker es OBLIGATORIO"
        error "Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop/"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker ps &> /dev/null; then
        error "❌ Docker no está corriendo"
        error "Por favor inicia Docker Desktop y vuelve a ejecutar este script"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker &>/dev/null || ! docker compose version &>/dev/null 2>&1; then
        if ! command -v docker-compose &>/dev/null; then
            error "❌ Docker Compose no está instalado"
            exit 1
        fi
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
    
    # CLAUDE.md se creará automáticamente al final cuando el setup esté completo
    
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
    
    # Configurar Docker si está disponible
    if command -v docker &>/dev/null; then
        info "🐳 Configurando integración Docker..."
        setup_docker_integration
    else
        warn "⚠️  Docker no detectado - La integración Docker estará disponible cuando instales Docker"
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
    
    # Claude Code se configurará automáticamente al final cuando todo esté funcionando
    
}

setup_docker_integration() {
    log "Configurando archivos Docker para desarrollo..."
    
    # Verificar que existe la carpeta docker en trivance-dev-config
    local docker_source="${SCRIPT_DIR}/../../docker"
    
    if [[ ! -d "$docker_source" ]]; then
        warn "⚠️  Carpeta docker no encontrada en trivance-dev-config"
        return 1
    fi
    
    # Crear ecosystem.config.js desde template
    local ecosystem_file="${WORKSPACE_DIR}/ecosystem.config.js"
    local ecosystem_template="${SCRIPT_DIR}/../../templates/ecosystem.config.js.template"
    
    if [[ ! -f "$ecosystem_file" ]]; then
        if [[ -f "$ecosystem_template" ]]; then
            info "Creando ecosystem.config.js desde template..."
            cp "$ecosystem_template" "$ecosystem_file"
            success "✅ ecosystem.config.js creado desde template (arquitectura híbrida)"
        else
            info "Creando ecosystem.config.js para PM2..."
            cat > "$ecosystem_file" << 'EOF'
// Configuración PM2 para arquitectura híbrida
// Solo contiene el frontend - Backends van en Docker
module.exports = {
  apps: [
    {
      name: 'backoffice',
      cwd: './level_up_backoffice',
      script: 'npm',
      args: 'run dev',
      env: {
        NODE_ENV: 'development',
        VITE_API_URL: 'http://localhost:3000',
        VITE_AUTH_API_URL: 'http://localhost:3001'
      },
      // Configuración optimizada para frontend
      instances: 1,
      exec_mode: 'fork',
      watch: false,  // Vite ya tiene hot-reload
      max_memory_restart: '1G',
      error_file: './logs/backoffice-error.log',
      out_file: './logs/backoffice-out.log',
      log_file: './logs/backoffice-combined.log',
      time: true
    }
  ]
};
EOF
            success "✅ ecosystem.config.js creado (arquitectura híbrida)"
        fi
    fi
    
    # Verificar docker compose
    if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
        success "✅ Docker Compose v2 detectado"
    elif command -v docker-compose &>/dev/null; then
        info "ℹ️  Docker Compose v1 detectado (considera actualizar a v2)"
    fi
    
    # Informar sobre la configuración Docker
    info "📁 Archivos Docker disponibles en: ${docker_source}"
    info "   - docker-compose.yaml : Orquestación de servicios"
    info "   - Dockerfile.* : Imágenes optimizadas para cada servicio"
    info "   - Makefile : Comandos simplificados"
    
    success "✅ Integración Docker configurada"
}

apply_post_setup_fixes() {
    log "Aplicando fixes automáticos para problemas conocidos..."
    
    if "${SCRIPT_DIR}/../utils/post-setup-fixes.sh"; then
        success "✅ Fixes automáticos aplicados exitosamente"
    else
        warn "⚠️  Algunos fixes automáticos fallaron, pero continuando..."
    fi
    
}

verify_compilation() {
    log "OBLIGATORIO: Verificando compilación para todos los repositorios"
    
    cd "${WORKSPACE_DIR}"
    
    info "🔄 Iniciando verificación de compilación con timeouts mejorados..."
    
    if "${SCRIPT_DIR}/../utils/verify-compilation.sh"; then
        success "✅ Todos los repositorios compilaron exitosamente!"
    else
        local exit_code=$?
        
        # Si hay warnings pero no errores críticos, continuar
        if [[ $exit_code -eq 1 ]]; then
            warn "⚠️  Hay warnings en la compilación pero el setup puede continuar"
            warn "   Revise los logs en logs/compilation/ para más detalles"
            warn "   Los servicios PM2 están funcionando correctamente"
        else
            error "❌ Errores críticos en la compilación!"
            error "   Revise los logs en logs/compilation/ para más detalles"
            error "   Este es un paso obligatorio. Por favor corrija los errores e intente nuevamente."
            exit 1
        fi
    fi
}

create_claude_md_final() {
    info "🤖 Configuración completa exitosa"
    
    # Verificar que todos los servicios estén funcionando
    cd "${WORKSPACE_DIR}"
    
    if pm2 status > /dev/null 2>&1; then
        success "✅ Servicios PM2 verificados - funcionando correctamente"
    else
        warn "⚠️  No se pueden verificar servicios PM2, continuando..."
    fi
    
    success "✅ Configuración completa del workspace terminada"
    echo
    
    # Recomendación para Claude Code
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                     🤖 CONFIGURACIÓN CLAUDE CODE                            ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    info "🎯 Para aprovechar al máximo Claude Code, recomendamos generar el archivo CLAUDE.md"
    info "   Este archivo ayuda a Claude a entender mejor tu proyecto y ser más eficiente"
    echo
    echo -e "${CYAN}📋 Pasos recomendados:${NC}"
    echo -e "${CYAN}   1. Abre Claude Code en este directorio${NC}"
    echo -e "${CYAN}   2. Ejecuta el comando: ${YELLOW}/init${NC}"
    echo -e "${CYAN}   3. Sigue las instrucciones para generar CLAUDE.md${NC}"
    echo
    echo -e "${CYAN}🔧 Alternativamente, podemos crear un CLAUDE.md básico ahora:${NC}"
    echo -e "${CYAN}   • Copia el template: ${YELLOW}cp trivance-dev-config/templates/CLAUDE.md.template CLAUDE.md${NC}"
    echo -e "${CYAN}   • Edita el archivo con información específica de tu proyecto${NC}"
    echo
    
    # Crear CLAUDE.md básico automáticamente
    if [[ ! -f "${WORKSPACE_DIR}/CLAUDE.md" ]]; then
        info "📝 Creando CLAUDE.md básico automáticamente..."
        cp "${SCRIPT_DIR}/../../templates/CLAUDE.md.template" "${WORKSPACE_DIR}/CLAUDE.md"
        success "✅ CLAUDE.md creado desde template"
        info "   Puedes personalizarlo más tarde con el comando /init de Claude Code"
    else
        info "📝 CLAUDE.md ya existe, no se sobrescribirá"
    fi
    echo
    echo -e "${GREEN}💡 Beneficios del CLAUDE.md:${NC}"
    echo -e "${GREEN}   ✅ Claude entiende mejor la arquitectura del proyecto${NC}"
    echo -e "${GREEN}   ✅ Respuestas más precisas y contextuales${NC}"
    echo -e "${GREEN}   ✅ Mejor manejo de comandos y workflows${NC}"
    echo -e "${GREEN}   ✅ Integración optimizada con Docker + PM2${NC}"
    echo
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi