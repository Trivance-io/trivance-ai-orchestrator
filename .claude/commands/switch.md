# Switch Branch

Comando minimalista para cambiar de rama PR a rama objetivo y limpiar ramas temporales.

## Uso

```bash
/switch <target_branch>  # Argumento requerido
```

## Ejemplos

```bash
/switch main        # Cambiar a main y actualizar
/switch develop     # Cambiar a develop y actualizar
/switch feature/x   # Cambiar a rama específica
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

# Validar target branch (MANDATORIO)
target_branch="${1:-$ARGUMENTS}"
if [ -z "$target_branch" ]; then
    echo "❌ Error: Branch requerida"
    echo "Uso: /switch <target_branch>"
    echo "Ejemplo: /switch main"
    exit 1
fi

current_branch=$(git branch --show-current)
echo "🔄 Cambiando de '$current_branch' → '$target_branch'"

# 1. Cambiar a rama objetivo
if ! git checkout "$target_branch" 2>/dev/null; then
    echo "❌ Branch '$target_branch' no existe localmente"
    echo "🔄 Intentando fetch desde remoto..."
    git fetch origin "$target_branch" 2>/dev/null || git fetch origin 2>/dev/null
    git checkout -b "$target_branch" "origin/$target_branch" 2>/dev/null || {
        echo "❌ No se pudo crear/cambiar a '$target_branch'"
        exit 1
    }
fi

# 2. Actualizar con remoto
echo "📡 Actualizando '$target_branch' con remoto..."
git pull origin "$target_branch" 2>/dev/null || {
    echo "⚠️  No se pudo actualizar desde remoto (branch puede ser nuevo)"
}

# 3. Limpiar ramas temporales locales
echo "🧹 Limpiando ramas temporales..."
temporal_patterns=(
    "pr/[0-9]*-*-to-*"      # pr/1754781903-main-to-main
    "pull-[0-9]*-*-to-*"    # pull-102-feature-to-main
    "*-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]*" # add-claude-github-actions-1754360632146
)

deleted_count=0
for pattern in "${temporal_patterns[@]}"; do
    # Buscar ramas que coincidan con el patrón (excluyendo la actual)
    while IFS= read -r branch; do
        # Limpiar formato de git branch
        clean_branch=$(echo "$branch" | sed 's/^[ *]*//g' | sed 's/ .*$//')
        
        # No borrar rama actual ni main/master/develop
        if [[ "$clean_branch" != "$target_branch" ]] && \
           [[ "$clean_branch" != "main" ]] && \
           [[ "$clean_branch" != "master" ]] && \
           [[ "$clean_branch" != "develop" ]] && \
           [[ -n "$clean_branch" ]]; then
            
            echo "  🗑️  Borrando: $clean_branch"
            git branch -D "$clean_branch" 2>/dev/null || true
            ((deleted_count++))
        fi
    done < <(git branch | grep -E "$pattern" 2>/dev/null || true)
done

# Resultado
echo ""
echo "✅ Switch completado:"
echo "   📍 Branch actual: $target_branch"
echo "   🧹 Ramas temporales eliminadas: $deleted_count"
echo "   📡 Status: $(git status --porcelain | wc -l | xargs) archivos sin commitear"

# Mostrar status si hay cambios
if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
    echo ""
    git status --short
fi
```