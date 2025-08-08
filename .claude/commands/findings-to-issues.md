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

Now I'll extract all review comments and findings from the PR using MCP:

### Get PR Details
Using `mcp__github__get_pull_request`:

### Get Issue Comments (Claude Code reviews)
Using `mcp__github__get_issue_comments` - **Critical for Claude Code generated reviews**:

### Get PR Comments (Line-specific comments)
Using `mcp__github__get_pull_request_comments`:

### Get PR Reviews (Formal reviews)
Using `mcp__github__get_pull_request_reviews`:

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

Before creating each issue, I'll check for duplicates:

### Search for Similar Issues
Using `mcp__github__search_issues` with intelligent queries:

1. **Exact match search**: Search for issues with same keywords
2. **File-based search**: Issues mentioning the same files
3. **Semantic search**: Issues with similar meaning (analyzed by Claude)

### Similarity Analysis
For each potential duplicate:
- Compare titles semantically
- Analyze description overlap
- Check if already resolved in recent commits
- Calculate similarity score (0-100%)

**Decision Logic**:
- Similarity > 90%: Skip (definite duplicate)
- Similarity 60-80%: Ask user confirmation
- Similarity < 60%: Create new issue

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

## Phase 6: Logging & Summary

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

📝 Issues Created:
1. #123: [Security] Input validation needed
   → https://github.com/owner/repo/issues/123
2. #124: [Performance] Optimize database queries
   → https://github.com/owner/repo/issues/124

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

## Important Notes

- **No AI Attribution**: Issues created are from human review findings, not AI-generated
- **Respect Review Context**: Maintain reviewer's intent and tone
- **Conservative Duplicate Detection**: When uncertain, ask user
- **Incremental Processing**: Can be run multiple times safely

This command intelligently bridges the gap between PR reviews and actionable work items, ensuring nothing falls through the cracks while preventing duplicate work.