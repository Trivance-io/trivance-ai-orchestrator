#!/bin/bash

# Trivance Platform - Workspace Setup
# Clone repositories and copy Claude workspace configuration

set -euo pipefail

# Calculate correct workspace (parent of orchestrator repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(realpath "$SCRIPT_DIR/../../..")"

# Validate workspace calculation
if [[ -z "$WORKSPACE_DIR" || ! -d "$WORKSPACE_DIR" ]]; then
    echo "❌ Failed to calculate workspace directory" >&2
    exit 1
fi

REPOS_FILE="$SCRIPT_DIR/../../docs/trivance-repos.md"
CLAUDE_SOURCE="$SCRIPT_DIR/../../.claude"  
CLAUDE_TARGET="$WORKSPACE_DIR/.claude"

# Essential validation only
if ! command -v git &>/dev/null; then
    echo "❌ Git not found" >&2
    exit 1
fi

if [[ ! -f "$REPOS_FILE" ]]; then
    echo "❌ docs/trivance-repos.md not found" >&2
    exit 1
fi

if [[ ! -d "$CLAUDE_SOURCE" ]]; then
    echo "❌ .claude directory not found" >&2
    exit 1
fi

if [[ ! -w "$WORKSPACE_DIR" ]]; then
    echo "❌ Workspace directory not writable: $WORKSPACE_DIR" >&2
    exit 1
fi

echo "🚀 Starting workspace setup..."
echo "📁 Workspace: $WORKSPACE_DIR"

# Process repositories with error tolerance  
echo "📥 Processing repositories..."
success_count=0
total_count=0

while IFS= read -r url; do
    # Skip empty lines and comments
    [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue
    
    total_count=$((total_count + 1))
    repo_url="${url%/}"
    repo_name=$(basename "$repo_url" .git)
    repo_path="$WORKSPACE_DIR/$repo_name"
    
    if [[ -d "$repo_path/.git" ]]; then
        echo "⚡ Updating $repo_name..."
        if (cd "$repo_path" && git fetch --quiet && git pull --ff-only --quiet 2>/dev/null); then
            echo "✅ Updated $repo_name"
            success_count=$((success_count + 1))
        else
            echo "⚠️  $repo_name: Manual merge needed or update failed"
        fi
    else
        echo "📥 Cloning $repo_name..."
        if git clone --quiet "$repo_url" "$repo_path" 2>/dev/null; then
            echo "✅ Cloned $repo_name"
            success_count=$((success_count + 1))
        else
            echo "❌ Failed to clone $repo_name from $repo_url"
        fi
    fi
done < "$REPOS_FILE"

echo "📊 Repository summary: $success_count/$total_count successful"

# Setup Claude workspace (avoid NOP if source == target)
if [[ "$CLAUDE_SOURCE" != "$CLAUDE_TARGET" ]]; then
    echo "🤖 Setting up Claude workspace..."
    temp_target="${CLAUDE_TARGET}.tmp.$$"
    
    # Atomic operation: copy to temp, then move
    if cp -r "$CLAUDE_SOURCE" "$temp_target" 2>/dev/null && mv "$temp_target" "$CLAUDE_TARGET" 2>/dev/null; then
        echo "✅ Claude workspace configured"
    else
        # Cleanup temp on failure
        rm -rf "$temp_target" 2>/dev/null
        echo "❌ Failed to copy .claude from $CLAUDE_SOURCE to $CLAUDE_TARGET" >&2
        exit 1
    fi
else
    echo "🤖 Claude workspace already in correct location"
fi

echo "🎉 Setup completed successfully!"
echo "💡 Navigate to workspace directory: $WORKSPACE_DIR"