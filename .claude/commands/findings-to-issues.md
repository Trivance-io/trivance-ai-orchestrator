# Findings to GitHub Issues

I'll convert PR review findings into trackable GitHub issues using the GitHub MCP Server.

## Prerequisites Check

First, let me verify the GitHub MCP Server is configured:

```bash
claude mcp list | grep -q "github" || echo "⚠️ GitHub MCP Server not configured. Run: .claude/mcp-servers/github/setup.sh"
```

## Phase 1: Context Detection

I'll detect your current repository and PR context:

```bash
# Get repository information from git remote
git_remote=$(git remote get-url origin 2>/dev/null)
if [[ "$git_remote" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]%.git}"
    echo "✓ Repository: $owner/$repo"
else
    echo "❌ Not a GitHub repository or no remote configured"
    exit 1
fi

# Get current branch and detect PR
current_branch=$(git branch --show-current)
echo "✓ Branch: $current_branch"

# Check if PR exists for current branch
pr_output=$(gh pr list --head "$current_branch" --json number,title,state --jq '.[0]' 2>/dev/null)
if [[ -n "$pr_output" ]]; then
    pr_number=$(echo "$pr_output" | jq -r '.number')
    pr_title=$(echo "$pr_output" | jq -r '.title')
    pr_state=$(echo "$pr_output" | jq -r '.state')
    echo "✓ PR #$pr_number: $pr_title (State: $pr_state)"
else
    echo "❌ No PR found for branch '$current_branch'"
    echo "💡 Create a PR first with: gh pr create"
    exit 1
fi
```

## Phase 2: Extract PR Findings

I'll extract all review comments and findings from the PR using MCP functions:
- `mcp__github__get_pull_request`
- `mcp__github__get_issue_comments` 
- `mcp__github__get_pull_request_comments`
- `mcp__github__get_pull_request_reviews`

## Phase 3: Intelligent Analysis

I'll analyze each finding to determine:

1. **Actionability**: Is this a real finding that needs work?
   - Skip: "LGTM", "Great work!", pure emojis, approvals
   - Process: Suggestions, issues, requests for changes

2. **Category**: What type of issue is this?
   - **Security**: Authentication, validation, injection, exposure risks
   - **Bug**: Logic errors, crashes, incorrect behavior
   - **Performance**: Slow queries, memory leaks, optimization needs
   - **Testing**: Missing tests, coverage gaps
   - **Documentation**: Missing docs, unclear comments
   - **Enhancement**: Feature improvements, UX suggestions
   - **Technical Debt**: Refactoring needs, code cleanup

3. **Priority**: How urgent is this?
   - **Critical**: Security vulnerabilities, data loss risks
   - **High**: Bugs affecting functionality, performance issues
   - **Medium**: Testing gaps, documentation needs
   - **Low**: Minor improvements, nice-to-haves

## Phase 4: Duplicate Prevention

Before creating each issue, I'll check for duplicates using `mcp__github__search_issues`.

**Decision Logic**:
- Exact title match: Skip as duplicate
- Similar keywords: Ask user confirmation
- No match: Create new issue

## Phase 5: Issue Creation

For each unique, actionable finding, I'll create a GitHub issue:

Using `mcp__github__create_issue` with:

**Title Format**: `[Category] Clear, actionable description`
- Examples:
  - "[Security] Add input validation to user endpoint"
  - "[Performance] Optimize N+1 queries in dashboard"
  - "[Testing] Add unit tests for payment processing"

**Body Template**:
```markdown
## Description
[Clear explanation of the finding]

## Source
- **PR**: #[PR_NUMBER] - [PR_TITLE]
- **Review Type**: [Comment/Review/Suggestion]
- **File**: [If applicable]
- **Line**: [If applicable]

## Suggested Solution
[If reviewer provided suggestions]

## Acceptance Criteria
- [ ] Issue addressed according to recommendations
- [ ] Tests added/updated as needed
- [ ] Documentation updated if required

## Priority
[Critical/High/Medium/Low] - [Justification]
```

**Labels**: Automatically assigned based on category
- `bug`, `security`, `performance`, `testing`, `documentation`, `enhancement`, `technical-debt`

**Assignee**: Current authenticated user (auto-detected via `mcp__github__get_me`)

```bash
# Initialize issue tracking
created_issues_numbers=""

# For each actionable finding (example implementation):
# Loop through findings and create issues using MCP
for finding in "${actionable_findings[@]}"; do
    # Create issue using MCP function
    issue_response=$(echo '{"title": "'"$finding_title"'", "body": "'"$finding_body"'", "labels": ["'"$finding_label"'"], "assignee": "'"$current_user"'"}' | mcp__github__create_issue)
    
    # Extract issue number from response
    issue_number=$(echo "$issue_response" | jq -r '.number')
    
    # Add to tracking variable
    created_issues_numbers="$created_issues_numbers $issue_number"
    
    echo "✅ Created issue #$issue_number: $finding_title"
done

# Trim leading space
created_issues_numbers=$(echo "$created_issues_numbers" | sed 's/^ *//')
echo "📝 Created issues: $created_issues_numbers"
```

## Phase 6: Associate Issues to PR

After creating all issues, I'll atomically associate them to the PR:

```bash
# Variable already populated in Phase 5 with actual issue numbers

# Get current PR body
pr_body=$(gh pr view "$pr_number" --json body --jq '.body')

# Create AUTO-CLOSE section
auto_close_section="<!-- AUTO-CLOSE:START -->
### Associated Issues
$(echo "$created_issues_numbers" | tr ' ' '\n' | sed 's/^/Fixes #/')
<!-- AUTO-CLOSE:END -->"

# Update PR body
if echo "$pr_body" | grep -q "<!-- AUTO-CLOSE:START -->"; then
    # Replace existing section
    new_pr_body=$(echo "$pr_body" | sed '/<!-- AUTO-CLOSE:START -->/,/<!-- AUTO-CLOSE:END -->/d')
    new_pr_body="$new_pr_body

$auto_close_section"
else
    # Add new section
    new_pr_body="$pr_body

$auto_close_section"
fi

# Update PR via GitHub CLI
echo "🔗 Associating issues to PR #$pr_number..."
gh pr edit "$pr_number" --body "$new_pr_body"
echo "✅ Issues associated to PR #$pr_number (will auto-close on merge)"
```

**Key Benefits**:
- **Atomic Operation**: Issues are created AND associated in one command
- **Auto-close on Merge**: Uses GitHub's closing keywords
- **Idempotent**: Can be run multiple times safely (replaces AUTO-CLOSE section)
- **Clear Tracking**: PR shows all associated issues visually

## Phase 7: Logging & Summary

I'll create a structured log of all actions:

```bash
# Create log directory
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
today=$(date '+%Y-%m-%d')
log_dir=".claude/logs/$today"
mkdir -p "$log_dir"

# Log entry for each created issue (JSONL format)
log_file="$log_dir/findings_activity.jsonl"
```

**Summary Output**:
```
✅ Findings Analysis Complete

📊 Summary:
- Total findings reviewed: X
- Actionable findings: Y
- Duplicates prevented: Z

📝 Issues Created & Associated to PR #[PR_NUMBER]:
1. #123: [Security] Input validation needed
   → https://github.com/owner/repo/issues/123
2. #124: [Performance] Optimize database queries
   → https://github.com/owner/repo/issues/124

🔗 PR Association: Issues will auto-close when PR is merged

⏭️ Skipped (Duplicates):
- "Add tests" → Similar to existing #120 (85% match)

📁 Log saved to: .claude/logs/YYYY-MM-DD/findings_activity.jsonl
```

## Error Handling

**Common Issues & Solutions**:

1. **MCP Server Not Connected**:
   - Check: `claude mcp list`
   - Fix: Run setup script

2. **No PR Found**:
   - Check: Current branch has PR
   - Fix: Create PR with `gh pr create`

3. **Rate Limiting**:
   - Detection: API returns 403/429
   - Solution: Wait and retry with exponential backoff

4. **Permission Denied**:
   - Check: Token has correct scopes
   - Fix: Update token permissions

## Notes

- Issues created from PR review findings
- Can be run multiple times safely (idempotent)