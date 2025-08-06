# Findings to GitHub Issues

I'll scan PR review findings and create professional GitHub issues following your project's standards.

First, let me analyze your complete project context:

**Project Context:**
- Repository type (fork, personal, organization)
- Main language and framework conventions
- Testing requirements and CI/CD setup
- Branch strategy and release process
- Team workflow and communication style

**For Forks - Remote Analysis:**
```bash
# Get upstream repository info
git remote -v | grep upstream
# Fetch latest upstream guidelines
git fetch upstream main:upstream-main 2>/dev/null || true
```

Then verify GitHub setup:

```bash
# Check if we're in a git repository with GitHub remote
if ! git remote -v | grep -q github.com; then
    echo "Error: No GitHub remote found"
    echo "This command requires a GitHub repository"
    exit 1
fi

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) not found"
    echo "Install from: https://cli.github.com"
    exit 1
fi

# Verify authentication
if ! gh auth status &>/dev/null; then
    echo "Error: Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi
```

Now I'll detect and analyze the target PR:

```bash
# Detect PR from current branch if not provided
current_branch=$(git branch --show-current)
pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null)

if [ -z "$pr_number" ]; then
    echo "Error: No PR found for current branch"
    echo "Create a PR first or specify PR number"
    exit 1
fi

echo "Detected PR #$pr_number from branch: $current_branch"
```

**MANDATORY Pre-Checks:**
Before creating ANY GitHub issues, I MUST:
1. Verify PR exists and has content
2. Check if PR has review comments 
3. Validate issue creation permissions
4. Ensure no duplicate issues exist

If ANY check fails → I'll STOP and help fix it first!

Using native tools for comprehensive analysis:
- **Bash tool** to extract PR review content via gh CLI
- **Read tool** to understand project context
- **Grep tool** to find existing related issues

I'll intelligently analyze each finding:
1. Extract review content from PR comments and reviews
2. Parse findings using robust patterns
3. Determine priority and categorization
4. Create professional issue titles and descriptions

**Finding Detection Patterns:**
I'll use comprehensive regex patterns to capture ALL finding types:

**Critical Findings** (security, bugs):
- Pattern: `crítico|critical|security|vulnerability|injection|bug|error`
- Keywords: security, injection, validation, authentication, authorization
- Label: `bug,security,priority-critical`

**Performance Issues** (optimization):
- Pattern: `performance|slow|optimization|cache|memory|speed`
- Keywords: optimize, performance, cache, memory, bottleneck
- Label: `performance,optimization`

**Testing Gaps** (coverage, testing):
- Pattern: `test|testing|coverage|spec|unit|integration`
- Keywords: test, coverage, testing, validation, spec
- Label: `testing,quality`

**Documentation Issues** (docs, comments):
- Pattern: `documentation|docs|comment|explain|document`
- Keywords: document, docs, README, comment, explanation
- Label: `documentation`

**Technical Debt** (refactoring, cleanup):
- Pattern: `refactor|cleanup|debt|architecture|structure`
- Keywords: refactor, cleanup, technical debt, architecture
- Label: `refactoring,technical-debt`

**Issue creation strategy:**
- Titles matching project's naming conventions
- Descriptions following discovered templates
- Labels from existing project taxonomy
- Priority based on finding severity
- Language style matching documentation tone

**Professional Issue Template:**
```markdown
## Description
[Finding content with context]

## Source
- **PR:** #[PR_NUMBER]
- **Review Finding:** [FINDING_NUMBER]
- **File:** [AFFECTED_FILE]

## Acceptance Criteria
- [ ] Issue addressed according to finding recommendations
- [ ] Code changes implemented and tested
- [ ] Documentation updated if needed

## Priority
[High/Medium/Low based on finding type]
```

**Smart Categorization:**
I'll analyze each finding content to determine the correct issue type and labels automatically.

**Logging Strategy:**
Create clean JSONL logs in `.claude/logs/YYYY-MM-DD/` directory:

```bash
# Single-entry format
today=$(date '+%Y-%m-%d')
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
logs_dir=".claude/logs/$today"
mkdir -p "$logs_dir"

# Log each created issue
issue_log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "command": "findings-to-issues", 
  "pr": $pr_number,
  "issue": $issue_number,
  "title": "$issue_title",
  "priority": "$priority",
  "url": "$issue_url"
}
EOF
)

echo "$issue_log_entry" >> "$logs_dir/findings_activity.jsonl"
```

**Security Measures:**
- Input sanitization for shell injection prevention
- Content length validation  
- Proper shell escaping
- Error handling for API failures

**Critical Security Implementation:**
```bash
# Sanitize finding content before using in shell commands
sanitize_finding() {
    local finding="$1"
    # Sanitize dangerous shell characters
    sanitized_finding=$(echo "$finding" | sed 's/[`$"\\|]/\\&/g' | tr -d '\n\r')
    echo "$sanitized_finding"
}

# Usage in issue creation:
# Instead of: issue_body="$finding"
# Use: issue_body="$(sanitize_finding "$finding")"
```

I'll handle rate limits and show you a summary of all created issues.

**Important**: I will NEVER:
- Add "Created by Claude" or any AI attribution to issues
- Include "Generated with Claude Code" in issue descriptions  
- Modify repository settings or permissions
- Add any AI/assistant signatures or watermarks
- Use emojis in issues, PRs, or git-related content

This helps convert PR review findings into trackable work items following industry standards.