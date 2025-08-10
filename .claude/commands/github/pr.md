# Pull Request

Crea o actualiza PR automáticamente usando branch actual, con target branch requerido.

## Uso

```bash
/pr <target_branch>  # Argumento MANDATORY. Sin target branch bloquear proceso hasta que se indique
```

## Ejemplos

```bash
/pr develop     # Auto-crea o actualiza PR hacia develop
/pr main        # Auto-crea o actualiza PR hacia main  
/pr qa          # Auto-crea o actualiza PR hacia qa
```

**Ejecución automática:**
- Si PR existe desde branch actual → actualiza automáticamente
- Si no existe → crea nuevo PR
- Sin prompts de usuario, sin interrupciones

## Flujo de Ejecución

```bash
/pr develop
├─ 1. Valida que 'develop' existe en remoto
├─ 2. Detecta rama actual
├─ 2.1. Si rama actual == target → crea rama temporal automática
├─ 3. Detecta si ya existe PR desde branch actual
├─ 4a. Si existe → actualiza automáticamente  
└─ 4b. Si no existe → crea nuevo PR
   └─ 5. Log resultado + mostrar URL
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

# Input sanitization - Fix command injection
[[ ! "$target_branch" =~ ^[a-zA-Z0-9/_.-]+$ ]] && {
    echo "❌ Error: Branch name contiene caracteres inválidos"
    exit 1
}

# Verificar target existe en remoto - Fix error suppression
if ! git fetch origin "$target_branch" 2>&1; then
    if ! git fetch origin 2>&1; then
        echo "❌ Error conectando a remoto. Verificar autenticación."
        exit 1
    fi
fi
git show-ref --verify --quiet "refs/remotes/origin/$target_branch" || {
    echo "❌ Target '$target_branch' no existe en remoto"
    echo "💡 Branches disponibles: $(git branch -r | grep -v HEAD | sed 's/origin\///' | tr '\n' ' ')"
    exit 1
}

# [2] Auto-detección automática + Smart Branch Creation
current_branch=$(git branch --show-current)

# [2.1] Same-branch prevention + Auto-branch creation
[ "$current_branch" = "$target_branch" ] && {
    # Auto-create feature branch from current commits
    timestamp=$(date +%Y%m%d-%H%M%S)
    suffix=$(head -c 6 /dev/urandom 2>/dev/null | base64 | tr -d '+/=' | tr '[:upper:]' '[:lower:]' || echo "$(date +%N)")
    new_branch="feature/auto-pr-${timestamp}-${suffix}"
    
    # Verificar que no existe
    if git show-ref --verify --quiet "refs/remotes/origin/$new_branch" 2>/dev/null; then
        new_branch="feature/auto-pr-${timestamp}-$(date +%N)"
    fi
    
    echo "🔀 Detectado $current_branch → $target_branch (mismo branch)"
    echo "🚀 Creando rama temporal: $new_branch"
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Tienes cambios sin commit. ¿Proceder con stash? [y/N]"
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] || { echo "❌ Operación cancelada"; exit 1; }
        git stash push -m "Auto-stash antes de crear PR branch"
    fi
    
    # Create new branch and switch to it
    git checkout -b "$new_branch"
    git push origin "$new_branch" --set-upstream
    current_branch="$new_branch"
    echo "✅ Movido a: $current_branch"
}

existing_pr=$(gh pr list --head "$current_branch" --json number,url 2>/dev/null | jq '.[0] // empty' 2>/dev/null || echo "")
if [ "$?" -ne 0 ]; then
    echo "❌ Error consultando PRs existentes"
    exit 1
fi

# [3] Lógica de acción automática
if [ -n "$existing_pr" ]; then
    # Actualizar PR existente automáticamente
    git push origin "$current_branch"
    pr_number=$(echo "$existing_pr" | jq -r '.number')
    pr_url=$(echo "$existing_pr" | jq -r '.url')
    action="updated"
    echo "🔄 Actualizando PR existente #$pr_number"
else
    # Crear nuevo PR - Fix race condition
    commits_data=$(git rev-list --oneline "HEAD" "^origin/$target_branch" 2>/dev/null || {
        echo "❌ Error: No se pueden comparar commits con $target_branch"
        exit 1
    })
    commits_count=$(echo "$commits_data" | wc -l | xargs)
    [ "$commits_count" -eq 0 ] && { 
        echo "❌ No hay commits para PR"
        exit 1 
    }
    
    first_commit=$(echo "$commits_data" | head -1 | cut -d' ' -f2-)
    commits_list=$(echo "$commits_data" | head -5)
    
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

# [4] Logging estructurado
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