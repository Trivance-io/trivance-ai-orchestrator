---
description: "Elegant git workflow with smart validation and semantic commits"
argument-hint: "commit message or change description"
allowed-tools: ["Bash", "Read", "Grep"]
---

# 🚀 Git Workflow: Einstein Principle Applied

*"Everything should be made as simple as possible, but not simpler"*

## Core Validation & Smart Commit

```bash
# Essential security check - blocks critical secrets
security_check() {
    if git diff --cached --name-only | grep -E "\.env$|\.secret" 2>/dev/null; then
        echo "🚨 Environment files detected in staging area - commit blocked"
        return 1
    fi
    
    if grep -r -E "(password|token|secret|key).*=.*[\"'][^\"']*[\"']" . \
        --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -3; then
        echo "🚨 Potential credentials detected - verify before committing"
        return 1
    fi
    
    return 0
}

# Quality validation when needed
quality_check() {
    local changed_files=$(git diff --cached --name-only 2>/dev/null)
    
    # Skip validation for docs-only changes
    if echo "$changed_files" | grep -qvE "\.(md|txt)$" 2>/dev/null; then
        if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
            npm run lint --silent 2>/dev/null || {
                echo "❌ Lint check failed - run 'npm run lint' to fix"
                return 1
            }
        fi
    fi
    
    return 0
}

# Smart commit type detection
detect_commit_type() {
    local files="$1"
    
    # Documentation changes
    if echo "$files" | grep -qE "\.(md|txt)$" && ! echo "$files" | grep -qvE "\.(md|txt)$"; then
        echo "docs"
        return
    fi
    
    # Test files
    if echo "$files" | grep -qE "(test|spec)" && ! echo "$files" | grep -qvE "(test|spec)"; then
        echo "test"
        return
    fi
    
    # Configuration files
    if echo "$files" | grep -qE "(config|\.json$|\.yaml$)" && ! echo "$files" | grep -qvE "\.(js|ts|py)$"; then
        echo "chore"
        return
    fi
    
    # Detect fixes vs features
    local additions=$(git diff --cached --numstat 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    local deletions=$(git diff --cached --numstat 2>/dev/null | awk '{sum+=$2} END {print sum+0}')
    
    if [ "$deletions" -gt "$additions" ]; then
        echo "refactor"
    elif echo "$files" | grep -qE "fix|bug" || git log -1 --format=%B 2>/dev/null | grep -qi "fix"; then
        echo "fix"
    else
        echo "feat"
    fi
}

# Main workflow execution
execute_workflow() {
    echo "🔍 Validating changes..."
    
    # Security check (always critical)
    if ! security_check; then
        echo "🛑 Security validation failed"
        return 1
    fi
    
    # Quality check (when applicable)
    if ! quality_check; then
        echo "🛑 Quality validation failed"
        return 1
    fi
    
    # Auto-stage if needed
    local staged_files=$(git diff --cached --name-only 2>/dev/null)
    if [ -z "$staged_files" ]; then
        git add -A
        staged_files=$(git diff --cached --name-only 2>/dev/null)
    fi
    
    # Generate semantic commit
    local commit_type=$(detect_commit_type "$staged_files")
    local commit_msg="${commit_type}: $*

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    echo "✅ Validations passed"
    echo "📝 Commit type: $commit_type"
    echo "📄 Files: $(echo "$staged_files" | wc -l | tr -d ' ') staged"
    
    # Execute commit
    git commit -m "$commit_msg"
    
    if [ $? -eq 0 ]; then
        echo "✅ Commit created successfully"
        
        # Push confirmation
        echo ""
        echo "Push to origin? [y/N]: "
        read -r confirm
        case "$confirm" in
            [yY]|[yY][eE][sS])
                git push origin "$(git branch --show-current)"
                ;;
            *)
                echo "💡 Run 'git push' when ready"
                ;;
        esac
    else
        echo "❌ Commit failed"
        return 1
    fi
}

# Execute the workflow
execute_workflow "$@"
```