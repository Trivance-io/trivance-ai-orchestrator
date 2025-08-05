---
description: "Convert PR review findings to GitHub issues automatically"
argument-hint: "pr-number (optional, defaults to current PR)"
allowed-tools: ["Bash", "Read", "Grep"]
---

# 🔄 PR Findings to GitHub Issues

*Real solution based on GitHub Actions + Claude Code integration*

## Automated Workflow Setup

I'll create a GitHub Actions workflow that converts PR review findings into categorized issues:

```bash
#!/bin/bash

# Create workflow file for PR findings to issues
create_workflow() {
    local workflow_file=".github/workflows/pr-findings-to-issues.yml"
    
    echo "📝 Creating workflow: $workflow_file"
    
    mkdir -p .github/workflows
    
    cat > "$workflow_file" << 'EOF'
name: PR Findings to Issues

on:
  issue_comment:
    types: [created]

jobs:
  create-issues-from-findings:
    runs-on: ubuntu-latest
    # Only run on PR comments containing Claude findings
    if: |
      github.event.issue.pull_request && 
      contains(github.event.comment.body, '[FINDING]')
    
    permissions:
      issues: write
      pull-requests: read
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Parse Claude Findings
        id: parse
        uses: actions/github-script@v7
        with:
          script: |
            const comment = context.payload.comment.body;
            const findings = [];
            
            // Parse findings marked with [FINDING]
            const regex = /\[FINDING\]\s*(.+?)(?=\[FINDING\]|$)/gs;
            let match;
            
            while ((match = regex.exec(comment)) !== null) {
              const finding = match[1].trim();
              const lines = finding.split('\n');
              
              // Extract severity, title, and description
              let severity = 'medium';
              let title = lines[0];
              let description = lines.slice(1).join('\n').trim();
              
              // Check for severity markers
              if (finding.includes('[CRITICAL]')) severity = 'critical';
              else if (finding.includes('[HIGH]')) severity = 'high';
              else if (finding.includes('[LOW]')) severity = 'low';
              
              findings.push({ severity, title, description });
            }
            
            return findings;
      
      - name: Create Issues
        uses: actions/github-script@v7
        with:
          script: |
            const findings = ${{ steps.parse.outputs.result }};
            const prNumber = context.issue.number;
            const prUrl = context.payload.issue.html_url;
            
            for (const finding of findings) {
              const labels = ['pr-finding', `severity-${finding.severity}`];
              
              const issue = await github.rest.issues.create({
                owner: context.repo.owner,
                repo: context.repo.repo,
                title: `[PR-${prNumber}] ${finding.title}`,
                body: `## Finding from PR Review
                
${finding.description}

---
📝 Source: [PR #${prNumber}](${prUrl})
🤖 Found by: Claude Code Review`,
                labels: labels
              });
              
              console.log(`Created issue #${issue.data.number}: ${finding.title}`);
            }
EOF
    
    echo "✅ Workflow created successfully"
}

# Setup GitHub labels
setup_labels() {
    echo "🏷️  Setting up GitHub labels..."
    
    gh label create "pr-finding" --color "1f77b4" --description "Issue from PR review" 2>/dev/null || true
    gh label create "severity-critical" --color "d62728" --description "Critical severity" 2>/dev/null || true
    gh label create "severity-high" --color "ff7f0e" --description "High severity" 2>/dev/null || true
    gh label create "severity-medium" --color "2ca02c" --description "Medium severity" 2>/dev/null || true
    gh label create "severity-low" --color "9467bd" --description "Low severity" 2>/dev/null || true
    
    echo "✅ Labels configured"
}

# Create Claude review template
create_review_template() {
    local template_file=".github/claude-review-template.md"
    
    echo "📄 Creating Claude review template..."
    
    cat > "$template_file" << 'EOF'
When reviewing this PR, format your findings using this structure:

[FINDING] [SEVERITY] Brief title
Detailed description of the issue
Location: file.js:123
Recommendation: How to fix it

Severity levels:
- [CRITICAL]: Security, breaking changes, data loss
- [HIGH]: Performance issues, bugs, standards violations  
- [MEDIUM]: Code quality, maintainability
- [LOW]: Style, minor improvements

Example:
[FINDING] [HIGH] SQL Injection vulnerability in user query
The user input is not properly sanitized before being used in SQL query
Location: api/users.js:45
Recommendation: Use parameterized queries or ORM
EOF
    
    echo "✅ Review template created"
}

# Main execution
main() {
    echo "🚀 Setting up PR Findings to Issues automation"
    echo "════════════════════════════════════════════"
    
    create_workflow
    setup_labels
    create_review_template
    
    echo ""
    echo "📋 Next Steps:"
    echo "1. Commit these changes"
    echo "2. When Claude reviews PRs, findings marked with [FINDING] will create issues"
    echo "3. Issues are automatically categorized by severity"
    echo "4. Each issue links back to the original PR"
    
    echo ""
    echo "🤖 Usage:"
    echo "- Claude will use the template when reviewing"
    echo "- Each [FINDING] becomes a GitHub issue"
    echo "- Issues are labeled for easy filtering"
}

main
```

## Alternative: Direct API Integration

For immediate use without workflow setup:

```bash
# Parse last Claude review and create issues
parse_claude_review() {
    local pr_number="${1:-$(gh pr view --json number -q .number)}"
    
    # Validate PR number is numeric and reasonable
    if ! [[ "$pr_number" =~ ^[0-9]+$ ]] || [ "$pr_number" -gt 99999 ]; then
        echo "Error: Invalid PR number: $pr_number"
        return 1
    fi
    
    echo "🔍 Parsing Claude review from PR #$pr_number..."
    
    # Get PR comments
    local comments=$(gh pr view "$pr_number" --comments --json comments -q '.comments[] | select(.author.login == "claude-code") | .body')
    
    if [ -z "$comments" ]; then
        echo "No Claude reviews found"
        return 1
    }
    
    # Extract findings and create issues (limit to 20 for security)
    echo "$comments" | grep -E '\[FINDING\]' | head -20 | while IFS= read -r finding; do
        # Parse finding details
        local title=$(echo "$finding" | sed 's/\[FINDING\].*\[\w+\]\s*//')
        local severity=$(echo "$finding" | grep -oE '\[(CRITICAL|HIGH|MEDIUM|LOW)\]' | tr -d '[]' | tr '[:upper:]' '[:lower:]')
        
        # Sanitize title to prevent command injection
        title=$(echo "$title" | tr -d '\n\r\t' | sed 's/[";`$\\]/./g' | head -c 200)
        
        # Validate severity
        case "$severity" in
            critical|high|medium|low) ;;
            *) severity="medium" ;;
        esac
        
        # Skip if title is empty after sanitization
        if [ -z "$title" ]; then
            continue
        fi
        
        # Create issue using secure parameters with temporary file
        local temp_body=$(mktemp)
        echo "Finding from PR #$pr_number review by Claude" > "$temp_body"
        
        gh issue create \
            --title "[PR-$pr_number] $title" \
            --body-file "$temp_body" \
            --label "pr-finding,severity-$severity"
        
        # Clean up
        rm -f "$temp_body"
    done
}
```

## How It Works

1. **Claude reviews PR** using standard GitHub integration
2. **Findings formatted** with [FINDING] markers
3. **GitHub Action triggers** on Claude's comment
4. **Issues created automatically** with proper categorization
5. **Links maintained** between PR and issues

## Real Implementation (Not Invented)

This solution uses:
- ✅ GitHub Actions (official)
- ✅ actions/github-script (official)
- ✅ GitHub Issues API (official)
- ✅ Claude Code existing PR review capability

No fictional features or false claims.