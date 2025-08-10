# Switch Branch

Cambia de rama PR a rama objetivo y limpia ramas temporales.

## Uso
```bash
/switch <target_branch>
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

target_branch="${1:-$ARGUMENTS}"
if [ -z "$target_branch" ]; then
    echo "❌ Branch requerida. Uso: /switch <target_branch>"
    exit 1
fi

# Validación de seguridad: prevenir command injection
if [[ ! "$target_branch" =~ ^[a-zA-Z0-9/_-]+$ ]] || [ ${#target_branch} -gt 100 ]; then
    echo "❌ Nombre de branch inválido (solo a-zA-Z0-9/_-, max 100 chars)"
    exit 1
fi

# Cambiar a rama objetivo
if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
    timeout 30 git fetch origin 2>/dev/null || { echo "❌ Error en fetch"; exit 1; }
    if git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
        git checkout -b -- "$target_branch" "origin/$target_branch" 2>/dev/null || {
            echo "❌ No se pudo crear branch desde remoto"; exit 1; }
    else
        echo "❌ Branch '$target_branch' no existe"; exit 1
    fi
else
    git checkout -- "$target_branch" 2>/dev/null || { echo "❌ Error en checkout"; exit 1; }
fi

# Actualizar con remoto si existe
if git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    timeout 30 git pull origin "$target_branch" 2>/dev/null || echo "⚠️ No se pudo actualizar desde remoto"
fi

# Limpiar ramas temporales
temporal_patterns=(
    "^pr/[0-9]{10,}-[a-zA-Z0-9_/-]+-to-[a-zA-Z0-9_/-]+$"
    "^pull-[0-9]{1,4}-[a-zA-Z0-9_/-]+-to-[a-zA-Z0-9_/-]+$"  
    "^[a-zA-Z-]+-[0-9]{10,}$"
)
protected_branches=("main" "master" "develop" "staging" "production" "$target_branch")
candidates_found=()

if branches_output=$(git branch --format='%(refname:short)' 2>/dev/null); then
    while IFS= read -r branch_name; do
        [[ -z "$branch_name" ]] && continue
        [[ ! "$branch_name" =~ ^[a-zA-Z0-9/_-]+$ ]] && continue
        
        is_temporal=false
        for pattern in "${temporal_patterns[@]}"; do
            if [[ "$branch_name" =~ $pattern ]]; then
                is_temporal=true; break
            fi
        done
        
        if [ "$is_temporal" = true ]; then
            is_protected=false
            for protected in "${protected_branches[@]}"; do
                [[ "$branch_name" == "$protected" ]] && { is_protected=true; break; }
            done
            [ "$is_protected" = false ] && candidates_found+=("$branch_name")
        fi
    done <<< "$branches_output"
fi

deleted_count=0
if [ ${#candidates_found[@]} -gt 0 ]; then
    echo "Ramas temporales: ${candidates_found[*]}"
    echo "⚠️ ¿Eliminar ${#candidates_found[@]} ramas temporales? (y/N)"
    read -r -t 10 confirm || confirm=""
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for branch_to_delete in "${candidates_found[@]}"; do
            if git branch -D -- "$branch_to_delete" 2>/dev/null; then
                ((deleted_count++))
                echo "$(date '+%Y-%m-%d %H:%M:%S') - DELETED: $branch_to_delete" >> .git/branch_cleanup.log 2>/dev/null || true
            fi
        done
    fi
fi

echo "✅ Branch: $target_branch | Eliminadas: $deleted_count | Sin commit: $(git status --porcelain | wc -l | xargs)"
[ "$(git status --porcelain | wc -l)" -gt 0 ] && git status --short
```