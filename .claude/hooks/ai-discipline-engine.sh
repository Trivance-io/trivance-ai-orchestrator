#!/bin/bash
# .claude/hooks/ai-discipline-engine.sh
# AI Discipline Engine - Fortune 500 Excellence for AI-FIRST workflow
# Compatible with Claude Code hooks official documentation

# Source excellence standards
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/excellence-standards.sh"

# Get hook context from environment
EVENT_TYPE="${HOOK_EVENT_TYPE:-PreToolUse}"
TOOL_INPUT="${TOOL_INPUT:-}"

# Parse tool input if available
if [ -n "$TOOL_INPUT" ]; then
    TOOL_TYPE=$(echo "$TOOL_INPUT" | jq -r '.tool_type // empty' 2>/dev/null)
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
    # Fallback: read from stdin
    read -r input_data
    TOOL_TYPE=$(echo "$input_data" | jq -r '.tool_type // empty' 2>/dev/null)
    FILE_PATH=$(echo "$input_data" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    COMMAND=$(echo "$input_data" | jq -r '.tool_input.command // empty' 2>/dev/null)
fi

# Execute discipline checks based on event type
case "$EVENT_TYPE" in
    "PreToolUse")
        case "$TOOL_TYPE" in
            "Edit"|"MultiEdit"|"Write")
                if [ -n "$FILE_PATH" ]; then
                    echo "🧠 AI DISCIPLINE: Applying Fortune 500 standards..."
                    apply_excellence_principles "$FILE_PATH"
                fi
                ;;
            "Bash")
                if [ -n "$COMMAND" ]; then
                    validate_secure_command "$COMMAND"
                fi
                ;;
        esac
        ;;
    
    "PostToolUse")
        case "$TOOL_TYPE" in
            "Edit"|"MultiEdit"|"Write")
                if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
                    validate_output_quality "$FILE_PATH"
                fi
                ;;
        esac
        ;;
    
    "Stop")
        generate_session_audit
        ;;
esac

exit 0