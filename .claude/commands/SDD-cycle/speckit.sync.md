---
allowed-tools: Read, Edit, Write, Bash(gh), Bash(date)
description: Push spec to GitHub as child issue linked to parent PRD
---

# Spec Sync

Push spec to GitHub as child issue linked to parent PRD.

**IMPORTANT:** This command REQUIRES a parent PRD issue. Specs must always be linked to a PRD. If you don't have a PRD issue yet, run `/PRD-cycle:prd-sync` first.

## Usage

```
/SDD-cycle:speckit.sync <parent_issue_number>
```

## User Input

$ARGUMENTS

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:

- `.claude/rules/datetime.md` - For getting real current date/time
- `.claude/rules/github-operations.md` - For GitHub CLI operations

## Instructions

### 1. Parse Arguments and Validate

**Parse parent issue number** from `$ARGUMENTS`:

- **Parent issue number**: Extract the issue number (REQUIRED)
- If no argument provided: Show error "❌ Parent issue number required. Usage: /SDD-cycle:speckit.sync <issue_number>" and stop

**Detect feature from current branch:**

- Get branch name via `git branch --show-current`
- Extract feature directory name (e.g., `001-documentation-changelog-visibility`)
- Or check `SPECIFY_FEATURE` environment variable if set

**Validate parent issue exists:**

- Run `gh issue view <parent_issue_number> --json number,title` to verify issue exists
- If issue doesn't exist: Show error "❌ Parent issue #<number> not found" and stop

**Validate required files exist:**

- `specs/<feature>/spec.md` (REQUIRED)
- `specs/<feature>/plan.md` (optional)
- `specs/<feature>/tasks.md` (optional)

If spec.md missing, show error "❌ Spec file not found: specs/<feature>/spec.md" and stop.

### 2. Prepare Issue Content

**Read spec artifacts:**

- Read `specs/<feature>/spec.md`
- Read `specs/<feature>/plan.md` if exists
- Read `specs/<feature>/tasks.md` if exists

**Strip frontmatter** from spec.md (everything between `---` lines at top)

**Format for GitHub Issue body:**

If only spec.md exists:

```markdown
# Feature Specification: <Title from spec>

**Parent PRD**: #<parent_number>

---

<spec.md content without frontmatter>

---

_Synced from local specs at <timestamp>_
```

If plan.md and/or tasks.md also exist, append:

```markdown
---
## Implementation Plan

<plan.md content>
---

## Task Breakdown

<tasks.md content>
```

### 3. Create GitHub Issue and Link to Parent

**Create GitHub issue:**

- **Title**: "Spec: <feature-name>" (convert kebab-case to Title Case)
- **Body**: Formatted content from step 2
- **Labels**: `spec`, `sdd`, `feature`

```bash
gh issue create \
  --title "<title>" \
  --body "<formatted_body>" \
  --label spec,sdd,feature
```

**Notify parent PRD:**

- Add comment to parent issue:

```bash
gh issue comment <parent_number> \
  --body "📋 Technical specification created: #<spec_issue_number>"
```

### 4. Update Local Spec File

**Update** `specs/<feature>/spec.md` frontmatter with:

- `github: <issue_url>`
- `github_synced: <current_timestamp>`
- `parent_prd: #<parent_number>`

Use current timestamp in ISO format: `YYYY-MM-DDTHH:MM:SSZ`

**Preserve all other frontmatter fields** (Feature Branch, Created, Status, etc.)

### 5. Create GitHub Mapping File

**Create** `specs/<feature>/github-mapping.md` with this content:

```markdown
# GitHub Issue Mapping

Parent PRD: #<parent_number> - <parent_url>
Spec Issue: #<issue_number> - <issue_url>

Note: Implementation tasks tracked via this spec issue

Synced: <current_timestamp>
```

### 6. Output Results

**Display success message:**

```
✅ Spec synced to GitHub

  - Spec Issue: #<issue_number> - <feature_name>
  - Parent PRD: #<parent_number>
  - Files synced: spec.md[, plan.md][, tasks.md]

Next steps:
  - View spec: <issue_url>
  - Update spec: Edit specs/<feature>/spec.md and re-run /SDD-cycle:speckit.sync <parent_number>
  - Implement: /SDD-cycle:speckit.implement
```

## Error Handling

- **If no parent issue number provided**: Show usage error and stop
- **If parent issue doesn't exist**: Verify with `gh issue view` before proceeding
- **If spec.md not found**: Show clear error message with correct path and stop
- **If issue creation fails**: Report what succeeded, don't rollback local changes
- **If file updates fail**: Report specific file and continue with others

## Important Notes

- Parent PRD issue is REQUIRED (enforces correct workflow)
- Trust GitHub CLI authentication (no pre-auth checks)
- Update files only after successful GitHub operations
- Keep operations atomic and simple
- Re-running command creates duplicate issue (user must close old one manually)
- Spec represents technical implementation, PRD represents business requirement
- All data in Issue body/labels (100% portable to Linear)

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Validate parent issue** exists via `gh issue view`
2. **Detect feature** from branch name
3. **Read spec artifacts** using the Read tool
4. **Execute GitHub operations** using simple Bash commands
5. **Update files** using Edit tool for surgical changes
6. **Create mapping file** using Write tool

This approach is more robust than bash scripting because:

- No variable persistence issues between commands
- No temporary file dependencies
- Leverages Claude's natural language processing
- More maintainable and debuggable
- Handles edge cases intelligently

## Relationship to PRD Workflow

**Required Flow (Parent PRD → Child Spec):**

```
PRD.md → [prd-sync] → GitHub Issue #247 (PRD - parent)
                           ↓
                    [speckit.specify --from-issue 247]
                           ↓
                    specs/001-feature/spec.md (local)
                           ↓
                    [speckit.sync 247]
                           ↓
                    GitHub Issue #248 (Spec - child of #247)
```

**Stakeholder View:**

- Business team tracks PRD issue #247 (parent)
- Tech team tracks Spec issue #248 (child)
- Parent-child relationship via "Parent PRD: #247" in spec body
- Clear separation of concerns: business (PRD) vs technical (Spec)

## Portability to Linear

Issues created by this command import cleanly to Linear with full context preserved. Zero lock-in to GitHub Projects.
