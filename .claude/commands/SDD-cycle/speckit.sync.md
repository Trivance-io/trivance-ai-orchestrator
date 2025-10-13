---
allowed-tools: Read, Edit, Write, Bash(gh), Bash(date)
description: Push spec to GitHub as issue with optional parent PRD reference
---

# Spec Sync

Push spec to GitHub as issue with optional parent PRD reference.

## Usage

```
/SDD-cycle:speckit.sync
/SDD-cycle:speckit.sync --parent <issue_number>
```

## User Input

$ARGUMENTS

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:

- `.claude/rules/datetime.md` - For getting real current date/time
- `.claude/rules/github-operations.md` - For GitHub CLI operations

## Instructions

### 1. Detect Current Feature and Parse Arguments

**Detect feature from current branch:**

- Get branch name via `git branch --show-current`
- Extract feature directory name (e.g., `001-documentation-changelog-visibility`)
- Or check `SPECIFY_FEATURE` environment variable if set

**Parse arguments** from `$ARGUMENTS`:

- **Parent PRD**: Extract parent issue number if `--parent <number>` provided
- If no parent provided: Create standalone spec issue

**Validate required files exist:**

- `specs/<feature>/spec.md` (mandatory)
- `specs/<feature>/plan.md` (optional)
- `specs/<feature>/tasks.md` (optional)

If spec.md missing, show error and stop.

### 2. Prepare Issue Content

**Read spec artifacts:**

- Read `specs/<feature>/spec.md`
- Read `specs/<feature>/plan.md` if exists
- Read `specs/<feature>/tasks.md` if exists

**Strip frontmatter** from spec.md (everything between `---` lines at top)

**Format for GitHub Issue body:**

```markdown
# Feature Specification: <Title from spec>

[If --parent provided]
**Parent PRD**: #<parent_number>

---

## Specification

<spec.md content without frontmatter>

## [If plan.md exists]

## Implementation Plan

<plan.md content>

## [If tasks.md exists]

## Task Breakdown

<tasks.md content>

---

_Synced from local specs at <timestamp>_
```

### 3. Create GitHub Issue

**Prepare issue creation:**

- **Title**: "Spec: <feature-name>" (convert kebab-case to Title Case)
- **Body**: Formatted content from step 2
- **Labels**: `spec`, `sdd`
- **Additional labels**: `technical` if no parent, or `feature` if parent exists

**Create GitHub issue:**

```bash
gh issue create \
  --title "<title>" \
  --body "<formatted_body>" \
  --label spec,sdd,<additional_labels>
```

**If parent PRD provided:**

- Add comment to parent issue notifying of spec creation:

```bash
gh issue comment <parent_number> \
  --body "📋 Technical specification created: #<spec_issue_number>"
```

### 4. Update Local Spec File

**Update** `specs/<feature>/spec.md` frontmatter with:

- `github: <issue_url>`
- `github_synced: <current_timestamp>`
- `parent_prd: #<parent_number>` (only if parent provided)

Use current timestamp in ISO format: `YYYY-MM-DDTHH:MM:SSZ`

**Preserve all other frontmatter fields** (Feature Branch, Created, Status, etc.)

### 5. Create GitHub Mapping File

**Create** `specs/<feature>/github-mapping.md` with this content:

```markdown
# GitHub Issue Mapping

[If parent provided]
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
  [If parent provided] - Parent PRD: #<parent_number>
  - Files synced: spec.md[, plan.md][, tasks.md]

Next steps:
  - View spec: <issue_url>
  - Update spec: Edit specs/<feature>/spec.md and re-run /SDD-cycle:speckit.sync
  - Implement: /SDD-cycle:speckit.implement
```

## Error Handling

- **If spec.md not found**: Show clear error message with correct path
- **If parent issue invalid**: Show error that parent issue doesn't exist
- **If issue creation fails**: Report what succeeded, don't rollback
- **If file updates fail**: Report specific file and continue with others

## Important Notes

- Trust GitHub CLI authentication (no pre-auth checks)
- Don't pre-check for duplicates (let GitHub handle conflicts)
- Update files only after successful GitHub operations
- Keep operations atomic and simple
- Re-running command updates existing GitHub issue (manual for now)
- Use `--parent N` to link spec to existing PRD issue
- Spec represents technical implementation, PRD represents business requirement

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Detect feature** from branch name or env var
2. **Parse arguments** intelligently from `$ARGUMENTS`
3. **Read spec content** using the Read tool
4. **Execute GitHub operations** using simple Bash commands
5. **Update files** using Edit tool for surgical changes
6. **Create new files** using Write tool when needed

This approach is more robust than bash scripting because:

- No variable persistence issues between commands
- No temporary file dependencies
- Leverages Claude's natural language processing
- More maintainable and debuggable
- Handles edge cases intelligently

## Relationship to PRD Workflow

**PRD → Spec Integration:**

```
PRD.md → [prd-sync] → GitHub Issue #247 (PRD)
                           ↓
                    [SDD-cycle:specify --from-issue 247]
                           ↓
                    specs/001-feature/spec.md (local)
                           ↓
                    [SDD-cycle:speckit.sync --parent 247]
                           ↓
                    GitHub Issue #248 (Spec, linked to #247)
```

**Stakeholder View:**

- Business team tracks PRD issue #247
- Tech team tracks Spec issue #248
- Both linked via "Parent PRD: #247" in spec body
- Clear separation of concerns

## Portability Notes

**This design is 100% portable to Linear:**

- All data in Issue body/title/labels (Linear imports these)
- Zero GitHub Projects custom fields (Linear doesn't import these)
- Standard markdown formatting (Linear supports this)
- Labels follow common conventions (spec, sdd, technical, feature)
- Parent reference in body text (parseable by any system)

**Migration path:** When moving to Linear, issues import cleanly with full context preserved.
