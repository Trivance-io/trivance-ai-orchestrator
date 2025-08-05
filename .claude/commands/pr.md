# Pull Request

Creo PRs siguiendo el template establecido, con logging para auditoría y flujo simple.

## Flujo Simple

```bash
# Detectar branch base
base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's/refs\/remotes\/origin\///' || echo "main")
current_branch=$(git branch --show-current)

# Validaciones básicas
if ! git log "$base_branch"..HEAD --oneline >/dev/null 2>&1; then
    echo "❌ No hay commits para PR"
    exit 1
fi

# Obtener información básica
commits=$(git log --oneline "$base_branch"..HEAD)
first_commit=$(echo "$commits" | head -1 | cut -d' ' -f2-)
files_changed=$(git diff --name-only "$base_branch"..HEAD | wc -l)
commits_count=$(echo "$commits" | wc -l)

# Detectar tipo simple
pr_type="feature"
if echo "$commits" | grep -qi "fix\|bug"; then pr_type="bugfix"; fi
if echo "$commits" | grep -qi "docs"; then pr_type="docs"; fi

# Generar descripción con template
pr_description=$(cat <<EOF
## 🎯 Contexto

**Tipo**: $pr_type | **Archivos**: $files_changed | **Commits**: $commits_count

### Resumen
$first_commit

### Cambios incluidos
\`\`\`  
$commits
\`\`\`

### Checklist
- [x] Implementación completada
- [x] Cambios validados localmente
- [ ] Review pendiente
- [ ] Testing en staging

### Notas para reviewer
$(if [ "$pr_type" = "bugfix" ]; then echo "- Verificar que el fix resuelve el issue reportado"; fi)
$(if [ "$pr_type" = "feature" ]; then echo "- Validar que la funcionalidad cumple los requirements"; fi)

---
*PR creado con /pr*
EOF
)
```

## Creación y Logging

```bash
# Guardar PR info en logs JSONL con estructura por fechas
today=$(date '+%Y-%m-%d')
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
logs_dir=".claude/logs/$today"
mkdir -p "$logs_dir"

# Crear entrada JSONL en el archivo diario
pr_log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "event": "pr_created",
  "branch": "$current_branch",
  "target": "$base_branch",
  "pr_type": "$pr_type",
  "files_changed": $files_changed,
  "commits_count": $commits_count,
  "first_commit": "$first_commit",
  "pr_description": $(echo "$pr_description" | jq -R -s .)
}
EOF
)

echo "$pr_log_entry" >> "$logs_dir/pr_activity.jsonl"
echo "📝 PR info guardado en: $logs_dir/pr_activity.jsonl"

# Push y crear PR
echo "📤 Pushing $current_branch..."
if git push origin "$current_branch"; then
    echo "🚀 Creando PR..."
    if gh pr create \
        --base "$base_branch" \
        --title "$first_commit" \
        --body "$pr_description"; then
        
        echo "✅ PR creado exitosamente!"
        
        # Actualizar log JSONL con URL del PR
        pr_url=$(gh pr view --json url --jq '.url' 2>/dev/null)
        pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null)
        
        if [ -n "$pr_url" ]; then
            # Crear entrada de PR creado exitosamente
            pr_success_entry=$(cat <<EOF
{
  "timestamp": "$(date '+%Y-%m-%dT%H:%M:%S')",
  "event": "pr_created_success",
  "branch": "$current_branch",
  "pr_number": $pr_number,
  "pr_url": "$pr_url"
}
EOF
)
            echo "$pr_success_entry" >> "$logs_dir/pr_activity.jsonl"
            echo "🌐 $pr_url"
        fi
        
        gh pr view --web
    else
        echo "❌ Error creando PR"
    fi
else
    echo "❌ Error en push"
fi
```

## Uso

```bash
/pr  # Simple, hace todo automáticamente
```

Template consistente, logging automático, sin complejidad innecesaria.