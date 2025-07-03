#!/bin/bash

# Validation utilities for setup scripts

source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

check_tool_version() {
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
        warning "Could not determine ${tool} version"
        return 0
    fi
    
    if version_compare "${current_version}" "${min_version}"; then
        info "✅ ${tool} ${current_version} meets minimum requirement ${min_version}"
        return 0
    else
        error "${tool} ${current_version} is below minimum requirement ${min_version}"
        return 1
    fi
}

version_compare() {
    local version1=$1
    local version2=$2
    
    # Simple version comparison (major.minor.patch)
    local IFS='.'
    read -ra V1 <<< "${version1}"
    read -ra V2 <<< "${version2}"
    
    for i in {0..2}; do
        local v1_part=${V1[i]:-0}
        local v2_part=${V2[i]:-0}
        
        if (( v1_part > v2_part )); then
            return 0
        elif (( v1_part < v2_part )); then
            return 1
        fi
    done
    
    return 0
}

validate_git_config() {
    if [[ -z "$(git config --global user.name)" ]] || [[ -z "$(git config --global user.email)" ]]; then
        warning "Git user configuration is incomplete"
        info "Configure with:"
        info "  git config --global user.name \"Your Name\""
        info "  git config --global user.email \"your-email@example.com\""
        return 1
    fi
    
    info "✅ Git configuration is complete"
    return 0
}

validate_ssh_access() {
    local repo_url=$1
    local host
    
    # Extract host from SSH URL
    host=$(echo "${repo_url}" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    
    if [[ -z "${host}" ]]; then
        warning "Could not extract host from repository URL: ${repo_url}"
        return 1
    fi
    
    if ssh -T "git@${host}" 2>&1 | grep -q "successfully authenticated"; then
        info "✅ SSH access to ${host} is configured"
        return 0
    else
        error "SSH access to ${host} is not configured"
        info "Configure SSH key access to ${host}"
        return 1
    fi
}

check_port_available() {
    local port=$1
    
    if command -v lsof &> /dev/null; then
        if lsof -Pi ":${port}" -sTCP:LISTEN -t >/dev/null 2>&1; then
            warning "Port ${port} is already in use"
            return 1
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -ln 2>/dev/null | grep -q ":${port} "; then
            warning "Port ${port} is already in use"
            return 1
        fi
    fi
    
    return 0
}

validate_workspace_structure() {
    local workspace_dir=$1
    local required_dirs=("ms_level_up_management" "ms_trivance_auth" "level_up_backoffice" "trivance-mobile")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "${workspace_dir}/${dir}" ]]; then
            error "Required directory ${dir} not found in workspace"
            return 1
        fi
    done
    
    info "✅ Workspace structure is valid"
    return 0
}