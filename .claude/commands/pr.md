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
echo "🔄 Actualizando información del branch remoto..."
git fetch origin "$target_branch" 2>/dev/null || git fetch origin 2>/dev/null
if ! git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    echo "❌ Target branch '$target_branch' no existe en remoto"
    echo "💡 Branches disponibles: $(git branch -r | grep -v HEAD | sed 's/origin\///' | tr '\n' ' ')"
    exit 1
fi

# Variables básicas
current_branch=$(git branch --show-current)

# CRÍTICO: Verificar si ya existe PR para la rama actual
existing_pr=$(gh pr list --head "$current_branch" --json number --jq '.[0].number // ""' 2>/dev/null)
if [ -n "$existing_pr" ]; then
    echo "⚠️  Ya existe PR #$existing_pr para la rama $current_branch"
    echo "🔄 Actualizando PR existente en lugar de crear nuevo..."
    git push origin "$current_branch"
    pr_url=$(gh pr view "$existing_pr" --json url --jq '.url' 2>/dev/null)
    echo "🌐 $pr_url"
    gh pr view --web 2>/dev/null
    exit 0
fi

# Obtener próximo número de PR para naming predictivo
next_pr_number=$(gh pr list --limit 1 --json number --jq '.[0].number // 0' 2>/dev/null || echo "0")
next_pr_number=$((next_pr_number + 1))
temporal_branch="pull-${next_pr_number}-${current_branch}-to-${target_branch}"

echo "📝 Creando PR: $temporal_branch → $target_branch"

# Verificar commits justo antes de crear branch (evitar race condition)
commits_check=$(git log HEAD --not origin/$target_branch --oneline | head -1 2>/dev/null)
if [ -z "$commits_check" ]; then
    echo "❌ No hay commits para PR en el momento de ejecución"
    exit 1
fi

commits_count=$(git log HEAD --not origin/$target_branch --oneline | wc -l | xargs)
# Sanitizar first_commit para prevenir command injection
first_commit_raw=$(git log HEAD --not origin/$target_branch --oneline | head -1 | cut -d' ' -f2-)
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
commits_list=$(git log HEAD --not origin/$target_branch --oneline | head -10)
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
    
    # Obtener PR info con retry consolidado
    pr_url=""
    pr_number=""
    pr_info=""
    for i in {1..3}; do
        pr_info=$(gh pr view --json url,number 2>/dev/null) && break
        sleep 1
    done
    pr_url=$(echo "$pr_info" | jq -r '.url // ""')
    pr_number=$(echo "$pr_info" | jq -r '.number // ""')
    
    # Log entry - evaluar variables jq por separado para evitar errores de path
    first_commit_json=""
    pr_url_json=""
    if command -v jq >/dev/null 2>&1; then
        first_commit_json=$(echo "$first_commit" | tr -d '\n\r' | jq -R . 2>/dev/null || echo "\"$(echo "$first_commit" | tr -d '\n\r' | sed 's/"/\\"/g')\"")
        pr_url_json=$(echo "$pr_url" | tr -d '\n\r' | jq -R . 2>/dev/null || echo "\"$(echo "$pr_url" | tr -d '\n\r' | sed 's/"/\\"/g')\"")
    else
        # Fallback sin jq - escapar manualmente
        first_commit_json="\"$(echo "$first_commit" | tr -d '\n\r' | sed 's/"/\\"/g')\""
        pr_url_json="\"$(echo "$pr_url" | tr -d '\n\r' | sed 's/"/\\"/g')\""
    fi
    
    # Crear log de forma segura
    if [ -w "$logs_dir" ] || mkdir -p "$logs_dir" 2>/dev/null; then
        cat > "$logs_dir/pr_activity.jsonl" << EOF
{
  "timestamp": "$timestamp_iso",
  "event": "temporal_pr_created",
  "original_branch": "$current_branch", 
  "temporal_branch": "$temporal_branch",
  "target_branch": "$target_branch",
  "pr_type": "$pr_type",
  "files_changed": $files_changed,
  "commits_count": $commits_count,
  "first_commit": $first_commit_json,
  "pr_number": ${pr_number:-null},
  "pr_url": $pr_url_json
}
EOF
    else
        echo "⚠️  Advertencia: No se pudo crear el log de trazabilidad"
    fi
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