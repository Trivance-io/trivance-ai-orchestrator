#!/bin/bash
# .claude/hooks/excellence-standards.sh
# Fortune 500 Excellence Standards for AI-FIRST Development

# Detect service context from file path
detect_service_context() {
    local file_path="$1"
    
    if [[ "$file_path" == *"ms_level_up_management"* ]]; then
        echo "management"
    elif [[ "$file_path" == *"ms_trivance_auth"* ]]; then
        echo "auth"
    elif [[ "$file_path" == *"level_up_backoffice"* ]]; then
        echo "frontend"
    elif [[ "$file_path" == *"trivance-mobile"* ]]; then
        echo "mobile"
    else
        echo "general"
    fi
}

# Apply Fortune 500 excellence principles before code generation
apply_excellence_principles() {
    local file_path="$1"
    local service=$(detect_service_context "$file_path")
    
    echo "📋 AI EXCELLENCE CHECKLIST (Fortune 500 Standards)"
    echo "=================================================="
    echo "🎯 Context: $service service"
    echo "📍 File: $file_path"
    echo ""
    
    echo "🔒 SECURITY PRINCIPLES:"
    echo "   ✓ No hardcoded credentials or secrets"
    echo "   ✓ Input validation and sanitization"
    echo "   ✓ OWASP Top 10 compliance"
    echo "   ✓ Secure coding practices"
    echo ""
    
    echo "🏗️ ARCHITECTURAL PRINCIPLES:"
    echo "   ✓ SOLID principles adherence"
    echo "   ✓ Single responsibility focus"
    echo "   ✓ Appropriate design patterns"
    echo "   ✓ Service-specific best practices"
    echo ""
    
    echo "📊 QUALITY PRINCIPLES:"
    echo "   ✓ Clean, maintainable code"
    echo "   ✓ Appropriate complexity levels"
    echo "   ✓ Consistent naming conventions"
    echo "   ✓ Minimal technical debt"
    echo ""
    
    case "$service" in
        "management"|"auth")
            echo "🔧 NESTJS SPECIFIC PRINCIPLES:"
            echo "   ✓ Dependency injection patterns"
            echo "   ✓ Repository pattern for data access"
            echo "   ✓ DTO pattern for API boundaries"
            echo "   ✓ Guard pattern for auth/validation"
            ;;
        "frontend")
            echo "⚛️ REACT SPECIFIC PRINCIPLES:"
            echo "   ✓ Hooks pattern for state management"
            echo "   ✓ Component composition over inheritance"
            echo "   ✓ TypeScript interfaces for type safety"
            echo "   ✓ Redux Toolkit for global state"
            ;;
        "mobile")
            echo "📱 REACT NATIVE PRINCIPLES:"
            echo "   ✓ Platform-specific optimizations"
            echo "   ✓ Performance-first component design"
            echo "   ✓ Proper navigation patterns"
            echo "   ✓ Environment-aware configurations"
            ;;
    esac
    
    echo ""
    echo "🎯 Ready to apply these standards to code generation."
}

# Validate secure commands for Bash tool
validate_secure_command() {
    local command="$1"
    
    echo "🔒 SECURITY VALIDATION: Checking command safety..."
    echo "📝 Command: $command"
    
    # Check for dangerous patterns
    local dangerous_patterns=(
        "rm -rf /"
        "chmod 777"
        "sudo rm"
        "curl.*|.*sh"
        "wget.*|.*sh"
        "eval"
        "> /etc/"
        "dd if="
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if echo "$command" | grep -qE "$pattern"; then
            echo "🚨 BLOCKED: Potentially dangerous command detected"
            echo "❌ Pattern: $pattern"
            echo "💡 Consider safer alternatives or be more specific"
            echo ""
            echo "📚 Safe command guidelines:"
            echo "   - Use absolute paths instead of wildcards"
            echo "   - Avoid piping downloads directly to shell"
            echo "   - Use specific permissions instead of 777"
            echo "   - Review scripts before executing"
            exit 1
        fi
    done
    
    echo "✅ Command appears safe to execute"
}

# Validate output quality after code generation
validate_output_quality() {
    local file_path="$1"
    local service=$(detect_service_context "$file_path")
    local issues=0
    local warnings=0
    
    echo "📊 QUALITY AUDIT: Analyzing generated code..."
    echo "=============================================="
    echo "📍 File: $file_path"
    echo "🎯 Service: $service"
    echo ""
    
    # Security validation
    echo "🔒 SECURITY AUDIT:"
    if grep -qE "password.*=.*['\"][^'\"]*['\"]|secret.*=.*['\"][^'\"]*['\"]|token.*=.*['\"][^'\"]*['\"]" "$file_path" 2>/dev/null; then
        echo "   ❌ CRITICAL: Hardcoded credentials detected"
        ((issues++))
    else
        echo "   ✅ No hardcoded credentials found"
    fi
    
    if grep -qE "console\.log.*password|console\.log.*secret|console\.log.*token" "$file_path" 2>/dev/null; then
        echo "   ❌ CRITICAL: Sensitive data in logs"
        ((issues++))
    else
        echo "   ✅ No sensitive data in logs"
    fi
    
    if grep -qE "innerHTML\s*=|eval\(|exec\(" "$file_path" 2>/dev/null; then
        echo "   ⚠️  WARNING: Potential injection vulnerability"
        ((warnings++))
    else
        echo "   ✅ No obvious injection vectors"
    fi
    
    echo ""
    
    # Architecture validation
    echo "🏗️ ARCHITECTURE AUDIT:"
    local line_count=$(wc -l < "$file_path" 2>/dev/null || echo 0)
    if [ "$line_count" -gt 300 ]; then
        echo "   ⚠️  WARNING: Large file ($line_count lines) - consider breaking down"
        ((warnings++))
    else
        echo "   ✅ File size appropriate ($line_count lines)"
    fi
    
    if grep -qE "new\s+\w+Service\(\)|new\s+\w+Repository\(\)" "$file_path" 2>/dev/null; then
        echo "   ⚠️  WARNING: Direct instantiation detected - prefer dependency injection"
        ((warnings++))
    else
        echo "   ✅ No direct service instantiation"
    fi
    
    echo ""
    
    # Quality validation
    echo "📊 CODE QUALITY AUDIT:"
    local todo_count=$(grep -c "TODO\|FIXME\|XXX\|HACK" "$file_path" 2>/dev/null || echo 0)
    if [ "$todo_count" -gt 3 ]; then
        echo "   ⚠️  WARNING: High technical debt indicators ($todo_count TODOs/FIXMEs)"
        ((warnings++))
    else
        echo "   ✅ Minimal technical debt indicators ($todo_count)"
    fi
    
    if grep -qE "\b(a|b|x|y|z|tmp|temp|data|info|obj)\b\s*[:=]" "$file_path" 2>/dev/null; then
        echo "   ⚠️  WARNING: Non-descriptive variable names detected"
        ((warnings++))
    else
        echo "   ✅ Variable names appear descriptive"
    fi
    
    echo ""
    
    # Final score
    echo "🎯 AUDIT SUMMARY:"
    echo "=================="
    if [ "$issues" -eq 0 ] && [ "$warnings" -eq 0 ]; then
        echo "   🏆 EXCELLENT: Code meets Fortune 500 standards"
        log_audit_result "$file_path" "EXCELLENT" "$issues" "$warnings"
    elif [ "$issues" -eq 0 ] && [ "$warnings" -le 2 ]; then
        echo "   ✅ GOOD: Minor improvements recommended ($warnings warnings)"
        log_audit_result "$file_path" "GOOD" "$issues" "$warnings"
    elif [ "$issues" -eq 0 ]; then
        echo "   ⚠️  ACCEPTABLE: Several improvements needed ($warnings warnings)"
        log_audit_result "$file_path" "ACCEPTABLE" "$issues" "$warnings"
    else
        echo "   ❌ NEEDS WORK: Critical issues must be addressed ($issues critical, $warnings warnings)"
        log_audit_result "$file_path" "NEEDS_WORK" "$issues" "$warnings"
    fi
}

# Generate session audit summary
generate_session_audit() {
    echo "📊 AI SESSION AUDIT SUMMARY"
    echo "============================"
    echo "🕐 Session completed: $(date)"
    echo ""
    
    # Check for any recent changes
    if command -v git &>/dev/null; then
        echo "📝 FILES MODIFIED IN SESSION:"
        git status --porcelain 2>/dev/null | head -20 | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi
    
    # Show recent audit results
    if [ -f ".claude/logs/quality-audit.log" ]; then
        echo "🎯 RECENT QUALITY AUDITS:"
        tail -5 .claude/logs/quality-audit.log 2>/dev/null | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi
    
    echo "💡 RECOMMENDATION: Review changes and run project tests before commit"
}

# Log audit results for enterprise tracking
log_audit_result() {
    local file_path="$1"
    local result="$2"
    local issues="$3"
    local warnings="$4"
    
    local log_dir=".claude/logs"
    mkdir -p "$log_dir"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp | $file_path | $result | Issues: $issues | Warnings: $warnings" >> "$log_dir/quality-audit.log"
}