---
allowed-tools: Bash(test), Bash(sed), Bash(gh), Bash(date -u), Bash(git), Bash(cat), Bash(jq), Read, Write, LS
---

# Epic Sync

Push epic to GitHub as parent issue with milestone tracking.

## Usage

```
/pm:epic-sync <feature_name>
/pm:epic-sync <feature_name> --milestone <number>
```

## Arguments Parsing

!bash if echo "$ARGUMENTS" | grep -q '\--milestone'; then
    milestone_number=$(echo "$ARGUMENTS" | sed 's/.*--milestone \([0-9]*\).*/\1/')
    epic_name=$(echo "$ARGUMENTS" | sed 's/ *--milestone [0-9]*//')
    use_existing_milestone=true
else
    epic_name="$ARGUMENTS"
milestone_number=""
use_existing_milestone=false
fi

## Quick Check

!bash test -f .claude/epics/$epic_name/epic.md || echo "❌ Epic not found. Run: /pm:prd-parse $epic_name"

## Instructions

### 1. Milestone Handling

Handle milestone creation or reuse:

!bash test -f .claude/prds/$epic_name.md || echo "❌ PRD not found. Run: /pm:prd-new $epic_name"

!bash repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)

!bash if [ "$use_existing_milestone" = "true" ]; then
echo "🔄 Using existing milestone #$milestone_number"
    gh api repos/$repo/milestones/$milestone_number > /tmp/milestone_response.json
else
echo "🤖 Generating intelligent milestone name from PRD..."
echo "🎯 Creating milestone description from PRD key sections..."

    # Extract Executive Summary section
    sed -n '/## Executive Summary/,/## /p' .claude/prds/$epic_name.md | head -n -1 > /tmp/executive-summary.md

    # Extract Success Criteria -> Métricas Primarias
    sed -n '/### Métricas Primarias/,/### /p' .claude/prds/$epic_name.md | head -n -1 > /tmp/success-metrics.md

    # Build milestone description using template
    echo "## Objetivo" > /tmp/prd-body.md
    # Get main objective from Executive Summary (skip header, take first paragraph)
    sed -n '3,6p' /tmp/executive-summary.md | tr '\n' ' ' | sed 's/\*\*[^*]*\*\*: //g' | head -c 200 >> /tmp/prd-body.md
    echo "..." >> /tmp/prd-body.md
    echo "" >> /tmp/prd-body.md

    echo "## Valor Esperado" >> /tmp/prd-body.md
    # Extract the "Valor esperado" line
    grep "Valor esperado" /tmp/executive-summary.md | sed 's/.*: //' >> /tmp/prd-body.md
    echo "" >> /tmp/prd-body.md

    echo "## Métricas de Éxito" >> /tmp/prd-body.md
    # Get the first 3 metrics from Métricas Primarias
    grep -E "^- \*\*.*:" /tmp/success-metrics.md | head -3 >> /tmp/prd-body.md

fi

## Generate Intelligent Milestone Name

When `use_existing_milestone=false`, read the PRD content and generate a short, intuitive milestone name that represents a broader business objective. The milestone should:

- **NOT be the same as the epic name**: `$epic_name`
- **Include a clear objective word** (e.g., "Onboarding", "Enhancement", "Modernization", "Performance")
- **Represent a broader initiative** that could logically group multiple related epics
- **Be concise** (2-4 words maximum)
- **Focus on business value** rather than technical implementation

Examples of good milestone names with clear objectives:

- "Developer Onboarding" (for reducing time-to-productivity, workflow adoption)
- "Documentation Modernization" (for obsolete docs, knowledge gaps, process clarity)
- "User Experience Enhancement" (for usability improvements, interface optimization)
- "Platform Performance" (for speed optimization, monitoring, reliability)

Read `.claude/prds/$epic_name.md` and generate milestone_title variable based on analysis:

milestone_title="Developer Onboarding" # Replace with Claude-generated name based on PRD analysis

!bash if [ "$use_existing_milestone" = "false" ]; then # Use Claude-generated milestone name from above analysis
echo "📝 Using milestone name: $milestone_title"
    echo "🆕 Creating new milestone from PRD"
    # Try to create milestone with intelligent name, if exists get existing one
    gh api repos/$repo/milestones --method POST --field title="$milestone_title" --field description="$(cat /tmp/prd-body.md)" > /tmp/milestone_response.json 2>/dev/null || \
 gh api repos/$repo/milestones --jq '.[] | select(.title=="'$milestone_title'")' > /tmp/milestone_response.json
fi

!bash if [ -f /tmp/milestone_response.json ]; then
milestone_number=$(jq -r '.number' /tmp/milestone_response.json)
    milestone_title=$(jq -r '.title' /tmp/milestone_response.json)
milestone_url=$(jq -r '.html_url' /tmp/milestone_response.json)

    if [ -n "$milestone_number" ] && [ "$milestone_number" != "null" ]; then
        echo "✅ Milestone: #$milestone_number - $milestone_title"
    else
        echo "❌ CRITICAL: milestone_number extraction failed"
        exit 1
    fi

else
echo "❌ CRITICAL: milestone_response.json not found"
exit 1
fi

### 2. Create Parent Issue

Strip frontmatter and prepare GitHub issue body:

!bash sed '1,/^---$/d; 1,/^---$/d' .claude/epics/$epic_name/epic.md > /tmp/epic-body.md

!bash gh issue create --title "$epic_name" --body-file /tmp/epic-body.md > /tmp/gh_output.txt

!bash if [ -f /tmp/gh_output.txt ]; then
issue_url=$(cat /tmp/gh_output.txt)
    if [[ "$issue_url" =~ /issues/([0-9]+)$ ]]; then
epic_number="${BASH_REMATCH[1]}"
        echo "✅ Epic issue created: #$epic_number"
else
echo "❌ CRITICAL: Failed to extract issue number from: $issue_url"
exit 1
fi
else
echo "❌ CRITICAL: gh_output.txt not found"
exit 1
fi

!bash echo "🔗 Assigning issue #$epic_number to milestone #$milestone_number..."
if gh issue edit "$epic_number" --milestone "$milestone_title"; then
echo "✅ Milestone assigned using title: $milestone_title"
elif gh issue edit "$epic_number" --milestone "$milestone_number"; then
    echo "✅ Milestone assigned using number: $milestone_number"
else
    echo "❌ CRITICAL: Milestone assignment failed for issue #$epic_number to milestone #$milestone_number"
exit 1
fi

### 3. Update Epic File

Update the epic file with GitHub URL, milestone info and timestamp:

!bash epic_url="https://github.com/$repo/issues/$epic_number" && \
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

!bash sed -i.bak "/^github:/c\\
github: $epic_url" .claude/epics/$epic_name/epic.md
!bash sed -i.bak "/^updated:/c\\
updated: $current_date" .claude/epics/$epic_name/epic.md

Add milestone information to epic frontmatter:

!bash sed -i.bak "/^updated:/a\\
milestone: $milestone_number\\
milestone_url: $milestone_url" .claude/epics/$epic_name/epic.md

!bash rm .claude/epics/$epic_name/epic.md.bak

### 4. Update PRD File

Update the PRD file with milestone information:

!bash sed -i.bak "/^created:/a\\
milestone: $milestone_number\\
milestone_url: $milestone_url\\
github_synced: $current_date" .claude/prds/$epic_name.md

!bash rm .claude/prds/$epic_name.md.bak

### 5. Create Mapping File

Create `.claude/epics/$epic_name/github-mapping.md`:

!bash cat > .claude/epics/$epic_name/github-mapping.md << EOF

# GitHub Issue Mapping

Milestone: #$milestone_number - $milestone_url
Epic: #$epic_number - https://github.com/$repo/issues/$epic_number

Note: Sub-issues will be created by SDD workflow via /specify --from-issue $epic_number

Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

### 6. Cleanup

!bash rm -f /tmp/epic-body.md /tmp/gh_output.txt /tmp/prd-body.md /tmp/milestone_response.json /tmp/executive-summary.md /tmp/success-metrics.md

### 7. Output

```
✅ Synced to GitHub
  - Milestone: #$milestone_number - $milestone_url
  - Epic: #$epic_number - $epic_name
  - Parent Issue created and assigned to milestone

Next steps:
  - Technical breakdown: /specify --from-issue $epic_number
  - View milestone: $milestone_url
  - View epic: https://github.com/$repo/issues/$epic_number
```

## Error Handling

Follow `/rules/github-operations.md` for GitHub CLI errors.

If milestone creation fails:

- Check if milestone already exists with same name
- If exists, use existing milestone
- Report what succeeded and continue with issue creation

If parent issue creation fails:

- Report what succeeded (milestone may have been created)
- Note what failed
- Don't attempt rollback (partial sync is fine)

## Important Notes

- Trust GitHub CLI authentication
- Milestone uses PRD content as description for comprehensive tracking
- Don't pre-check for duplicates (let GitHub handle conflicts)
- Update frontmatter only after successful creation
- Keep operations simple and atomic
- Sub-issues are handled by SDD workflow, not PRD workflow
- Milestone provides business-level progress tracking for the entire PRD
- Use `--milestone N` to reuse existing milestones across multiple epics
