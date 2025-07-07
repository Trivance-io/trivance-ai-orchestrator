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
    local port_process=""
    if check_port_availability "$port" "$name"; then
        port_status="OCUPADO"
        # Obtener información del proceso que usa el puerto
        if command -v lsof >/dev/null 2>&1; then
            port_process=$(lsof -ti:"$port" 2>/dev/null | head -1)
        fi
    else
        port_status="LIBRE"
    fi
    
    # Verificar respuesta HTTP con múltiples intentos
    local http_status="N/A"
    local response_time="N/A"
    local connection_error=""
    
    if command -v curl >/dev/null 2>&1; then
        local start_time end_time
        local max_attempts=3
        local attempt=1
        
        while [[ $attempt -le $max_attempts ]]; do
            start_time=$(date +%s%3N)
            
            # Capturar el error específico de curl
            local curl_output
            curl_output=$(curl -s -f -m 5 "$url" 2>&1)
            local curl_exit_code=$?
            
            if [[ $curl_exit_code -eq 0 ]]; then
                end_time=$(date +%s%3N)
                response_time=$((end_time - start_time))
                http_status="OK"
                break
            else
                # Analizar el tipo de error
                if echo "$curl_output" | grep -q "Connection refused"; then
                    connection_error="PUERTO_RECHAZA_CONEXIONES"
                elif echo "$curl_output" | grep -q "Failed to connect"; then
                    connection_error="NO_SE_PUEDE_CONECTAR"
                elif echo "$curl_output" | grep -q "Empty reply"; then
                    connection_error="RESPUESTA_VACIA"
                else
                    connection_error="ERROR_HTTP"
                fi
                
                if [[ $attempt -eq $max_attempts ]]; then
                    http_status="ERROR"
                else
                    # Esperar un poco antes del siguiente intento
                    sleep 1
                fi
            fi
            
            ((attempt++))
        done
    fi
    
    # Generar reporte del servicio con diagnóstico automático
    local status_symbol=""
    local status_color=""
    local overall_status=""
    local diagnostic_info=""
    local auto_fix_suggestion=""
    
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
                auto_fix_suggestion="cd level_up_backoffice && npm run dev"
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
                
                # Diagnóstico específico del problema
                case "$connection_error" in
                    "PUERTO_RECHAZA_CONEXIONES")
                        diagnostic_info="🔍 El puerto está ocupado pero rechaza conexiones HTTP"
                        auto_fix_suggestion="Proceso zombie detectado. Ejecutar: lsof -ti:$port | xargs kill -9"
                        ;;
                    "NO_SE_PUEDE_CONECTAR")
                        diagnostic_info="🔍 El proceso en el puerto no responde a HTTP"
                        if [[ -n "$port_process" ]]; then
                            diagnostic_info="$diagnostic_info (PID: $port_process)"
                            auto_fix_suggestion="kill -9 $port_process && cd ${service_key/management/ms_level_up_management} && npm run start:dev"
                        fi
                        ;;
                    "RESPUESTA_VACIA")
                        diagnostic_info="🔍 El servicio responde pero con respuesta vacía (posible inicialización)"
                        auto_fix_suggestion="Esperar 10 segundos - el servicio puede estar iniciando"
                        ;;
                    *)
                        diagnostic_info="🔍 Error HTTP no específico"
                        auto_fix_suggestion="Verificar logs del servicio"
                        ;;
                esac
            else
                status_symbol="❌"
                status_color="$RED"
                overall_status="NO DISPONIBLE"
                if [[ "$service_key" == "management" ]]; then
                    auto_fix_suggestion="cd ms_level_up_management && npm run start:dev"
                elif [[ "$service_key" == "auth" ]]; then
                    auto_fix_suggestion="cd ms_trivance_auth && npm run start:dev"
                fi
            fi
            ;;
    esac
    
    # Mostrar resultado con diagnóstico mejorado
    echo -e "   ${status_symbol} ${status_color}${name}${NC}: ${overall_status}"
    echo -e "      📍 URL: ${url}"
    echo -e "      🔌 Puerto ${port}: ${port_status}"
    
    if [[ "$response_time" != "N/A" ]]; then
        echo -e "      ⏱️  Tiempo respuesta: ${response_time}ms"
    fi
    
    # Mostrar información de diagnóstico si existe
    if [[ -n "$diagnostic_info" ]]; then
        echo -e "      ${diagnostic_info}"
    fi
    
    # Mostrar sugerencia de corrección automática si existe
    if [[ -n "$auto_fix_suggestion" ]]; then
        echo -e "      💡 ${BLUE}Solución sugerida:${NC} ${auto_fix_suggestion}"
    fi
    
    # Mostrar información del proceso si está disponible
    if [[ -n "$port_process" && "$port_status" == "OCUPADO" ]]; then
        echo -e "      🔧 Proceso activo: PID ${port_process}"
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

# Función para corrección automática de problemas comunes
auto_fix_services() {
    echo "🔧 Iniciando corrección automática de servicios..."
    echo
    
    local fixed_services=0
    local total_issues=0
    
    for service_key in $SERVICES_LIST; do
        local port=$(get_service_port "$service_key")
        local name=$(get_service_name "$service_key")
        
        echo "🔍 Verificando ${name}..."
        
        # Verificar si el puerto está ocupado pero no responde
        if check_port_availability "$port" "$name"; then
            # Puerto ocupado, verificar si responde
            local url=$(get_service_url "$service_key")
            
            if ! curl -s -f -m 3 "$url" >/dev/null 2>&1; then
                ((total_issues++))
                warn "⚠️  ${name}: Puerto ocupado pero no responde"
                
                # Obtener PID del proceso
                local pid
                if command -v lsof >/dev/null 2>&1; then
                    pid=$(lsof -ti:"$port" 2>/dev/null | head -1)
                    
                    if [[ -n "$pid" ]]; then
                        info "🔧 Terminando proceso zombie (PID: ${pid})..."
                        if kill -9 "$pid" 2>/dev/null; then
                            success "✅ Proceso zombie terminado"
                            
                            # Reiniciar el servicio
                            info "🚀 Reiniciando ${name}..."
                            case "$service_key" in
                                "management")
                                    (cd ms_level_up_management && npm run start:dev > /dev/null 2>&1 &)
                                    ;;
                                "auth")
                                    (cd ms_trivance_auth && npm run start:dev > /dev/null 2>&1 &)
                                    ;;
                                "frontend")
                                    (cd level_up_backoffice && npm run dev > /dev/null 2>&1 &)
                                    ;;
                            esac
                            
                            # Esperar un momento y verificar
                            sleep 3
                            if check_port_availability "$port" "$name"; then
                                success "✅ ${name} reiniciado exitosamente"
                                ((fixed_services++))
                            else
                                error "❌ Falló el reinicio de ${name}"
                            fi
                        else
                            error "❌ No se pudo terminar el proceso (permisos?)"
                        fi
                    fi
                fi
            fi
        else
            # Puerto libre, servicio no está corriendo
            ((total_issues++))
            info "🚀 Iniciando ${name}..."
            
            case "$service_key" in
                "management")
                    (cd ms_level_up_management && npm run start:dev > /dev/null 2>&1 &)
                    ;;
                "auth")
                    (cd ms_trivance_auth && npm run start:dev > /dev/null 2>&1 &)
                    ;;
                "frontend")
                    (cd level_up_backoffice && npm run dev > /dev/null 2>&1 &)
                    ;;
            esac
            
            # Esperar y verificar
            sleep 5
            if check_port_availability "$port" "$name"; then
                success "✅ ${name} iniciado exitosamente"
                ((fixed_services++))
            else
                error "❌ Falló el inicio de ${name}"
            fi
        fi
        
        echo
    done
    
    # Reporte final
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${PURPLE}📊 REPORTE DE CORRECCIÓN AUTOMÁTICA${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "🔧 Problemas detectados: ${total_issues}"
    echo -e "✅ Servicios corregidos: ${fixed_services}"
    
    if [[ $fixed_services -eq $total_issues && $total_issues -gt 0 ]]; then
        echo -e "🎉 ${GREEN}¡Todos los problemas fueron corregidos automáticamente!${NC}"
    elif [[ $fixed_services -gt 0 ]]; then
        echo -e "⚠️  ${YELLOW}Algunos problemas fueron corregidos${NC}"
    elif [[ $total_issues -eq 0 ]]; then
        echo -e "✅ ${GREEN}No se detectaron problemas${NC}"
    else
        echo -e "❌ ${RED}No se pudieron corregir los problemas automáticamente${NC}"
    fi
    
    echo
    echo "💡 Ejecuta './health-check.sh' para verificar el estado final"
}

# Manejar argumentos
case "${1:-full}" in
    "quick"|"--quick"|"-q")
        quick_check
        ;;
    "fix"|"--fix"|"-f"|"autofix")
        auto_fix_services
        ;;
    "fix-and-check"|"--fix-and-check")
        auto_fix_services
        echo
        echo "🔍 Ejecutando health check final..."
        echo
        main
        ;;
    "help"|"--help"|"-h")
        echo "Health check y corrección automática para servicios de Trivance"
        echo ""
        echo "Uso: $0 [OPCIÓN]"
        echo ""
        echo "Opciones:"
        echo "  (sin argumentos)     Health check completo con diagnóstico"
        echo "  quick, -q           Health check rápido (solo servicios)"
        echo "  fix, -f, autofix    Corrección automática de problemas comunes"
        echo "  fix-and-check       Corrección automática + health check final"
        echo "  help, -h            Mostrar esta ayuda"
        echo ""
        echo "Ejemplos:"
        echo "  ./health-check.sh           # Health check completo"
        echo "  ./health-check.sh quick     # Verificación rápida"
        echo "  ./health-check.sh fix       # Corregir problemas automáticamente"
        echo ""
        ;;
    *)
        main "$@"
        ;;
esac