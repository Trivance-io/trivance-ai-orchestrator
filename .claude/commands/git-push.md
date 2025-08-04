---
description: "Security-focused git push with comprehensive validation filters"
argument-hint: "optional: target branch (defaults to current branch)"
allowed-tools: ["Bash", "Read", "Grep"]
---

# 🔒 Secure Git Push: Security-First Approach

*"Security validation before push - Einstein Principle applied"*

## Pre-Push Security Filters

I'll perform comprehensive security validations before allowing any push to remote repository:

```bash
#!/bin/bash

# 🚨 CRITICAL: Environment & Secret Files Detection
check_environment_files() {
    echo "🔍 Scanning for environment files..."
    
    local sensitive_files=$(find . -name "*.env*" -o -name "*.secret*" -o -name "*.key" -o -name "*.pem" -o -name "*.p12" \
        -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null)
    
    if [ -n "$sensitive_files" ]; then
        echo "🚨 BLOCKED: Sensitive files detected:"
        echo "$sensitive_files"
        return 1
    fi
    
    return 0
}

# 🚨 CRITICAL: Credential Pattern Detection
check_credentials_in_code() {
    echo "🔍 Scanning for hardcoded credentials..."
    
    local patterns=(
        "password\s*=\s*['\"][^'\"]{3,}"
        "token\s*=\s*['\"][^'\"]{10,}"
        "secret\s*=\s*['\"][^'\"]{8,}"
        "api[_-]?key\s*=\s*['\"][^'\"]{8,}"
        "private[_-]?key\s*=\s*['\"][^'\"]{20,}"
        "aws[_-]?(access|secret)\s*=\s*['\"][^'\"]{10,}"
        "database[_-]?url\s*=\s*['\"].*://.*:[^'\"]*@"
    )
    
    for pattern in "${patterns[@]}"; do
        if grep -rE "$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude="*.md" 2>/dev/null | head -1; then
            echo "🚨 BLOCKED: Potential credential pattern detected"
            echo "Pattern: $pattern"
            return 1
        fi
    done
    
    return 0
}

# 🚨 CRITICAL: Large File Detection  
check_large_files() {
    echo "🔍 Scanning for large files..."
    
    local large_files=$(find . -type f -size +10M -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null)
    
    if [ -n "$large_files" ]; then
        echo "⚠️  WARNING: Large files detected (>10MB):"
        echo "$large_files"
        echo "Consider using Git LFS for these files"
        echo ""
        echo "Continue anyway? [y/N]: "
        read -r confirm
        case "$confirm" in
            [yY]|[yY][eE][sS]) return 0 ;;
            *) return 1 ;;
        esac
    fi
    
    return 0
}

# 🔒 Branch Protection Check
check_protected_branches() {
    local current_branch=$(git branch --show-current)
    local protected_branches=("main" "master" "production" "prod")
    
    for branch in "${protected_branches[@]}"; do
        if [ "$current_branch" = "$branch" ]; then
            echo "⚠️  WARNING: Pushing directly to protected branch: $current_branch"
            echo "Consider using feature branches and pull requests"
            echo ""
            echo "Continue push to $current_branch? [y/N]: "
            read -r confirm
            case "$confirm" in
                [yY]|[yY][eE][sS]) return 0 ;;
                *) return 1 ;;
            esac
        fi
    done
    
    return 0
}

# 🔍 Unpushed Commits Summary
show_push_summary() {
    local target_branch="${1:-$(git branch --show-current)}"
    local remote_exists=$(git ls-remote --heads origin "$target_branch" 2>/dev/null)
    
    echo "📊 Push Summary:"
    echo "─────────────────────────────────────"
    echo "🎯 Target: origin/$target_branch"
    
    if [ -n "$remote_exists" ]; then
        local commits_ahead=$(git rev-list --count "origin/$target_branch..$target_branch" 2>/dev/null || echo "0")
        echo "📈 Commits ahead: $commits_ahead"
        
        if [ "$commits_ahead" -gt 0 ]; then
            echo ""
            echo "📝 Commits to push:"
            git log --oneline "origin/$target_branch..$target_branch" 2>/dev/null || git log --oneline -n 5
        fi
    else
        echo "🆕 New branch (no remote tracking)"
        echo "📝 Recent commits:"
        git log --oneline -n 5
    fi
    echo "─────────────────────────────────────"
}

# 🚀 Execute Security Validations & Push Authorization
execute_secure_push() {
    local target_branch="${1:-$(git branch --show-current)}"
    
    echo "🔒 SECURITY VALIDATION PROTOCOL"
    echo "═══════════════════════════════════════"
    
    if ! check_environment_files; then
        echo "🛑 PUSH BLOCKED: Environment files detected"
        return 1
    fi
    
    if ! check_credentials_in_code; then
        echo "🛑 PUSH BLOCKED: Credentials detected in code"
        return 1
    fi
    
    if ! check_large_files; then
        echo "🛑 PUSH BLOCKED: Large files validation failed"
        return 1
    fi
    
    if ! check_protected_branches; then
        echo "🛑 PUSH BLOCKED: Protected branch validation failed"
        return 1
    fi
    
    echo "✅ ALL SECURITY VALIDATIONS PASSED"
    echo "═══════════════════════════════════════"
    echo ""
    
    show_push_summary "$target_branch"
    echo ""
    
    echo "🚀 AUTHORIZATION REQUIRED"
    echo "─────────────────────────────────────"
    echo "All security checks passed successfully."
    echo "Ready to push to: origin/$target_branch"
    echo ""
    echo "🔐 Authorize push? [y/N]: "
    read -r authorize
    
    case "$authorize" in
        [yY]|[yY][eE][sS])
            echo "🚀 Executing push..."
            git push origin "$target_branch"
            
            if [ $? -eq 0 ]; then
                echo "✅ Push completed successfully!"
                echo "🌐 Changes are now live on origin/$target_branch"
            else
                echo "❌ Push failed - check output above"
                return 1
            fi
            ;;
        *)
            echo "🛑 Push cancelled by user"
            echo "💡 Run this command again when ready to push"
            return 1
            ;;
    esac
}

execute_secure_push "$@"
```