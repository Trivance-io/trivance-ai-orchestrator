---
allowed-tools: Bash(git *), Read, Grep, TodoWrite
description: Intelligent git commit with automatic grouping and quality checks
argument-hint: "commit message or 'all changes'"
---

# Smart Git Commit

Intelligently analyze and commit changes with automatic grouping and quality checks using natural language instructions.

## User Input

$ARGUMENTS

## Instructions

### 1. Parse Arguments and Validate Repository

**Parse the arguments** from `$ARGUMENTS`:

- **Commit message**: Extract custom commit message if provided
- **Auto mode**: Check if "all changes" or similar auto-commit requested
- Display: "Analyzing repository for intelligent commit..."

**Validate git repository**:

- Execute: `git rev-parse --git-dir` to verify git repository
- If command fails, show error: "❌ Error: Not a git repository. This command requires git version control." and stop
- If successful, show: "✓ Git repository verified"

### 2. Analyze Repository Status and Changes

**Check repository status** using atomic bash commands:

- Execute: `git status --porcelain` to check for any changes
- If no output, show: "No changes to commit" and stop
- If changes exist, show: "Changes detected, analyzing..."

**Analyze change details**:

- Execute: `git diff --cached --name-only` to get staged files
- Execute: `git diff --name-only` to get unstaged modified files
- Execute: `git ls-files --others --exclude-standard` to get untracked new files
- Execute: `git status --short` to show change summary
- Display summary of files to be processed (including new, modified, and staged)

### 3. Handle Staging Strategy

**Determine staging approach**:

- Execute: `git diff --cached --quiet` to check if anything is staged
- If nothing staged and unstaged changes exist:
  - Show: "No files staged. Staging all changes..."
  - Execute: `git add -A` to stage all changes (modified, new, deleted)
  - Show: "✓ Staged all changes (including new files)"
- If files already staged, show: "✓ Using existing staged files"

**Display staging status**:

- Execute: `git diff --cached --name-status` to show what will be committed
- Execute: `git diff --cached --stat` to show change statistics

### 4. Classify Changed Files by Category

**Get list of files to classify**:

- Execute: `git diff --cached --name-only` to get final staged file list

**Classify each file using Claude's natural language processing**:

Apply this classification logic to each file:

- **config**: Files matching `.claude/*`, `*.md`, `CLAUDE.md`, configuration files
- **docs**: Files matching `docs/*`, `README*`, `CHANGELOG*`, documentation
- **security**: Files matching `scripts/*`, `*setup*`, `*security*`, security-related
- **test**: Files matching `*test*`, `*spec*`, `*.test.*`, testing files
- **main**: All other files (core functionality)

Store classification results for decision making.

### 5. Determine Commit Strategy (Single vs Multiple)

**Analyze file groups for smart commit strategy**:

- Count files in each category from step 4
- Apply grouping decision logic:
  - **Multiple commits** if: 2+ categories with 2+ files each OR any security files exist
  - **Single commit** if: Only one significant category OR limited file changes

**Display commit strategy**:

- If multiple commits: "🔄 Creating logical commits for <N> categories..."
- If single commit: "📦 Creating single commit for all changes..."

### 6. Execute Smart Commit Strategy

**If multiple commits strategy**:

For each category with files (in order: security, config, docs, test, main):

- Execute: `git reset` to unstage all files
- Execute: `git add <files_for_category>` to stage category files only
- Generate appropriate commit message:
  - **config**: "feat(config): update configuration and commands"
  - **docs**: "docs: enhance documentation and setup guides"
  - **security**: "security: improve security measures and validation"
  - **test**: "test: update test suite and coverage"
  - **main**: "feat: implement core functionality changes"
- Execute: `git commit -m "<generated_message>"` to create commit
- Show: "✅ Committed <category>: <file_list>"

**If single commit strategy**:

- Use custom message from $ARGUMENTS if provided
- Otherwise generate conventional commit message based on dominant file type
- Execute: `git commit -m "<commit_message>"` to create single commit
- Show: "✅ Created single commit: <commit_message>"

### 7. Report Results and Status

**Display final status**:

- Execute: `git log --oneline -n 3` to show recent commit history
- Show summary:
  ```
  ✅ Commit completed:
  - Strategy: <Single|Multiple> commits
  - Files processed: <count>
  - Categories: <list_of_categories>
  ```

## Error Handling

- **If not a git repository**: Show clear error and stop execution
- **If no changes to commit**: Inform user and exit gracefully
- **If staging fails**: Show specific error and suggest resolution
- **If commit fails**: Display git error message and suggest fixes
- **If file classification unclear**: Default to 'main' category

## Important Notes

- Uses only existing git user configuration (no config modifications)
- No AI signatures, attributions, or generated markers in commits
- Maintains full commit ownership and authenticity
- Preserves conventional commit message format
- Stages ALL changes when no files are pre-staged: modified, new (untracked), and deleted
- Automatic grouping triggers: 2+ categories with 2+ files each, or any security changes
- Categories: config, docs, security, test, main (processed in priority order)
- Fallback to single commit when grouping provides no benefit

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Parse arguments** intelligently from `$ARGUMENTS`
2. **Execute atomic git commands** using the Bash tool
3. **Classify files naturally** using pattern recognition and context
4. **Make grouping decisions** through logical reasoning
5. **Generate appropriate commit messages** following conventional formats
6. **Manage commit workflow** with proper error handling

This approach is more robust than complex bash scripting because:

- No associative arrays or complex variable manipulation
- No function definitions or nested loops in bash
- Leverages Claude's natural language classification capabilities
- More maintainable and debuggable approach
- Handles edge cases intelligently through reasoning
- Each git command is atomic and verifiable
