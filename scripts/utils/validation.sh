#!/bin/bash

# Simplified validation utilities for setup scripts

source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Simplified tool version checking using common utilities
check_tool_version() {
    local tool=$1
    local min_version=$2
    local check_command=$3
    
    check_tool_version_simple "${tool}" "${min_version}" "${check_command}"
}

# Simplified version comparison using common utilities
version_compare() {
    local version1=$1
    local version2=$2
    
    version_compare_simple "${version1}" "${version2}"
}

# Simplified Git configuration validation
validate_git_config() {
    if validate_git_config_simple; then
        info "✅ Git configuration is complete"
        return 0
    else
        return 1
    fi
}

# Simplified Git access validation using common utilities
validate_git_access() {
    local repo_url=$1
    
    log "Testing Git access for repository: ${repo_url}"
    
    # Use simplified git access testing from common.sh
    if test_git_access "${repo_url}" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Simplified utility functions using common.sh

get_clone_url() {
    local repo_url=$1
    
    # Security validation using common utilities
    if ! validate_git_url "${repo_url}"; then
        error "Invalid repository URL: ${repo_url}"
        return 1
    fi
    
    # Use simplified git access testing
    test_git_access "${repo_url}"
}

check_port_available() {
    local port=$1
    check_port_available "${port}"
}

validate_workspace_structure() {
    local workspace_dir=$1
    
    if validate_workspace_structure_simple "${workspace_dir}"; then
        info "✅ Workspace structure is valid"
        return 0
    else
        return 1
    fi
}