#!/bin/bash

# Common utilities for Trivance Platform setup scripts
# Consolidates shared functionality to reduce duplication

# Source logging utilities (check if already loaded)
if ! command -v log &> /dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
fi

# ============= SHARED FUNCTIONS =============

# Git URL validation and conversion utilities
validate_git_url() {
    local url=$1
    
    # Security check: Ensure URL matches expected Git patterns
    if [[ "${url}" =~ ^git@github\.com:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]] || \
       [[ "${url}" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]] || \
       [[ "${url}" =~ ^git@[A-Za-z0-9.-]+:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]] || \
       [[ "${url}" =~ ^https://[A-Za-z0-9.-]+/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]]; then
        return 0
    fi
    
    return 1
}

convert_to_https_url() {
    local repo_url=$1
    
    if [[ "${repo_url}" == git@github.com:* ]]; then
        echo "${repo_url}" | sed 's|git@github.com:\(.*\)|https://github.com/\1|'
    elif [[ "${repo_url}" == git@* ]]; then
        # Generic SSH to HTTPS conversion
        echo "${repo_url}" | sed 's|git@\([^:]*\):\(.*\)|https://\1/\2|'
    else
        echo "${repo_url}"
    fi
}

# Simplified Git access testing (2 methods only: SSH + HTTPS)
test_git_access() {
    local repo_url=$1
    
    # Method 1: SSH (if original URL is SSH)
    if [[ "${repo_url}" == git@* ]]; then
        if test_ssh_access_simple "${repo_url}"; then
            info "✅ SSH access confirmed"
            echo "${repo_url}"
            return 0
        fi
    fi
    
    # Method 2: HTTPS with credential helper
    local https_url
    https_url=$(convert_to_https_url "${repo_url}")
    if test_https_access_simple "${https_url}"; then
        info "✅ HTTPS access confirmed"
        echo "${https_url}"
        return 0
    fi
    
    # Both methods failed
    error "Cannot access repository: ${repo_url}"
    display_simple_auth_help
    return 1
}

test_ssh_access_simple() {
    local repo_url=$1
    local host
    
    # Extract host from SSH URL
    host=$(echo "${repo_url}" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    
    if [[ -z "${host}" ]]; then
        return 1
    fi
    
    # Test SSH connection with timeout
    if timeout 10 ssh -T "git@${host}" 2>&1 | grep -q "successfully authenticated\|Hi.*You've successfully authenticated"; then
        return 0
    fi
    
    return 1
}

test_https_access_simple() {
    local https_url=$1
    
    # Test HTTPS access with git ls-remote
    if timeout 10 git ls-remote "${https_url}" &> /dev/null; then
        return 0
    fi
    
    return 1
}

display_simple_auth_help() {
    echo ""
    error "🔐 Git Authentication Required"
    echo ""
    info "Configure one of the following:"
    echo ""
    info "Option 1 - SSH Key (Recommended):"
    echo "  1. Generate: ssh-keygen -t ed25519 -C \"your-email@example.com\""
    echo "  2. Add to GitHub: https://github.com/settings/keys"
    echo ""
    info "Option 2 - HTTPS Credential Helper:"
    echo "  1. Configure: git config --global credential.helper manager"
    echo "  2. Enter credentials when prompted"
}

# Port management utilities
check_port_available() {
    local port=$1
    
    if command -v lsof &> /dev/null; then
        if lsof -Pi ":${port}" -sTCP:LISTEN -t >/dev/null 2>&1; then
            return 1  # Port in use
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -ln 2>/dev/null | grep -q ":${port} "; then
            return 1  # Port in use
        fi
    fi
    
    return 0  # Port available
}

kill_port_process() {
    local port=$1
    
    if ! check_port_available "${port}"; then
        warning "Port ${port} is in use, terminating process..."
        if command -v lsof &> /dev/null; then
            lsof -ti:"${port}" | xargs kill -9 2>/dev/null || true
        fi
        sleep 2
    fi
}

# Tool version validation
check_tool_version_simple() {
    local tool=$1
    local min_version=$2
    local check_command=$3
    
    if ! command -v "${tool}" &> /dev/null; then
        error "${tool} is not installed"
        return 1
    fi
    
    local current_version
    current_version=$(${check_command} 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "${current_version}" ]]; then
        warning "Could not determine ${tool} version, continuing..."
        return 0
    fi
    
    if version_compare_simple "${current_version}" "${min_version}"; then
        info "✅ ${tool} ${current_version} (>= ${min_version})"
        return 0
    else
        error "${tool} ${current_version} is below minimum ${min_version}"
        return 1
    fi
}

version_compare_simple() {
    local version1=$1
    local version2=$2
    
    # Simple version comparison using sort
    local result
    result=$(printf '%s\n%s\n' "${version1}" "${version2}" | sort -V | head -n1)
    
    if [[ "${result}" == "${version2}" ]]; then
        return 0  # version1 >= version2
    else
        return 1  # version1 < version2
    fi
}

# Environment file utilities
create_env_from_template() {
    local repo_name=$1
    local template_content=$2
    local target_file="${WORKSPACE_DIR}/${repo_name}/.env"
    
    if [[ -f "${target_file}" ]]; then
        info "${repo_name}/.env already exists, skipping"
        return 0
    fi
    
    echo "${template_content}" > "${target_file}"
    success "✅ Created ${repo_name}/.env"
}

# Workspace validation
validate_workspace_structure_simple() {
    local workspace_dir=$1
    local required_dirs=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "${workspace_dir}/${dir}" ]]; then
            missing_dirs+=("${dir}")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -eq 0 ]]; then
        return 0
    else
        error "Missing directories: ${missing_dirs[*]}"
        return 1
    fi
}

# Dependencies installation
install_repo_dependencies_simple() {
    local repo_name=$1
    
    if [[ ! -d "${repo_name}" ]]; then
        warning "Repository ${repo_name} not found, skipping"
        return 0
    fi
    
    if [[ ! -f "${repo_name}/package.json" ]]; then
        info "${repo_name} has no package.json, skipping"
        return 0
    fi
    
    log "Installing dependencies for ${repo_name}"
    
    cd "${repo_name}"
    
    if npm install; then
        success "✅ Dependencies installed for ${repo_name}"
        cd ..
        return 0
    else
        error "Failed to install dependencies for ${repo_name}"
        cd ..
        return 1
    fi
}

# Service health check utilities
check_service_health() {
    local port=$1
    local health_endpoint=$2
    local service_name=$3
    local max_attempts=${4:-15}
    
    local attempts=0
    
    while [[ ${attempts} -lt ${max_attempts} ]]; do
        if check_port_available "${port}"; then
            sleep 2
            attempts=$((attempts + 1))
            continue
        fi
        
        # Port is in use, check health endpoint if provided
        if [[ -n "${health_endpoint}" ]]; then
            if command -v curl &> /dev/null; then
                if curl -s -f "${health_endpoint}" >/dev/null 2>&1; then
                    success "✅ ${service_name} is healthy"
                    return 0
                fi
            fi
        else
            # No health endpoint, just check if port responds
            success "✅ ${service_name} is running on port ${port}"
            return 0
        fi
        
        sleep 2
        attempts=$((attempts + 1))
    done
    
    warning "⚠️ ${service_name} health check timeout"
    return 1
}

# Error handling and cleanup
cleanup_on_error() {
    local script_name=$1
    error "Error occurred in ${script_name}"
    info "Check logs for details"
    
    # Cleanup any temporary files or processes if needed
    # This function can be extended as needed
}

# Git configuration validation
validate_git_config_simple() {
    if [[ -z "$(git config --global user.name)" ]] || [[ -z "$(git config --global user.email)" ]]; then
        warning "Git user configuration incomplete"
        info "Configure with:"
        info "  git config --global user.name \"Your Name\""
        info "  git config --global user.email \"your-email@example.com\""
        return 1
    fi
    
    return 0
}