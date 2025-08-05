# Pull Request AI-First

Creo pull requests inteligentes usando análisis contextual completo de commits y cambios.

## Flujo Inteligente

**1. Validaciones automáticas**
```bash
# Verificar contexto de repositorio
current_branch=$(git branch --show-current)
base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's/refs\/remotes\/origin\///' || echo "main")

# Verificar que hay commits para PR
if ! git log "$base_branch"..HEAD --oneline >/dev/null 2>&1; then
    echo "❌ No hay commits nuevos para crear PR"
    exit 1
fi

# Advertir si estamos en branch principal
if [[ "$current_branch" =~ ^(main|master|develop)$ ]]; then
    echo "⚠️ Estás en branch principal: $current_branch"
    echo "¿Continuar? [y/N]:"
    read -r confirm
    [[ "$confirm" =~ ^[yY]$ ]] || exit 1
fi
```

**2. Análisis AI de cambios**
```bash
# Generar contenido inteligente usando pr_analyzer.py
echo "🧠 Analizando cambios con inteligencia AI..."
pr_content=$(python3 "$CLAUDE_PROJECT_DIR/.claude/hooks/pr_analyzer.py" "$base_branch")

# Extraer título inteligente del análisis
pr_title=$(echo "$pr_content" | grep -A5 "## 🎯 Contexto" | tail -1 | sed 's/^.*: //')
```

**3. Push seguro y creación de PR**
```bash
# Push controlado (permitido en settings.json)
echo "📤 Pushing branch: $current_branch"
if ! git push origin "$current_branch"; then
    echo "❌ Push failed"
    exit 1
fi

# Crear PR con contenido AI
echo "🚀 Creando PR con contenido inteligente..."
if gh pr create \
    --base "$base_branch" \
    --title "$pr_title" \
    --body "$pr_content" \
    --assignee "@me"; then
    
    echo "✅ PR creado exitosamente!"
    echo "🌐 $(gh pr view --web --json url --jq '.url' 2>/dev/null)"
else
    echo "❌ Error creando PR"
    exit 1
fi
```

## Análisis Inteligente Incluye

- **Detección automática de tipo**: feat/fix/chore/docs/refactor
- **Evaluación de impacto**: critical/high/medium/low
- **Generación contextual**: Por qué, qué, cómo
- **Preguntas relevantes**: Basadas en archivos modificados
- **Métricas automáticas**: Files, commits, stats
- **Integration tracking**: Session IDs, correlation IDs

## Uso

```bash
# Comando simple (auto-detecta base branch)
/pr

# Con branch específico
/pr develop

# Draft PR
/pr --draft
```

## Integración Enterprise

- **Logging completo**: pr_creation.jsonl con métricas
- **Cache inteligente**: Análisis con TTL para performance
- **Security validation**: Push controlado y validado
- **Template system**: Estructura enterprise consistente
- **AI-first approach**: Contenido generado contextualmente

Este comando representa la evolución natural de la arquitectura existente: simple en uso, inteligente en ejecución.