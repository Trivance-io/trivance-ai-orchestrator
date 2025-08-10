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

# SEGURIDAD: Validar formato de branch name para prevenir command injection
if [[ ! "$target_branch" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
    echo "❌ Error: Nombre de branch contiene caracteres inválidos"
    echo "Formato permitido: letras, números, /, _, -"
    exit 1
fi

# Validar longitud máxima razonable
if [ ${#target_branch} -gt 100 ]; then
    echo "❌ Error: Nombre de branch demasiado largo (max 100 caracteres)"
    exit 1
fi

current_branch=$(git branch --show-current)
echo "🔄 Cambiando de '$current_branch' → '$target_branch'"

# 1. Cambiar a rama objetivo (serializado para evitar race conditions)
echo "🔍 Verificando si branch existe localmente..."
if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "❌ Branch '$target_branch' no existe localmente"
    echo "🔄 Intentando fetch desde remoto..."
    
    # SEGURIDAD: Serializar operaciones para evitar race conditions
    if ! timeout 30 git fetch origin 2>/dev/null; then
        echo "❌ Error: timeout o falla en git fetch"
        exit 1
    fi
    
    # Verificar que existe en remoto antes de crear
    if git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
        git checkout -b -- "$target_branch" "origin/$target_branch" 2>/dev/null || {
            echo "❌ No se pudo crear branch desde remoto"
            exit 1
        }
    else
        echo "❌ Branch '$target_branch' no existe en remoto"
        exit 1
    fi
else
    # Branch existe localmente, cambiar con seguridad
    git checkout -- "$target_branch" 2>/dev/null || {
        echo "❌ No se pudo cambiar a branch local"
        exit 1
    }
fi

# 2. Actualizar con remoto (solo si existe en remoto)
if git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    echo "📡 Actualizando '$target_branch' con remoto..."
    timeout 30 git pull origin "$target_branch" 2>/dev/null || {
        echo "⚠️  No se pudo actualizar desde remoto (puede haber conflictos)"
    }
else
    echo "ℹ️  Branch solo existe localmente (no en remoto)"
fi

# 3. Limpiar ramas temporales locales (CON CONFIRMACIÓN)
echo "🧹 Buscando ramas temporales para limpiar..."

# SEGURIDAD: Patrones más restrictivos con longitud mínima
temporal_patterns=(
    "^pr/[0-9]{10,}-[a-zA-Z0-9_/-]+-to-[a-zA-Z0-9_/-]+$"           # pr/1754781903-main-to-main
    "^pull-[0-9]{1,4}-[a-zA-Z0-9_/-]+-to-[a-zA-Z0-9_/-]+$"        # pull-102-feature-to-main  
    "^[a-zA-Z-]+-[0-9]{10,}$"                                      # add-claude-github-actions-1754360632146
)

# Lista de ramas protegidas (no eliminar nunca)
protected_branches=("main" "master" "develop" "staging" "production" "$target_branch")

deleted_count=0
candidates_found=()

# Obtener lista de ramas de forma segura
if ! branches_output=$(git branch --format='%(refname:short)' 2>/dev/null); then
    echo "⚠️  No se pudo obtener lista de ramas"
else
    # SEGURIDAD: Validar cada rama antes de procesarla
    while IFS= read -r branch_name; do
        # Saltar líneas vacías
        [[ -z "$branch_name" ]] && continue
        
        # SEGURIDAD: Validar que el nombre de rama sea seguro antes de usar
        if [[ ! "$branch_name" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
            echo "⚠️  Rama con nombre inseguro ignorada: $branch_name"
            continue
        fi
        
        # Verificar si coincide con patrones temporales
        is_temporal=false
        for pattern in "${temporal_patterns[@]}"; do
            if [[ "$branch_name" =~ $pattern ]]; then
                is_temporal=true
                break
            fi
        done
        
        # Si es temporal y no es protegida, añadir a candidatos
        if [ "$is_temporal" = true ]; then
            is_protected=false
            for protected in "${protected_branches[@]}"; do
                if [[ "$branch_name" == "$protected" ]]; then
                    is_protected=true
                    break
                fi
            done
            
            if [ "$is_protected" = false ]; then
                candidates_found+=("$branch_name")
            fi
        fi
    done <<< "$branches_output"
fi

# Mostrar candidatos y pedir confirmación
if [ ${#candidates_found[@]} -eq 0 ]; then
    echo "ℹ️  No se encontraron ramas temporales para limpiar"
else
    echo "📋 Ramas temporales encontradas (${#candidates_found[@]}):"
    for candidate in "${candidates_found[@]}"; do
        echo "    🗑️  $candidate"
    done
    
    echo ""
    echo "⚠️  ¿Eliminar estas ${#candidates_found[@]} ramas temporales? (y/N)"
    read -r -t 10 confirm || confirm=""
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "🧹 Eliminando ramas temporales..."
        for branch_to_delete in "${candidates_found[@]}"; do
            echo "  🗑️  Eliminando: $branch_to_delete"
            if git branch -D -- "$branch_to_delete" 2>/dev/null; then
                ((deleted_count++))
                # LOGGING: Registrar operación destructiva
                echo "$(date '+%Y-%m-%d %H:%M:%S') - DELETED BRANCH: $branch_to_delete" >> .git/branch_cleanup.log 2>/dev/null || true
            else
                echo "    ❌ Error eliminando: $branch_to_delete"
            fi
        done
    else
        echo "ℹ️  Limpieza de ramas cancelada por el usuario"
    fi
fi

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