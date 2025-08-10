# Pull Request

Crea PR usando rama temporal, con target branch requerido.

## Uso

```bash
/pr <target_branch>  # Argumento requerido
```

## Ejemplos

```bash
/pr develop     # PR hacia develop
/pr main        # PR hacia main  
/pr qa          # PR hacia qa
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

# [1] Validación fail-fast target_branch
target_branch="${1:-}"
[ -z "$target_branch" ] && { 
    echo "❌ Error: Target branch requerida"
    echo "Uso: /pr <target_branch>" 
    exit 1 
}

# Verificar target existe en remoto
git fetch origin "$target_branch" 2>/dev/null || git fetch origin 2>/dev/null
git show-ref --verify --quiet "refs/remotes/origin/$target_branch" || {
    echo "❌ Target '$target_branch' no existe en remoto"
    echo "💡 Branches disponibles: $(git branch -r | grep -v HEAD | sed 's/origin\///' | tr '\n' ' ')"
    exit 1
}

# [2] Auto-detección determinística
current_branch=$(git branch --show-current)
existing_pr=$(gh pr list --head "$current_branch" --json number,url --jq '.[0] // empty')

# [3] Lógica de acción determinística
if [ -n "$existing_pr" ]; then
    # Actualizar PR existente automáticamente
    git push origin "$current_branch"
    pr_number=$(echo "$existing_pr" | jq -r '.number')
    pr_url=$(echo "$existing_pr" | jq -r '.url')
    action="updated"
    echo "🔄 Actualizando PR existente #$pr_number"
else
    # Crear nuevo PR
    commits_count=$(git log HEAD --not origin/$target_branch --oneline | wc -l | xargs)
    [ "$commits_count" -eq 0 ] && { 
        echo "❌ No hay commits para PR"
        exit 1 
    }
    
    first_commit=$(git log HEAD --not origin/$target_branch --oneline | head -1 | cut -d' ' -f2-)
    commits_list=$(git log HEAD --not origin/$target_branch --oneline | head -5)
    
    pr_body="**Target:** $target_branch | **Commits:** $commits_count

### Cambios incluidos:
\`\`\`
$commits_list
\`\`\`

### Related issues:
- Closes #
- Relates to #"
    
    git push origin "$current_branch" --set-upstream
    pr_info=$(gh pr create --base "$target_branch" --title "$first_commit" --body "$pr_body" --json number,url)
    pr_number=$(echo "$pr_info" | jq -r '.number')  
    pr_url=$(echo "$pr_info" | jq -r '.url')
    action="created"
    echo "✅ Nuevo PR creado #$pr_number"
fi

# [4] Logging determinístico
timestamp_iso=$(date -Iseconds)
logs_dir=".claude/logs/$(date +%Y-%m-%d)"
mkdir -p "$logs_dir"

log_entry=$(jq -n \
    --arg timestamp "$timestamp_iso" \
    --arg event "pr_${action}" \
    --arg original_branch "$current_branch" \
    --arg target_branch "$target_branch" \
    --arg pr_number "$pr_number" \
    --arg pr_url "$pr_url" \
    '{
        timestamp: $timestamp,
        event: $event,
        original_branch: $original_branch, 
        target_branch: $target_branch,
        pr_number: ($pr_number | tonumber),
        pr_url: $pr_url
    }')

echo "$log_entry" >> "$logs_dir/pr_activity.jsonl"

# [5] Output consistente
echo "🌐 $pr_url"
echo "✅ PR $action exitosamente!"
```