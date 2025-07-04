#!/bin/bash

# Progress utility for trivance-dev-config
# Provides real-time progress feedback during long operations

set -euo pipefail

# Configuración de colores y símbolos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Símbolos Unicode
SPINNER_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
PROGRESS_BAR_CHARS="▏▎▍▌▋▊▉█"
CHECK_MARK="✅"
CROSS_MARK="❌"
GEAR="⚙️"
ROCKET="🚀"

# Variables globales
PROGRESS_PID=""
PROGRESS_FILE="/tmp/trivance_progress_$$"
PROGRESS_LOG_FILE="/tmp/trivance_progress_log_$$"

# Limpiar archivos temporales al salir
cleanup() {
    [[ -f "$PROGRESS_FILE" ]] && rm -f "$PROGRESS_FILE"
    [[ -f "$PROGRESS_LOG_FILE" ]] && rm -f "$PROGRESS_LOG_FILE"
    if [[ -n "$PROGRESS_PID" ]] && kill -0 "$PROGRESS_PID" 2>/dev/null; then
        kill "$PROGRESS_PID" 2>/dev/null
    fi
}
trap cleanup EXIT

# Función para mostrar spinner
show_spinner() {
    local message="$1"
    local duration="${2:-0}"  # 0 = infinito
    local start_time
    start_time=$(date +%s)
    
    local i=0
    while true; do
        local current_time
        current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $duration -gt 0 && $elapsed -ge $duration ]]; then
            break
        fi
        
        local spinner_char="${SPINNER_CHARS:$((i % ${#SPINNER_CHARS})):1}"
        
        if [[ $duration -gt 0 ]]; then
            printf "\r${CYAN}%s${NC} %s (${elapsed}s/${duration}s)" "$spinner_char" "$message"
        else
            printf "\r${CYAN}%s${NC} %s (${elapsed}s)" "$spinner_char" "$message"
        fi
        
        sleep 0.1
        ((i++))
        
        # Verificar si hay señal para parar
        if [[ -f "$PROGRESS_FILE" ]]; then
            local status
            status=$(cat "$PROGRESS_FILE")
            if [[ "$status" == "STOP" ]]; then
                break
            fi
        fi
    done
    
    printf "\r\033[K"  # Limpiar línea
}

# Función para mostrar barra de progreso
show_progress_bar() {
    local current="$1"
    local total="$2" 
    local message="$3"
    local bar_width=30
    
    local percentage=$((current * 100 / total))
    local filled_width=$((current * bar_width / total))
    
    # Construir barra de progreso
    local bar=""
    local i=0
    while [[ $i -lt $bar_width ]]; do
        if [[ $i -lt $filled_width ]]; then
            bar+="█"
        else
            bar+=" "
        fi
        ((i++))
    done
    
    printf "\r${BLUE}[%s]${NC} %3d%% %s (%d/%d)" "$bar" "$percentage" "$message" "$current" "$total"
}

# Función para progreso con etapas
show_stage_progress() {
    local current_stage="$1"
    local total_stages="$2"
    local stage_name="$3"
    local stage_progress="${4:-0}"    # Progreso dentro de la etapa (0-100)
    
    echo
    echo -e "${PURPLE}▶${NC} ${YELLOW}ETAPA ${current_stage}/${total_stages}:${NC} ${stage_name}"
    
    if [[ $stage_progress -gt 0 ]]; then
        local bar_width=40
        local filled_width=$((stage_progress * bar_width / 100))
        
        local bar=""
        local i=0
        while [[ $i -lt $bar_width ]]; do
            if [[ $i -lt $filled_width ]]; then
                bar+="▉"
            else
                bar+="░"
            fi
            ((i++))
        done
        
        echo -e "   ${CYAN}[${bar}]${NC} ${stage_progress}%"
    fi
}

# Función para mostrar progreso de instalación npm
show_npm_install_progress() {
    local repo_name="$1"
    local log_file="$2"
    local estimated_time="${3:-300}"  # 5 minutos por defecto
    
    local start_time
    start_time=$(date +%s)
    
    echo -e "${GEAR} Instalando dependencias para ${YELLOW}${repo_name}${NC}"
    echo -e "   ${BLUE}Tiempo estimado:${NC} ${estimated_time}s"
    echo -e "   ${BLUE}Log file:${NC} ${log_file}"
    echo
    
    local i=0
    while true; do
        local current_time
        current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local percentage=$((elapsed * 100 / estimated_time))
        
        # Limitar porcentaje a 99% hasta que termine realmente
        if [[ $percentage -gt 99 ]]; then
            percentage=99
        fi
        
        # Mostrar progreso
        show_progress_bar "$elapsed" "$estimated_time" "$repo_name npm install"
        
        # Verificar si hay señal para parar
        if [[ -f "$PROGRESS_FILE" ]]; then
            local status
            status=$(cat "$PROGRESS_FILE")
            if [[ "$status" == "STOP" ]]; then
                echo
                break
            fi
        fi
        
        sleep 1
        ((i++))
    done
}

# Función para mostrar progreso de compilación
show_compilation_progress() {
    local repos=("$@")
    local total=${#repos[@]}
    local current=0
    
    echo -e "${ROCKET} ${YELLOW}Iniciando verificación de compilación${NC}"
    echo -e "   ${BLUE}Repositorios a verificar:${NC} ${total}"
    echo
    
    for repo in "${repos[@]}"; do
        ((current++))
        echo -e "${GEAR} Compilando ${YELLOW}${repo}${NC} (${current}/${total})"
        
        # Simular progreso de compilación
        local compile_steps=("Verificando archivos" "Transpilando TypeScript" "Resolviendo dependencias" "Generando build")
        local step_num=0
        
        for step in "${compile_steps[@]}"; do
            ((step_num++))
            local step_progress=$((step_num * 100 / ${#compile_steps[@]}))
            
            printf "   ${CYAN}[%d/4]${NC} %s" "$step_num" "$step"
            
            # Mini spinner para cada paso
            local j=0
            while [[ $j -lt 10 ]]; do
                local spinner_char="${SPINNER_CHARS:$((j % ${#SPINNER_CHARS})):1}"
                printf " %s" "$spinner_char"
                sleep 0.1
                printf "\b\b"
                ((j++))
            done
            
            echo -e " ${CHECK_MARK}"
        done
        
        show_progress_bar "$current" "$total" "compilación completada"
        echo
    done
}

# Función para mostrar tiempo transcurrido en formato legible
format_duration() {
    local duration=$1
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" $hours $minutes $seconds
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

# Función para iniciar spinner en background
start_spinner() {
    local message="$1"
    local log_file="${2:-}"
    
    # Crear archivo de control
    echo "RUNNING" > "$PROGRESS_FILE"
    
    # Iniciar spinner en background
    {
        show_spinner "$message"
    } &
    
    PROGRESS_PID=$!
}

# Función para parar spinner
stop_spinner() {
    local result="${1:-success}"  # success, error, warning
    local final_message="${2:-Completado}"
    
    # Señalar al spinner que pare
    echo "STOP" > "$PROGRESS_FILE"
    
    # Esperar a que termine
    if [[ -n "$PROGRESS_PID" ]] && kill -0 "$PROGRESS_PID" 2>/dev/null; then
        wait "$PROGRESS_PID" 2>/dev/null || true
    fi
    
    # Mostrar resultado final
    case "$result" in
        "success")
            echo -e "${CHECK_MARK} ${GREEN}${final_message}${NC}"
            ;;
        "error")
            echo -e "${CROSS_MARK} ${RED}${final_message}${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  ${final_message}${NC}"
            ;;
    esac
    
    PROGRESS_PID=""
}

# Función para mostrar resumen final
show_final_summary() {
    local start_time="$1"
    local end_time="$2"
    local success_count="$3"
    local total_count="$4"
    local errors=("${@:5}")
    
    local duration=$((end_time - start_time))
    local formatted_duration
    formatted_duration=$(format_duration "$duration")
    
    echo
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${ROCKET} ${YELLOW}RESUMEN DE CONFIGURACIÓN${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "⏱️  ${BLUE}Tiempo total:${NC} ${formatted_duration}"
    echo -e "📊 ${BLUE}Repositorios procesados:${NC} ${success_count}/${total_count}"
    
    if [[ $success_count -eq $total_count ]]; then
        echo -e "${CHECK_MARK} ${GREEN}¡Configuración completada exitosamente!${NC}"
    else
        echo -e "${CROSS_MARK} ${RED}Configuración completada con errores${NC}"
        echo
        echo -e "${RED}Errores encontrados:${NC}"
        for error in "${errors[@]}"; do
            [[ -n "$error" ]] && echo -e "  • ${error}"
        done
    fi
    
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════${NC}"
}

# Función de utilidad para logging con timestamp
log_with_timestamp() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${timestamp} ${BLUE}[INFO]${NC} ${message}"
            ;;
        "WARN")
            echo -e "${timestamp} ${YELLOW}[WARN]${NC} ${message}"
            ;;
        "ERROR")
            echo -e "${timestamp} ${RED}[ERROR]${NC} ${message}"
            ;;
        "SUCCESS")
            echo -e "${timestamp} ${GREEN}[SUCCESS]${NC} ${message}"
            ;;
    esac
}

# Función para testing
test_progress_functions() {
    echo "Testing progress functions..."
    
    # Test spinner
    start_spinner "Testing spinner for 5 seconds"
    sleep 5
    stop_spinner "success" "Spinner test completed"
    
    # Test progress bar
    echo "Testing progress bar..."
    for i in {1..10}; do
        show_progress_bar "$i" "10" "test progress"
        sleep 0.5
    done
    echo
    
    # Test stage progress
    show_stage_progress "2" "5" "Testing stage progress" "75"
    
    # Test compilation progress
    show_compilation_progress "repo1" "repo2" "repo3"
    
    echo "All tests completed!"
}

# Si el script se ejecuta directamente, mostrar ayuda o ejecutar tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "test")
            test_progress_functions
            ;;
        "help"|*)
            echo "Progress utility for trivance-dev-config"
            echo ""
            echo "Usage: source progress.sh"
            echo ""
            echo "Available functions:"
            echo "  start_spinner <message> [log_file]    - Start spinner in background"
            echo "  stop_spinner [result] [message]       - Stop spinner with result"
            echo "  show_progress_bar <cur> <total> <msg> - Show progress bar"
            echo "  show_stage_progress <stage> <total> <name> [progress] - Show stage"
            echo "  show_npm_install_progress <repo> <log> [time] - NPM install progress"
            echo "  show_compilation_progress <repos...>  - Compilation progress"
            echo "  log_with_timestamp <level> <message>  - Timestamped logging"
            echo ""
            echo "Test: ./progress.sh test"
            ;;
    esac
fi