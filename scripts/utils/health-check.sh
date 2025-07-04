#!/bin/bash

# Health check script para servicios de Trivance
# Verifica que todos los servicios estén funcionando correctamente

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Configuración de servicios - Compatible con bash 3.x
get_service_url() {
    case "$1" in
        "auth") echo "http://localhost:3001/health" ;;
        "management") echo "http://localhost:3000/health" ;;
        "frontend") echo "http://localhost:5173" ;;
        *) echo "" ;;
    esac
}

get_service_name() {
    case "$1" in
        "auth") echo "Auth Service" ;;
        "management") echo "Management API" ;;
        "frontend") echo "Frontend React" ;;
        *) echo "" ;;
    esac
}

get_service_port() {
    case "$1" in
        "auth") echo "3001" ;;
        "management") echo "3000" ;;
        "frontend") echo "5173" ;;
        *) echo "" ;;
    esac
}

# Lista de servicios
SERVICES_LIST="auth management frontend"

show_health_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                           🏥 HEALTH CHECK TRIVANCE                          ║
║                    Verificación de Estado de Servicios                      ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

check_port_availability() {
    local port="$1"
    local service_name="$2"
    
    if command -v nc >/dev/null 2>&1; then
        if nc -z localhost "$port" 2>/dev/null; then
            return 0  # Puerto está ocupado (servicio corriendo)
        else
            return 1  # Puerto libre (servicio no corriendo)
        fi
    elif command -v lsof >/dev/null 2>&1; then
        if lsof -i:"$port" >/dev/null 2>&1; then
            return 0  # Puerto está ocupado
        else
            return 1  # Puerto libre
        fi
    else
        warn "⚠️  No se puede verificar puerto $port - nc/lsof no disponibles"
        return 2  # No se puede verificar
    fi
}

check_service_health() {
    local service_key="$1"
    local url=$(get_service_url "$service_key")
    local name=$(get_service_name "$service_key")
    local port=$(get_service_port "$service_key")
    
    info "🔍 Verificando ${name} (Puerto ${port})..."
    
    # Verificar si el puerto está en uso
    local port_status
    if check_port_availability "$port" "$name"; then
        port_status="OCUPADO"
    else
        port_status="LIBRE"
    fi
    
    # Verificar respuesta HTTP
    local http_status="N/A"
    local response_time="N/A"
    
    if command -v curl >/dev/null 2>&1; then
        local start_time end_time
        start_time=$(date +%s%3N)
        
        if curl -s -f -m 10 "$url" >/dev/null 2>&1; then
            end_time=$(date +%s%3N)
            response_time=$((end_time - start_time))
            http_status="OK"
        else
            http_status="ERROR"
        fi
    fi
    
    # Generar reporte del servicio
    local status_symbol=""
    local status_color=""
    local overall_status=""
    
    case "$service_key" in
        "frontend")
            # Para frontend, solo verificamos puerto ya que no tiene endpoint /health
            if [[ "$port_status" == "OCUPADO" ]]; then
                status_symbol="✅"
                status_color="$GREEN"
                overall_status="SALUDABLE"
            else
                status_symbol="❌"
                status_color="$RED"
                overall_status="NO DISPONIBLE"
            fi
            ;;
        *)
            # Para APIs, verificamos tanto puerto como respuesta HTTP
            if [[ "$port_status" == "OCUPADO" && "$http_status" == "OK" ]]; then
                status_symbol="✅"
                status_color="$GREEN"
                overall_status="SALUDABLE"
            elif [[ "$port_status" == "OCUPADO" && "$http_status" == "ERROR" ]]; then
                status_symbol="⚠️"
                status_color="$YELLOW"
                overall_status="PUERTO OCUPADO - HEALTH CHECK FALLÓ"
            else
                status_symbol="❌"
                status_color="$RED"
                overall_status="NO DISPONIBLE"
            fi
            ;;
    esac
    
    # Mostrar resultado
    echo -e "   ${status_symbol} ${status_color}${name}${NC}: ${overall_status}"
    echo -e "      📍 URL: ${url}"
    echo -e "      🔌 Puerto ${port}: ${port_status}"
    
    if [[ "$response_time" != "N/A" ]]; then
        echo -e "      ⏱️  Tiempo respuesta: ${response_time}ms"
    fi
    
    echo
    
    # Retornar código según estado
    case "$overall_status" in
        "SALUDABLE")
            return 0
            ;;
        "PUERTO OCUPADO - HEALTH CHECK FALLÓ")
            return 1
            ;;
        *)
            return 2
            ;;
    esac
}

check_repository_status() {
    log "Verificando estado de repositorios..."
    
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local repo_count=0
    
    for repo in "${repos[@]}"; do
        local repo_path="${WORKSPACE_DIR}/${repo}"
        
        if [[ -d "$repo_path" ]]; then
            if [[ -f "${repo_path}/package.json" ]]; then
                success "✅ ${repo}: Repositorio disponible"
                ((repo_count++))
            else
                warn "⚠️  ${repo}: Directorio existe pero falta package.json"
            fi
        else
            error "❌ ${repo}: Repositorio no encontrado"
        fi
    done
    
    info "📊 Repositorios disponibles: ${repo_count}/${#repos[@]}"
    echo
}

check_development_environment() {
    log "Verificando entorno de desarrollo..."
    
    # Verificar herramientas esenciales
    local tools=(
        "node:Node.js"
        "npm:npm package manager"
        "git:Git version control"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        
        if command -v "$tool" >/dev/null 2>&1; then
            local version
            case "$tool" in
                "node")
                    version=$(node --version)
                    ;;
                "npm")
                    version=$(npm --version)
                    ;;
                "git")
                    version=$(git --version | awk '{print $3}')
                    ;;
            esac
            success "✅ ${desc}: ${version}"
        else
            error "❌ ${desc}: No instalado"
        fi
    done
    
    echo
}

check_database_connections() {
    log "Verificando conexiones de base de datos..."
    
    # PostgreSQL
    if command -v psql >/dev/null 2>&1; then
        if psql "postgresql://trivance_dev:trivance_dev_pass@localhost:5432/trivance_development" -c "SELECT 1;" >/dev/null 2>&1; then
            success "✅ PostgreSQL: Conexión exitosa"
        else
            warn "⚠️  PostgreSQL: Conexión falló (es normal si no está configurado)"
        fi
    else
        warn "⚠️  PostgreSQL: Cliente no instalado"
    fi
    
    # MongoDB
    if command -v mongosh >/dev/null 2>&1; then
        if mongosh "mongodb://localhost:27017/trivance_auth_development" --eval "db.runCommand('ping')" >/dev/null 2>&1; then
            success "✅ MongoDB: Conexión exitosa"
        else
            warn "⚠️  MongoDB: Conexión falló (es normal si no está configurado)"
        fi
    elif command -v mongo >/dev/null 2>&1; then
        if mongo "mongodb://localhost:27017/trivance_auth_development" --eval "db.runCommand('ping')" >/dev/null 2>&1; then
            success "✅ MongoDB: Conexión exitosa (legacy client)"
        else
            warn "⚠️  MongoDB: Conexión falló (es normal si no está configurado)"
        fi
    else
        warn "⚠️  MongoDB: Cliente no instalado"
    fi
    
    echo
}

generate_health_report() {
    local healthy_services="$1"
    local total_services="$2"
    local start_time="$3"
    local end_time="$4"
    
    local duration=$((end_time - start_time))
    local health_percentage=$((healthy_services * 100 / total_services))
    
    echo
    log "════════════════════════════════════════════════════════════════════════════════"
    echo -e "${PURPLE}📊 REPORTE DE SALUD DEL SISTEMA${NC}"
    log "════════════════════════════════════════════════════════════════════════════════"
    echo
    echo -e "⏱️  ${BLUE}Tiempo de verificación:${NC} ${duration}s"
    echo -e "🎯 ${BLUE}Servicios saludables:${NC} ${healthy_services}/${total_services} (${health_percentage}%)"
    
    if [[ $health_percentage -eq 100 ]]; then
        echo -e "🎉 ${GREEN}¡Sistema completamente saludable!${NC}"
        echo -e "✅ ${GREEN}Todos los servicios están funcionando correctamente${NC}"
    elif [[ $health_percentage -ge 66 ]]; then
        echo -e "⚠️  ${YELLOW}Sistema parcialmente saludable${NC}"
        echo -e "🔧 ${YELLOW}Algunos servicios necesitan atención${NC}"
    else
        echo -e "❌ ${RED}Sistema con problemas críticos${NC}"
        echo -e "🚨 ${RED}Múltiples servicios no están funcionando${NC}"
    fi
    
    echo
    echo -e "${BLUE}Para iniciar servicios:${NC}"
    echo "   cd ms_trivance_auth && npm run start:dev     # Auth Service"
    echo "   cd ms_level_up_management && npm run start:dev  # Management API"
    echo "   cd level_up_backoffice && npm run dev          # Frontend"
    echo "   cd trivance-mobile && npm start               # Mobile (Expo)"
    
    log "════════════════════════════════════════════════════════════════════════════════"
}

main() {
    local start_time end_time
    start_time=$(date +%s)
    
    show_health_banner
    
    # Verificaciones previas
    check_repository_status
    check_development_environment
    check_database_connections
    
    # Health check de servicios
    log "Iniciando health check de servicios..."
    echo
    
    local healthy_services=0
    local total_services=0
    
    for service_key in $SERVICES_LIST; do
        ((total_services++))
        if check_service_health "$service_key"; then
            ((healthy_services++))
        fi
    done
    
    end_time=$(date +%s)
    
    # Generar reporte final
    generate_health_report "$healthy_services" "$total_services" "$start_time" "$end_time"
    
    # Código de salida basado en la salud del sistema
    local health_percentage=$((healthy_services * 100 / total_services))
    
    if [[ $health_percentage -eq 100 ]]; then
        exit 0  # Todo perfecto
    elif [[ $health_percentage -ge 66 ]]; then
        exit 1  # Advertencias
    else
        exit 2  # Errores críticos
    fi
}

# Función para health check rápido (solo servicios)
quick_check() {
    echo "🔍 Health check rápido..."
    
    local healthy=0
    local total=0
    
    for service_key in $SERVICES_LIST; do
        ((total++))
        local port=$(get_service_port "$service_key")
        local name=$(get_service_name "$service_key")
        
        if check_port_availability "$port" "$name"; then
            echo -e "✅ ${name} (Puerto ${port})"
            ((healthy++))
        else
            echo -e "❌ ${name} (Puerto ${port})"
        fi
    done
    
    echo "📊 Servicios activos: ${healthy}/${total}"
}

# Manejar argumentos
case "${1:-full}" in
    "quick"|"--quick"|"-q")
        quick_check
        ;;
    "help"|"--help"|"-h")
        echo "Health check para servicios de Trivance"
        echo ""
        echo "Uso: $0 [OPCIÓN]"
        echo ""
        echo "Opciones:"
        echo "  (sin argumentos)  Health check completo"
        echo "  quick, -q         Health check rápido (solo servicios)"
        echo "  help, -h          Mostrar esta ayuda"
        echo ""
        ;;
    *)
        main "$@"
        ;;
esac