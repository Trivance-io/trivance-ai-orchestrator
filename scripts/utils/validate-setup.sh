#!/bin/bash
# Trivance Platform - Setup Validation Tests
# Automated validation to ensure setup completeness

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
test_repositories_exist() {
    echo -n "Testing: All repositories cloned... "
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local all_exist=true
    
    for repo in "${repos[@]}"; do
        if [[ ! -d "$WORKSPACE_DIR/$repo/.git" ]]; then
            all_exist=false
            break
        fi
    done
    
    if $all_exist; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - Missing repositories"
        ((TESTS_FAILED++))
    fi
}

test_env_files_exist() {
    echo -n "Testing: Environment files created... "
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local all_exist=true
    
    for repo in "${repos[@]}"; do
        if [[ ! -f "$WORKSPACE_DIR/$repo/.env" ]]; then
            all_exist=false
            break
        fi
    done
    
    if $all_exist; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - Missing .env files"
        ((TESTS_FAILED++))
    fi
}

test_dependencies_installed() {
    echo -n "Testing: Dependencies installed... "
    local repos=("ms_trivance_auth" "ms_level_up_management" "level_up_backoffice" "trivance-mobile")
    local all_installed=true
    
    for repo in "${repos[@]}"; do
        if [[ ! -d "$WORKSPACE_DIR/$repo/node_modules" ]]; then
            all_installed=false
            break
        fi
    done
    
    if $all_installed; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - Missing node_modules"
        ((TESTS_FAILED++))
    fi
}

test_secrets_generated() {
    echo -n "Testing: Secrets file generated... "
    if [[ -f "$WORKSPACE_DIR/.trivance-secrets" ]]; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - No secrets file found"
        ((TESTS_FAILED++))
    fi
}

test_no_hardcoded_secrets() {
    echo -n "Testing: No hardcoded secrets in .env files... "
    local found_hardcoded=false
    
    # Check for common hardcoded patterns
    if grep -r "dev_jwt_secret_auth_2024" "$WORKSPACE_DIR"/ms_*/.env 2>/dev/null; then
        found_hardcoded=true
    fi
    
    if $found_hardcoded; then
        error "FAIL - Found hardcoded secrets"
        ((TESTS_FAILED++))
    else
        success "PASS"
        ((TESTS_PASSED++))
    fi
}

test_ports_available() {
    echo -n "Testing: Required ports available... "
    local ports=(3000 3001 5173)
    local all_available=true
    
    for port in "${ports[@]}"; do
        if lsof -i:$port &>/dev/null; then
            all_available=false
            break
        fi
    done
    
    if $all_available; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        warn "WARN - Some ports in use"
        ((TESTS_PASSED++))  # Warning, not failure
    fi
}

test_pm2_installed() {
    echo -n "Testing: PM2 installed globally... "
    if command -v pm2 &>/dev/null; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - PM2 not found"
        ((TESTS_FAILED++))
    fi
}

test_compilation() {
    echo -n "Testing: Backend services compile... "
    local compile_success=true
    
    # Test auth service
    if [[ -d "$WORKSPACE_DIR/ms_trivance_auth" ]]; then
        cd "$WORKSPACE_DIR/ms_trivance_auth"
        if ! npm run build &>/dev/null; then
            compile_success=false
        fi
    fi
    
    # Test management service
    if [[ -d "$WORKSPACE_DIR/ms_level_up_management" ]] && $compile_success; then
        cd "$WORKSPACE_DIR/ms_level_up_management"
        if ! npm run build &>/dev/null; then
            compile_success=false
        fi
    fi
    
    cd "$WORKSPACE_DIR"
    
    if $compile_success; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - Compilation errors"
        ((TESTS_FAILED++))
    fi
}

test_workspace_structure() {
    echo -n "Testing: Workspace structure correct... "
    local required_dirs=("logs" "envs")
    local all_exist=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$WORKSPACE_DIR/$dir" ]]; then
            all_exist=false
            break
        fi
    done
    
    if $all_exist; then
        success "PASS"
        ((TESTS_PASSED++))
    else
        error "FAIL - Missing required directories"
        ((TESTS_FAILED++))
    fi
}

# Main test runner
run_all_tests() {
    echo "Running Trivance Setup Validation Tests"
    echo "======================================="
    echo
    
    test_repositories_exist
    test_env_files_exist
    test_dependencies_installed
    test_secrets_generated
    test_no_hardcoded_secrets
    test_ports_available
    test_pm2_installed
    test_compilation
    test_workspace_structure
    
    echo
    echo "======================================="
    echo "Test Results:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "======================================="
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        success "✅ All tests passed!"
        return 0
    else
        error "❌ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi