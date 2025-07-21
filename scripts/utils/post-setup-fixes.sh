#!/bin/bash

# Post-setup fixes para repositorios clonados
# Aplica correcciones automáticas para problemas conocidos en desarrollo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Variables globales para modo de operación AI-First
INTERACTIVE_MODE=true
FIXES_TO_APPLY=()
FIXES_APPLIED=0
FIXES_SKIPPED=0

# Sistema de detección de issues (usando arrays simples por compatibilidad bash 3.x)
DETECTED_ISSUES=()
ISSUE_IMPACTS=()
ISSUE_ACTIONS=()
ISSUE_KEYS=()

# Verificación de seguridad
if [[ "${NODE_ENV:-}" == "production" ]] || [[ -f "${WORKSPACE_DIR}/.production" ]]; then
    error "❌ SEGURIDAD: Este script es SOLO para desarrollo local"
    error "   No debe ejecutarse en entornos de producción"
    exit 1
fi

# Detectar modo interactivo vs automatizado
detect_interactive_mode() {
    # Si hay un TTY y no estamos en CI, es interactivo
    if [[ -t 0 ]] && [[ -z "${CI:-}" ]] && [[ -z "${CONTINUOUS_INTEGRATION:-}" ]] && [[ -z "${NONINTERACTIVE:-}" ]]; then
        INTERACTIVE_MODE=true
    else
        INTERACTIVE_MODE=false
    fi
    
    # Permitir override explícito
    if [[ "${TRIVANCE_AUTO_FIX:-}" == "yes" ]]; then
        INTERACTIVE_MODE=false
    fi
}

show_fixes_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🔧 POST-SETUP FIXES AUTOMÁTICOS                        ║
║                   Aplicando correcciones para desarrollo                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

# Función principal de detección de issues (AI-First pattern)
detect_all_issues() {
    log "🔍 Analizando consistencia del sistema..."
    
    # Reset arrays
    DETECTED_ISSUES=()
    ISSUE_IMPACTS=()
    ISSUE_ACTIONS=()
    ISSUE_KEYS=()
    
    # Detectar cada tipo de issue tradicional
    detect_sentry_issue
    detect_firebase_issue
    detect_port_conflicts_issue
    
    # NUEVO: Análisis inteligente de logs (AI-First pattern)
    detect_log_analysis_issues
    
    # Retornar número de issues
    return ${#ISSUE_KEYS[@]}
}

detect_sentry_issue() {
    local repo_path="${WORKSPACE_DIR}/ms_level_up_management"
    
    if [[ -d "$repo_path" ]] && [[ -f "${repo_path}/package.json" ]]; then
        if ! grep -q '"build:dev"' "${repo_path}/package.json"; then
            ISSUE_KEYS+=("sentry")
            DETECTED_ISSUES+=("Falta comando build:dev sin Sentry")
            ISSUE_IMPACTS+=("Build fallará en desarrollo sin credenciales Sentry")
            ISSUE_ACTIONS+=("critical")
        fi
    fi
}

detect_firebase_issue() {
    local env_file="${WORKSPACE_DIR}/ms_level_up_management/.env"
    
    if [[ -f "$env_file" ]]; then
        if grep -q "PLACEHOLDER_WILL_BE_REPLACED_BY_POST_SETUP_FIX" "$env_file"; then
            ISSUE_KEYS+=("firebase")
            DETECTED_ISSUES+=("Firebase tiene placeholders vacíos")
            ISSUE_IMPACTS+=("Warnings en logs, pero no bloquea desarrollo")
            ISSUE_ACTIONS+=("recommended")
        fi
    fi
}

detect_port_conflicts_issue() {
    local ports=(3000 3001 5173)
    local conflicts=0
    
    for port in "${ports[@]}"; do
        # Usar netstat más rápido que lsof en macOS
        if netstat -an 2>/dev/null | grep -q ":${port} .*LISTEN" 2>/dev/null; then
            ((conflicts++))
        fi
    done
    
    if [[ $conflicts -gt 0 ]]; then
        ISSUE_KEYS+=("ports")
        DETECTED_ISSUES+=("$conflicts puerto(s) ya están en uso")
        ISSUE_IMPACTS+=("Los servicios no podrán iniciar")
        ISSUE_ACTIONS+=("warning")
    fi
}

# NUEVO: Análisis inteligente de logs (AI-First pattern)
detect_log_analysis_issues() {
    # Verificar si existe el analizador de logs
    local log_analyzer="${SCRIPT_DIR}/log-analyzer.sh"
    
    if [[ ! -f "$log_analyzer" ]]; then
        # Fallback silencioso - no afecta funcionamiento existente
        return 0
    fi
    
    # Cargar el analizador sin ejecutar main
    source "$log_analyzer"
    
    # Ejecutar análisis
    if get_log_analysis_results 2>/dev/null; then
        # No hay issues críticos de logs
        return 0
    fi
    
    # Procesar resultados si existen
    if [[ -n "${LOG_ANALYSIS_RESULTS:-}" ]] && [[ ${#LOG_ANALYSIS_RESULTS[@]} -gt 0 ]]; then
        local i
        for i in "${!LOG_ANALYSIS_RESULTS[@]}"; do
            local result="${LOG_ANALYSIS_RESULTS[$i]}"
            local suggestion="${LOG_ANALYSIS_SUGGESTIONS[$i]:-}"
            
            # Categorizar según severidad
            case "$result" in
                *"missing_deps"*|*"permissions"*|*"conflicts"*)
                    ISSUE_KEYS+=("log_$result")
                    DETECTED_ISSUES+=("Problema en logs: $(echo "$suggestion" | cut -d':' -f2 | xargs)")
                    ISSUE_IMPACTS+=("Puede afectar instalación/compilación futura")
                    ISSUE_ACTIONS+=("critical")
                    ;;
                *"typescript"*|*"sentry"*)
                    ISSUE_KEYS+=("log_$result")
                    DETECTED_ISSUES+=("Optimización sugerida: $(echo "$suggestion" | cut -d':' -f2 | xargs)")
                    ISSUE_IMPACTS+=("Mejora calidad código/build")
                    ISSUE_ACTIONS+=("recommended")
                    ;;
                *"build"*|*"optimization"*)
                    ISSUE_KEYS+=("log_$result")
                    DETECTED_ISSUES+=("Optimización build: $(echo "$suggestion" | cut -d':' -f2 | xargs)")
                    ISSUE_IMPACTS+=("Mejora performance de compilación")
                    ISSUE_ACTIONS+=("recommended")
                    ;;
            esac
        done
    fi
}

# Mostrar reporte de issues detectados
show_issues_report() {
    if [[ ${#ISSUE_KEYS[@]} -eq 0 ]]; then
        success "✅ No se detectaron problemas de configuración"
        return 0
    fi
    
    echo
    echo "┌─────────────────────────┬────────────────────────────────────┬──────────────┐"
    echo "│ Issue                   │ Impacto                            │ Prioridad    │"
    echo "├─────────────────────────┼────────────────────────────────────┼──────────────┤"
    
    local i
    for i in "${!ISSUE_KEYS[@]}"; do
        local desc="${DETECTED_ISSUES[$i]}"
        local impact="${ISSUE_IMPACTS[$i]}"
        local action="${ISSUE_ACTIONS[$i]}"
        
        # Colorear según prioridad
        case "$action" in
            "critical")
                printf "│ %-23s │ %-34s │ \033[31m%-12s\033[0m │\n" "$desc" "$impact" "CRÍTICA"
                ;;
            "recommended")
                printf "│ %-23s │ %-34s │ \033[33m%-12s\033[0m │\n" "$desc" "$impact" "Recomendada"
                ;;
            "warning")
                printf "│ %-23s │ %-34s │ \033[36m%-12s\033[0m │\n" "$desc" "$impact" "Advertencia"
                ;;
        esac
    done
    
    echo "└─────────────────────────┴────────────────────────────────────┴──────────────┘"
    echo
}

# Solicitar autorización del usuario
request_user_authorization() {
    if ! $INTERACTIVE_MODE; then
        log "Modo no-interactivo detectado, aplicando fixes automáticamente..."
        return 0
    fi
    
    local response
    read -p "¿Aplicar fixes recomendados? ([s]í/[n]o/[d]etalles): " -r response
    
    case "$response" in
        s|S|si|SI|yes|YES|y|Y|"")
            return 0
            ;;
        n|N|no|NO)
            log "Fixes omitidos por el usuario"
            return 1
            ;;
        d|D|detalles|DETALLES)
            show_fix_details
            # Preguntar de nuevo
            request_user_authorization
            ;;
        *)
            warn "Opción no válida. Por favor responde s, n o d."
            request_user_authorization
            ;;
    esac
}

show_fix_details() {
    echo
    info "📋 DETALLES DE FIXES DISPONIBLES:"
    echo
    
    local i
    for i in "${!ISSUE_KEYS[@]}"; do
        local key="${ISSUE_KEYS[$i]}"
        case "$key" in
            "sentry")
                echo "🔧 FIX DE SENTRY:"
                echo "  - Agrega script 'build:dev' sin dependencia de Sentry"
                echo "  - Permite compilar en desarrollo sin credenciales"
                echo "  - Cambio: package.json en ms_level_up_management"
                echo
                ;;
            "firebase")
                echo "🔧 FIX DE FIREBASE:"
                echo "  - Reemplaza placeholders con valores de desarrollo"
                echo "  - Elimina warnings molestos en logs"
                echo "  - Cambio: .env en ms_level_up_management"
                echo
                ;;
            "ports")
                echo "⚠️  CONFLICTO DE PUERTOS:"
                echo "  - No se puede arreglar automáticamente"
                echo "  - Ejecuta: killall node"
                echo "  - O detén manualmente los procesos"
                echo
                ;;
            log_*)
                echo "🤖 ANÁLISIS DE LOGS:"
                echo "  - Detectado en análisis automático de logs"
                echo "  - Sugerencia: ${DETECTED_ISSUES[$i]}"
                echo "  - Impacto: ${ISSUE_IMPACTS[$i]}"
                echo
                ;;
        esac
    done
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
    
    # NO generar claves privadas reales - usar placeholder seguro
    info "🔧 Configurando Firebase con placeholder de desarrollo..."
    
    # Placeholder seguro que claramente NO es una clave real
    local dev_placeholder="-----BEGIN PRIVATE KEY-----\\nDEVELOPMENT_ONLY_NOT_A_REAL_KEY_DO_NOT_USE_IN_PRODUCTION\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC9W8bA\\nTHIS_IS_A_FAKE_KEY_FOR_LOCAL_DEVELOPMENT_ONLY\\n-----END PRIVATE KEY-----"
    
    # Actualizar variables Firebase con valores de desarrollo seguros
    if sed -i '' "s|FIREBASE_PROJECT_ID=.*|FIREBASE_PROJECT_ID=trivance-dev-local|g" "$env_file" && \
       sed -i '' "s|FIREBASE_PRIVATE_KEY=.*|FIREBASE_PRIVATE_KEY=\"${dev_placeholder}\"|g" "$env_file" && \
       sed -i '' "s|FIREBASE_CLIENT_EMAIL=.*|FIREBASE_CLIENT_EMAIL=firebase-dev@trivance-dev-local.iam.gserviceaccount.com|g" "$env_file"; then
        
        success "✅ Firebase configurado con placeholder de desarrollo"
        info "   • Usando placeholder seguro (no es una clave real)"
        info "   • Para Firebase real, configura manualmente las credenciales"
        warn "   ⚠️  NUNCA uses esta configuración en producción"
    else
        error "❌ Error configurando Firebase placeholder"
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
    
    # Detectar modo de operación
    detect_interactive_mode
    
    # Fase 1: Detección AI-First
    detect_all_issues
    local num_issues=$?
    
    if [[ $num_issues -eq 0 ]]; then
        success "✅ No se detectaron problemas de configuración"
        return 0
    fi
    
    # Fase 2: Reporte inteligente
    show_issues_report
    
    # Fase 3: Autorización (si es interactivo)
    if ! request_user_authorization; then
        info "📋 Fixes omitidos. Puedes ejecutar este script más tarde si es necesario."
        return 0
    fi
    
    # Fase 4: Aplicación inteligente de fixes
    log "Aplicando fixes autorizados..."
    
    # Aplicar solo los fixes necesarios basados en detección
    local key
    for key in "${ISSUE_KEYS[@]}"; do
        case "$key" in
            "sentry")
                fix_sentry_build_command
                ((FIXES_APPLIED++))
                ;;
            "firebase")
                fix_firebase_credentials
                ((FIXES_APPLIED++))
                ;;
            "ports")
                fix_port_conflicts
                # Los conflictos de puerto no se "aplican", solo se reportan
                ;;
            log_*)
                # Los issues de logs son informativos, no requieren fixes específicos
                info "🤖 Issue de logs detectado: $key (solo informativo)"
                ;;
        esac
    done
    
    # Verificaciones adicionales (siempre se ejecutan)
    fix_development_env_values
    fix_react_native_typescript
    
    # Resumen final inteligente
    echo
    if [[ $FIXES_APPLIED -gt 0 ]]; then
        success "✅ Fixes aplicados: $FIXES_APPLIED"
    fi
    if [[ $FIXES_SKIPPED -gt 0 ]]; then
        info "ℹ️  Fixes omitidos: $FIXES_SKIPPED"
    fi
    
    success "🎉 Proceso de fixes AI-First completado"
}

main() {
    apply_all_fixes
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi