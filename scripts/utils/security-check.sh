#!/bin/bash
# 🔒 Script de verificación de seguridad
# Verifica que no estamos en producción antes de ejecutar scripts

set -euo pipefail

# Función para verificar que estamos en desarrollo
verify_development_environment() {
    # Verificar NODE_ENV
    if [[ "${NODE_ENV:-}" == "production" ]]; then
        echo "❌ ERROR: NODE_ENV está configurado como 'production'"
        echo "   Este script es SOLO para desarrollo local"
        exit 1
    fi
    
    # Verificar archivo marcador de producción
    if [[ -f "${WORKSPACE_DIR}/.production" ]] || [[ -f "/etc/trivance/production" ]]; then
        echo "❌ ERROR: Detectado marcador de entorno de producción"
        echo "   Este script es SOLO para desarrollo local"
        exit 1
    fi
    
    # Verificar que no estamos en servidor conocido de producción
    local hostname=$(hostname)
    if [[ "$hostname" =~ (prod|production|live) ]]; then
        echo "⚠️  ADVERTENCIA: El hostname sugiere un entorno de producción: $hostname"
        read -p "¿Estás SEGURO que esto es desarrollo local? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            echo "❌ Abortando por seguridad"
            exit 1
        fi
    fi
    
    # Verificar que Docker está en modo desarrollo
    if command -v docker &>/dev/null; then
        local docker_context=$(docker context show 2>/dev/null || echo "default")
        if [[ "$docker_context" =~ (prod|production) ]]; then
            echo "❌ ERROR: Docker context sugiere producción: $docker_context"
            exit 1
        fi
    fi
    
    return 0
}

# Exportar para uso en otros scripts
export -f verify_development_environment