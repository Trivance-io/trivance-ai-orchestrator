#!/bin/bash

# 📍 TRIVANCE PATH RESOLVER
# Script centralizado para calcular rutas de forma consistente
# Todos los scripts deben usar este resolver para evitar inconsistencias

set -euo pipefail

# 🎯 Función principal para resolver rutas del workspace
resolve_workspace_paths() {
    local script_file="${1:-${BASH_SOURCE[1]}}"
    
    # Obtener directorio del script que llama
    local calling_script_dir
    calling_script_dir="$(cd "$(dirname "$script_file")" && pwd)"
    
    # Detectar estructura basada en ubicación del script
    local config_dir workspace_dir
    
    # Casos posibles:
    # 1. Script en trivance-dev-config/scripts/core/
    # 2. Script en trivance-dev-config/scripts/utils/
    # 3. Script en trivance-dev-config/scripts/
    # 4. Script ejecutado como symlink desde workspace
    
    if [[ "$calling_script_dir" == */trivance-dev-config/scripts/core ]]; then
        # Desde scripts/core/
        config_dir="$(cd "${calling_script_dir}/../.." && pwd)"
        workspace_dir="$(cd "${config_dir}/.." && pwd)"
    elif [[ "$calling_script_dir" == */trivance-dev-config/scripts/utils ]]; then
        # Desde scripts/utils/
        config_dir="$(cd "${calling_script_dir}/../.." && pwd)"
        workspace_dir="$(cd "${config_dir}/.." && pwd)"
    elif [[ "$calling_script_dir" == */trivance-dev-config/scripts ]]; then
        # Desde scripts/
        config_dir="$(cd "${calling_script_dir}/.." && pwd)"
        workspace_dir="$(cd "${config_dir}/.." && pwd)"
    elif [[ -L "$script_file" ]]; then
        # Es un symlink - resolver la ubicación real
        local real_script
        real_script="$(readlink "$script_file")"
        local real_dir
        real_dir="$(cd "$(dirname "$real_script")" && pwd)"
        
        # Ahora calcular desde la ubicación real
        if [[ "$real_dir" == */trivance-dev-config/scripts ]]; then
            config_dir="$(cd "${real_dir}/.." && pwd)"
            workspace_dir="$(cd "${config_dir}/.." && pwd)"
        else
            # Fallback: asumir que estamos en el workspace
            workspace_dir="$(cd "${calling_script_dir}" && pwd)"
            config_dir="${workspace_dir}/trivance-dev-config"
        fi
    else
        # Fallback: intentar detectar automáticamente
        local current_dir="$calling_script_dir"
        
        # Buscar hacia arriba hasta encontrar trivance-dev-config
        while [[ "$current_dir" != "/" ]]; do
            if [[ -d "$current_dir/trivance-dev-config" ]]; then
                workspace_dir="$current_dir"
                config_dir="$current_dir/trivance-dev-config"
                break
            fi
            current_dir="$(dirname "$current_dir")"
        done
        
        # Si no encontramos, error
        if [[ -z "${workspace_dir:-}" ]]; then
            echo "ERROR: No se pudo determinar la estructura del workspace" >&2
            exit 1
        fi
    fi
    
    # Validar que las rutas calculadas son correctas
    if [[ ! -d "$workspace_dir" ]]; then
        echo "ERROR: Workspace directory no existe: $workspace_dir" >&2
        exit 1
    fi
    
    if [[ ! -d "$config_dir" ]]; then
        echo "ERROR: Config directory no existe: $config_dir" >&2
        exit 1
    fi
    
    # Exportar variables globales
    export WORKSPACE_DIR="$workspace_dir"
    export CONFIG_DIR="$config_dir"
    export ENVS_DIR="$workspace_dir/envs"
    export LOGS_DIR="$workspace_dir/logs"
    
    # Crear directorios necesarios
    ensure_required_directories
    
    return 0
}

# 📁 Asegurar que todos los directorios necesarios existen
ensure_required_directories() {
    local required_dirs=(
        "$LOGS_DIR"
        "$LOGS_DIR/compilation"
        "$ENVS_DIR"
        "$WORKSPACE_DIR/level_up_backoffice/logs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
        fi
    done
}

# 🔍 Función para verificar estructura completa del workspace
validate_workspace_structure() {
    local expected_repos=(
        "trivance-dev-config"
        "ms_level_up_management"
        "ms_trivance_auth"
        "level_up_backoffice"
        "trivance-mobile"
    )
    
    local missing_repos=()
    
    for repo in "${expected_repos[@]}"; do
        if [[ ! -d "$WORKSPACE_DIR/$repo" ]]; then
            missing_repos+=("$repo")
        fi
    done
    
    if [[ ${#missing_repos[@]} -gt 0 ]]; then
        echo "WARNING: Repositorios faltantes en workspace:" >&2
        printf "  - %s\n" "${missing_repos[@]}" >&2
        return 1
    fi
    
    return 0
}

# 🔧 Función para verificar permisos
validate_permissions() {
    if [[ ! -w "$WORKSPACE_DIR" ]]; then
        echo "ERROR: No tienes permisos de escritura en: $WORKSPACE_DIR" >&2
        exit 1
    fi
    
    if [[ ! -w "$CONFIG_DIR" ]]; then
        echo "ERROR: No tienes permisos de escritura en: $CONFIG_DIR" >&2
        exit 1
    fi
    
    return 0
}

# 📊 Función para mostrar información de debug
show_path_debug() {
    echo "=== TRIVANCE PATH RESOLVER DEBUG ==="
    echo "WORKSPACE_DIR: $WORKSPACE_DIR"
    echo "CONFIG_DIR: $CONFIG_DIR"
    echo "ENVS_DIR: $ENVS_DIR"
    echo "LOGS_DIR: $LOGS_DIR"
    echo "=================================="
}

# 🎯 Función principal para usar desde otros scripts
# Uso: source path-resolver.sh && resolve_paths
resolve_paths() {
    resolve_workspace_paths "${BASH_SOURCE[1]}"
    validate_permissions
    
    # Mostrar debug si está habilitado
    if [[ "${DEBUG_PATHS:-false}" == "true" ]]; then
        show_path_debug
    fi
}

# 📝 Función para obtener rutas específicas
get_workspace_dir() { echo "$WORKSPACE_DIR"; }
get_config_dir() { echo "$CONFIG_DIR"; }
get_envs_dir() { echo "$ENVS_DIR"; }
get_logs_dir() { echo "$LOGS_DIR"; }

# 🔄 Auto-resolver si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ejecutado directamente para debug
    resolve_workspace_paths "${BASH_SOURCE[0]}"
    show_path_debug
fi