#!/bin/bash

# Trivance Platform - Workspace Setup
# Clone repositories and copy Claude workspace configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "${SCRIPT_DIR}")"
REPOS_FILE="${SCRIPT_DIR}/docs/trivance-repos.md"
CLAUDE_SOURCE="${SCRIPT_DIR}/.claude"
CLAUDE_TARGET="${WORKSPACE_DIR}/.claude"

# Check prerequisites
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

echo "🚀 Starting workspace setup..."
echo "📁 Workspace: $WORKSPACE_DIR"

# Process repositories
echo "📥 Processing repositories..."
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Clean URL and extract repo name
    repo_url="${line%/}"
    repo_name=$(basename "$repo_url" .git)
    repo_path="${WORKSPACE_DIR}/${repo_name}"
    
    if [[ -d "$repo_path" ]]; then
        echo "⚡ Updating $repo_name..."
        if cd "$repo_path" && git pull --quiet; then
            echo "✅ Updated $repo_name"
        else
            echo "⚠️  Failed to update $repo_name"
        fi
    else
        echo "📥 Cloning $repo_name..."
        if git clone --quiet "$repo_url" "$repo_path"; then
            echo "✅ Cloned $repo_name"
        else
            echo "❌ Failed to clone $repo_name"
            exit 1
        fi
    fi
done < "$REPOS_FILE"

# Copy Claude workspace
echo "🤖 Setting up Claude workspace..."
if [[ -d "$CLAUDE_TARGET" ]]; then
    echo "🔄 Updating existing .claude..."
    rm -rf "$CLAUDE_TARGET"
fi

if cp -r "$CLAUDE_SOURCE" "$CLAUDE_TARGET"; then
    echo "✅ Claude workspace configured"
else
    echo "❌ Failed to copy .claude"
    exit 1
fi

# Verify copy
if [[ -d "${CLAUDE_TARGET}/agents" && -d "${CLAUDE_TARGET}/commands" ]]; then
    echo "✅ Claude workspace verified"
else
    echo "❌ Claude workspace incomplete"
    exit 1
fi

echo "🎉 Setup completed successfully!"
echo "💡 Open Claude Code in this workspace directory"