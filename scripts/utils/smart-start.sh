#!/bin/bash

# Smart Start - Inicio inteligente de servicios con validación automática
# Soluciona el problema de validación manual detectado

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

show_smart_start_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🧠 SMART START TRIVANCE                              ║
║                   Inicio Inteligente con Validación Auto                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

start_service_smart() {
    local service_name="$1"
    local service_dir="$2"
    local service_command="$3"
    local service_port="$4"
    local max_wait="${5:-30}"
    
    info "🚀 Iniciando ${service_name}..."
    
    # Verificar si el directorio existe
    if [[ ! -d "$service_dir" ]]; then
        error "❌ Directorio ${service_dir} no encontrado"
        return 1
    fi
    
    # Terminar procesos existentes en el puerto
    if command -v lsof >/dev/null 2>&1; then
        local existing_pid
        existing_pid=$(lsof -ti:"$service_port" 2>/dev/null || true)
        if [[ -n "$existing_pid" ]]; then
            warn "⚠️  Terminando proceso existente en puerto ${service_port} (PID: ${existing_pid})"
            kill -9 "$existing_pid" 2>/dev/null || true
            sleep 2
        fi
    fi
    
    # Iniciar el servicio en segundo plano
    info "📦 Ejecutando: cd ${service_dir} && ${service_command}"
    (cd "$service_dir" && eval "$service_command" > /dev/null 2>&1 &)
    
    # Esperar y validar que el servicio esté funcionando
    info "⏳ Esperando que ${service_name} esté disponible (máximo ${max_wait}s)..."
    
    local attempt=1
    local max_attempts=$((max_wait / 2))
    local service_ready=false
    
    while [[ $attempt -le $max_attempts ]]; do
        sleep 2
        
        # Verificar si el puerto está ocupado
        if command -v lsof >/dev/null 2>&1; then
            if lsof -i:"$service_port" >/dev/null 2>&1; then
                # Puerto ocupado, verificar si responde (para APIs)
                if [[ "$service_name" == *"API"* || "$service_name" == *"Service"* ]]; then
                    # Intentar conexión HTTP
                    if curl -s -f -m 3 "http://localhost:${service_port}" >/dev/null 2>&1; then
                        service_ready=true
                        break
                    fi
                else
                    # Para frontend, solo verificar que el puerto esté ocupado
                    service_ready=true
                    break
                fi
            fi
        fi
        
        echo -n "."
        ((attempt++))
    done
    
    echo
    
    if [[ "$service_ready" == "true" ]]; then
        success "✅ ${service_name} iniciado exitosamente en puerto ${service_port}"
        
        # Verificación adicional de salud específica
        case "$service_name" in
            *"Management"*)
                # Verificar GraphQL específicamente
                sleep 3
                if curl -s -H "Content-Type: application/json" \
                   -d '{"query":"{__schema{types{name}}}"}' \
                   "http://localhost:${service_port}/graphql" >/dev/null 2>&1; then
                    success "🎯 GraphQL endpoint verificado"
                else
                    warn "⚠️  GraphQL endpoint no responde aún (puede necesitar más tiempo)"
                fi
                ;;
        esac
        
        return 0
    else
        error "❌ ${service_name} no pudo iniciarse correctamente"
        
        # Diagnóstico del fallo
        if command -v lsof >/dev/null 2>&1; then
            local port_user
            port_user=$(lsof -ti:"$service_port" 2>/dev/null || echo "ninguno")
            if [[ "$port_user" != "ninguno" ]]; then
                warn "🔍 Puerto ${service_port} está ocupado por PID: ${port_user}"
            else
                warn "🔍 Puerto ${service_port} está libre - el servicio no se inició"
            fi
        fi
        
        # Sugerir solución
        warn "💡 Intenta ejecutar manualmente: cd ${service_dir} && ${service_command}"
        return 1
    fi
}

start_all_services_smart() {
    local services_started=0
    local total_services=4
    
    # Auth Service
    if start_service_smart "Auth Service" "ms_trivance_auth" "npm run start:dev" "3001" 30; then
        ((services_started++))
    fi
    
    echo
    
    # Management API  
    if start_service_smart "Management API" "ms_level_up_management" "npm run start:dev" "3000" 45; then
        ((services_started++))
    fi
    
    echo
    
    # Frontend
    if start_service_smart "Frontend React" "level_up_backoffice" "npm run dev" "5173" 25; then
        ((services_started++))
    fi
    
    echo
    
    # Mobile (opcional - solo si se especifica)
    if [[ "${1:-}" == "mobile" || "${1:-}" == "all" ]]; then
        if start_service_smart "Mobile App" "trivance-mobile" "npm start" "8081" 30; then
            ((services_started++))
        fi
        total_services=4
    else
        total_services=3
        info "📱 Mobile app omitida (usa 'mobile' para incluirla)"
        ((services_started++)) # Contar como "no requerida"
    fi
    
    return $((total_services - services_started))
}

smart_health_check() {
    info "🏥 Ejecutando health check inteligente..."
    
    # Ejecutar health check mejorado
    if "${SCRIPT_DIR}/health-check.sh" quick; then
        success "🎉 Todos los servicios están funcionando correctamente"
        return 0
    else
        warn "⚠️  Algunos servicios tienen problemas"
        
        # Intentar corrección automática
        info "🔧 Intentando corrección automática..."
        "${SCRIPT_DIR}/health-check.sh" fix
        
        # Verificar de nuevo
        echo
        info "🔍 Verificación final..."
        "${SCRIPT_DIR}/health-check.sh" quick
        return $?
    fi
}

main() {
    local start_time end_time
    start_time=$(date +%s)
    
    show_smart_start_banner
    
    info "Iniciando servicios Trivance con validación automática..."
    echo
    
    # Iniciar servicios
    if start_all_services_smart "$@"; then
        success "🎉 Todos los servicios iniciados exitosamente"
    else
        error "❌ Algunos servicios fallaron al iniciar"
    fi
    
    echo
    
    # Health check automático
    smart_health_check
    
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo
    log "════════════════════════════════════════════════════════════════════════════════"
    echo -e "${PURPLE}🏁 INICIO INTELIGENTE COMPLETADO${NC}"
    log "════════════════════════════════════════════════════════════════════════════════"
    echo -e "⏱️  ${BLUE}Tiempo total:${NC} ${duration}s"
    echo
    echo -e "${GREEN}URLs disponibles:${NC}"
    echo "  🔐 Auth Service:     http://localhost:3001"  
    echo "  🚀 Management API:   http://localhost:3000"
    echo "  🎯 GraphQL:          http://localhost:3000/graphql"
    echo "  🌐 Frontend:         http://localhost:5173"
    if [[ "${1:-}" == "mobile" || "${1:-}" == "all" ]]; then
        echo "  📱 Mobile:           http://localhost:8081"
    fi
    echo
    echo -e "${BLUE}Para monitoreo continuo:${NC}"
    echo "  ./health-check.sh           # Health check completo"
    echo "  ./health-check.sh quick     # Verificación rápida"
    echo "  ./health-check.sh fix       # Corrección automática"
    
    log "════════════════════════════════════════════════════════════════════════════════"
}

# Manejar argumentos
case "${1:-}" in
    "help"|"--help"|"-h")
        echo "Smart Start - Inicio inteligente de servicios Trivance"
        echo ""
        echo "Uso: $0 [OPCIÓN]"
        echo ""
        echo "Opciones:"
        echo "  (sin argumentos)  Iniciar servicios principales (sin mobile)"
        echo "  mobile           Incluir aplicación móvil"
        echo "  all              Iniciar todos los servicios"
        echo "  help, -h         Mostrar esta ayuda"
        echo ""
        echo "Características:"
        echo "  • Validación automática de inicio"
        echo "  • Detección y corrección de procesos zombie"
        echo "  • Health check automático post-inicio"
        echo "  • Diagnóstico inteligente de problemas"
        echo "  • Tiempo de espera configurado por servicio"
        echo ""
        ;;
    *)
        main "$@"
        ;;
esac