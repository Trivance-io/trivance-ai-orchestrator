#!/bin/bash

# Post-setup fixes para repositorios clonados
# Aplica correcciones automáticas para problemas conocidos en desarrollo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

show_fixes_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🔧 POST-SETUP FIXES AUTOMÁTICOS                        ║
║                   Aplicando correcciones para desarrollo                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

# Fix para ms_level_up_management: Sentry opcional en desarrollo
fix_sentry_build_command() {
    local repo_path="${WORKSPACE_DIR}/ms_level_up_management"
    
    if [[ ! -d "$repo_path" ]]; then
        warn "⚠️  ms_level_up_management no encontrado, omitiendo fix de Sentry"
        return 0
    fi
    
    local package_json="${repo_path}/package.json"
    
    if [[ ! -f "$package_json" ]]; then
        warn "⚠️  package.json no encontrado en ms_level_up_management"
        return 0
    fi
    
    info "🔧 Aplicando fix de Sentry para ms_level_up_management..."
    
    # Verificar si ya tiene build:dev
    if grep -q '"build:dev"' "$package_json"; then
        success "✅ build:dev ya existe en ms_level_up_management"
        return 0
    fi
    
    # Crear backup
    cp "$package_json" "${package_json}.backup"
    
    # Aplicar fix usando sed para agregar build:dev después de build
    if sed -i '' 's/"build": "nest build && npm run sentry:sourcemaps",/"build": "nest build \&\& npm run sentry:sourcemaps",\
    "build:dev": "nest build",/' "$package_json"; then
        success "✅ Fix de Sentry aplicado a ms_level_up_management"
        info "   • Agregado script build:dev sin Sentry para desarrollo"
        return 0
    else
        error "❌ Error aplicando fix de Sentry"
        # Restaurar backup
        mv "${package_json}.backup" "$package_json"
        return 1
    fi
}

# Fix para variables de entorno con valores de desarrollo robustos
fix_development_env_values() {
    info "🔧 Verificando valores de variables de entorno para desarrollo..."
    
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    
    for repo in "${repos[@]}"; do
        local env_file="${WORKSPACE_DIR}/${repo}/.env"
        
        if [[ -f "$env_file" ]]; then
            # Verificar que Firebase esté configurado para desarrollo
            if [[ "$repo" == "ms_level_up_management" ]]; then
                if grep -q "FIREBASE_PROJECT_ID=development-project" "$env_file"; then
                    success "✅ ${repo}: Variables Firebase configuradas para desarrollo"
                else
                    warn "⚠️  ${repo}: Valores Firebase podrían necesitar ajuste"
                fi
            fi
        fi
    done
}

# Fix para configuración TypeScript en React Native (opcional)
fix_react_native_typescript() {
    local repo_path="${WORKSPACE_DIR}/trivance-mobile"
    
    if [[ ! -d "$repo_path" ]]; then
        warn "⚠️  trivance-mobile no encontrado, omitiendo fix de TypeScript"
        return 0
    fi
    
    local tsconfig="${repo_path}/tsconfig.json"
    
    if [[ -f "$tsconfig" ]]; then
        info "🔧 Verificando configuración TypeScript de React Native..."
        
        # Verificar configuraciones comunes que pueden causar warnings
        if grep -q '"strict": true' "$tsconfig"; then
            info "   📋 TypeScript en modo strict (warnings esperados en RN)"
        fi
        
        success "✅ trivance-mobile: Configuración TypeScript verificada"
    fi
}

# Fix para puertos ocupados (verificación)
fix_port_conflicts() {
    info "🔧 Verificando conflictos de puertos..."
    
    local ports=(3000 3001 5173)
    local conflicts=0
    
    for port in "${ports[@]}"; do
        if lsof -i:"$port" >/dev/null 2>&1; then
            warn "⚠️  Puerto $port está ocupado"
            ((conflicts++))
        fi
    done
    
    if [[ $conflicts -eq 0 ]]; then
        success "✅ Todos los puertos están disponibles"
    else
        warn "⚠️  Encontrados $conflicts conflictos de puerto - servicios podrían no iniciar"
        info "   💡 Ejecuta 'killall node' para liberar puertos Node.js"
    fi
}

# Aplicar todos los fixes
apply_all_fixes() {
    show_fixes_banner
    
    log "Aplicando fixes automáticos para desarrollo..."
    
    # Fix crítico: Sentry en ms_level_up_management
    fix_sentry_build_command
    
    # Verificaciones adicionales
    fix_development_env_values
    fix_react_native_typescript
    fix_port_conflicts
    
    success "✅ Todos los fixes post-setup completados"
}

main() {
    apply_all_fixes
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi