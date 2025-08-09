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

# Validar target branch
target_branch="${1:-$ARGUMENTS}"
if [ -z "$target_branch" ]; then
    echo "❌ Error: Target branch requerida"
    echo "Uso: /pr <target_branch>"
    echo "Ejemplo: /pr develop"
    exit 1
fi

# Verificar que target branch existe en remoto
if ! git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    echo "❌ Target branch '$target_branch' no existe en remoto"
    echo "💡 Branches disponibles: $(git branch -r | grep -v HEAD | sed 's/origin\///' | tr '\n' ' ')"
    exit 1
fi

# Variables básicas
current_branch=$(git branch --show-current)
timestamp=$(date +%s)
temporal_branch="pr/${timestamp}-${current_branch}-to-${target_branch}"

echo "📝 Creando PR: $temporal_branch → $target_branch"

# Verificar commits justo antes de crear branch (evitar race condition)
commits_check=$(git log HEAD --not --remotes --oneline | head -1 2>/dev/null)
if [ -z "$commits_check" ]; then
    echo "❌ No hay commits para PR en el momento de ejecución"
    exit 1
fi

commits_count=$(git log HEAD --not --remotes --oneline | wc -l | xargs)
# Sanitizar first_commit para prevenir command injection
first_commit_raw=$(git log HEAD --not --remotes --oneline | head -1 | cut -d' ' -f2-)
first_commit=$(echo "$first_commit_raw" | sed 's/[\$`"\\]/\\&/g' | tr -d '\n\r')

# Crear rama temporal
git checkout -b "$temporal_branch" || exit 1

# Push rama temporal
if ! git push origin "$temporal_branch" --set-upstream; then
    git checkout "$current_branch" 2>/dev/null
    git branch -D "$temporal_branch" 2>/dev/null
    exit 1
fi

# Generar descripción
commits_list=$(git log HEAD --not --remotes/${target_branch} --oneline | head -10)
files_changed=$(git diff --name-only HEAD "origin/$target_branch" | wc -l | xargs)

pr_type="feature"
if echo "$commits_list" | grep -qi "fix\|bug"; then pr_type="bugfix"; fi
if echo "$commits_list" | grep -qi "docs"; then pr_type="docs"; fi

pr_description="## Cambios desde $current_branch

**Target:** $target_branch | **Type:** $pr_type | **Commits:** $commits_count | **Files:** $files_changed

### Cambios incluidos:
\`\`\`
$commits_list
\`\`\`

### Related issues:
- Closes #
- Relates to #

---
*Temporal branch: $temporal_branch*"

# Crear PR
if gh pr create --base "$target_branch" --title "$first_commit" --body "$pr_description"; then
    echo "✅ PR creado exitosamente!"
    
    # Logging
    today=$(date '+%Y-%m-%d')
    timestamp_iso=$(date '+%Y-%m-%dT%H:%M:%S')
    logs_dir=".claude/logs/$today"
    mkdir -p "$logs_dir"
    
    # Obtener PR info
    pr_url=""
    pr_number=""
    for i in {1..3}; do
        pr_url=$(gh pr view --json url --jq '.url' 2>/dev/null) && break
        sleep 1
    done
    for i in {1..3}; do
        pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null) && break  
        sleep 1
    done
    
    # Log entry
    pr_log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp_iso",
  "event": "temporal_pr_created",
  "original_branch": "$current_branch", 
  "temporal_branch": "$temporal_branch",
  "target_branch": "$target_branch",
  "pr_type": "$pr_type",
  "files_changed": $files_changed,
  "commits_count": $commits_count,
  "first_commit": $(echo "$first_commit" | jq -R -s .),
  "pr_number": ${pr_number:-null},
  "pr_url": $(echo "$pr_url" | jq -R -s .)
}
EOF
)
    
    echo "$pr_log_entry" >> "$logs_dir/pr_activity.jsonl"
    echo "🌐 $pr_url"
    gh pr view --web
    
else
    echo "❌ Error creando PR - limpiando..."
    git checkout "$current_branch" 2>/dev/null
    git branch -D "$temporal_branch" 2>/dev/null
    git push origin --delete "$temporal_branch" 2>/dev/null
    exit 1
fi
```