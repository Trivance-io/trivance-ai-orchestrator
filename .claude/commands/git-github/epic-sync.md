---
allowed-tools: Bash(test), Bash(sed), Bash(gh), Bash(date -u), Bash(git), Bash(cat), Read, Write, LS
---

# Epic Sync

Push epic to GitHub as parent issue.

## Usage

```
/pm:epic-sync <feature_name>
```

## Quick Check

!bash test -f .claude/epics/$ARGUMENTS/epic.md || echo "❌ Epic not found. Run: /pm:prd-parse $ARGUMENTS"

## Instructions

### 1. Create Parent Issue

Strip frontmatter and prepare GitHub issue body:

!bash sed '1,/^---$/d; 1,/^---$/d' .claude/epics/$ARGUMENTS/epic.md > /tmp/epic-body.md

!bash if grep -qi "bug\|fix\|issue\|problem\|error" /tmp/epic-body.md; then epic_type="bug"; else epic_type="feature"; fi

!bash gh issue create --title "$ARGUMENTS" --body-file /tmp/epic-body.md --label "$epic_type" > /tmp/gh_output.txt

!bash epic_number=$(basename "$(cat /tmp/gh_output.txt)")

Store the returned issue number for epic frontmatter update.

### 2. Update Epic File

Update the epic file with GitHub URL and timestamp:

!bash repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
!bash epic_url="https://github.com/$repo/issues/$epic_number"
!bash current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

!bash sed -i.bak "/^github:/c\github: $epic_url" .claude/epics/$ARGUMENTS/epic.md
!bash sed -i.bak "/^updated:/c\updated: $current_date" .claude/epics/$ARGUMENTS/epic.md
!bash rm .claude/epics/$ARGUMENTS/epic.md.bak

### 3. Create Mapping File

Create `.claude/epics/$ARGUMENTS/github-mapping.md`:

!bash cat > .claude/epics/$ARGUMENTS/github-mapping.md << EOF

# GitHub Issue Mapping

Epic: #\${epic_number} - https://github.com/\${repo}/issues/\${epic_number}

Note: Sub-issues will be created by SDD workflow via /specify --from-issue \${epic_number}

Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

### 4. Cleanup

!bash rm -f /tmp/epic-body.md /tmp/gh_output.txt

### 5. Output

```
✅ Synced to GitHub
  - Epic: #{epic_number} - {epic_title}
  - Parent Issue created for business-level tracking

Next steps:
  - Technical breakdown: /specify --from-issue {epic_number}
  - View epic: https://github.com/{owner}/{repo}/issues/{epic_number}
```

## Error Handling

Follow `/rules/github-operations.md` for GitHub CLI errors.

If parent issue creation fails:

- Report what succeeded
- Note what failed
- Don't attempt rollback (partial sync is fine)

## Important Notes

- Trust GitHub CLI authentication
- Don't pre-check for duplicates
- Update frontmatter only after successful creation
- Keep operations simple and atomic
- Sub-issues are handled by SDD workflow, not PRD workflow
