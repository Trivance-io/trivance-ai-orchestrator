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
    echo
    info "🔧 Para iniciar los servicios:"
    echo "   • Auth Service: cd ms_trivance_auth && npm run start:dev"
    echo "   • Management API: cd ms_level_up_management && npm run start:dev"  
    echo "   • Frontend: cd level_up_backoffice && npm run dev"
    echo "   • Mobile: cd trivance-mobile && npm start"
}

validate_configuration() {
    log "Validando archivos de configuración..."
    
    if [[ ! -f "${SCRIPT_DIR}/../../config/repositories.json" ]]; then
        error "Archivo repositories.json no encontrado"
        exit 1
    fi
    
    if [[ ! -f "${SCRIPT_DIR}/../../config/environments.json" ]]; then
        error "Archivo environments.json no encontrado"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        error "Git no está instalado"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        error "Node.js no está instalado"
        exit 1
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
    log "Configurando variables de entorno automáticamente..."
    
    local env_config="${SCRIPT_DIR}/../../config/environments.json"
    
    # Configurar cada repositorio
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
                
                echo "$env_vars" | jq -r 'to_entries[] | "\(.key)=\(.value)"' >> "$env_file"
                
                success "✅ Archivo .env creado para ${repo}"
            else
                warn "⚠️  No se encontraron variables de entorno para ${repo}"
            fi
        fi
    done
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
    
    # Crear archivo CLAUDE.md
    local claude_template="${SCRIPT_DIR}/../../templates/CLAUDE.md.template"
    local claude_file="${WORKSPACE_DIR}/CLAUDE.md"
    
    if [[ -f "$claude_template" ]]; then
        cp "$claude_template" "$claude_file"
        success "✅ Archivo CLAUDE.md configurado"
    fi
    
    # Crear README dinámico del workspace
    local readme_template="${SCRIPT_DIR}/../../templates/dynamic/README.workspace.template"
    local readme_file="${WORKSPACE_DIR}/README.md"
    
    if [[ -f "$readme_template" ]]; then
        envsubst < "$readme_template" > "$readme_file"
        success "✅ README del workspace configurado"
    fi
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
    
    if "${SCRIPT_DIR}/../verify-compilation.sh"; then
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