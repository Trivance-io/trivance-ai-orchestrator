#!/bin/bash
# Trivance Platform - Dynamic Secret Generation
# Generates unique development secrets for each installation

set -e

# Generate random secret
generate_secret() {
    local length="${1:-32}"
    openssl rand -hex "$length" 2>/dev/null || \
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# Generate JWT secret
generate_jwt_secret() {
    echo "jwt_$(generate_secret 48)_$(date +%s)"
}

# Generate password secret
generate_password_secret() {
    echo "pwd_$(generate_secret 32)_secure"
}

# Generate API key
generate_api_key() {
    local prefix="${1:-api}"
    echo "${prefix}_$(generate_secret 24)_dev"
}

# Main function to generate all secrets
generate_all_secrets() {
    local output_file="${1:-secrets.env}"
    
    cat > "$output_file" << EOF
# Generated Development Secrets - $(date)
# DO NOT COMMIT THIS FILE TO GIT

# JWT Secrets
AUTH_JWT_SECRET=$(generate_jwt_secret)
MGMT_JWT_SECRET=$(generate_jwt_secret)

# Password Secrets
AUTH_PASSWORD_SECRET=$(generate_password_secret)
MGMT_PASSWORD_SECRET=$(generate_password_secret)

# Encryption Keys
AUTH_ENCRYPT_SECRET=$(generate_secret 32)
MGMT_ENCRYPT_SECRET=$(generate_secret 32)
CARD_ENCRYPT_KEY=$(generate_secret 32)
BACKOFFICE_ENCRYPT_SECRET=$(generate_secret 32)

# API Keys (Development)
EMAIL_API_KEY=$(generate_api_key "email")
TWILIO_AUTH_TOKEN=$(generate_api_key "twilio")
AWS_ACCESS_KEY=$(generate_api_key "aws")
AWS_SECRET_KEY=$(generate_secret 40)
EPAYCO_API_KEY=$(generate_api_key "epayco")
EPAYCO_SECRET_KEY=$(generate_secret 32)
WOMPI_ACCESS_KEY=$(generate_api_key "wompi")
WOMPI_SECRET_KEY=$(generate_secret 32)
WOMPI_INTEGRITY_KEY=$(generate_secret 32)

# OAuth Secrets
GOOGLE_OAUTH_SECRET=$(generate_api_key "google")

# Firebase (Generated)
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n$(generate_secret 64)\n-----END PRIVATE KEY-----"
EOF

    echo "Secrets generated in: $output_file"
}

# Export functions for use in other scripts
export -f generate_secret
export -f generate_jwt_secret
export -f generate_password_secret
export -f generate_api_key

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_all_secrets "$@"
fi