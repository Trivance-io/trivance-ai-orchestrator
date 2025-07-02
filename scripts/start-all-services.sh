#!/bin/bash

# 🚀 Script para iniciar todos los servicios de Trivance Platform
# Uso: ./scripts/start-all-services.sh [environment]
# Environment: local (default), qa, prod

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar si estamos en el directorio correcto
if [ ! -f "TrivancePlatform.code-workspace" ]; then
    error "Por favor ejecuta este script desde el directorio raíz del workspace"
    exit 1
fi

# Environment por defecto
ENVIRONMENT=${1:-local}

log "🚀 Iniciando servicios de Trivance Platform - Environment: $ENVIRONMENT"

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0  # Puerto está en uso
    else
        return 1  # Puerto está libre
    fi
}

# Función para matar proceso en un puerto
kill_port() {
    local port=$1
    if check_port $port; then
        warning "Puerto $port está en uso, terminando proceso..."
        lsof -ti:$port | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Limpiar puertos si están en uso
log "🧹 Limpiando puertos..."
kill_port 3000  # Management API
kill_port 3001  # Auth API
kill_port 5173  # Frontend dev server
kill_port 19000 # Expo dev server
kill_port 19001 # Expo metro bundler

# Verificar dependencias
log "📦 Verificando dependencias..."

check_dependencies() {
    local dir=$1
    if [ ! -d "$dir/node_modules" ]; then
        warning "Node modules no encontrados en $dir, instalando..."
        cd $dir
        npm install
        cd ..
    fi
}

check_dependencies "ms_trivance_auth"
check_dependencies "ms_level_up_management"
check_dependencies "level_up_backoffice"
check_dependencies "trivance-mobile"

# Función para iniciar un servicio en background
start_service() {
    local name=$1
    local dir=$2
    local command=$3
    local port=$4
    local health_endpoint=$5
    
    log "🔧 Iniciando $name..."
    
    cd $dir
    
    # Crear archivo de log
    mkdir -p ../logs
    local log_file="../logs/${name}.log"
    
    # Iniciar servicio en background
    eval $command > $log_file 2>&1 &
    local pid=$!
    
    # Guardar PID para poder terminarlo después
    echo $pid > "../logs/${name}.pid"
    
    cd ..
    
    # Esperar a que el servicio esté listo
    if [ ! -z "$health_endpoint" ]; then
        info "Esperando a que $name esté listo en puerto $port..."
        local attempts=0
        local max_attempts=30
        
        while [ $attempts -lt $max_attempts ]; do
            if check_port $port; then
                # Si tiene health endpoint, verificar que esté respondiendo
                if curl -s $health_endpoint > /dev/null 2>&1; then
                    log "✅ $name está listo!"
                    break
                fi
            fi
            
            sleep 2
            attempts=$((attempts + 1))
            
            # Verificar si el proceso sigue corriendo
            if ! kill -0 $pid 2>/dev/null; then
                error "$name falló al iniciar. Ver logs en $log_file"
                return 1
            fi
        done
        
        if [ $attempts -eq $max_attempts ]; then
            error "$name no respondió dentro del tiempo esperado"
            return 1
        fi
    fi
}

# Crear directorio de logs
mkdir -p logs

# Iniciar servicios backend
log "🏗️ Iniciando servicios backend..."

start_service "Auth Service" "ms_trivance_auth" "npm run start:dev" 3001 "http://localhost:3001/health"
start_service "Management API" "ms_level_up_management" "npm run start:dev" 3000 "http://localhost:3000/health"

# Iniciar frontend
log "🎨 Iniciando frontend..."
start_service "Frontend" "level_up_backoffice" "npm run dev" 5173 ""

# Iniciar mobile app (opcional)
if [ "$2" = "mobile" ] || [ "$2" = "all" ]; then
    log "📱 Iniciando aplicación móvil..."
    case $ENVIRONMENT in
        local)
            start_service "Mobile App" "trivance-mobile" "EXPO_ENV=local npm start" 19000 ""
            ;;
        qa)
            start_service "Mobile App" "trivance-mobile" "EXPO_ENV=qa npm start" 19000 ""
            ;;
        prod)
            start_service "Mobile App" "trivance-mobile" "EXPO_ENV=production npm start" 19000 ""
            ;;
    esac
fi

log "🎉 ¡Todos los servicios están corriendo!"

# Mostrar información de servicios
echo ""
echo -e "${BLUE}=== SERVICIOS ACTIVOS ===${NC}"
echo -e "${GREEN}Auth Service:${NC}      http://localhost:3001"
echo -e "${GREEN}Management API:${NC}    http://localhost:3000"
echo -e "${GREEN}GraphQL Playground:${NC} http://localhost:3000/graphql"
echo -e "${GREEN}Swagger Auth:${NC}      http://localhost:3001/api-docs"
echo -e "${GREEN}Frontend:${NC}          http://localhost:5173"

if [ "$2" = "mobile" ] || [ "$2" = "all" ]; then
    echo -e "${GREEN}Mobile App:${NC}        http://localhost:19000"
fi

echo ""
echo -e "${BLUE}=== LOGS ===${NC}"
echo -e "${YELLOW}Auth Service:${NC}      tail -f logs/Auth\\ Service.log"
echo -e "${YELLOW}Management API:${NC}    tail -f logs/Management\\ API.log"
echo -e "${YELLOW}Frontend:${NC}          tail -f logs/Frontend.log"

if [ "$2" = "mobile" ] || [ "$2" = "all" ]; then
    echo -e "${YELLOW}Mobile App:${NC}        tail -f logs/Mobile\\ App.log"
fi

echo ""
echo -e "${BLUE}=== COMANDOS ÚTILES ===${NC}"
echo -e "${YELLOW}Detener servicios:${NC}  ./scripts/stop-all-services.sh"
echo -e "${YELLOW}Ver logs:${NC}           ./scripts/show-logs.sh"
echo -e "${YELLOW}Restart servicios:${NC}  ./scripts/restart-services.sh"

echo ""
warning "Para detener todos los servicios, ejecuta: ./scripts/stop-all-services.sh"

# Mantener el script corriendo para mostrar logs
if [ "$3" = "logs" ]; then
    log "📄 Mostrando logs en tiempo real (Ctrl+C para salir)..."
    tail -f logs/*.log
fi