#!/bin/bash
# Trivance Platform - Service Orchestration
# Automated service management with PM2

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones de logging
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Detectar el directorio del workspace
WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WORKSPACE_DIR"

# Verificar si PM2 está instalado
check_pm2() {
    if ! command -v pm2 &> /dev/null; then
        log "PM2 not found. Installing globally..."
        npm install -g pm2
    fi
}

# Crear configuración de PM2
create_pm2_config() {
    cat > "$WORKSPACE_DIR/ecosystem.config.js" << 'EOF'
module.exports = {
  apps: [
    {
      name: 'auth-service',
      cwd: './ms_trivance_auth',
      script: 'npm',
      args: 'run start:dev',
      env: {
        NODE_ENV: 'development',
        PORT: 3001
      },
      watch: false,
      max_memory_restart: '1G',
      error_file: '../logs/pm2/auth-error.log',
      out_file: '../logs/pm2/auth-out.log'
    },
    {
      name: 'management-api',
      cwd: './ms_level_up_management',
      script: 'npm',
      args: 'run start:dev',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      watch: false,
      max_memory_restart: '1G',
      error_file: '../logs/pm2/management-error.log',
      out_file: '../logs/pm2/management-out.log'
    },
    {
      name: 'backoffice',
      cwd: './level_up_backoffice',
      script: 'npm',
      args: 'run dev',
      env: {
        NODE_ENV: 'development'
      },
      watch: false,
      max_memory_restart: '1G',
      error_file: '../logs/pm2/backoffice-error.log',
      out_file: '../logs/pm2/backoffice-out.log'
    }
  ]
};
EOF
}

# Crear directorio de logs si no existe
mkdir -p "$WORKSPACE_DIR/logs/pm2"

# Función principal
main() {
    log "Starting Trivance platform services..."
    
    # Verificar PM2
    check_pm2
    
    # Crear configuración
    create_pm2_config
    
    # Detener servicios existentes
    log "Stopping existing services..."
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
    
    # Iniciar todos los servicios
    log "Starting services with PM2..."
    pm2 start ecosystem.config.js
    
    # Esperar a que los servicios estén listos
    log "Waiting for services to be ready..."
    sleep 10
    
    # Verificar estado
    log "Verifying service status..."
    pm2 status
    
    # Mostrar URLs
    echo
    success "All services are running"
    echo
    echo "Available endpoints:"
    echo "  Auth Service:     http://localhost:3001"
    echo "  Management API:   http://localhost:3000"
    echo "  GraphQL:          http://localhost:3000/graphql"
    echo "  Frontend:         http://localhost:5173"
    echo
    echo "Management commands:"
    echo "  pm2 status          # Check service status"
    echo "  pm2 logs            # View real-time logs"
    echo "  pm2 stop all        # Stop all services"
    echo "  pm2 restart all     # Restart all services"
    echo "  pm2 monit           # Real-time monitoring"
    echo
    
    # Guardar configuración de PM2
    pm2 save
    
    # Configurar PM2 para inicio automático (opcional)
    read -p "Configure services to start automatically on system boot? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        pm2 startup
        success "Automatic startup configured"
    fi
}

# Ejecutar
main "$@"