#!/bin/bash
# Trivance Platform - Punto de entrada único
# Script inteligente que detecta el contexto y sugiere acciones

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="$(cd "${CONFIG_DIR}/.." && pwd)"

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🚀 TRIVANCE PLATFORM                               ║
║                         Sistema de Gestión Unificado                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Detectar estado del sistema
detect_system_state() {
    local state="not_setup"
    
    # Verificar si está configurado
    if [[ -d "${WORKSPACE_DIR}/ms_level_up_management" ]] && \
       [[ -d "${WORKSPACE_DIR}/ms_trivance_auth" ]] && \
       [[ -d "${WORKSPACE_DIR}/level_up_backoffice" ]] && \
       [[ -d "${WORKSPACE_DIR}/trivance-mobile" ]]; then
        state="configured"
    fi
    
    # Verificar si hay servicios corriendo
    if command -v pm2 &> /dev/null && pm2 list 2>/dev/null | grep -q "online"; then
        state="running"
    fi
    
    echo "$state"
}

# Obtener environment actual
get_current_env() {
    if [[ -f "${WORKSPACE_DIR}/envs/.current_environment" ]]; then
        cat "${WORKSPACE_DIR}/envs/.current_environment"
    else
        echo "local"
    fi
}

# Menú principal
show_main_menu() {
    local state="$1"
    local current_env=$(get_current_env)
    
    echo -e "${CYAN}Estado del sistema:${NC} "
    case "$state" in
        "not_setup")
            echo -e "  ${YELLOW}⚠️  No configurado${NC}"
            echo -e "  ${YELLOW}   Ejecuta la opción 1 para configurar${NC}"
            ;;
        "configured")
            echo -e "  ${GREEN}✅ Configurado${NC}"
            echo -e "  ${BLUE}📍 Environment: ${current_env}${NC}"
            ;;
        "running")
            echo -e "  ${GREEN}✅ Servicios ejecutándose${NC}"
            echo -e "  ${BLUE}📍 Environment: ${current_env}${NC}"
            ;;
    esac
    
    echo
    echo -e "${CYAN}Opciones disponibles:${NC}"
    echo
    
    if [[ "$state" == "not_setup" ]]; then
        echo -e "  ${GREEN}1)${NC} 🔧 Configurar entorno completo (setup inicial)"
        echo -e "  ${YELLOW}   Las demás opciones estarán disponibles después del setup${NC}"
    else
        echo -e "  ${GREEN}1)${NC} 🚀 Iniciar servicios"
        echo -e "  ${GREEN}2)${NC} 📊 Ver estado de servicios"
        echo -e "  ${GREEN}3)${NC} 🔄 Cambiar environment (actual: ${current_env})"
        echo -e "  ${GREEN}4)${NC} 🛑 Detener servicios"
        echo -e "  ${GREEN}5)${NC} 🔍 Verificar salud del sistema"
        echo -e "  ${GREEN}6)${NC} 📚 Ver documentación"
        echo -e "  ${GREEN}7)${NC} 🗑️  Limpiar y reconfigurar"
    fi
    
    echo -e "  ${GREEN}0)${NC} 🚪 Salir"
    echo
}

# Ejecutar opción
execute_option() {
    local option="$1"
    local state="$2"
    
    # Si no está configurado, solo permitir setup
    if [[ "$state" == "not_setup" && "$option" != "1" && "$option" != "0" ]]; then
        echo -e "${RED}❌ Primero debes configurar el entorno (opción 1)${NC}"
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    case "$option" in
        "1")
            if [[ "$state" == "not_setup" ]]; then
                echo -e "${BLUE}🔧 Iniciando configuración completa...${NC}"
                "${CONFIG_DIR}/setup.sh"
            else
                echo -e "${BLUE}🚀 Iniciando servicios...${NC}"
                if ! command -v pm2 &> /dev/null; then
                    echo -e "${YELLOW}Instalando PM2...${NC}"
                    npm install -g pm2
                fi
                pm2 start "${CONFIG_DIR}/../ecosystem.config.js" 2>/dev/null || {
                    "${CONFIG_DIR}/start-all.sh"
                }
            fi
            ;;
        "2")
            echo -e "${BLUE}📊 Estado de servicios:${NC}"
            pm2 status
            ;;
        "3")
            echo -e "${BLUE}🔄 Cambiar environment:${NC}"
            echo "  1) local"
            echo "  2) qa"
            echo "  3) production"
            read -p "Selecciona environment: " env_option
            case "$env_option" in
                "1") env="local" ;;
                "2") env="qa" ;;
                "3") env="production" ;;
                *) echo -e "${RED}Opción inválida${NC}"; return ;;
            esac
            "${CONFIG_DIR}/scripts/envs.sh" switch "$env"
            ;;
        "4")
            echo -e "${BLUE}🛑 Deteniendo servicios...${NC}"
            pm2 stop all
            ;;
        "5")
            echo -e "${BLUE}🔍 Verificando salud del sistema...${NC}"
            echo
            echo "Estado de servicios PM2:"
            pm2 status
            echo
            echo "Verificando endpoints:"
            echo -n "• Auth Service (3001): "
            curl -s http://localhost:3001/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
            echo -n "• Management API (3000): "
            curl -s http://localhost:3000/health >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
            echo -n "• Frontend (5173): "
            curl -s http://localhost:5173 >/dev/null 2>&1 && echo -e "${GREEN}✅ OK${NC}" || echo -e "${RED}❌ No responde${NC}"
            echo
            ;;
        "6")
            echo -e "${BLUE}📚 Documentación disponible:${NC}"
            echo
            echo "  📖 README principal: ${WORKSPACE_DIR}/README.md"
            echo "  🤖 Claude Config: Ejecuta /init después del setup"
            echo "  🎛️  Environments: ${WORKSPACE_DIR}/envs/ENVIRONMENTS.md"
            echo "  🚀 Comandos: ${CONFIG_DIR}/docs/COMMANDS.md"
            echo
            ;;
        "7")
            echo -e "${YELLOW}⚠️  Esto eliminará toda la configuración actual${NC}"
            read -p "¿Estás seguro? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                "${CONFIG_DIR}/scripts/utils/clean-workspace.sh"
                echo -e "${GREEN}✅ Workspace limpio. Ejecuta opción 1 para reconfigurar${NC}"
            fi
            ;;
        "0")
            echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    if [[ "$option" != "0" ]]; then
        echo
        read -p "Presiona Enter para continuar..."
    fi
}

# Main
main() {
    while true; do
        show_banner
        local state=$(detect_system_state)
        show_main_menu "$state"
        
        read -p "Selecciona una opción: " option
        execute_option "$option" "$state"
    done
}

# Si se pasa un argumento, ejecutarlo directamente
if [[ $# -gt 0 ]]; then
    case "$1" in
        "start")
            if ! command -v pm2 &> /dev/null; then
                echo "Instalando PM2..."
                npm install -g pm2
            fi
            pm2 start "${CONFIG_DIR}/../ecosystem.config.js" 2>/dev/null || {
                "${CONFIG_DIR}/start-all.sh"
            }
            ;;
        "stop")
            pm2 stop all
            ;;
        "status")
            pm2 status
            ;;
        "setup")
            "${CONFIG_DIR}/setup.sh"
            ;;
        *)
            echo "Uso: $0 [start|stop|status|setup]"
            exit 1
            ;;
    esac
else
    # Modo interactivo
    main
fi