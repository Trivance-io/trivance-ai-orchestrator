#!/bin/bash

# 📊 Dozzle Log Monitor - Trivance Platform
# Script para gestionar el monitor de logs Dozzle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCKER_DIR="$PROJECT_ROOT/trivance-dev-config/docker"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}📊 Dozzle Log Monitor${NC}"
    echo -e "${PURPLE}================================${NC}"
}

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado o no está en PATH"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker no está corriendo. Inicia Docker Desktop"
        return 1
    fi
    
    return 0
}

start_dozzle() {
    print_status "Iniciando Dozzle..."
    
    if ! check_docker; then
        return 1
    fi
    
    cd "$DOCKER_DIR" || {
        print_error "No se pudo acceder al directorio Docker: $DOCKER_DIR"
        return 1
    }
    
    # Verificar si ya está corriendo
    if docker ps | grep -q "trivance_dozzle"; then
        print_warning "Dozzle ya está corriendo"
        show_status
        return 0
    fi
    
    # Iniciar solo Dozzle
    docker-compose up -d dozzle
    
    if [ $? -eq 0 ]; then
        print_success "Dozzle iniciado correctamente"
        echo -e "${CYAN}🌐 Accede a: http://localhost:9999${NC}"
        echo -e "${CYAN}📊 Monitor todos los contenedores con prefijo 'trivance_'${NC}"
    else
        print_error "Error al iniciar Dozzle"
        return 1
    fi
}

stop_dozzle() {
    print_status "Deteniendo Dozzle..."
    
    cd "$DOCKER_DIR" || {
        print_error "No se pudo acceder al directorio Docker: $DOCKER_DIR"
        return 1
    }
    
    docker-compose stop dozzle
    docker-compose rm -f dozzle
    
    print_success "Dozzle detenido"
}

show_status() {
    print_status "Estado de Dozzle:"
    
    if docker ps | grep -q "trivance_dozzle"; then
        print_success "✅ Dozzle está corriendo"
        echo -e "${CYAN}   🌐 URL: http://localhost:9999${NC}"
        echo -e "${CYAN}   📊 Puerto: 9999${NC}"
        echo -e "${CYAN}   🔍 Filtrando: contenedores trivance_*${NC}"
        
        # Mostrar contenedores monitoreados
        echo -e "\n${BLUE}📦 Contenedores monitoreados:${NC}"
        docker ps --filter "name=trivance_*" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || true
    else
        print_warning "❌ Dozzle no está corriendo"
        echo -e "${YELLOW}   Usa: $0 start${NC}"
    fi
}

show_logs() {
    print_status "Logs de Dozzle:"
    docker logs trivance_dozzle --tail=50 -f
}

open_browser() {
    print_status "Abriendo Dozzle en el navegador..."
    
    if docker ps | grep -q "trivance_dozzle"; then
        # Detectar OS y abrir navegador
        case "$(uname -s)" in
            Darwin)  # macOS
                open http://localhost:9999
                ;;
            Linux)
                if command -v xdg-open &> /dev/null; then
                    xdg-open http://localhost:9999
                else
                    print_warning "No se pudo abrir el navegador automáticamente"
                    echo -e "${CYAN}Accede manualmente a: http://localhost:9999${NC}"
                fi
                ;;
            *)
                print_warning "OS no soportado para abrir navegador automáticamente"
                echo -e "${CYAN}Accede manualmente a: http://localhost:9999${NC}"
                ;;
        esac
        
        print_success "Si no se abrió automáticamente, ve a: http://localhost:9999"
    else
        print_error "Dozzle no está corriendo. Inicia primero con: $0 start"
        return 1
    fi
}

show_help() {
    print_banner
    echo ""
    echo "📊 Gestión del monitor de logs Dozzle para Trivance"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start    🚀 Iniciar Dozzle"
    echo "  stop     🛑 Detener Dozzle"
    echo "  status   📊 Ver estado de Dozzle"
    echo "  logs     📝 Ver logs de Dozzle"
    echo "  open     🌐 Abrir Dozzle en navegador"
    echo "  restart  🔄 Reiniciar Dozzle"
    echo "  help     ❓ Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start     # Iniciar monitor de logs"
    echo "  $0 open      # Abrir en navegador"
    echo "  $0 status    # Ver estado actual"
    echo ""
    echo "🌐 URL: http://localhost:9999"
    echo "📊 Filtra automáticamente contenedores 'trivance_*'"
}

restart_dozzle() {
    print_status "Reiniciando Dozzle..."
    stop_dozzle
    sleep 2
    start_dozzle
}

# Main switch
case "${1:-}" in
    "start")
        print_banner
        start_dozzle
        ;;
    "stop")
        print_banner
        stop_dozzle
        ;;
    "status")
        print_banner
        show_status
        ;;
    "logs")
        print_banner
        show_logs
        ;;
    "open")
        print_banner
        open_browser
        ;;
    "restart")
        print_banner
        restart_dozzle
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        print_error "Comando desconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
