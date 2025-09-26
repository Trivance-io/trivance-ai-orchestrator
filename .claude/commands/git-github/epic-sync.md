---
allowed-tools: Bash(test), Bash(sed), Bash(gh), Bash(date -u), Bash(git), Bash(cat), Bash(jq), Read, Write, LS
---

# Epic Sync

Push epic to GitHub as parent issue with milestone tracking.

## Usage

```
/pm:epic-sync <feature_name>
```

## Quick Check

!bash test -f .claude/epics/$ARGUMENTS/epic.md || echo "❌ Epic not found. Run: /pm:prd-parse $ARGUMENTS"

## Instructions

### 1. Create GitHub Milestone

First, create or find the milestone using PRD content:

!bash test -f .claude/prds/$ARGUMENTS.md || echo "❌ PRD not found. Run: /pm:prd-new $ARGUMENTS"

Extract PRD content for milestone description:

!bash sed '1,/^---$/d; 1,/^---$/d' .claude/prds/$ARGUMENTS.md > /tmp/prd-body.md

Create milestone with 2-week due date:

!bash milestone_due_date=$(date -v+2w +%Y-%m-%dT%H:%M:%SZ)

!bash gh api repos/{owner}/{repo}/milestones --method POST --field title="$ARGUMENTS" --field description="$(cat /tmp/prd-body.md)" --field due_on="$milestone_due_date" > /tmp/milestone_response.json 2>/dev/null || gh api repos/{owner}/{repo}/milestones --jq '.[] | select(.title=="'$ARGUMENTS'")' > /tmp/milestone_response.json

!bash milestone_number=$(cat /tmp/milestone_response.json | jq -r '.number')

!bash milestone_url=$(cat /tmp/milestone_response.json | jq -r '.html_url')

### 2. Create Parent Issue

Strip frontmatter and prepare GitHub issue body:

!bash sed '1,/^---$/d; 1,/^---$/d' .claude/epics/$ARGUMENTS/epic.md > /tmp/epic-body.md

!bash if grep -qi "bug\|fix\|issue\|problem\|error" /tmp/epic-body.md; then epic_type="bug"; else epic_type="feature"; fi

!bash gh issue create --title "$ARGUMENTS" --body-file /tmp/epic-body.md --label "$epic_type" --milestone "$milestone_number" > /tmp/gh_output.txt

!bash epic_number=$(basename "$(cat /tmp/gh_output.txt)")

Store the returned issue number for epic frontmatter update.

### 3. Update Epic File

Update the epic file with GitHub URL, milestone info and timestamp:

!bash repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
!bash epic_url="https://github.com/$repo/issues/$epic_number"
!bash current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

!bash sed -i.bak "/^github:/c\github: $epic_url" .claude/epics/$ARGUMENTS/epic.md
!bash sed -i.bak "/^updated:/c\updated: $current_date" .claude/epics/$ARGUMENTS/epic.md

Add milestone information to epic frontmatter:

!bash sed -i.bak "/^updated:/a\\
milestone: $milestone_number\\
milestone_url: $milestone_url" .claude/epics/$ARGUMENTS/epic.md

!bash rm .claude/epics/$ARGUMENTS/epic.md.bak

### 4. Update PRD File

Update the PRD file with milestone information:

!bash sed -i.bak "/^created:/a\\
milestone: $milestone_number\\
milestone_url: $milestone_url\\
github_synced: $current_date" .claude/prds/$ARGUMENTS.md

!bash rm .claude/prds/$ARGUMENTS.md.bak

### 5. Create Mapping File

Create `.claude/epics/$ARGUMENTS/github-mapping.md`:

!bash cat > .claude/epics/$ARGUMENTS/github-mapping.md << EOF

# GitHub Issue Mapping

Milestone: #\${milestone_number} - \${milestone_url}
Epic: #\${epic_number} - https://github.com/\${repo}/issues/\${epic_number}

Note: Sub-issues will be created by SDD workflow via /specify --from-issue \${epic_number}

Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

### 6. Cleanup

!bash rm -f /tmp/epic-body.md /tmp/gh_output.txt /tmp/prd-body.md /tmp/milestone_response.json

### 7. Output

```
✅ Synced to GitHub
  - Milestone: #{milestone_number} - {milestone_url}
  - Epic: #{epic_number} - {epic_title}
  - Parent Issue created and assigned to milestone

Next steps:
  - Technical breakdown: /specify --from-issue {epic_number}
  - View milestone: {milestone_url}
  - View epic: https://github.com/{owner}/{repo}/issues/{epic_number}
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
