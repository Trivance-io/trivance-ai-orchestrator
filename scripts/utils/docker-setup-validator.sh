#!/bin/bash

# 🔍 DOCKER SETUP VALIDATOR
# Valida que el setup automático funcione sin errores ni confusiones
# Garantiza experiencia perfecta para nuevos desarrolladores

set -euo pipefail

# Colores para feedback claro
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_check() { echo -e "${BLUE}[CHECK]${NC} $1"; }
log_ok() { echo -e "${GREEN}[✅ OK]${NC} $1"; }
log_fail() { echo -e "${RED}[❌ FAIL]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠️  WARN]${NC} $1"; }

# Validar Dockerfiles
validate_dockerfiles() {
    log_check "Validando Dockerfiles..."
    
    local repos=("ms_level_up_management" "level_up_backoffice" "ms_trivance_auth")
    local all_valid=true
    
    for repo in "${repos[@]}"; do
        local dockerfile_path="/Users/dariarcos/G-Lab/Prueba instalación desde cero/$repo/Dockerfile"
        local dockerignore_path="/Users/dariarcos/G-Lab/Prueba instalación desde cero/$repo/.dockerignore"
        
        if [[ -f "$dockerfile_path" ]]; then
            # Verificar que tiene multi-stage
            if grep -q "FROM.*AS development" "$dockerfile_path" && 
               grep -q "FROM.*AS production" "$dockerfile_path"; then
                log_ok "✅ $repo: Dockerfile multi-stage correcto"
            else
                log_fail "❌ $repo: Dockerfile sin multi-stage"
                all_valid=false
            fi
            
            # Verificar supresión de warnings Prisma
            if grep -q "PRISMA_DISABLE_WARNINGS=true" "$dockerfile_path"; then
                log_ok "✅ $repo: Warnings Prisma suprimidos"
            else
                log_warn "⚠️  $repo: Warnings Prisma no suprimidos (no crítico)"
            fi
        else
            log_fail "❌ $repo: Dockerfile no encontrado"
            all_valid=false
        fi
        
        if [[ -f "$dockerignore_path" ]]; then
            log_ok "✅ $repo: .dockerignore presente"
        else
            log_fail "❌ $repo: .dockerignore faltante"
            all_valid=false
        fi
    done
    
    return $([ "$all_valid" = true ] && echo 0 || echo 1)
}

# Test de build sin errores confusos
test_build_clarity() {
    log_check "Probando build sin errores confusos..."
    
    local test_output="/tmp/docker_build_test.log"
    
    # Test build del management service
    cd "/Users/dariarcos/G-Lab/Prueba instalación desde cero/ms_level_up_management"
    if docker build --target development -t test-mgmt:validation . >"$test_output" 2>&1; then
        
        # Verificar que no haya mensajes confusos
        local confusing_messages=0
        
        if grep -qi "error" "$test_output" && ! grep -qi "ERROR.*expected" "$test_output"; then
            confusing_messages=$((confusing_messages + 1))
        fi
        
        if grep -qi "failed" "$test_output" && ! grep -qi "FAILED.*expected" "$test_output"; then
            confusing_messages=$((confusing_messages + 1))
        fi
        
        # Verificar warnings suprimidos
        if grep -qi "Prisma failed to detect" "$test_output"; then
            log_warn "⚠️  Warnings de Prisma aún visibles - puede confundir usuarios"
        else
            log_ok "✅ Warnings de Prisma suprimidos correctamente"
        fi
        
        if [[ $confusing_messages -eq 0 ]]; then
            log_ok "✅ Build output limpio sin mensajes confusos"
        else
            log_fail "❌ Build output contiene $confusing_messages mensajes confusos"
            return 1
        fi
        
        # Limpiar imagen de test
        docker rmi test-mgmt:validation >/dev/null 2>&1 || true
        
    else
        log_fail "❌ Build de test falló"
        cat "$test_output"
        return 1
    fi
    
    cd - >/dev/null
    rm -f "$test_output"
    return 0
}

# Validar Smart Docker Manager
validate_smart_manager() {
    log_check "Validando Smart Docker Manager..."
    
    local manager_path="./smart-docker-manager.sh"
    
    if [[ -f "$manager_path" ]]; then
        # Verificar función docker_dev_mode
        if grep -q "docker_dev_mode()" "$manager_path"; then
            log_ok "✅ Función docker_dev_mode presente"
        else
            log_fail "❌ Función docker_dev_mode faltante"
            return 1
        fi
        
        # Verificar filtrado de warnings
        if grep -q "Prisma failed to detect" "$manager_path"; then
            log_ok "✅ Filtrado de warnings Prisma implementado"
        else
            log_warn "⚠️  Filtrado de warnings no implementado"
        fi
        
        # Verificar mensajes de feedback claros
        if grep -q "Los warnings de Prisma.*son NORMALES" "$manager_path"; then
            log_ok "✅ Mensajes explicativos para usuarios presentes"
        else
            log_fail "❌ Mensajes explicativos faltantes"
            return 1
        fi
    else
        log_fail "❌ Smart Docker Manager no encontrado"
        return 1
    fi
    
    return 0
}

# Función principal
main() {
    echo "🔍 VALIDADOR DE SETUP DOCKER AUTOMÁTICO"
    echo "==============================================="
    echo
    
    local all_tests_passed=true
    
    # Ejecutar validaciones
    if ! validate_dockerfiles; then
        all_tests_passed=false
    fi
    
    echo
    
    if ! test_build_clarity; then
        all_tests_passed=false
    fi
    
    echo
    
    if ! validate_smart_manager; then
        all_tests_passed=false
    fi
    
    echo
    echo "==============================================="
    
    if [[ "$all_tests_passed" == "true" ]]; then
        log_ok "🎉 TODAS LAS VALIDACIONES PASARON"
        log_ok "✅ Setup automático será libre de errores confusos"
        return 0
    else
        log_fail "❌ ALGUNAS VALIDACIONES FALLARON"
        log_fail "🚫 Setup automático puede confundir a usuarios"
        return 1
    fi
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi