#!/bin/bash
# Trivance Log Analyzer - AI-First Pattern Implementation
# Analiza logs de instalación/compilación para detectar patrones automáticamente

set -euo pipefail

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Variables globales para resultados (compatibles con bash 3.x en macOS)
LOG_ANALYSIS_RESULTS=()
LOG_ANALYSIS_SUGGESTIONS=()

# Función principal de análisis
get_log_analysis_results() {
    # Reset arrays
    LOG_ANALYSIS_RESULTS=()
    LOG_ANALYSIS_SUGGESTIONS=()
    
    # Directorio de logs
    local logs_dir="${WORKSPACE_DIR}/logs"
    
    if [[ ! -d "$logs_dir" ]]; then
        return 0
    fi
    
    # Analizar logs de compilación
    analyze_compilation_logs "$logs_dir/compilation"
    
    # Analizar logs de instalación
    analyze_installation_logs "$logs_dir"
    
    # Retornar 0 si no hay issues críticos, 1 si los hay
    local critical_count=0
    for result in "${LOG_ANALYSIS_RESULTS[@]}"; do
        if [[ "$result" =~ missing_deps|permissions|conflicts ]]; then
            ((critical_count++))
        fi
    done
    
    return $critical_count
}

# Analizar logs de compilación
analyze_compilation_logs() {
    local compilation_dir="$1"
    
    if [[ ! -d "$compilation_dir" ]]; then
        return 0
    fi
    
    # Analizar cada log de compilación
    for log_file in "$compilation_dir"/*.log; do
        if [[ -f "$log_file" ]]; then
            local service_name=$(basename "$log_file" | sed 's/_.*\.log$//')
            
            # Análisis específico por tipo de servicio
            case "$service_name" in
                "level_up_backoffice")
                    analyze_frontend_build_log "$log_file" "$service_name"
                    ;;
                "ms_level_up_management"|"ms_trivance_auth")
                    analyze_backend_build_log "$log_file" "$service_name"
                    ;;
                "trivance-mobile")
                    analyze_mobile_typecheck_log "$log_file" "$service_name"
                    ;;
            esac
        fi
    done
}

# Analizar logs de instalación
analyze_installation_logs() {
    local logs_dir="$1"
    
    for log_file in "$logs_dir"/*_install.log; do
        if [[ -f "$log_file" ]]; then
            local service_name=$(basename "$log_file" | sed 's/_install\.log$//')
            analyze_installation_log "$log_file" "$service_name"
        fi
    done
}

# Analizar log de frontend (React/Vite)
analyze_frontend_build_log() {
    local log_file="$1"
    local service_name="$2"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    # Detectar warnings de Sentry
    if grep -q "SENTRY" "$log_file" 2>/dev/null; then
        if grep -q "warn" "$log_file" 2>/dev/null; then
            LOG_ANALYSIS_RESULTS+=("sentry_warnings")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Warnings de Sentry detectados - revisar configuración")
        fi
    fi
    
    # Detectar chunks vacíos o problemas de build
    if grep -q "empty chunk" "$log_file" 2>/dev/null; then
        LOG_ANALYSIS_RESULTS+=("build_optimization")
        LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Chunks vacíos detectados - optimizar imports")
    fi
    
    # Detectar problemas de memoria en build
    if grep -q -i "out of memory\|heap" "$log_file" 2>/dev/null; then
        LOG_ANALYSIS_RESULTS+=("build_memory")
        LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Posible problema de memoria en build")
    fi
}

# Analizar log de backend (NestJS)
analyze_backend_build_log() {
    local log_file="$1"
    local service_name="$2"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    # Detectar errores de Prisma específicos
    if grep -q "Prisma" "$log_file" 2>/dev/null; then
        if grep -q -i "error\|failed" "$log_file" 2>/dev/null; then
            LOG_ANALYSIS_RESULTS+=("prisma_errors")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Errores de Prisma detectados - verificar schema")
        fi
    fi
    
    # Detectar problemas de dependencias
    if grep -q -i "cannot find module\|module not found" "$log_file" 2>/dev/null; then
        LOG_ANALYSIS_RESULTS+=("missing_deps")
        LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Dependencias faltantes - ejecutar npm install")
    fi
}

# Analizar log de mobile (React Native TypeScript)
analyze_mobile_typecheck_log() {
    local log_file="$1"
    local service_name="$2"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    # Contar errores TypeScript
    local ts_error_count=0
    if grep -q "error TS" "$log_file" 2>/dev/null; then
        ts_error_count=$(grep -c "error TS" "$log_file" 2>/dev/null || echo "0")
    fi
    
    if [[ "$ts_error_count" -gt 0 ]]; then
        # Categorizar por tipo de error más común
        if grep -q "Property.*does not exist on type" "$log_file" 2>/dev/null; then
            LOG_ANALYSIS_RESULTS+=("typescript_missing_props")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: $ts_error_count errores TypeScript - revisar interfaces/tipos")
        elif grep -q "Type.*is not assignable to type" "$log_file" 2>/dev/null; then
            LOG_ANALYSIS_RESULTS+=("typescript_type_mismatch")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: $ts_error_count errores de tipos - revisar asignaciones")
        else
            LOG_ANALYSIS_RESULTS+=("typescript_generic")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: $ts_error_count errores TypeScript - revisar código")
        fi
    fi
}

# Analizar log de instalación
analyze_installation_log() {
    local log_file="$1"
    local service_name="$2"
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    # Detectar errores de permisos
    if grep -q -i "permission denied\|EACCES" "$log_file" 2>/dev/null; then
        LOG_ANALYSIS_RESULTS+=("permissions")
        LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Problemas de permisos durante instalación")
    fi
    
    # Detectar conflictos de versiones
    if grep -q -i "conflicting peer dependency\|version conflict" "$log_file" 2>/dev/null; then
        LOG_ANALYSIS_RESULTS+=("version_conflicts")
        LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Conflictos de versiones detectados")
    fi
    
    # Detectar problemas de red/registry
    if grep -q -i "network\|timeout\|registry" "$log_file" 2>/dev/null; then
        if grep -q -i "error\|failed" "$log_file" 2>/dev/null; then
            LOG_ANALYSIS_RESULTS+=("network_issues")
            LOG_ANALYSIS_SUGGESTIONS+=("${service_name}: Problemas de red durante instalación")
        fi
    fi
}

# Función para mostrar resumen de análisis (para debugging)
show_analysis_summary() {
    if [[ ${#LOG_ANALYSIS_RESULTS[@]} -eq 0 ]]; then
        echo "✅ No se detectaron problemas en los logs"
        return 0
    fi
    
    echo "📋 Análisis de logs:"
    local i
    for i in "${!LOG_ANALYSIS_RESULTS[@]}"; do
        local result="${LOG_ANALYSIS_RESULTS[$i]}"
        local suggestion="${LOG_ANALYSIS_SUGGESTIONS[$i]:-}"
        echo "  • $result: $suggestion"
    done
}

# Solo ejecutar si se llama directamente (no cuando se hace source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Modo standalone para testing
    get_log_analysis_results
    show_analysis_summary
fi