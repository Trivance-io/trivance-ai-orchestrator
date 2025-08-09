# Findings to GitHub Issues

Convierte findings del PR en GitHub issues.

## Uso

```bash
/findings-to-issues <pr_number>
```

## Ejemplos

```bash
/findings-to-issues 96     # PR #96
/findings-to-issues 123    # PR #123
```

## Prerequisites

```bash
claude mcp list | grep -q "github" || echo "⚠️ GitHub MCP Server not configured"
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

pr_number="${1:-$ARGUMENTS}"
if [[ -z "$pr_number" || ! "$pr_number" =~ ^[1-9][0-9]*$ ]]; then
    echo "❌ Error: PR number requerido"
    echo "Uso: /findings-to-issues <pr_number>"
    echo "Ejemplo: /findings-to-issues 96"
    exit 1
fi

if ! gh pr view "$pr_number" >/dev/null 2>&1; then
    echo "❌ PR #$pr_number no existe"
    exit 1
fi

pr_info=$(gh pr view "$pr_number" --json title,state)
pr_title=$(echo "$pr_info" | jq -r '.title')
echo "PR #$pr_number: $pr_title"

echo "Extracting review findings..."
reviews=$(mcp__github__get_pull_request_reviews "$pr_number" 2>/dev/null || echo "[]")
comments=$(mcp__github__get_pull_request_comments "$pr_number" 2>/dev/null || echo "[]")

review_count=$(echo "$reviews" | jq length)
comment_count=$(echo "$comments" | jq length)
echo "Found $review_count reviews and $comment_count comments"

actionable_findings=()
current_user=$(mcp__github__get_me | jq -r '.login' 2>/dev/null || echo "")

echo "$reviews" | jq -c '.[]' | while read -r review; do
    review_state=$(echo "$review" | jq -r '.state')
    review_body=$(echo "$review" | jq -r '.body // ""')
    reviewer=$(echo "$review" | jq -r '.user.login')
    
    if [[ "$review_state" == "APPROVED" || -z "$review_body" || "$review_body" =~ ^(LGTM|👍|✅|Good|Great)$ ]]; then
        continue
    fi
    
    if [[ "$review_state" == "CHANGES_REQUESTED" || "$review_body" =~ (should|must|need|fix|error|issue|problem|security|performance|test) ]]; then
        echo "Actionable review from $reviewer: $review_body" >> /tmp/actionable_findings.txt
    fi
done

echo "$comments" | jq -c '.[]' | while read -r comment; do
    comment_body=$(echo "$comment" | jq -r '.body // ""')
    commenter=$(echo "$comment" | jq -r '.user.login')
    
    if [[ -z "$comment_body" || "$comment_body" =~ ^(LGTM|👍|✅|Good|Great|Thanks)$ ]]; then
        continue
    fi
    
    if [[ "$comment_body" =~ (should|must|need|fix|error|issue|problem|security|performance|test|suggestion|recommend) ]]; then
        echo "Actionable comment from $commenter: $comment_body" >> /tmp/actionable_findings.txt
    fi
done

created_issues=""
issue_count=0

if [[ -f /tmp/actionable_findings.txt ]]; then
    while IFS= read -r finding; do
        category="Bug"
        labels="bug"
        
        if [[ "$finding" =~ security|vulnerability|injection ]]; then
            category="Security"
            labels="security"
        elif [[ "$finding" =~ performance|slow|optimize ]]; then
            category="Performance" 
            labels="performance"
        elif [[ "$finding" =~ test|coverage ]]; then
            category="Testing"
            labels="testing"
        elif [[ "$finding" =~ documentation|readme|docs ]]; then
            category="Documentation"
            labels="documentation"
        fi
        
        title_text=$(echo "$finding" | cut -c1-50 | sed 's/.*: //')
        issue_title="[$category] $title_text"
        issue_body="## Finding from PR #$pr_number

**Source**: $finding

**Context**: 
- **PR**: #$pr_number - $pr_title
- **Type**: Review Finding
- **Category**: $category

## Suggested Solution
Address the concern mentioned in the review comment.

## Acceptance Criteria
- [ ] Issue addressed according to review feedback
- [ ] Tests added/updated if needed
- [ ] No similar issues remain in codebase"

        issue_response=$(mcp__github__create_issue "$pr_number" "$issue_title" "$issue_body" "$labels" "$current_user" 2>/dev/null || echo '{"number": ""}')
        issue_number=$(echo "$issue_response" | jq -r '.number // ""')
        
        if [[ -n "$issue_number" && "$issue_number" != "null" ]]; then
            created_issues="$created_issues $issue_number"
            issue_count=$((issue_count + 1))
            echo "Created issue #$issue_number: $issue_title"
        fi
        
    done < /tmp/actionable_findings.txt
    
    rm -f /tmp/actionable_findings.txt
fi

created_issues=$(echo "$created_issues" | xargs)

if [[ -n "$created_issues" ]]; then
    pr_body=$(gh pr view "$pr_number" --json body --jq '.body // ""')
    
    auto_close_section="<!-- AUTO-CLOSE:START -->
## Associated Issues from Findings

$(echo "$created_issues" | tr ' ' '\n' | while read num; do
    if [[ -n "$num" ]]; then
        issue_info=$(gh issue view "$num" --json title --jq '.title' 2>/dev/null || echo "Issue")
        category=$(echo "$issue_info" | grep -o '\[[^]]*\]' | head -1)
        echo "- Fixes #$num - $issue_info"
    fi
done)
<!-- AUTO-CLOSE:END -->"
    
    if echo "$pr_body" | grep -q "<!-- AUTO-CLOSE:START -->"; then
        new_pr_body=$(echo "$pr_body" | sed '/<!-- AUTO-CLOSE:START -->/,/<!-- AUTO-CLOSE:END -->/d')
        new_pr_body="$new_pr_body

$auto_close_section"
    else
        new_pr_body="$pr_body

$auto_close_section"
    fi
    
    gh pr edit "$pr_number" --body "$new_pr_body"
    echo "Issues associated to PR #$pr_number"
fi

timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
today=$(date '+%Y-%m-%d')
logs_dir=".claude/logs/$today"
mkdir -p "$logs_dir"

jq -n \
    --arg timestamp "$timestamp" \
    --argjson pr "$pr_number" \
    --arg issues "$created_issues" \
    --argjson count "$issue_count" \
    --argjson review_count "$review_count" \
    --argjson comment_count "$comment_count" \
    '{timestamp: $timestamp, pr_number: $pr, issues: $issues, issues_created: $count, reviews_analyzed: $review_count, comments_analyzed: $comment_count}' \
    >> "$logs_dir/findings_activity.jsonl"

echo ""
echo "Summary:"
echo "- PR analyzed: #$pr_number"
echo "- Reviews: $review_count | Comments: $comment_count" 
echo "- Issues created: $issue_count"
if [[ -n "$created_issues" ]]; then
    echo "- Issues: $created_issues"
fi
echo "- Log: $logs_dir/findings_activity.jsonl"
```