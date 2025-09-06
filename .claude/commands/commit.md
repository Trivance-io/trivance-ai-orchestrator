# Smart Git Commit

I'll intelligently analyze your changes and create meaningful commits. When you have diverse changes across different areas, I'll automatically group them into logical, separate commits for better project history.

**Pre-Commit Quality Checks:**
Before committing, I'll verify:
- Build passes (if build command exists)
- Tests pass (if test command exists)
- Linter passes (if lint command exists)
- No obvious errors in changed files

First, let me check if this is a git repository and what's changed:

```bash
# Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository"
    echo "This command requires git version control"
    exit 1
fi

# Check if we have changes to commit
if ! git diff --cached --quiet || ! git diff --quiet; then
    echo "Changes detected:"
    git status --short
else
    echo "No changes to commit"
    exit 0
fi

# Show detailed changes
git diff --cached --stat
git diff --stat
```

Now I'll analyze the changes to determine:
1. What files were modified
2. The nature of changes (feature, fix, refactor, etc.)
3. The scope/component affected

If the analysis or commit encounters errors:
- I'll explain what went wrong
- Suggest how to resolve it
- Ensure no partial commits occur

```bash
# If nothing is staged, I'll stage modified files (not untracked)
if git diff --cached --quiet; then
    echo "No files staged. Staging modified files..."
    git add -u
fi

# Show what will be committed
git diff --cached --name-status
```

## Smart Commit Grouping

Before creating the commit, I'll analyze if the changes should be grouped into multiple logical commits:

```bash
# Get list of changed files
changed_files=$(git diff --cached --name-only)

# Classify files into logical groups
classify_file() {
    case "$1" in
        .claude/*|*.md) echo "config" ;;
        docs/*|README*|CHANGELOG*) echo "docs" ;;
        scripts/*|*setup*|*security*) echo "security" ;;
        *test*|*spec*) echo "test" ;;
        *) echo "main" ;;
    esac
}

# Group files by category
declare -A file_groups
for file in $changed_files; do
    group=$(classify_file "$file")
    file_groups[$group]+="$file "
done

# Decision: Multiple commits if 2+ groups with 2+ files each
group_count=$(echo "${!file_groups[@]}" | wc -w)
significant_groups=0
for group in "${!file_groups[@]}"; do
    file_count=$(echo "${file_groups[$group]}" | wc -w)
    if [[ $file_count -ge 2 || "$group" == "security" ]]; then
        ((significant_groups++))
    fi
done

# Execute smart commit strategy
if [[ $significant_groups -ge 2 ]]; then
    echo "🔄 Creating $significant_groups logical commits..."
    
    # Create individual commits by group
    for group in config docs security test main; do
        if [[ -n "${file_groups[$group]}" ]]; then
            files=(${file_groups[$group]})
            if [[ ${#files[@]} -ge 1 ]]; then
                # Stage and commit this group
                git reset > /dev/null 2>&1  # Unstage all
                git add ${files[@]}
                
                # Generate appropriate commit message for group
                case "$group" in
                    config) git commit -m "feat(config): update configuration and commands" ;;
                    docs) git commit -m "docs: enhance documentation and setup guides" ;;
                    security) git commit -m "security: improve security measures and validation" ;;
                    test) git commit -m "test: update test suite and coverage" ;;
                    main) git commit -m "feat: implement core functionality changes" ;;
                esac
                echo "✅ Committed $group: ${files[@]}"
            fi
        fi
    done
    
    echo "🎯 Created $significant_groups logical commits automatically"
    exit 0
fi

# Fallback to single commit if grouping not beneficial
echo "📦 Creating single commit for all changes..."
```

Based on the analysis, I'll create a conventional commit message:
- **Type**: feat|fix|docs|style|refactor|test|chore
- **Scope**: component or area affected (optional)
- **Subject**: clear description in present tense
- **Body**: why the change was made (if needed)

```bash
# I'll create the commit with the analyzed message
# Example: git commit -m "fix(auth): resolve login timeout issue"
```

The commit message will be concise, meaningful, and follow your project's conventions if I can detect them from recent commits.

**Important**: I will NEVER:
- Add "Co-authored-by" or any Claude signatures
- Include "Generated with Claude Code" or similar messages
- Modify git config or user credentials
- Add any AI/assistant attribution to the commit
- Use emojis in commits, PRs, or git-related content

The commit will use only your existing git user configuration, maintaining full ownership and authenticity of your commits.

## Intelligent Commit Grouping

This command automatically detects when changes span multiple logical areas and creates separate commits:

**Auto-grouping triggers when:**
- 2+ groups with significant changes (2+ files each, or any security changes)
- Different functional areas: config, docs, security, tests, main code

**Groups created:**
- **config**: `.claude/` files, `*.md` command files  
- **docs**: `docs/`, `README`, `CHANGELOG` files
- **security**: `scripts/`, `*setup*`, `*security*` files
- **test**: `*test*`, `*spec*` files
- **main**: all other code files

**Fallback**: Single commit if grouping provides no benefit

This ensures clean, logical commit history without manual intervention.

## Commit Summary

After creating commits, I'll show a summary of commits created in this session.

This displays commits from this session with:
- Commit hash and message  
- Files modified in each commit
- Only commits created during implementation