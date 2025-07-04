#!/bin/bash

# Script para limpiar completamente el workspace de Trivance
# Elimina todos los repositorios clonados y archivos generados

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

show_clean_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                            🧹 LIMPIAR WORKSPACE                             ║
║                   Eliminar todos los repositorios clonados                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

confirm_cleanup() {
    echo
    warn "⚠️  ADVERTENCIA: Esta operación eliminará TODOS los repositorios clonados"
    warn "⚠️  Se eliminarán:"
    echo "   • ms_trivance_auth/"
    echo "   • ms_level_up_management/"
    echo "   • level_up_backoffice/"
    echo "   • trivance-mobile/"
    echo "   • logs/"
    echo "   • CLAUDE.md"
    echo "   • TrivancePlatform.code-workspace"
    echo "   • README.md del workspace"
    echo
    
    read -p "¿Estás seguro de que quieres continuar? [y/N]: " -r confirmation
    
    case "$confirmation" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            info "Operación cancelada por el usuario"
            exit 0
            ;;
    esac
}

clean_repositories() {
    log "Eliminando repositorios clonados..."
    
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local cleaned_count=0
    
    for repo in "${repos[@]}"; do
        local repo_path="${WORKSPACE_DIR}/${repo}"
        if [[ -d "$repo_path" ]]; then
            info "🗑️  Eliminando ${repo}..."
            
            # Forzar eliminación incluso si hay archivos bloqueados
            chmod -R u+w "$repo_path" 2>/dev/null || true
            rm -rf "$repo_path"
            
            if [[ ! -d "$repo_path" ]]; then
                success "✅ ${repo} eliminado exitosamente"
                ((cleaned_count++))
            else
                error "❌ No se pudo eliminar ${repo}"
            fi
        else
            info "📁 ${repo} no existe, omitiendo..."
        fi
    done
    
    log "Repositorios limpiados: ${cleaned_count}/${#repos[@]}"
}

clean_generated_files() {
    log "Eliminando archivos generados..."
    
    local files_to_clean=(
        "${WORKSPACE_DIR}/logs"
        "${WORKSPACE_DIR}/CLAUDE.md"
        "${WORKSPACE_DIR}/TrivancePlatform.code-workspace"
        "${WORKSPACE_DIR}/README.md"
    )
    
    local cleaned_count=0
    
    for file_path in "${files_to_clean[@]}"; do
        local file_name
        file_name=$(basename "$file_path")
        
        if [[ -e "$file_path" ]]; then
            info "🗑️  Eliminando ${file_name}..."
            
            if [[ -d "$file_path" ]]; then
                rm -rf "$file_path"
            else
                rm -f "$file_path"
            fi
            
            if [[ ! -e "$file_path" ]]; then
                success "✅ ${file_name} eliminado exitosamente"
                ((cleaned_count++))
            else
                error "❌ No se pudo eliminar ${file_name}"
            fi
        else
            info "📁 ${file_name} no existe, omitiendo..."
        fi
    done
    
    log "Archivos generados limpiados: ${cleaned_count}/${#files_to_clean[@]}"
}

clean_vscode_settings() {
    log "Limpiando configuraciones temporales de VS Code..."
    
    local vscode_paths=(
        "${WORKSPACE_DIR}/.vscode"
    )
    
    for vscode_path in "${vscode_paths[@]}"; do
        if [[ -d "$vscode_path" ]]; then
            # Solo eliminar archivos específicos, no toda la carpeta .vscode
            local temp_files=(
                "${vscode_path}/.trivance-temp"
                "${vscode_path}/workspace-cache"
            )
            
            for temp_file in "${temp_files[@]}"; do
                if [[ -e "$temp_file" ]]; then
                    rm -rf "$temp_file"
                    info "🗑️  Configuración temporal de VS Code eliminada"
                fi
            done
        fi
    done
}

clean_node_modules() {
    log "Buscando y eliminando node_modules residuales..."
    
    # Buscar node_modules que puedan haber quedado
    while IFS= read -r -d '' node_modules_path; do
        local parent_dir
        parent_dir=$(dirname "$node_modules_path")
        local repo_name
        repo_name=$(basename "$parent_dir")
        
        # Solo eliminar si el parent es uno de nuestros repos
        case "$repo_name" in
            "ms_trivance_auth"|"ms_level_up_management"|"level_up_backoffice"|"trivance-mobile")
                info "🗑️  Eliminando node_modules residual en ${repo_name}..."
                rm -rf "$node_modules_path"
                success "✅ node_modules eliminado de ${repo_name}"
                ;;
        esac
    done < <(find "$WORKSPACE_DIR" -name "node_modules" -type d -print0 2>/dev/null)
}

verify_cleanup() {
    log "Verificando limpieza del workspace..."
    
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local remaining_repos=0
    
    # Verificar que no queden repositorios
    for repo in "${repos[@]}"; do
        if [[ -d "${WORKSPACE_DIR}/${repo}" ]]; then
            warn "⚠️  ${repo} aún existe después de la limpieza"
            ((remaining_repos++))
        fi
    done
    
    # Verificar que no queden archivos generados principales
    local generated_files=("CLAUDE.md" "TrivancePlatform.code-workspace" "logs")
    local remaining_files=0
    
    for file in "${generated_files[@]}"; do
        if [[ -e "${WORKSPACE_DIR}/${file}" ]]; then
            warn "⚠️  ${file} aún existe después de la limpieza"
            ((remaining_files++))
        fi
    done
    
    # Mostrar resultado de verificación
    if [[ $remaining_repos -eq 0 && $remaining_files -eq 0 ]]; then
        success "✅ Workspace limpiado completamente"
        return 0
    else
        error "❌ Limpieza incompleta: ${remaining_repos} repos + ${remaining_files} archivos restantes"
        return 1
    fi
}

show_post_cleanup_info() {
    echo
    log "════════════════════════════════════════════════════════════════════════════════"
    success "🎉 ¡Workspace limpiado exitosamente!"
    log "════════════════════════════════════════════════════════════════════════════════"
    echo
    info "📂 Estado actual del workspace:"
    
    # Mostrar estructura actual
    if command -v tree >/dev/null 2>&1; then
        tree "$WORKSPACE_DIR" -L 2 -a -I '.git'
    else
        ls -la "$WORKSPACE_DIR"
    fi
    
    echo
    info "🔄 Para volver a configurar el entorno:"
    echo "   cd $(basename "$WORKSPACE_DIR")/trivance-dev-config"
    echo "   ./setup.sh"
    echo
}

main() {
    local start_time
    start_time=$(date +%s)
    
    show_clean_banner
    
    # Validar que estamos en el workspace correcto
    if [[ ! -d "${WORKSPACE_DIR}/trivance-dev-config" ]]; then
        error "❌ No se encontró trivance-dev-config en el workspace"
        error "   Workspace esperado: ${WORKSPACE_DIR}"
        exit 1
    fi
    
    # Confirmar con el usuario
    confirm_cleanup
    
    log "Iniciando limpieza del workspace: ${WORKSPACE_DIR}"
    
    # Ejecutar limpieza paso a paso
    clean_repositories
    clean_generated_files
    clean_vscode_settings
    clean_node_modules
    
    # Verificar que todo se limpió correctamente
    if verify_cleanup; then
        local end_time duration
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        show_post_cleanup_info
        info "⏱️  Tiempo total de limpieza: ${duration} segundos"
    else
        error "❌ La limpieza no se completó correctamente"
        error "   Revise los mensajes de advertencia anteriores"
        exit 1
    fi
}

# Función para limpieza silenciosa (sin confirmación)
silent_clean() {
    log "Ejecutando limpieza silenciosa..."
    
    clean_repositories
    clean_generated_files
    clean_vscode_settings
    clean_node_modules
    
    if verify_cleanup; then
        success "✅ Limpieza silenciosa completada"
    else
        error "❌ Limpieza silenciosa falló"
        return 1
    fi
}

# Manejar argumentos de línea de comandos
case "${1:-interactive}" in
    "silent"|"--silent"|"-s")
        silent_clean
        ;;
    "help"|"--help"|"-h")
        echo "Limpiador de workspace para trivance-dev-config"
        echo ""
        echo "Uso: $0 [OPCIÓN]"
        echo ""
        echo "Opciones:"
        echo "  (sin argumentos)  Limpieza interactiva con confirmación"
        echo "  silent, -s        Limpieza silenciosa sin confirmación"
        echo "  help, -h          Mostrar esta ayuda"
        echo ""
        echo "Ejemplos:"
        echo "  $0                # Limpieza interactiva"
        echo "  $0 silent         # Limpieza automática"
        ;;
    *)
        main "$@"
        ;;
esac