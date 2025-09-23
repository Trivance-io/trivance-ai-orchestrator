---
description: Intelligent git commit with automatic grouping and quality checks
argument-hint: "commit message or 'all changes'"
allowed-tools: Bash, Read, Grep, TodoWrite
---

# Smart Git Commit

**Intelligently analyze and commit changes:** $ARGUMENTS

Automatically groups diverse changes into logical, separate commits for better project history.

## Pre-Commit Quality Checks

Verifies build, tests, and linter pass before committing.

## Process

Check repository status and analyze changes:

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

Analyzes files, change types, and scope. Handles errors with explanations and ensures no partial commits.

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

Creates conventional commit messages (feat|fix|docs|style|refactor|test|chore) with appropriate scope and description.

```bash
# Example: git commit -m "fix(auth): resolve login timeout issue"
```

## Security & Authenticity

- Uses only your existing git user configuration
- No AI signatures, attributions, or generated markers
- No git config modifications
- Maintains full commit ownership and authenticity

## Auto-Grouping Logic

- **Triggers**: 2+ groups with 2+ files each, or any security changes
- **Groups**: config, docs, security, test, main
- **Fallback**: Single commit when grouping provides no benefit
- **Result**: Clean, logical commit history without manual intervention
