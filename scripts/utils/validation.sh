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

validate_git_access() {
    local repo_url=$1
    local test_method=""
    
    log "Testing Git access for repository: ${repo_url}"
    
    # Try multiple authentication methods in order of preference
    
    # Method 1: SSH (fastest and most secure)
    if [[ "${repo_url}" == git@* ]]; then
        if test_ssh_access "${repo_url}"; then
            info "✅ SSH access confirmed for ${repo_url}"
            return 0
        fi
        test_method="SSH"
    fi
    
    # Method 2: GitHub CLI (if available and authenticated)
    if command -v gh &> /dev/null; then
        if test_github_cli_access "${repo_url}"; then
            info "✅ GitHub CLI access confirmed for ${repo_url}"
            return 0
        fi
        test_method="${test_method:+$test_method, }GitHub CLI"
    fi
    
    # Method 3: HTTPS with credential helper
    local https_url
    https_url=$(convert_to_https_url "${repo_url}")
    if test_https_access "${https_url}"; then
        info "✅ HTTPS access confirmed for ${https_url}"
        return 0
    fi
    test_method="${test_method:+$test_method, }HTTPS"
    
    # Method 4: Last resort - check if running in authenticated environment (VS Code, etc.)
    if test_environment_access "${repo_url}"; then
        info "✅ Environment-based access confirmed for ${repo_url}"
        return 0
    fi
    test_method="${test_method:+$test_method, }Environment"
    
    # All methods failed
    error "Git access validation failed for ${repo_url}"
    error "Tried methods: ${test_method}"
    display_auth_help "${repo_url}"
    return 1
}

test_ssh_access() {
    local repo_url=$1
    local host
    
    # Extract host from SSH URL
    host=$(echo "${repo_url}" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    
    if [[ -z "${host}" ]]; then
        return 1
    fi
    
    # Test SSH connection with standardized timeout
    if timeout 15 ssh -T "git@${host}" 2>&1 | grep -q "successfully authenticated\|Hi.*You've successfully authenticated"; then
        return 0
    fi
    
    return 1
}

test_github_cli_access() {
    local repo_url=$1
    
    # Check if GitHub CLI is authenticated
    if ! gh auth status &> /dev/null; then
        return 1
    fi
    
    # Extract repo info from URL
    local repo_path
    if [[ "${repo_url}" == git@github.com:* ]]; then
        repo_path=$(echo "${repo_url}" | sed 's/git@github.com:\(.*\)\.git/\1/')
    elif [[ "${repo_url}" == https://github.com/* ]]; then
        repo_path=$(echo "${repo_url}" | sed 's|https://github.com/\(.*\)\.git|\1|')
    else
        return 1
    fi
    
    # Test access using GitHub CLI
    if gh repo view "${repo_path}" &> /dev/null; then
        return 0
    fi
    
    return 1
}

test_https_access() {
    local https_url=$1
    
    # Test HTTPS access with git ls-remote (lightweight operation)
    if timeout 15 git ls-remote "${https_url}" &> /dev/null; then
        return 0
    fi
    
    return 1
}

test_environment_access() {
    local repo_url=$1
    
    # Check if we're in a Git-authenticated environment (VS Code, etc.)
    # These environments often have Git credentials cached
    
    # Test if git credential helper is configured and working
    if git config --get credential.helper &> /dev/null; then
        local https_url
        https_url=$(convert_to_https_url "${repo_url}")
        
        # Try a lightweight git operation with standardized timeout
        if timeout 15 git ls-remote --exit-code "${https_url}" &> /dev/null; then
            return 0
        fi
    fi
    
    # Check for VS Code Git authentication indicators
    if [[ -n "${VSCODE_GIT_ASKPASS_NODE}" ]] || [[ -n "${VSCODE_GIT_ASKPASS_EXTRA_ARGS}" ]]; then
        # We're likely in VS Code environment with Git integration
        local https_url
        https_url=$(convert_to_https_url "${repo_url}")
        
        # Try with VS Code's Git helper
        if timeout 15 git ls-remote "${https_url}" &> /dev/null; then
            return 0
        fi
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

get_clone_url() {
    local repo_url=$1
    
    # Security validation: Ensure URL is a valid Git repository URL
    if ! validate_git_url "${repo_url}"; then
        error "Invalid or potentially unsafe repository URL: ${repo_url}"
        return 1
    fi
    
    log "Testing authentication methods for repository access"
    
    # Method 1: SSH (if original URL is SSH and it works)
    if [[ "${repo_url}" == git@* ]]; then
        if test_ssh_access "${repo_url}"; then
            info "Authentication method: SSH"
            echo "${repo_url}"
            return 0
        fi
    fi
    
    # Method 2: GitHub CLI (if available and authenticated)
    if command -v gh &> /dev/null; then
        if test_github_cli_access "${repo_url}"; then
            info "Authentication method: GitHub CLI"
            echo "${repo_url}"
            return 0
        fi
    fi
    
    # Method 3: HTTPS with credential helper
    local https_url
    https_url=$(convert_to_https_url "${repo_url}")
    if test_https_access "${https_url}"; then
        info "Authentication method: HTTPS credential helper"
        echo "${https_url}"
        return 0
    fi
    
    # Method 4: Environment-based access (VS Code, etc.)
    if test_environment_access "${repo_url}"; then
        local https_url
        https_url=$(convert_to_https_url "${repo_url}")
        info "Authentication method: Environment credential cache"
        echo "${https_url}"
        return 0
    fi
    
    # All methods failed
    return 1
}

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

display_auth_help() {
    local repo_url=$1
    
    echo ""
    error "🔐 Git Authentication Required"
    echo ""
    info "To access private repositories, configure one of the following:"
    echo ""
    info "Option 1 - SSH Key (Recommended):"
    echo "  1. Generate SSH key: ssh-keygen -t ed25519 -C \"your-email@example.com\""
    echo "  2. Add to SSH agent: ssh-add ~/.ssh/id_ed25519"
    echo "  3. Add public key to GitHub: https://github.com/settings/keys"
    echo ""
    info "Option 2 - GitHub CLI:"
    echo "  1. Install GitHub CLI: https://cli.github.com/"
    echo "  2. Authenticate: gh auth login"
    echo ""
    info "Option 3 - Git Credential Manager:"
    echo "  1. Install Git Credential Manager"
    echo "  2. Configure: git config --global credential.helper manager"
    echo ""
    warning "If you're in VS Code with GitHub integration, ensure you're signed in to GitHub"
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