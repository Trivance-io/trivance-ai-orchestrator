#!/bin/bash

# Dynamic secrets generation for development environment
# Replaces hardcoded secrets with dynamically generated ones

if ! command -v log &> /dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
fi

# Generate secure random secrets
generate_jwt_secret() {
    local length=${1:-64}
    
    if command -v openssl &> /dev/null; then
        openssl rand -base64 "$length" | tr -d '\n'
    elif command -v head &> /dev/null && [[ -e /dev/urandom ]]; then
        head -c "$length" /dev/urandom | base64 | tr -d '\n'
    else
        # Fallback using built-in random
        local secret=""
        for i in {1..64}; do
            secret+=$(printf "%x" $((RANDOM % 16)))
        done
        echo "$secret"
    fi
}

generate_api_key() {
    local prefix=${1:-"dev"}
    local length=${2:-32}
    
    local random_part
    if command -v openssl &> /dev/null; then
        random_part=$(openssl rand -hex "$length")
    else
        random_part=""
        for i in $(seq 1 $((length * 2))); do
            random_part+=$(printf "%x" $((RANDOM % 16)))
        done
    fi
    
    echo "${prefix}_${random_part}"
}

# Get or generate JWT secret for a repository
get_jwt_secret_for_repo() {
    local repo_name=$1
    local secrets_file="${WORKSPACE_DIR}/.dev-secrets"
    
    # Create secrets file if it doesn't exist
    if [[ ! -f "$secrets_file" ]]; then
        touch "$secrets_file"
        chmod 600 "$secrets_file"  # Secure permissions
    fi
    
    # Check if secret already exists for this repo
    local existing_secret
    existing_secret=$(grep "^${repo_name}_JWT_SECRET=" "$secrets_file" 2>/dev/null | cut -d'=' -f2-)
    
    if [[ -n "$existing_secret" ]]; then
        echo "$existing_secret"
    else
        # Generate new secret
        local new_secret
        new_secret=$(generate_jwt_secret)
        
        # Store it
        echo "${repo_name}_JWT_SECRET=${new_secret}" >> "$secrets_file"
        
        info "Generated new JWT secret for ${repo_name}"
        echo "$new_secret"
    fi
}

# Generate development database URL with random database name
generate_dev_database_url() {
    local database_type=$1
    local repo_name=$2
    
    # Generate a unique database name to avoid conflicts
    local db_suffix
    db_suffix=$(date +%s | tail -c 6)  # Last 5 digits of timestamp
    
    case "$database_type" in
        "postgresql")
            echo "postgresql://trivance_dev:trivance_dev_pass@localhost:5432/trivance_${repo_name}_${db_suffix}"
            ;;
        "mongodb")
            echo "mongodb://localhost:27017/trivance_${repo_name}_${db_suffix}"
            ;;
        *)
            warning "Unknown database type: $database_type"
            echo ""
            ;;
    esac
}

# Clean up old secrets (for testing/development)
clean_dev_secrets() {
    local secrets_file="${WORKSPACE_DIR}/.dev-secrets"
    
    if [[ -f "$secrets_file" ]]; then
        rm "$secrets_file"
        info "Cleaned development secrets"
    fi
}

# Display current secrets (masked for security)
show_dev_secrets() {
    local secrets_file="${WORKSPACE_DIR}/.dev-secrets"
    
    if [[ ! -f "$secrets_file" ]]; then
        info "No development secrets file found"
        return 0
    fi
    
    info "Current development secrets:"
    while IFS='=' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            # Mask the value for security
            local masked_value="${value:0:8}...${value: -4}"
            echo "  $key = $masked_value"
        fi
    done < "$secrets_file"
}

# Initialize secrets file with gitignore entry
init_secrets_management() {
    local workspace_dir=$1
    local gitignore_file="${workspace_dir}/.gitignore"
    
    # Add secrets file to gitignore if not already there
    if [[ -f "$gitignore_file" ]]; then
        if ! grep -q ".dev-secrets" "$gitignore_file"; then
            echo ".dev-secrets" >> "$gitignore_file"
            info "Added .dev-secrets to .gitignore"
        fi
    fi
    
    # Create initial secrets file
    local secrets_file="${workspace_dir}/.dev-secrets"
    if [[ ! -f "$secrets_file" ]]; then
        cat > "$secrets_file" << 'EOF'
# Development secrets - Auto-generated
# This file is ignored by git for security
# DO NOT commit this file to version control
EOF
        chmod 600 "$secrets_file"
        info "Initialized development secrets file"
    fi
}

# Generate environment-specific configuration
generate_env_config() {
    local repo_name=$1
    local repo_config=$2
    local environment=${3:-"development"}
    
    local technology port database
    technology=$(echo "$repo_config" | jq -r '.technology')
    port=$(echo "$repo_config" | jq -r '.port // empty')
    database=$(echo "$repo_config" | jq -r '.database // empty')
    
    # Generate dynamic values
    local jwt_secret database_url
    jwt_secret=$(get_jwt_secret_for_repo "$repo_name")
    
    if [[ -n "$database" ]]; then
        database_url=$(generate_dev_database_url "$database" "$repo_name")
    fi
    
    # Build configuration
    local config=""
    config+="# ${repo_name} - Auto-configured for ${environment}\n"
    config+="# Generated: $(date)\n"
    config+="# This configuration uses dynamically generated secrets\n\n"
    
    config+="NODE_ENV=${environment}\n"
    
    if [[ -n "$port" ]]; then
        config+="PORT=${port}\n"
    fi
    
    if [[ -n "$database_url" ]]; then
        config+="\n# Database (dynamically generated)\n"
        config+="DATABASE_URL=${database_url}\n"
    fi
    
    config+="\n# Security (dynamically generated)\n"
    config+="JWT_SECRET=${jwt_secret}\n"
    config+="JWT_EXPIRATION_TIME=24h\n"
    
    config+="\n# Development settings\n"
    config+="LOG_LEVEL=debug\n"
    config+="CORS_ORIGIN=http://localhost:5173,http://localhost:3000\n"
    
    if [[ "$technology" == "nestjs" ]]; then
        config+="GRAPHQL_PLAYGROUND=true\n"
        config+="GRAPHQL_DEBUG=true\n"
        config+="GRAPHQL_INTROSPECTION=true\n"
    fi
    
    config+="\n# External services (configure as needed)\n"
    config+="# AWS_ACCESS_KEY_ID=your-aws-key\n"
    config+="# AWS_SECRET_ACCESS_KEY=your-aws-secret\n"
    config+="# SENTRY_DSN=your-sentry-dsn\n"
    
    config+="\n# Rate limiting\n"
    config+="RATE_LIMIT_TTL=60\n"
    config+="RATE_LIMIT_LIMIT=1000\n"
    
    echo -e "$config"
}