#!/bin/bash

# Enhanced StatusLine with Better UX/UI
input=$(cat)

# Extract JSON fields
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')
session_id=$(echo "$input" | jq -r '.session_id')
workspace=$(echo "$input" | jq -r '.workspace.current_dir' | sed 's|.*/||')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')

# Git branch detection
branch=$(cd "$project_dir" 2>/dev/null && git branch --show-current 2>/dev/null || echo "no-git")

# Clean display with essential information
printf "\\033[1;35m🧠 %s\\033[0m\\n" "$model"
printf "\\033[0;36m📁 %s\\033[0m  \\033[0;32m🌿 %s\\033[0m" "$workspace" "$branch"