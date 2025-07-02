#!/bin/bash

# 🛑 Script para detener todos los servicios de Trivance Platform
# Uso: ./scripts/stop-all-services.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log "🛑 Deteniendo todos los servicios de Trivance Platform..."

# Función para matar proceso en un puerto
kill_port() {
    local port=$1
    local service_name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        log "🔴 Deteniendo $service_name en puerto $port..."
        lsof -ti:$port | xargs kill -9 2>/dev/null || true
        sleep 1
    else
        log "✅ $service_name ya estaba detenido"
    fi
}

# Función para detener proceso por PID guardado
kill_by_pid() {
    local service_name=$1
    local pid_file="logs/${service_name}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 $pid 2>/dev/null; then
            log "🔴 Deteniendo $service_name (PID: $pid)..."
            kill -TERM $pid 2>/dev/null || true
            sleep 2
            
            # Si todavía está corriendo, forzar terminación
            if kill -0 $pid 2>/dev/null; then
                warning "Forzando terminación de $service_name..."
                kill -KILL $pid 2>/dev/null || true
            fi
        fi
        rm -f "$pid_file"
    fi
}

# Detener servicios por PID si existen
if [ -d "logs" ]; then
    kill_by_pid "Auth Service"
    kill_by_pid "Management API" 
    kill_by_pid "Frontend"
    kill_by_pid "Mobile App"
fi

# Detener servicios por puerto (fallback)
kill_port 3001 "Auth Service"
kill_port 3000 "Management API"
kill_port 5173 "Frontend"
kill_port 19000 "Expo Dev Server"
kill_port 19001 "Metro Bundler"

# Matar todos los procesos node relacionados con el proyecto
log "🧹 Limpiando procesos restantes..."

# Buscar y matar procesos específicos del proyecto
pkill -f "nest start" 2>/dev/null || true
pkill -f "vite.*5173" 2>/dev/null || true
pkill -f "expo start" 2>/dev/null || true
pkill -f "metro" 2>/dev/null || true

sleep 2

# Verificar que los puertos estén libres
check_port_free() {
    local port=$1
    local service_name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        error "$service_name sigue activo en puerto $port"
        return 1
    else
        log "✅ Puerto $port liberado ($service_name)"
        return 0
    fi
}

log "🔍 Verificando que todos los puertos estén libres..."

all_stopped=true

check_port_free 3001 "Auth Service" || all_stopped=false
check_port_free 3000 "Management API" || all_stopped=false  
check_port_free 5173 "Frontend" || all_stopped=false
check_port_free 19000 "Expo Dev Server" || all_stopped=false

if [ "$all_stopped" = true ]; then
    log "🎉 ¡Todos los servicios han sido detenidos exitosamente!"
else
    error "Algunos servicios no pudieron ser detenidos completamente"
    echo ""
    echo -e "${YELLOW}Procesos activos en puertos de desarrollo:${NC}"
    lsof -i :3000,3001,5173,19000,19001 2>/dev/null || echo "Ningún proceso activo encontrado"
fi

# Limpiar archivos de log y PID opcionales
if [ "$1" = "clean" ]; then
    log "🧹 Limpiando archivos de log..."
    rm -rf logs/
    log "✅ Archivos de log eliminados"
fi

echo ""
log "Para reiniciar los servicios: ./scripts/start-all-services.sh"