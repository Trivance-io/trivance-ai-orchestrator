---
allowed-tools: Read, Edit, Write, Bash(gh), Bash(date)
description: Push epic to GitHub as parent issue with optional milestone assignment
---

# Epic Sync

Push epic to GitHub as parent issue with optional milestone assignment.

## Usage

```
/git-github:epic-sync <feature_name>
/git-github:epic-sync <feature_name> --milestone <number>
```

## User Input

$ARGUMENTS

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:

- `.claude/rules/datetime.md` - For getting real current date/time
- `.claude/rules/github-operations.md` - For GitHub CLI operations

## Instructions

### 1. Parse Arguments and Validate Files

**Parse the arguments** from `$ARGUMENTS`:

- **Epic name**: Extract the feature name (remove `--milestone <number>` if present)
- **Milestone mode**: Check if `--milestone <number>` is provided for reuse
- **Milestone number**: Extract number if provided

**Validate required files exist**:

- `.claude/epics/<epic_name>/epic.md`
- `.claude/prds/<epic_name>.md`

If either file missing, show error and stop.

### 2. Milestone Handling

**If milestone number provided** (format: `--milestone 5`):

- Use existing milestone #5
- Get milestone details via GitHub API

**If no milestone provided**:

- Continue without milestone assignment
- Skip milestone-related operations

### 3. Create GitHub Issue

**Prepare issue content**:

- Read `.claude/epics/<epic_name>/epic.md`
- Strip the frontmatter (everything between `---` lines)
- Use clean epic content as issue body

**Create GitHub issue**:

- Title: `<epic_name>`
- Body: Clean epic content without frontmatter
- Assign to milestone only if milestone number was provided

### 4. Update Epic File

**Update** `.claude/epics/<epic_name>/epic.md` frontmatter with:

- `github: <issue_url>`
- `updated: <current_timestamp>`
- `milestone: <milestone_number>` (only if milestone provided)
- `milestone_url: <milestone_url>` (only if milestone provided)

Use current timestamp in ISO format: `YYYY-MM-DDTHH:MM:SSZ`

### 5. Update PRD File

**Update** `.claude/prds/<epic_name>.md` frontmatter with:

- `milestone: <milestone_number>` (only if milestone provided)
- `milestone_url: <milestone_url>` (only if milestone provided)
- `github_synced: <current_timestamp>`

Add these fields after the `created:` line in frontmatter.

### 6. Create GitHub Mapping File

**Create** `.claude/epics/<epic_name>/github-mapping.md` with this content:

```markdown
# GitHub Issue Mapping

[If milestone provided] Milestone: #<milestone_number> - <milestone_url>
[If no milestone] No milestone assigned
Epic: #<issue_number> - <issue_url>

Note: Sub-issues will be created by SDD workflow via /SDD-cycle:specify --from-issue <issue_number>

Synced: <current_timestamp>
```

### 7. Output Results

**Display success message**:

```
✅ Synced to GitHub
  [If milestone provided] - Milestone: #<milestone_number> - <milestone_title>
  - Epic: #<issue_number> - <epic_name>
  [If milestone provided] - Parent Issue created and assigned to milestone
  [If no milestone] - Parent Issue created (no milestone assigned)

Next steps:
  - Technical breakdown: /SDD-cycle:specify --from-issue <issue_number>
  [If milestone provided] - View milestone: <milestone_url>
  - View epic: <issue_url>
```

## Error Handling

- **If epic.md not found**: Show clear error message with correct path
- **If PRD.md not found**: Show clear error message with correct path
- **If milestone number invalid**: Show error that milestone doesn't exist
- **If issue creation fails**: Report what succeeded, don't rollback
- **If file updates fail**: Report specific file and continue with others

## Important Notes

- Trust GitHub CLI authentication (no pre-auth checks)
- Don't pre-check for duplicates (let GitHub handle conflicts)
- Update files only after successful GitHub operations
- Keep operations atomic and simple
- Sub-issues handled by SDD workflow, not this command
- Use `--milestone N` to assign epic to existing milestone
- Milestones provide optional business-level progress tracking

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Parse arguments** intelligently from `$ARGUMENTS`
2. **Read epic content** using the Read tool
3. **Execute GitHub operations** using simple Bash commands (issue creation, optional milestone assignment)
4. **Update files** using Edit tool for surgical changes
5. **Create new files** using Write tool when needed

This approach is more robust than bash scripting because:

- No variable persistence issues between commands
- No temporary file dependencies
- Leverages Claude's natural language processing
- More maintainable and debuggable
- Handles edge cases intelligently
