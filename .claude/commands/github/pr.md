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
- Siempre crea rama temporal con nomenclatura: pr-{consecutivo}-{timestamp}
- Crea PR automáticamente con template minimalista
- Sin prompts de usuario, sin interrupciones

## Flujo de Ejecución

```bash
/pr develop
├─ 1. Valida que 'develop' existe en remoto
├─ 2. Obtiene consecutivo próximo PR + timestamp
├─ 3. Crea rama temporal MANDATORY: pr-{consecutivo}-{timestamp}
├─ 4. Crea PR con template minimalista
└─ 5. Log resultado + mostrar URL
```

## Implementación

```bash
#!/bin/bash
set -euo pipefail

# Cleanup function for failed operations
cleanup() {
    if [[ -n "${new_branch:-}" ]] && git show-ref --verify --quiet "refs/heads/$new_branch" 2>/dev/null; then
        echo "🧹 Cleaning up failed branch creation..."
        git checkout - 2>/dev/null || true
        git branch -D "$new_branch" 2>/dev/null || true
    fi
}
trap cleanup EXIT ERR

# [1] Validación target_branch
target_branch="${1:-}"
[ -z "$target_branch" ] && { 
    echo "❌ Error: Target branch requerida"
    echo "Uso: /pr <target_branch>" 
    exit 1 
}

# Input sanitization
[[ ! "$target_branch" =~ ^[a-zA-Z0-9/_.-]+$ ]] && {
    echo "❌ Error: Branch name contiene caracteres inválidos"
    exit 1
}

# Verificar target existe en remoto
if ! git fetch origin 2>/dev/null; then
    echo "❌ Error conectando a remoto"
    exit 1
fi

if ! git show-ref --verify --quiet "refs/remotes/origin/$target_branch"; then
    echo "❌ Target '$target_branch' no existe en remoto"
    exit 1
fi

# [2] CORRECCIÓN CRÍTICA: Obtener máximo número PR histórico
if ! next_pr_raw=$(gh pr list --state all --json number --jq 'if length == 0 then 0 else map(.number) | max end' 2>/dev/null); then
    echo "❌ Error obteniendo información de PRs"
    exit 1
fi

[[ "$next_pr_raw" =~ ^[0-9]+$ ]] || {
    echo "❌ Número de PR inválido obtenido: '$next_pr_raw'"
    exit 1
}

readonly next_pr=$((next_pr_raw + 1))
readonly timestamp=$(date +%H%M%S)
readonly new_branch="pr-${next_pr}-${timestamp}"

echo "🔄 Próximo PR será #$next_pr, creando rama: $new_branch"

# [3] CORRECCIÓN: Validar variables antes de uso
[[ -z "$new_branch" ]] && {
    echo "❌ Variable new_branch está vacía"
    exit 1
}

# Crear rama temporal MANDATORY
echo "🚀 Creando rama: $new_branch"
if ! git checkout -b "$new_branch"; then
    echo "❌ Error creando rama local"
    exit 1
fi

if ! git push origin "$new_branch" --set-upstream; then
    echo "❌ Error enviando rama al remoto"
    exit 1
fi

# [4] Crear PR con template minimalista (mejorado)
first_commit=$(git log -1 --pretty=format:"%s" | head -c 100 | tr -d '\n\r' | sed 's/[^a-zA-Z0-9 .,!?:()-]/_/g')
pr_body_file=$(mktemp)
trap "rm -f $pr_body_file" EXIT

cat > "$pr_body_file" << 'EOF'
## Summary
Brief description of changes.

## Changes
- List key changes here

## Testing
- [ ] Tested locally
- [ ] All tests passing
EOF

if ! pr_url=$(gh pr create --base "$target_branch" --title "$first_commit" --body-file "$pr_body_file"); then
    echo "❌ Error creando PR"
    exit 1
fi

# [5] Output consistente
echo "🌐 $pr_url"
echo "✅ PR creado: $new_branch → $target_branch"

# Disable cleanup on success
trap - EXIT ERR
```