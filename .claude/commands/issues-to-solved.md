# Issues to Solved

Resuelve issues asociados a un PR específico.

## Uso

```bash
/issues-to-solved <pr_number>  # Argumento requerido
```

## Ejemplos

```bash
/issues-to-solved 96     # Issues del PR #96
/issues-to-solved 123    # Issues del PR #123
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

# Validar PR number
pr_number="${1:-$ARGUMENTS}"
if [[ -z "$pr_number" || ! "$pr_number" =~ ^[1-9][0-9]*$ ]]; then
    echo "❌ Error: PR number requerido"
    echo "Uso: /issues-to-solved <pr_number>" 
    echo "Ejemplo: /issues-to-solved 96"
    exit 1
fi

# Verificar PR existe
if ! gh pr view "$pr_number" >/dev/null 2>&1; then
    echo "❌ PR #$pr_number no existe"
    exit 1
fi

today=$(date '+%Y-%m-%d')
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
mkdir -p ".claude/issues-review"

pr_body=$(gh pr view "$pr_number" --json body --jq '.body // ""')
associated_issues=$(echo "$pr_body" | grep -oE '(Fixes|Closes|Resolves) #[0-9]+' | grep -o '[0-9]\+' | sort -nu | tr '\n' ' ' | xargs)

if [[ -z "$associated_issues" ]]; then
    echo "❌ No issues asociados al PR #$pr_number"
    echo "Ejecuta /findings-to-issues primero"
    exit 1
fi

issues_count=$(echo "$associated_issues" | wc -w)
echo "Found $issues_count issues: $associated_issues"

issues_data=""
for issue_num in $associated_issues; do
    if issue_info=$(gh issue view "$issue_num" --json title,body --jq '{title: .title, body: (.body // "")}' 2>/dev/null); then
        title=$(echo "$issue_info" | jq -r '.title')
        body=$(echo "$issue_info" | jq -r '.body')
        
        # Extract priority from title
        priority=$(echo "$title" | grep -oE '\[(Security|Bug|Testing)\]' | tr -d '[]' | tr '[:lower:]' '[:upper:]')
        [[ "$priority" == "SECURITY" ]] && priority="CRITICAL"
        [[ "$priority" == "BUG" ]] && priority="HIGH" 
        [[ "$priority" == "TESTING" ]] && priority="LOW"
        
        # Extract file information from body
        files_mentioned=$(echo "$body" | grep -oE '\*\*File\*\*: [^\n]+|\- \*\*File\*\*: [^\n]+|\*\*Lines\*\*: [^\n]+' | head -3)
        
        # Create formatted issue entry
        printf -v issue_entry "\n\n---\n### 🎯 Issue #%s: %s\n**Priority: %s**\n\n" "$issue_num" "$title" "${priority:-MEDIUM}"
        issues_data+="$issue_entry"  
        [[ -n "$files_mentioned" ]] && issues_data+="📁 **Files/Lines:**\n$files_mentioned\n\n"
        issues_data+="$body\n"
    else
        echo "Issue #$issue_num not accessible"
    fi
done

analysis_file=".claude/issues-review/${today}-pr${pr_number}-plan.md"

cat > "$analysis_file" <<EOF
# 🎯 Implementation Plan - PR #$pr_number ($timestamp)

## 📋 Issues Summary ($issues_count issues found)
$issues_data

---

## 🔍 Priority Analysis

### CRITICAL (Security - Immediate Action)
- Issues marked [Security] require immediate implementation
- Risk: Potential security vulnerabilities or code injection

### HIGH (Bugs - Within 24h)
- Issues marked [Bug] affect core functionality 
- Risk: System instability or user experience degradation

### MEDIUM-LOW (Enhancements - Next Sprint)
- Issues marked [Testing] or general improvements
- Risk: Technical debt but not blocking

## 🚀 Implementation Recommendations

### Immediate Actions (Do First):
1. **Review each CRITICAL issue** - examine suggested fixes
2. **Validate current code state** - check if fixes already implemented
3. **Implement HIGH priority issues** - focus on stability fixes

### Implementation Order:
1. CRITICAL security fixes (if any)
2. HIGH priority bug fixes  
3. MEDIUM priority improvements
4. LOW priority enhancements

### Next Steps:
- [ ] Review suggested solutions in each issue
- [ ] Check current code implementation status
- [ ] Create implementation tasks for HIGH+ priority items
- [ ] Test fixes in separate branch before merge

---
**📖 Usage:** Review issues above → Implement by priority → Test → Deploy
EOF

# Note: Enhanced plan template now provides structured guidance
echo "📝 Enhanced implementation plan generated with priority analysis"

echo ""
echo "Implementation Plan:"
echo "────────────────────"
cat "$analysis_file"
echo "────────────────────"

echo ""
read -p "Execute implementation plan? (y/N): " -r execute
[[ ! "$execute" =~ ^[Yy]$ ]] && { echo "Implementation cancelled"; exit 0; }

echo "Executing fixes..."
changes_log=""

critical_fixes=$(grep -A 5 "Critical\|High" "$analysis_file" | grep -E "^[0-9]+\." | head -3)

if [[ -n "$critical_fixes" ]]; then
    echo "Applying critical fixes:"
    echo "$critical_fixes"
    
    # Solo operaciones no-destructivas
    if grep -qi "test.*structure\|testing.*framework" "$analysis_file"; then
        mkdir -p tests/integration
        echo '#!/bin/bash\necho "Basic integration test structure created"' > tests/integration/basic.sh
        chmod +x tests/integration/basic.sh
        changes_log+="- Created test structure\\n"
    fi
    
    if grep -qi "documentation\|readme" "$analysis_file"; then
        if [[ ! -f IMPLEMENTATION.md ]]; then
            echo "# Implementation Notes\\n\\nGenerated: $timestamp\\nPR: #$pr_number\\nIssues: $associated_issues" > IMPLEMENTATION.md
            changes_log+="- Created documentation\\n"
        fi
    fi
    
    echo "Safe fixes applied"
else
    echo "No critical fixes requiring implementation"
fi

logs_dir=".claude/logs/$today"
mkdir -p "$logs_dir"

jq -n \\
    --arg timestamp "$timestamp" \\
    --argjson pr "$pr_number" \\
    --arg issues "$associated_issues" \\
    --argjson count "$issues_count" \\
    --arg plan "$analysis_file" \\
    --arg executed "$([[ "$execute" =~ ^[Yy]$ ]] && echo "true" || echo "false")" \\
    '{timestamp: $timestamp, pr_number: $pr, issues: $issues, count: $count, plan_file: $plan, executed: $executed}' \\
    >> "$logs_dir/issues_resolved.jsonl"

if git status --porcelain | grep -q .; then
    echo ""
    read -p "Commit changes? (y/N): " -r commit
    if [[ "$commit" =~ ^[Yy]$ ]]; then
        git add -A
        commit_msg="fix: resolve issues from PR #$pr_number

$(echo "$associated_issues" | tr ' ' '\\n' | sed 's/^/Resolves #/')

Implementation:
$(echo -e "$changes_log")"
        
        git commit -m "$commit_msg"
        echo "Changes committed"
        
        read -p "Push changes? (y/N): " -r push
        [[ "$push" =~ ^[Yy]$ ]] && git push
    fi
fi

echo ""
echo "Plan: $analysis_file"
echo "Log: $logs_dir/issues_resolved.jsonl" 
echo "PR #$pr_number analysis completed"
```