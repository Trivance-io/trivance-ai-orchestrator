#!/bin/bash

# Trivance Platform - Workspace Setup
# Clone repositories and copy Claude workspace configuration

set -euo pipefail

# Secure path construction with validation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(realpath "$(dirname "$(dirname "$SCRIPT_DIR")")")"

# Validate we're in expected directory structure
if [[ ! "$SCRIPT_DIR" =~ /trivance-ai-orchestrator/scripts/core$ ]]; then
    echo "❌ Script must be run from trivance-ai-orchestrator/scripts/core/" >&2
    exit 1
fi

REPOS_FILE="$SCRIPT_DIR/../../docs/trivance-repos.md"
CLAUDE_SOURCE="$SCRIPT_DIR/../../.claude"
CLAUDE_TARGET="$WORKSPACE_DIR/.claude"

# Validate critical paths are within expected locations
if [[ ! "$CLAUDE_TARGET" == "$WORKSPACE_DIR/.claude" ]] || [[ "$CLAUDE_TARGET" == "/" ]]; then
    echo "❌ Invalid Claude target path" >&2
    exit 1
fi

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

# Validate repository URL to prevent command injection
validate_repo_url() {
    local url="$1"
    # Only allow GitHub URLs with valid repo format
    if [[ ! "$url" =~ ^https://github\.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+/?$ ]]; then
        echo "❌ Invalid repository URL: $url" >&2
        return 1
    fi
}

echo "🚀 Starting workspace setup..."
echo "📁 Workspace: $WORKSPACE_DIR"

# Process repositories
echo "📥 Processing repositories..."
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Clean URL and extract repo name
    repo_url="${line%/}"
    
    # Validate URL before using with git commands
    if ! validate_repo_url "$repo_url"; then
        echo "❌ Skipping invalid URL: $repo_url"
        continue
    fi
    
    repo_name=$(basename "$repo_url" .git)
    repo_path="${WORKSPACE_DIR}/${repo_name}"
    
    # Validate repo_path is within workspace
    if [[ ! "$repo_path" == "$WORKSPACE_DIR"/* ]]; then
        echo "❌ Invalid repository path: $repo_path" >&2
        continue
    fi
    
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
    
    # Validate path before rm -rf to prevent accidental system deletion
    if [[ "$CLAUDE_TARGET" == "$WORKSPACE_DIR/.claude" ]] && [[ -n "$CLAUDE_TARGET" ]] && [[ "$CLAUDE_TARGET" != "/" ]]; then
        rm -rf "$CLAUDE_TARGET"
    else
        echo "❌ Unsafe path for deletion: $CLAUDE_TARGET" >&2
        exit 1
    fi
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