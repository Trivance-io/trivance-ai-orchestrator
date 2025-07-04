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

# Fix para Firebase: Generar claves válidas para desarrollo
fix_firebase_credentials() {
    local repo_path="${WORKSPACE_DIR}/ms_level_up_management"
    
    if [[ ! -d "$repo_path" ]]; then
        warn "⚠️  ms_level_up_management no encontrado, omitiendo fix de Firebase"
        return 0
    fi
    
    local env_file="${repo_path}/.env"
    
    if [[ ! -f "$env_file" ]]; then
        warn "⚠️  .env no encontrado en ms_level_up_management"
        return 0
    fi
    
    info "🔧 Aplicando fix de Firebase para ms_level_up_management..."
    
    # Verificar si ya tiene credenciales Firebase válidas
    if grep -q "FIREBASE_PRIVATE_KEY.*BEGIN PRIVATE KEY" "$env_file"; then
        success "✅ Firebase ya tiene clave privada válida"
        return 0
    fi
    
    # Verificar si tiene el placeholder que necesita ser reemplazado
    if ! grep -q "PLACEHOLDER_WILL_BE_REPLACED_BY_POST_SETUP_FIX" "$env_file"; then
        success "✅ Firebase parece estar configurado (no es placeholder)"
        return 0
    fi
    
    # Generar clave privada temporal para desarrollo
    local temp_key_file="${repo_path}/temp_firebase_key.pem"
    
    if openssl genrsa -out "$temp_key_file" 2048 >/dev/null 2>&1; then
        local private_key
        private_key=$(cat "$temp_key_file" | tr '\n' '#')
        private_key=${private_key//#/\\n}
        
        # Actualizar variables Firebase en .env
        if sed -i '' "s|FIREBASE_PROJECT_ID=.*|FIREBASE_PROJECT_ID=trivance-dev-local|g" "$env_file" && \
           sed -i '' "s|FIREBASE_PRIVATE_KEY=.*|FIREBASE_PRIVATE_KEY=\"${private_key}\"|g" "$env_file" && \
           sed -i '' "s|FIREBASE_CLIENT_EMAIL=.*|FIREBASE_CLIENT_EMAIL=firebase-dev@trivance-dev.iam.gserviceaccount.com|g" "$env_file"; then
            
            success "✅ Fix de Firebase aplicado a ms_level_up_management"
            info "   • Generada clave privada válida para desarrollo"
            info "   • Configuradas credenciales Firebase locales"
        else
            error "❌ Error aplicando fix de Firebase"
            rm -f "$temp_key_file"
            return 1
        fi
        
        # Limpiar archivo temporal
        rm -f "$temp_key_file"
    else
        warn "⚠️  No se pudo generar clave privada (openssl no disponible)"
        # Fallback: usar clave estática válida
        local static_key="-----BEGIN PRIVATE KEY-----\\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC6bxYj1gavQJc2\\nlRpGq8rW9onj6B+cXPsc3h+tesy/a19Vdw+7KEcqcI3rqBcP2RFO3gc5PWzdPxek\\nyyUScrjSQQWzIHtatMB5C5aAC6gvnpHx2dIKC1vap29PiX/fBbvIPTEeT61emh+d\\nfuRfwlmmezZ8QTZ0s394ygGKMLXQPRcFekAqj6XcOAymXKIgWPkwhCtGol7XHVKZ\\nBmDb7ZP+wUxZcDEs0EaCeN4wef4mKfHnvMJBDm+rhzPzD5Ksd2a829RTPbfZ4Ppq\\n3B1b8R9f0uqM8Wkop7z0GOszaNsX9rZJHQqz2B9FSOBVbZTM6Bp8K+313ppeL1NT\\nB73iyB9nAgMBAAECggEAA/cnc6rM1eSQyWiSiy6vnSPI5mhrsoekl9VVFgqEAquZ\\nq4pwgfRlKTv18NMb5ne35AcOqnP80Ey9kvmNqM+0wTY8ydP5qOPPwFvVpsHCISLQ\\nkwA0VuIPYTElhgzlKVv5iZDVSHqt6I7WByN6m6aztlgTdN9PwNQ8sLml02JD6WRG\\nlfc6lW7y6muDf4GkieGpAudrhFQp0KmNryNbOYRCIqrSMyVSAStYmwwydEw+O4HN\\nzwtGlPFhC2F5LYpziJgJ83LBxkPVgvaoF11Vl6rOVLqxcsL9p9mD7pyTwobYifaM\\nC3f8XjO6QAyHYFY06scxHEgO8Qok7t+KyUgvbvbMlQKBgQD5XjevoxuSB+4g4Qz0\\nLFvezmZStxBnP3KUFWleR9oMeyklB86Ph/FiYeVzXUvDdKur6yWvxSXD4zTM9P/m\\nhtqbKKr69eY9vZxOX7hLS15dSkpGUumSzEObhJLuA89C6ciwIBC6C76w7LE36VaE\\n6fGrB3s5FBbucZkby3qYWCIZswKBgQC/ZGRj0wCeF3qmwNGEDMQqMpdjCi/eBZJz\\nJ/4VHMXiE7ZJFXNV1ktEwwhXYXobsR/q4cc4CaeQkNBNzDF4vSACSWhqbSXeRKla\\n6nFPzdBysWzH48PX5EwPDCml/7PSjP3ADA75vYqnR7tiwgRIiLOCvmed7JVO86rM\\nptCHDCihfQKBgA9jLPR9kBn2u070FCSNCC47djzsZuq4E43ntFTJAj966hMK5Egf\\nD1oOyGXR//bToDQ/klfCRo5L2to60/+ZmquwWryZp9dvd9GuPmUHBY+kIeks/JS+\\nXf2etKJTQdrTKjsT/3Q7fUzVjinxEBGrjeoL0CK5hqC4CcaZS7tS1OfZAoGATC8D\\nAvVPrp479TqVa5HFV+KxffvlF+Rx6iLGMdM1NYuRKMBAG6/kYCeeH2Iuv+0eflmG\\n+lhledcbA4y/OIdXwXFE/fAafcIpA4aEujZ7vdvAKEUShNJcMDUwMuJ4ytvSeeqS\\n33hCQ9n6zhHasKCxi96M0kEFIds+Zp4ULV16ouUCgYB4bndd6bJi/zNUdNz0jtyT\\nO2j51wp5lODJr2peLqxFG8R5dbr9gwddc8OY8o7Sgr5U5K3kefKLDgQ9XPsk86h8\\nXwDXZv73Lxj8KsWBw5J/oOz4cwT6hpmwkyriiMjjRsfpB5qOkHzi4RV5FsQasDHJ\\n/FvAEcZUzjBWdfzAFnzuSA==\\n-----END PRIVATE KEY-----"
        
        if sed -i '' "s|FIREBASE_PRIVATE_KEY=.*|FIREBASE_PRIVATE_KEY=\"${static_key}\"|g" "$env_file"; then
            success "✅ Firebase configurado con clave estática para desarrollo"
        fi
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
    
    # Fix crítico: Firebase en ms_level_up_management
    fix_firebase_credentials
    
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