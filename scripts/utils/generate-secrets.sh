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

# Generate safe development values
generate_dev_safe_value() {
    local type="$1"
    case "$type" in
        "firebase")
            echo "AIzaSyDEV-$(generate_secret 16)-SAFE"
            ;;
        "recaptcha")
            echo "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"  # Google's test key
            ;;
        *)
            echo "dev_safe_$(generate_secret 16)"
            ;;
    esac
}

# Main function to generate all secrets
generate_all_secrets() {
    local output_file="${1:-secrets.env}"
    
    cat > "$output_file" << EOF
# Generated Development Secrets - $(date)
# DO NOT COMMIT THIS FILE TO GIT
# These are secure values for LOCAL DEVELOPMENT ONLY

# JWT Secrets (Auto-generated secure)
AUTH_JWT_SECRET=$(generate_jwt_secret)
MGMT_JWT_SECRET=$(generate_jwt_secret)

# Password Secrets (Auto-generated secure)
AUTH_PASSWORD_SECRET=$(generate_password_secret)
MGMT_PASSWORD_SECRET=$(generate_password_secret)

# Encryption Keys (Auto-generated secure)
AUTH_ENCRYPT_SECRET=$(generate_secret 32)
MGMT_ENCRYPT_SECRET=$(generate_secret 32)
CARD_ENCRYPT_KEY=$(generate_secret 32)
BACKOFFICE_ENCRYPT_SECRET=$(generate_secret 32)
FRONTEND_APP_SECRET=$(generate_secret 32)

# Email Secrets (Auto-generated secure)
AUTH_SECRET_EMAIL=$(generate_secret 24)
MGMT_SECRET_EMAIL=$(generate_secret 24)

# API Keys (Optional - Empty for local dev)
EMAIL_API_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
VERIFY_SERVICE_SID=
AWS_ACCESS_KEY=
AWS_SECRET_KEY=
EPAYCO_API_KEY=
EPAYCO_SECRET_KEY=
WOMPI_ACCESS_KEY=
WOMPI_SECRET_KEY=
WOMPI_INTEGRITY_KEY=
GOOGLE_OAUTH_SECRET=
GOOGLE_MAPS_KEY=

# Safe Development Values (Non-sensitive)
DEV_FIREBASE_API_KEY=$(generate_dev_safe_value "firebase")
DEV_RECAPTCHA_KEY=$(generate_dev_safe_value "recaptcha")

# Firebase (Generated safe key for dev)
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n$(generate_secret 64)\n-----END PRIVATE KEY-----"
EOF

    echo "✅ Secrets generated in: $output_file"
    echo "🔐 All sensitive values are unique and secure"
    echo "📋 Optional API keys are empty (configure if needed)"
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