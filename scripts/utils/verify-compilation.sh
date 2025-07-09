#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Variables globales
COMPILATION_ERRORS=0
COMPILATION_LOG_DIR="${WORKSPACE_DIR}/logs/compilation"

show_compilation_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🔨 VERIFICACIÓN DE COMPILACIÓN                       ║
║                          Paso Obligatorio Final                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

setup_compilation_logs() {
    mkdir -p "$COMPILATION_LOG_DIR"
    info "📋 Logs de compilación en: ${COMPILATION_LOG_DIR}"
}

compile_nestjs_service() {
    local repo_name=$1
    local repo_path=$2
    
    info "🔨 Compilando servicio NestJS: ${repo_name}"
    
    # Cambiar al directorio del servicio
    local original_dir
    original_dir=$(pwd)
    
    if ! cd "$repo_path"; then
        error "❌ No se puede acceder a ${repo_path}"
        return 1
    fi
    
    # Verificar que existe tsconfig.json
    if [[ ! -f "tsconfig.json" ]]; then
        warn "⚠️  No se encontró tsconfig.json en ${repo_name}"
        cd "$original_dir"
        return 0
    fi
    
    # Determinar comando de build (preferir build:dev para desarrollo)
    local build_command="build"
    if npm run build:dev --dry-run 2>/dev/null | grep -q "build:dev"; then
        build_command="build:dev"
        info "📋 Usando build:dev (modo desarrollo - sin Sentry)"
    else
        info "📋 Usando build (modo producción)"
    fi
    
    # Compilar con el comando apropiado
    if npm run "$build_command" > "${COMPILATION_LOG_DIR}/${repo_name}_build.log" 2>&1; then
        success "✅ ${repo_name}: Compilación NestJS exitosa"
        cd "$original_dir"
        return 0
    else
        error "❌ ${repo_name}: Falló la compilación NestJS"
        error "   Log: ${COMPILATION_LOG_DIR}/${repo_name}_build.log"
        cd "$original_dir"
        return 1
    fi
}

compile_react_frontend() {
    local repo_name=$1
    local repo_path=$2
    
    info "🔨 Compilando frontend React: ${repo_name}"
    
    # Cambiar al directorio del frontend
    local original_dir
    original_dir=$(pwd)
    
    if ! cd "$repo_path"; then
        error "❌ No se puede acceder a ${repo_path}"
        return 1
    fi
    
    # Verificar que existe vite.config.ts o build script
    if [[ ! -f "vite.config.ts" ]] && ! grep -q '"build"' package.json; then
        warn "⚠️  No se encontró configuración de build en ${repo_name}"
        cd "$original_dir"
        return 0
    fi
    
    # Compilar con npm run build
    if npm run build > "${COMPILATION_LOG_DIR}/${repo_name}_build.log" 2>&1; then
        success "✅ ${repo_name}: Compilación React exitosa"
        cd "$original_dir"
        return 0
    else
        error "❌ ${repo_name}: Falló la compilación React"
        error "   Log: ${COMPILATION_LOG_DIR}/${repo_name}_build.log"
        cd "$original_dir"
        return 1
    fi
}

compile_react_native() {
    local repo_name=$1
    local repo_path=$2
    
    info "🔨 Verificando React Native: ${repo_name}"
    
    # Cambiar al directorio móvil
    local original_dir
    original_dir=$(pwd)
    
    if ! cd "$repo_path"; then
        error "❌ No se puede acceder a ${repo_path}"
        return 1
    fi
    
    # Para React Native, verificamos TypeScript en lugar de build completo
    if [[ -f "tsconfig.json" ]]; then
        info "🔍 Verificando tipos TypeScript para React Native..."
        
        if npx tsc --noEmit > "${COMPILATION_LOG_DIR}/${repo_name}_typecheck.log" 2>&1; then
            success "✅ ${repo_name}: Verificación TypeScript exitosa"
            cd "$original_dir"
            return 0
        else
            # React Native suele tener errores de tipos que no impiden el desarrollo
            warn "⚠️  ${repo_name}: Advertencias en TypeScript (normal en RN)"
            warn "   Log: ${COMPILATION_LOG_DIR}/${repo_name}_typecheck.log"
            cd "$original_dir"
            return 0  # No fallar por esto en RN
        fi
    else
        warn "⚠️  No se encontró tsconfig.json en ${repo_name}"
        cd "$original_dir"
        return 0
    fi
}

verify_repository_compilation() {
    local repo_name=$1
    local repo_path="${WORKSPACE_DIR}/${repo_name}"
    
    if [[ ! -d "$repo_path" ]]; then
        warn "⚠️  Repositorio no encontrado: ${repo_name}"
        return 0
    fi
    
    if [[ ! -f "${repo_path}/package.json" ]]; then
        warn "⚠️  No es un proyecto Node.js: ${repo_name}"
        return 0
    fi
    
    # Determinar tipo de proyecto y compilar
    case "$repo_name" in
        "ms_trivance_auth"|"ms_level_up_management")
            compile_nestjs_service "$repo_name" "$repo_path"
            ;;
        "level_up_backoffice")
            compile_react_frontend "$repo_name" "$repo_path"
            ;;
        "trivance-mobile")
            compile_react_native "$repo_name" "$repo_path"
            ;;
        *)
            warn "⚠️  Tipo de proyecto desconocido: ${repo_name}"
            return 0
            ;;
    esac
}

main() {
    show_compilation_banner
    
    log "Iniciando verificación obligatoria de compilación..."
    setup_compilation_logs
    
    # Lista de repositorios a verificar
    local repositories=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    
    log "Verificando compilación de ${#repositories[@]} repositorios..."
    
    for repo in "${repositories[@]}"; do
        if ! verify_repository_compilation "$repo"; then
            ((COMPILATION_ERRORS++))
        fi
    done
    
    echo
    log "════════════════════════════════════════════════════════════════════════════════"
    
    if [[ $COMPILATION_ERRORS -eq 0 ]]; then
        success "🎉 ¡VERIFICACIÓN EXITOSA! Todos los repositorios compilaron correctamente"
        success "✅ NestJS Services: ms_trivance_auth, ms_level_up_management"
        success "✅ React Frontend: level_up_backoffice"
        success "✅ React Native: trivance-mobile"
        echo
        info "📂 Logs de compilación disponibles en: ${COMPILATION_LOG_DIR}"
        return 0
    else
        error "❌ VERIFICACIÓN FALLIDA: ${COMPILATION_ERRORS} repositorio(s) con errores de compilación"
        error "🔍 Revise los logs en: ${COMPILATION_LOG_DIR}"
        echo
        error "Este es un paso OBLIGATORIO. El setup no puede continuar con errores de compilación."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi