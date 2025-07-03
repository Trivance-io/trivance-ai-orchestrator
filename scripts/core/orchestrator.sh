#!/bin/bash

# Core orchestrator for Trivance Platform workspace setup
# Manages complete environment configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKSPACE_DIR="$(dirname "${PROJECT_ROOT}")"

# Source utilities
source "${SCRIPT_DIR}/../utils/logging.sh"
source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/../utils/validation.sh"
source "${SCRIPT_DIR}/../utils/secrets.sh"

# Configuration files
REPOSITORIES_CONFIG="${PROJECT_ROOT}/config/repositories.json"
ENVIRONMENTS_CONFIG="${PROJECT_ROOT}/config/environments.json"

main() {
    print_banner
    log "Starting Trivance Platform workspace setup"
    
    detect_environment
    validate_prerequisites
    setup_workspace_structure
    init_secrets_management "${WORKSPACE_DIR}"
    clone_repositories
    install_dependencies
    configure_environment_files
    copy_configurations
    generate_documentation
    validate_installation
    
    display_summary
}

detect_environment() {
    log "Detecting system environment"
    
    info "Operating System: $(uname -s)"
    info "Architecture: $(uname -m)"
    info "Working Directory: ${WORKSPACE_DIR}"
    
    # Detect if running in CI/automation
    if [[ -n "${CI:-}" ]] || [[ -n "${AUTOMATION:-}" ]]; then
        export AUTOMATION_MODE=true
        info "Automation mode detected"
    fi
}

validate_prerequisites() {
    log "Validating system prerequisites"
    
    local tools
    tools=$(jq -r '.required_tools[] | "\(.name) \(.min_version) \(.check_command)"' "${ENVIRONMENTS_CONFIG}")
    
    local validation_failed=false
    
    while IFS= read -r tool_info; do
        read -r tool_name min_version check_command <<< "${tool_info}"
        
        if ! check_tool_version "${tool_name}" "${min_version}" "${check_command}"; then
            validation_failed=true
        fi
    done <<< "${tools}"
    
    if [[ "${validation_failed}" == "true" ]]; then
        error "Prerequisites validation failed"
        exit 1
    fi
    
    validate_git_config || warning "Git configuration needs attention"
    
    success "Prerequisites validation completed"
}

setup_workspace_structure() {
    log "Setting up workspace structure"
    
    cd "${WORKSPACE_DIR}"
    
    # Create necessary directories
    mkdir -p logs scripts .vscode
    
    # Set up gitignore for workspace root
    if [[ ! -f .gitignore ]]; then
        cat > .gitignore << 'EOF'
# Workspace-level ignores
logs/
*.log
.DS_Store
.env
.env.local
node_modules/
dist/
build/
EOF
        info "Created workspace .gitignore"
    fi
}

clone_repositories() {
    log "Cloning project repositories"
    
    cd "${WORKSPACE_DIR}"
    
    local repos
    repos=$(jq -c '.repositories[]' "${REPOSITORIES_CONFIG}")
    
    while IFS= read -r repo; do
        local name url
        name=$(echo "${repo}" | jq -r '.name')
        url=$(echo "${repo}" | jq -r '.url')
        
        clone_repository "${name}" "${url}"
    done <<< "${repos}"
}

clone_repository() {
    local repo_name=$1
    local repo_url=$2
    
    if [[ -d "${repo_name}" ]]; then
        info "${repo_name} already exists, skipping clone"
        return 0
    fi
    
    log "Cloning ${repo_name}"
    
    # Determine the best URL for cloning based on available authentication
    local clone_url
    clone_url=$(get_clone_url "${repo_url}")
    
    if [[ -z "${clone_url}" ]]; then
        error "Cannot access repository ${repo_url}"
        return 1
    fi
    
    log "Using repository: ${repo_name}"
    
    if git clone "${clone_url}" "${repo_name}"; then
        success "✅ ${repo_name} cloned successfully"
    else
        error "Failed to clone ${repo_name}"
        return 1
    fi
}

install_dependencies() {
    log "Installing project dependencies"
    
    cd "${WORKSPACE_DIR}"
    
    local repos
    repos=$(jq -r '.repositories[].name' "${REPOSITORIES_CONFIG}")
    
    while IFS= read -r repo_name; do
        install_repo_dependencies "${repo_name}"
    done <<< "${repos}"
}

install_repo_dependencies() {
    local repo_name=$1
    
    cd "${WORKSPACE_DIR}"
    install_repo_dependencies_simple "${repo_name}"
}

configure_environment_files() {
    log "Configuring environment files"
    
    cd "${WORKSPACE_DIR}"
    
    local repos
    repos=$(jq -c '.repositories[] | select(.has_env == true)' "${REPOSITORIES_CONFIG}")
    
    while IFS= read -r repo; do
        local name
        name=$(echo "${repo}" | jq -r '.name')
        
        create_env_file "${name}" "${repo}"
    done <<< "${repos}"
}

create_env_file() {
    local repo_name=$1
    local repo_config=$2
    
    local env_file="${WORKSPACE_DIR}/${repo_name}/.env"
    local env_example_file="${WORKSPACE_DIR}/${repo_name}/.env.example"
    
    # Skip if .env already exists
    if [[ -f "${env_file}" ]]; then
        info "${repo_name}/.env already exists, skipping"
        return 0
    fi
    
    # Check if auto-configuration is enabled for development
    local auto_configure
    auto_configure=$(jq -r '.environments.development.auto_configure // false' "${ENVIRONMENTS_CONFIG}")
    
    if [[ "${auto_configure}" == "true" ]]; then
        log "Auto-configuring ${repo_name} for development environment"
        create_auto_configured_env "${repo_name}" "${repo_config}"
    else
        # Create .env.example if it doesn't exist
        if [[ ! -f "${env_example_file}" ]]; then
            create_env_example_file "${repo_name}" "${repo_config}"
        fi
        
        # Copy .env.example to .env
        if [[ -f "${env_example_file}" ]]; then
            cp "${env_example_file}" "${env_file}"
            info "Created ${repo_name}/.env from .env.example"
        fi
    fi
}

create_auto_configured_env() {
    local repo_name=$1
    local repo_config=$2
    local env_file="${WORKSPACE_DIR}/${repo_name}/.env"
    
    # Use the new dynamic configuration generation
    local env_content
    env_content=$(generate_env_config "${repo_name}" "${repo_config}" "development")
    
    echo -e "${env_content}" > "${env_file}"
    
    success "✅ Auto-configured ${repo_name}/.env for development (ready to use)"
    
    # Also create .env.example for reference
    create_env_example_file "${repo_name}" "${repo_config}"
}

create_env_example_file() {
    local repo_name=$1
    local repo_config=$2
    local env_example_file="${WORKSPACE_DIR}/${repo_name}/.env.example"
    
    local technology port database
    technology=$(echo "${repo_config}" | jq -r '.technology')
    port=$(echo "${repo_config}" | jq -r '.port // empty')
    database=$(echo "${repo_config}" | jq -r '.database // empty')
    
    cat > "${env_example_file}" << EOF
# ${repo_name} Environment Configuration
NODE_ENV=development
EOF
    
    if [[ -n "${port}" ]]; then
        echo "PORT=${port}" >> "${env_example_file}"
    fi
    
    if [[ "${database}" == "postgresql" ]]; then
        cat >> "${env_example_file}" << EOF

# PostgreSQL Database
DATABASE_URL=postgresql://username:password@localhost:5432/trivance_${repo_name}
EOF
    elif [[ "${database}" == "mongodb" ]]; then
        cat >> "${env_example_file}" << EOF

# MongoDB Database  
DATABASE_URL=mongodb://localhost:27017/trivance_${repo_name}
EOF
    fi
    
    cat >> "${env_example_file}" << EOF

# JWT Configuration
JWT_SECRET=your-secure-jwt-secret-here
JWT_EXPIRATION_TIME=3600

# External Services (configure as needed)
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_REGION=us-east-1
# SENTRY_DSN=
EOF
    
    info "Created ${repo_name}/.env.example"
}

copy_configurations() {
    log "Copying workspace configurations"
    
    cd "${WORKSPACE_DIR}"
    
    # Copy AI configurations (if they exist)
    if [[ -d "${PROJECT_ROOT}/.claude" ]] && [[ ! -d ".claude" ]]; then
        cp -r "${PROJECT_ROOT}/.claude" .
        info "Copied Claude Code configuration"
    elif [[ ! -d ".claude" ]]; then
        info "No Claude Code configuration found in repo - skipping"
    fi
    
    if [[ -d "${PROJECT_ROOT}/.ai-config" ]] && [[ ! -d ".ai-config" ]]; then
        cp -r "${PROJECT_ROOT}/.ai-config" .
        info "Copied universal AI configuration"
    elif [[ ! -d ".ai-config" ]]; then
        info "No AI configuration found in repo - skipping"
    fi
    
    # Copy scripts
    if [[ ! -d "scripts" ]]; then
        cp -r "${PROJECT_ROOT}/scripts" .
        chmod +x scripts/**/*.sh 2>/dev/null || true
        info "Copied workspace scripts"
    fi
    
    # Copy VS Code workspace
    if [[ ! -f "TrivancePlatform.code-workspace" ]]; then
        cp "${PROJECT_ROOT}/templates/TrivancePlatform.code-workspace.template" TrivancePlatform.code-workspace
        info "Copied VS Code workspace configuration"
    fi
}

generate_documentation() {
    log "Generating workspace documentation"
    
    cd "${WORKSPACE_DIR}"
    
    # Generate CLAUDE.md from template
    if [[ -f "${PROJECT_ROOT}/templates/CLAUDE.md.template" ]]; then
        local timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        sed "s/{{TIMESTAMP_PLACEHOLDER}}/${timestamp}/g" \
            "${PROJECT_ROOT}/templates/CLAUDE.md.template" > CLAUDE.md
        
        info "Generated CLAUDE.md"
    fi
    
    # Generate README.md if it doesn't exist
    if [[ ! -f "README.md" ]]; then
        generate_workspace_readme
        info "Generated workspace README.md"
    fi
}

generate_workspace_readme() {
    cat > README.md << 'EOF'
# Trivance Platform - Development Workspace

Multi-repository workspace for Trivance Platform development.

## Quick Start

```bash
# Start all services
./scripts/start-all-services.sh

# Check system health
./scripts/check-health.sh

# Stop all services  
./scripts/stop-all-services.sh
```

## Repository Structure

- `ms_level_up_management/` - Backend API (NestJS + GraphQL)
- `ms_trivance_auth/` - Authentication service (NestJS)
- `level_up_backoffice/` - Admin frontend (React + Vite)
- `trivance-mobile/` - Mobile app (React Native + Expo)
- `trivance-dev-config/` - Development configuration

## Development URLs

- Frontend: http://localhost:5173
- Backend API: http://localhost:3000
- Auth Service: http://localhost:3001
- GraphQL Playground: http://localhost:3000/graphql

## Documentation

- [Onboarding Guide](trivance-dev-config/docs/ONBOARDING.md)
- [Development Workflows](trivance-dev-config/docs/WORKFLOWS.md) 
- [Troubleshooting](trivance-dev-config/docs/TROUBLESHOOTING.md)
- [AI Configuration](CLAUDE.md)
EOF
}

validate_installation() {
    log "Validating workspace installation"
    
    cd "${WORKSPACE_DIR}"
    
    if ! validate_workspace_structure "${WORKSPACE_DIR}"; then
        error "Workspace structure validation failed"
        return 1
    fi
    
    # Check that all repositories have node_modules
    local repos
    repos=$(jq -r '.repositories[].name' "${REPOSITORIES_CONFIG}")
    
    while IFS= read -r repo_name; do
        if [[ -f "${repo_name}/package.json" ]] && [[ ! -d "${repo_name}/node_modules" ]]; then
            warning "${repo_name} is missing node_modules"
        fi
    done <<< "${repos}"
    
    success "Installation validation completed"
}

display_summary() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    SETUP COMPLETED                          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log "Trivance Platform workspace configured successfully"
    
    echo ""
    info "Next steps:"
    echo "  1. Configure environment variables in each repository"
    echo "  2. Start services: ./scripts/start-all-services.sh"
    echo "  3. Open workspace: code TrivancePlatform.code-workspace"
    echo "  4. Validate setup: ./scripts/check-health.sh"
    echo ""
    
    info "Documentation:"
    echo "  - Workspace overview: ./README.md"
    echo "  - AI configuration: ./CLAUDE.md"
    echo "  - Detailed guides: ./trivance-dev-config/docs/"
    echo ""
    
    success "Workspace setup completed successfully"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi