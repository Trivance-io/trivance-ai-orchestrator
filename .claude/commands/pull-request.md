---
description: "pull request creation following industry standards (Google, Netflix, Shopify)"
argument-hint: "optional: --draft, target-branch (auto-detects default branch)"
allowed-tools: ["Bash", "Read", "Grep"]
---

# 🏆 Enterprise Pull Request: Industry Standards

*"Google + Netflix + Shopify patterns - Zero friction, maximum structure"*

## Industry-Grade PR Creation

I'll create pull requests following Fortune 500 engineering standards with AI-powered structure generation:

```bash
#!/bin/bash

# 🎯 AUTO-DETECT DEFAULT BRANCH: Universal repository support
detect_default_branch() {
    local default_branch=""
    
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's/refs\/remotes\/origin\///')
    
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi
    
    default_branch=$(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d' ' -f5)
    
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi
    
    default_branch=$(git branch -r 2>/dev/null | grep -E "(origin/main|origin/master|origin/develop)" | head -1 | sed 's/.*origin\///' | tr -d ' ')
    
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi
    
    echo "main"
    return 0
}

# 🧠 ENTERPRISE ANALYSIS: Industry-standard PR generation
analyze_enterprise_pr() {
    local target_branch="${1:-$(detect_default_branch)}"
    local current_branch=$(git branch --show-current)
    
    echo "🧠 Analyzing changes with enterprise intelligence..."
    
    local files_changed=$(git diff --name-only "$target_branch"...HEAD 2>/dev/null || git diff --name-only --cached)
    local commits=$(git log --oneline "$target_branch"...HEAD 2>/dev/null || git log --oneline -n 5)
    local files_count=$(echo "$files_changed" | grep -c '^' 2>/dev/null || echo "0")
    
    local pr_type="feature"
    local business_impact="low"
    
    if echo "$commits" | grep -qi "fix\|bug\|resolve"; then
        pr_type="bugfix"
        business_impact="medium"
    elif echo "$commits" | grep -qi "hotfix\|critical\|urgent"; then
        pr_type="hotfix"
        business_impact="high"
    elif echo "$commits" | grep -qi "doc\|readme"; then
        pr_type="docs"
        business_impact="low"
    elif echo "$commits" | grep -qi "refactor\|optimize\|improve"; then
        pr_type="refactor"
        business_impact="medium"
    fi
    
    local first_commit=$(echo "$commits" | head -1 | cut -d' ' -f2-)
    local smart_title="$first_commit"
    
    local description="## 🎯 Business Context & Why
$smart_title

**Type**: $pr_type | **Impact**: $business_impact | **Files**: $files_count

## 🏗️ High-Level Design & How
$(if [ "$files_count" -gt 0 ]; then
    echo "**Modified Areas**:"
    echo "$files_changed" | head -8 | sed 's/^/- /'
    if [ "$files_count" -gt 8 ]; then
        echo "- ... and $((files_count - 8)) more files"
    fi
else
    echo "**Changes**: New implementation"
fi)

## 🧪 Testing Strategy
- [ ] Unit tests updated/added for new functionality
- [ ] Integration tests verified
- [ ] Manual testing completed
- [ ] Performance impact assessed

## 📚 Documentation Updates
- [ ] Code comments updated for complex logic
- [ ] API documentation updated (if applicable)
- [ ] README/guides updated (if applicable)

## 🤔 Questions for Reviewers
- Does this approach align with our architecture patterns?
- Any concerns about performance or scalability?
- Is the business logic clear and maintainable?

## 📋 Commit History
\`\`\`
$commits
\`\`\`

---
*Following enterprise standards: Google (focused changes) + Netflix (documentation) + Shopify (business context)*  
🤖 Generated with [Claude Code](https://claude.ai/code)"
    
    echo "📝 Enterprise PR Structure Generated:"
    echo "├── Title: $smart_title"
    echo "├── Type: $pr_type"
    echo "├── Impact: $business_impact"
    echo "└── Files: $files_count"
    echo ""
    
    export PR_TITLE="$smart_title"
    export PR_BODY="$description"
    export PR_TYPE="$pr_type"
}

# 🚀 CREATE ENTERPRISE PR: Direct GitHub integration
create_enterprise_pr() {
    local target_branch="${1:-main}"
    local is_draft="${2:-false}"
    local current_branch=$(git branch --show-current)
    
    if [ "$current_branch" = "$target_branch" ]; then
        echo "⚠️  Creating PR from $target_branch to itself"
        echo "Continue? [y/N]: "
        read -r confirm
        case "$confirm" in
            [yY]|[yY][eE][sS]) ;;
            *) echo "🛑 Cancelled"; return 1 ;;
        esac
    fi
    
    echo "🚀 Creating enterprise-grade pull request..."
    
    echo "📤 Pushing $current_branch..."
    if ! git push origin "$current_branch" 2>/dev/null; then
        echo "❌ Push failed - check git status"
        return 1
    fi
    
    local draft_flag=""
    if [ "$is_draft" = "true" ]; then
        draft_flag="--draft"
    fi
    
    echo "🎯 Creating PR: $current_branch → $target_branch"
    
    if gh pr create \
        --base "$target_branch" \
        --head "$current_branch" \
        --title "$PR_TITLE" \
        --body "$PR_BODY" \
        $draft_flag; then
        
        echo "✅ Enterprise PR created successfully!"
        echo "🌐 View: $(gh pr view --web --json url --jq '.url' 2>/dev/null || echo 'Check GitHub')"
        echo ""
        echo "🤖 Claude Code will now handle intelligent review and validation"
    else
        echo "❌ PR creation failed - check GitHub CLI setup"
        return 1
    fi
}

# 🎯 MAIN EXECUTION: Enterprise workflow
execute_enterprise_pr() {
    local target_branch="$(detect_default_branch)"
    local is_draft="false"
    
    for arg in "$@"; do
        case $arg in
            --draft) is_draft="true" ;;
            main|master|develop) target_branch="$arg" ;;
            *) target_branch="$arg" ;;
        esac
    done
    
    echo "🏆 Enterprise Pull Request Creation"
    echo "═══════════════════════════════════"
    echo "Following: Google + Netflix + Shopify standards"
    echo "Target: $target_branch | Draft: $is_draft"
    echo ""
    
    analyze_enterprise_pr "$target_branch"
    
    echo "Create enterprise-grade PR? [Y/n]: "
    read -r confirm
    case "$confirm" in
        [nN]|[nN][oO]) 
            echo "🛑 Cancelled"
            return 1 
            ;;
        *)
            create_enterprise_pr "$target_branch" "$is_draft"
            ;;
    esac
}

execute_enterprise_pr "$@"
```

## Usage Examples

```bash
# Enterprise PR creation (auto-detects default branch)
git-pull-request

# Draft PR for work-in-progress (auto-detects default branch)
git-pull-request --draft

# PR to specific target branch
git-pull-request develop

# Draft PR to specific branch
git-pull-request --draft feature-branch
```

## What It Does

1. **🎯 Smart Branch Detection**: Auto-detects repository default branch (main/master/develop/trunk)
2. **🧠 Enterprise Intelligence**: Analyzes changes with business context (Google pattern)
3. **🏗️ Structured Content**: Auto-generates Why/How/Testing/Questions (Netflix + Shopify)  
4. **🚀 Zero Friction**: One command → Industry-standard PR
5. **🤖 AI Integration**: Creates PR → Claude Code handles validation

## Branch Detection Logic

**Multi-method detection for maximum compatibility**:
1. **Symbolic ref** (`git symbolic-ref refs/remotes/origin/HEAD`) - Most reliable
2. **Remote show** (`git remote show origin`) - Fallback method  
3. **Branch pattern** (main/master/develop detection) - Legacy support
4. **Default fallback** (`main`) - Last resort safety

## Enterprise Structure Generated

- **Business Context**: Why this change matters
- **High-Level Design**: How it's implemented
- **Testing Strategy**: Validation checklist
- **Documentation Updates**: What docs need updates
- **Reviewer Questions**: Specific feedback requests
- **Impact Assessment**: Business impact level

## Industry Standards Applied

- **Google**: Small, focused, self-contained changes
- **Netflix**: Documentation integration and conversational tone
- **Shopify**: Business context links and high-level design explanation

*Zero security redundancy. Maximum structure quality. Claude Code handles post-creation validation.*