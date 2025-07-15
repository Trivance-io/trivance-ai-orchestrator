#!/bin/bash

# 📊 Instalación rápida de Dozzle para Trivance Platform
# Este script agrega Dozzle a un docker-compose.yaml existente

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

print_banner() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}📊 Instalación Dozzle${NC}"
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

# Verificar Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker no está corriendo"
        return 1
    fi
    
    return 0
}

# Instalar Dozzle
install_dozzle() {
    local docker_compose_file="$1"
    
    print_status "Verificando si Dozzle ya está configurado..."
    
    if grep -q "dozzle:" "$docker_compose_file"; then
        print_warning "Dozzle ya está configurado en $docker_compose_file"
        return 0
    fi
    
    print_status "Agregando servicio Dozzle a docker-compose.yaml..."
    
    # Crear backup
    cp "$docker_compose_file" "${docker_compose_file}.backup.$(date +%Y%m%d_%H%M%S)"
    print_status "Backup creado: ${docker_compose_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Agregar Dozzle al final del archivo
    cat >> "$docker_compose_file" << 'EOF'

  # 📊 Log monitoring service
  dozzle:
    image: amir20/dozzle:latest
    container_name: trivance_dozzle
    restart: unless-stopped
    ports:
      - "9999:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - DOZZLE_LEVEL=info
      - DOZZLE_TAILSIZE=300
      - DOZZLE_FILTER=name=trivance_*
    networks:
      - trivance_network
    labels:
      - "dozzle.enable=true"
      - "dozzle.name=Trivance Logs"
EOF
    
    print_success "Dozzle agregado al docker-compose.yaml"
}

# Iniciar Dozzle
start_dozzle() {
    local docker_dir="$1"
    
    print_status "Iniciando Dozzle..."
    
    cd "$docker_dir" || {
        print_error "No se pudo acceder al directorio: $docker_dir"
        return 1
    }
    
    # Verificar si ya está corriendo
    if docker ps | grep -q "trivance_dozzle"; then
        print_warning "Dozzle ya está corriendo"
        return 0
    fi
    
    # Iniciar solo Dozzle
    docker-compose up -d dozzle
    
    if [ $? -eq 0 ]; then
        print_success "Dozzle iniciado correctamente"
        echo -e "${CYAN}🌐 Accede a: http://localhost:9999${NC}"
        
        # Mostrar contenedores monitoreados
        echo -e "\n${BLUE}📦 Contenedores que serán monitoreados:${NC}"
        docker ps --filter "name=trivance_*" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || \
        echo -e "${YELLOW}   No hay contenedores trivance_* corriendo${NC}"
        
        return 0
    else
        print_error "Error al iniciar Dozzle"
        return 1
    fi
}

# Main
main() {
    print_banner
    
    # Verificar Docker
    if ! check_docker; then
        exit 1
    fi
    
    # Detectar ubicación del proyecto
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/../.." && pwd)"
    local docker_dir="$project_root/trivance-dev-config/docker"
    local docker_compose_file="$docker_dir/docker-compose.yaml"
    
    print_status "Directorio del proyecto: $project_root"
    print_status "Archivo docker-compose: $docker_compose_file"
    
    # Verificar que existe el archivo docker-compose
    if [[ ! -f "$docker_compose_file" ]]; then
        print_error "No se encontró docker-compose.yaml en: $docker_compose_file"
        print_error "Asegúrate de estar en el workspace correcto de Trivance"
        exit 1
    fi
    
    # Instalar Dozzle
    install_dozzle "$docker_compose_file"
    
    # Preguntar si iniciar
    echo
    read -p "¿Deseas iniciar Dozzle ahora? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_dozzle "$docker_dir"
        
        echo
        echo -e "${GREEN}🎉 ¡Instalación completada!${NC}"
        echo -e "${CYAN}📊 Accede a Dozzle: http://localhost:9999${NC}"
        echo -e "${BLUE}📖 Documentación: trivance-dev-config/docs/DOZZLE.md${NC}"
        
        # Ofrecer abrir en navegador
        echo
        read -p "¿Abrir Dozzle en el navegador? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            case "$(uname -s)" in
                Darwin)  # macOS
                    open http://localhost:9999
                    ;;
                Linux)
                    if command -v xdg-open &> /dev/null; then
                        xdg-open http://localhost:9999
                    fi
                    ;;
            esac
        fi
    else
        echo -e "${YELLOW}Dozzle está configurado pero no iniciado${NC}"
        echo -e "${BLUE}Para iniciarlo después: docker-compose -f $docker_compose_file up -d dozzle${NC}"
    fi
}

# Mostrar ayuda
show_help() {
    print_banner
    echo ""
    echo "Instala y configura Dozzle para monitorear logs de Docker"
    echo ""
    echo "Uso: $0 [opción]"
    echo ""
    echo "Opciones:"
    echo "  help, -h, --help    Mostrar esta ayuda"
    echo "  install             Instalar Dozzle (por defecto)"
    echo ""
    echo "¿Qué hace este script?"
    echo "• Detecta automáticamente la configuración de Trivance"
    echo "• Agrega Dozzle al docker-compose.yaml existente"
    echo "• Crea un backup de seguridad"
    echo "• Configura filtros para contenedores Trivance"
    echo "• Opcionalmente inicia el servicio"
    echo ""
    echo "Después de la instalación:"
    echo "• Accede a http://localhost:9999"
    echo "• Usa ./trivance-dev-config/scripts/dozzle.sh para gestionar"
    echo "• Lee trivance-dev-config/docs/DOZZLE.md para más información"
}

# Manejar argumentos
case "${1:-install}" in
    "help"|"-h"|"--help")
        show_help
        ;;
    "install"|"")
        main
        ;;
    "--silent")
        # Modo silencioso para automatización
        main > /dev/null 2>&1
        ;;
    *)
        print_error "Opción desconocida: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
