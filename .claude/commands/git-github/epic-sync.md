---
allowed-tools: Read, Edit, Write, Bash(gh), Bash(date)
description: Push epic to GitHub as parent issue with intelligent milestone tracking
---

# Epic Sync

Push epic to GitHub as parent issue with milestone tracking using intelligent PRD analysis.

## Usage

```
/git-github:epic-sync <feature_name>
/git-github:epic-sync <feature_name> --milestone <number>
```

## User Input

$ARGUMENTS

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

- Create intelligent milestone based on PRD analysis
- Follow the process below

### 3. Intelligent Milestone Creation

**Read and analyze** `.claude/prds/<epic_name>.md` to understand:

- Problem domain and business value
- Target outcomes and success metrics
- Main business objective

**Generate milestone name** (2-4 words) with clear objective word:

- **NOT the same as epic name**
- **Include objective word**: "Onboarding", "Enhancement", "Modernization", "Performance"
- **Focus on business value**, not technical implementation

**Examples of good milestone names**:

- "Developer Onboarding" (for reducing time-to-productivity)
- "Documentation Modernization" (for obsolete docs, knowledge gaps)
- "User Experience Enhancement" (for usability improvements)
- "Platform Performance" (for speed optimization, monitoring)

**Create milestone description** using this template:

```yaml
milestone_description_template: |
  ## Objetivo
  [Main business objective from Executive Summary - first paragraph, clean format]

  ## Valor Esperado
  [Extract the "Valor esperado" line from Executive Summary]

  ## Métricas de Éxito
  [Extract first 3 metrics from "Métricas Primarias" section]
```

**Create the milestone** via GitHub API with the generated name and description.

### 4. Create GitHub Issue

**Prepare issue content**:

- Read `.claude/epics/<epic_name>/epic.md`
- Strip the frontmatter (everything between `---` lines)
- Use clean epic content as issue body

**Create GitHub issue**:

- Title: `<epic_name>`
- Body: Clean epic content without frontmatter
- Assign to the milestone (either existing or newly created)

### 5. Update Epic File

**Update** `.claude/epics/<epic_name>/epic.md` frontmatter with:

- `github: <issue_url>`
- `updated: <current_timestamp>`
- `milestone: <milestone_number>`
- `milestone_url: <milestone_url>`

Use current timestamp in ISO format: `YYYY-MM-DDTHH:MM:SSZ`

### 6. Update PRD File

**Update** `.claude/prds/<epic_name>.md` frontmatter with:

- `milestone: <milestone_number>`
- `milestone_url: <milestone_url>`
- `github_synced: <current_timestamp>`

Add these fields after the `created:` line in frontmatter.

### 7. Create GitHub Mapping File

**Create** `.claude/epics/<epic_name>/github-mapping.md` with this content:

```markdown
# GitHub Issue Mapping

Milestone: #<milestone_number> - <milestone_url>
Epic: #<issue_number> - <issue_url>

Note: Sub-issues will be created by SDD workflow via /specify --from-issue <issue_number>

Synced: <current_timestamp>
```

### 8. Output Results

**Display success message**:

```
✅ Synced to GitHub
  - Milestone: #<milestone_number> - <milestone_title>
  - Epic: #<issue_number> - <epic_name>
  - Parent Issue created and assigned to milestone

Next steps:
  - Technical breakdown: /specify --from-issue <issue_number>
  - View milestone: <milestone_url>
  - View epic: <issue_url>
```

## Error Handling

- **If epic.md not found**: Show clear error message with correct path
- **If PRD.md not found**: Show clear error message with correct path
- **If milestone creation fails**: Try to find existing milestone with same name
- **If issue creation fails**: Report what succeeded, don't rollback
- **If file updates fail**: Report specific file and continue with others

## Important Notes

- Trust GitHub CLI authentication (no pre-auth checks)
- Milestone description uses PRD content for comprehensive tracking
- Don't pre-check for duplicates (let GitHub handle conflicts)
- Update files only after successful GitHub operations
- Keep operations atomic and simple
- Sub-issues handled by SDD workflow, not this command
- Milestone provides business-level progress tracking
- Use `--milestone N` to reuse existing milestones across epics

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Parse arguments** intelligently from `$ARGUMENTS`
2. **Read PRD content** using the Read tool
3. **Analyze content** to generate appropriate milestone names
4. **Execute GitHub operations** using simple Bash commands
5. **Update files** using Edit tool for surgical changes
6. **Create new files** using Write tool when needed

This approach is more robust than bash scripting because:

- No variable persistence issues between commands
- No temporary file dependencies
- Leverages Claude's natural language processing
- More maintainable and debuggable
- Handles edge cases intelligently
