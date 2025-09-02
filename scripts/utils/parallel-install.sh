#!/bin/bash

# Instalación paralela de dependencias para mayor velocidad
# Reduce tiempo total de instalación ejecutando repos en paralelo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Función universal de timeout que funciona en Windows, Mac y Linux
run_with_timeout() {
    local timeout_duration=$1
    shift
    local cmd=("$@")
    
    # Detectar sistema operativo y usar comando apropiado
    if command -v timeout >/dev/null 2>&1; then
        # Linux/GNU coreutils (incluye WSL en Windows)
        timeout "$timeout_duration" "${cmd[@]}"
        return $?
    elif command -v gtimeout >/dev/null 2>&1; then
        # macOS con coreutils instalado (brew install coreutils)
        gtimeout "$timeout_duration" "${cmd[@]}"
        return $?
    else
        # Implementación nativa bash para macOS sin coreutils o sistemas sin timeout
        info "🔧 Usando timeout nativo (sistema sin GNU timeout)"
        
        # Ejecutar comando en background
        "${cmd[@]}" &
        local cmd_pid=$!
        
        # Crear proceso de timeout en background
        ( 
            sleep "$timeout_duration" 
            if kill -0 $cmd_pid 2>/dev/null; then
                warn "⏰ Timeout alcanzado (${timeout_duration}s), terminando proceso..."
                kill -TERM $cmd_pid 2>/dev/null
                sleep 2
                # Si aún está corriendo, forzar terminación
                if kill -0 $cmd_pid 2>/dev/null; then
                    kill -KILL $cmd_pid 2>/dev/null
                fi
            fi
        ) &
        local timeout_pid=$!
        
        # Esperar a que termine el comando
        wait $cmd_pid 2>/dev/null
        local exit_code=$?
        
        # Limpiar proceso de timeout
        kill -TERM $timeout_pid 2>/dev/null || true
        wait $timeout_pid 2>/dev/null || true
        
        # Si el comando fue terminado por timeout, retornar código 124 (estándar timeout)
        if [[ $exit_code -eq 143 ]] || [[ $exit_code -eq 137 ]]; then
            return 124
        fi
        
        return $exit_code
    fi
}

# Función para instalar dependencias de un repo específico
install_repo_dependencies() {
    local repo_name="$1"
    local repo_path="${WORKSPACE_DIR}/${repo_name}"
    
    if [[ ! -d "$repo_path" ]] || [[ ! -f "${repo_path}/package.json" ]]; then
        warn "⚠️  ${repo_name}: No encontrado o sin package.json"
        return 0
    fi
    
    info "🚀 Iniciando instalación para ${repo_name}..."
    
    local log_file="${WORKSPACE_DIR}/logs/${repo_name}_install.log"
    local start_time=$(date +%s)
    
    # Cambiar al directorio del repo
    cd "$repo_path"
    
    # Instalación con timeout configurable (default 10 minutos para AI workflows)
    local timeout="${NPM_INSTALL_TIMEOUT:-600}"
    if run_with_timeout "$timeout" npm install --silent --no-audit --no-fund > "$log_file" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        success "✅ ${repo_name}: Completado en ${duration}s"
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $exit_code -eq 124 ]]; then
            local timeout_minutes=$((timeout / 60))
            error "❌ ${repo_name}: TIMEOUT después de ${timeout_minutes} minutos"
        else
            error "❌ ${repo_name}: Error en instalación (${duration}s)"
        fi
        
        # Mostrar últimas líneas del log para diagnóstico
        echo "📋 Últimas líneas del log:"
        tail -5 "$log_file" 2>/dev/null || echo "No se puede leer el log"
        
        return $exit_code
    fi
}

# Función principal para instalación paralela
parallel_install() {
    log "🚀 Iniciando instalación paralela de dependencias..."
    
    # Crear directorio de logs
    mkdir -p "${WORKSPACE_DIR}/logs"
    
    local repos=("trivance_auth" "trivance_management" "trivance_backoffice" "trivance-mobile")
    local pids=()
    local repo_names=()
    
    # Lanzar instalación de cada repo en paralelo
    for repo in "${repos[@]}"; do
        if [[ -d "${WORKSPACE_DIR}/${repo}" ]] && [[ -f "${WORKSPACE_DIR}/${repo}/package.json" ]]; then
            install_repo_dependencies "$repo" &
            pids+=($!)
            repo_names+=("$repo")
            info "📦 ${repo}: Proceso iniciado (PID: $!)"
        fi
    done
    
    if [[ ${#pids[@]} -eq 0 ]]; then
        warn "⚠️  No se encontraron repositorios con package.json"
        return 0
    fi
    
    info "⏳ Esperando ${#pids[@]} procesos paralelos (máximo 3 minutos cada uno)..."
    
    # Esperar todos los procesos con progreso
    local completed=0
    local total=${#pids[@]}
    local failed_repos=()
    
    for i in "${!pids[@]}"; do
        local pid=${pids[$i]}
        local repo_name=${repo_names[$i]}
        
        if wait "$pid"; then
            ((completed++))
            show_progress "Instalaciones completadas" "$completed" "$total"
        else
            failed_repos+=("$repo_name")
            ((completed++))
            show_progress "Procesos terminados" "$completed" "$total"
        fi
    done
    
    echo  # Nueva línea después del progreso
    
    # Reportar resultados
    local successful=$((total - ${#failed_repos[@]}))
    
    if [[ ${#failed_repos[@]} -eq 0 ]]; then
        success "🎉 Todas las instalaciones completadas exitosamente (${successful}/${total})"
        return 0
    else
        error "❌ Algunas instalaciones fallaron:"
        for repo in "${failed_repos[@]}"; do
            error "   • ${repo}"
        done
        
        if [[ $successful -gt 0 ]]; then
            warn "⚠️  ${successful}/${total} repositorios instalados correctamente"
            warn "   Puedes continuar, pero algunos servicios podrían no funcionar"
            return 1
        else
            error "💥 Todas las instalaciones fallaron - revisa conectividad y permisos"
            return 1
        fi
    fi
}

# Script principal
main() {
    parallel_install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi