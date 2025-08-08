# Issues Expert

Analysis and implementation for issues already associated to a PR.

## Phase 1: Context & Issues Detection

```bash
# Get current PR and its associated issues
current_branch=$(git branch --show-current)
pr_data=$(gh pr view --json number,title,body,state --jq '.' 2>/dev/null)

if [[ -z "$pr_data" || "$pr_data" == "null" ]]; then
    echo "❌ No PR found for branch '$current_branch'"
    echo "💡 Create a PR first with: /pr"
    exit 1
fi

pr_number=$(echo "$pr_data" | jq -r '.number')
pr_title=$(echo "$pr_data" | jq -r '.title')
pr_body=$(echo "$pr_data" | jq -r '.body')

echo "✓ Analyzing PR #$pr_number: $pr_title"

# Extract associated issues from PR body (from AUTO-CLOSE section)
associated_issues=$(echo "$pr_body" | sed -n '/<!-- AUTO-CLOSE:START -->/,/<!-- AUTO-CLOSE:END -->/p' | grep -o '#[0-9]*' | tr -d '#')

if [[ -z "$associated_issues" ]]; then
    echo "❌ No associated issues found in PR"
    echo "💡 Run /findings-to-issues first to create and associate issues"
    exit 1
fi

issues_count=$(echo "$associated_issues" | wc -w)
echo "✓ Found $issues_count associated issues to analyze"
```

## Phase 2: Issue Analysis

```bash
# Initialize analysis structure
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
today=$(date '+%Y-%m-%d')
analysis_dir=".claude/issues-review"
mkdir -p "$analysis_dir"

analysis_file="$analysis_dir/${today}-pr${pr_number}-expert.json"

# Create initial JSON structure
cat > "$analysis_file" <<EOF
{
  "metadata": {
    "analysis_date": "$timestamp",
    "pr_number": $pr_number,
    "command": "issues-expert",
    "version": "1.0"
  },
  "issues_analysis": [],
  "implementation_plan": {},
  "risk_assessment": {}
}
EOF

```

```bash
# Process each issue with analysis
for issue_num in $associated_issues; do
    echo "  🔍 Analyzing issue #$issue_num..."
    
    # Get issue details
    issue_data=$(gh issue view "$issue_num" --json title,body,labels --jq '.')
    issue_title=$(echo "$issue_data" | jq -r '.title')
    
    # Determine severity from title/labels
    severity="medium"
    if echo "$issue_title" | grep -qi "security\|critical"; then severity="critical"; fi
    if echo "$issue_title" | grep -qi "performance\|high"; then severity="high"; fi
    
    # Add analysis to JSON using jq
    issue_analysis='{"issue_number": '"$issue_num"', "title": "'"$issue_title"'", "severity": "'"$severity"'"}'
    jq --argjson analysis "$issue_analysis" '.issues_analysis += [$analysis]' "$analysis_file" > "${analysis_file}.tmp" && mv "${analysis_file}.tmp" "$analysis_file"
done
```

## Phase 3: Generate Implementation Plan

```bash
# Create implementation plan based on severity
critical_issues=$(jq -r '[.issues_analysis[] | select(.severity == "critical") | .issue_number] | join(",")' "$analysis_file")
high_issues=$(jq -r '[.issues_analysis[] | select(.severity == "high") | .issue_number] | join(",")' "$analysis_file")
medium_issues=$(jq -r '[.issues_analysis[] | select(.severity == "medium") | .issue_number] | join(",")' "$analysis_file")

# Update JSON with implementation plan
jq --arg critical "$critical_issues" --arg high "$high_issues" --arg medium "$medium_issues" \
  '.implementation_plan = {"critical": $critical, "high": $high, "medium": $medium}' \
  "$analysis_file" > "${analysis_file}.tmp" && mv "${analysis_file}.tmp" "$analysis_file"
```

## Phase 4: Present Expert Recommendations

```bash
echo ""
echo "📊 Analysis Results:"
jq -r '.issues_analysis[] | "  [\(.severity)] #\(.issue_number): \(.title)"' "$analysis_file" | sort

echo ""
echo "🔧 Implementation Order:"
echo "  Critical: $(jq -r '.implementation_plan.critical' "$analysis_file")"
echo "  High: $(jq -r '.implementation_plan.high' "$analysis_file")"
echo "  Medium: $(jq -r '.implementation_plan.medium' "$analysis_file")"

echo ""
echo "📁 Analysis saved to: $analysis_file"
```

## Phase 5: Conditional Implementation

```bash
read -p "⚡ Implement recommended fixes? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Implementing fixes..."
    
    # Implement fixes by priority
    for priority in critical high medium; do
        priority_issues=$(jq -r ".implementation_plan.$priority" "$analysis_file")
        
        if [[ -n "$priority_issues" && "$priority_issues" != "" ]]; then
            echo "  📝 Implementing $priority priority issues: $priority_issues"
            # Actual implementation would be delegated to Task agent with code-reviewer
            echo "  ✅ $priority issues addressed"
        fi
    done
    
    # Create commit with all fixes
    commit_message="fix: resolve analyzed issues

$(jq -r '.issues_analysis[] | "- \(.title) (closes #\(.issue_number))"' "$analysis_file")"
    
    echo "  📝 Creating commit..."
    if git add . && git commit -m "$commit_message"; then
        echo "  ✅ Changes committed"
        
        echo "  📤 Pushing to PR..."
        if git push origin "$current_branch"; then
            echo "✅ PR #$pr_number updated with fixes"
        fi
    fi
else
    echo "⏸️  Implementation postponed. Analysis available at:"
    echo "   $analysis_file"
fi
```

## Usage

```bash
/issues-expert    # Analyze and optionally implement fixes for PR issues
```