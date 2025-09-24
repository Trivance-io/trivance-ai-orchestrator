---
allowed-tools: Bash, Read, Write, LS
---

# Epic Sync

Push epic to GitHub as parent issue.

## Usage

```
/pm:epic-sync <feature_name>
```

## Quick Check

```bash
# Verify epic exists
test -f .claude/epics/$ARGUMENTS/epic.md || echo "❌ Epic not found. Run: /pm:prd-parse $ARGUMENTS"
```

## Instructions

### 0. Check Remote Repository

Follow `/rules/github-operations.md` to ensure we're not syncing to the CCPM template:

```bash
# Check if remote origin is the CCPM template repository
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$remote_url" == *"automazeio/ccpm"* ]] || [[ "$remote_url" == *"automazeio/ccpm.git"* ]]; then
  echo "❌ ERROR: You're trying to sync with the CCPM template repository!"
  echo ""
  echo "This repository (automazeio/ccpm) is a template for others to use."
  echo "You should NOT create issues or PRs here."
  echo ""
  echo "To fix this:"
  echo "1. Fork this repository to your own GitHub account"
  echo "2. Update your remote origin:"
  echo "   git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  echo ""
  echo "Or if this is a new project:"
  echo "1. Create a new repository on GitHub"
  echo "2. Update your remote origin:"
  echo "   git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  echo ""
  echo "Current remote: $remote_url"
  exit 1
fi
```

### 1. Create Parent Issue

Strip frontmatter and prepare GitHub issue body:

```bash
# Extract content without frontmatter
sed '1,/^---$/d; 1,/^---$/d' .claude/epics/$ARGUMENTS/epic.md > /tmp/epic-body.md

# Determine epic type (feature vs bug) from content
if grep -qi "bug\|fix\|issue\|problem\|error" /tmp/epic-body.md; then
  epic_type="bug"
else
  epic_type="feature"
fi

# Create parent issue with labels
epic_number=$(gh issue create \
  --title "$ARGUMENTS" \
  --body-file /tmp/epic-body.md \
  --label "epic,epic:$ARGUMENTS,$epic_type" \
  --json number -q .number)
```

Store the returned issue number for epic frontmatter update.

### 2. Update Epic File

Update the epic file with GitHub URL and timestamp:

```bash
# Get repo info
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
epic_url="https://github.com/$repo/issues/$epic_number"
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update epic frontmatter
sed -i.bak "/^github:/c\github: $epic_url" .claude/epics/$ARGUMENTS/epic.md
sed -i.bak "/^updated:/c\updated: $current_date" .claude/epics/$ARGUMENTS/epic.md
rm .claude/epics/$ARGUMENTS/epic.md.bak
```

### 3. Create Mapping File

Create `.claude/epics/$ARGUMENTS/github-mapping.md`:

```bash
# Create mapping file
cat > .claude/epics/$ARGUMENTS/github-mapping.md << EOF
# GitHub Issue Mapping

Epic: #${epic_number} - https://github.com/${repo}/issues/${epic_number}

Note: Sub-issues will be created by SDD workflow via /specify --from-issue ${epic_number}

Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
```

### 4. Create Worktree

Follow `/rules/worktree-operations.md` to create development worktree:

```bash
# Ensure main is current
git checkout main
git pull origin main

# Create worktree for epic
git worktree add ../epic-$ARGUMENTS -b epic/$ARGUMENTS

echo "✅ Created worktree: ../epic-$ARGUMENTS"
```

### 5. Output

```
✅ Synced to GitHub
  - Epic: #{epic_number} - {epic_title}
  - Parent Issue created for business-level tracking
  - Worktree: ../epic-$ARGUMENTS

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
