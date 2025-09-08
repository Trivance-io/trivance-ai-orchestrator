---
allowed-tools: Bash(git *), Bash(gh *), Read, Glob, Grep, Task
description: Crea PR desde rama actual hacia target branch
---

# Pull Request

Crea PR usando branch actual hacia el target branch especificado.

## Uso

```bash
/pr <target_branch>
```

## Ejemplos

```bash
/pr develop
/pr main
/pr qa
```

## Ejecución

### 1. Validación del target branch

- Si no se proporciona argumento, mostrar error: "❌ Error: Target branch requerido. Uso: /pr <target_branch>"
- Ejecutar `git fetch origin`
- Verificar que el branch objetivo existe: `git branch -r | grep origin/<target_branch>`
- Si no existe, mostrar error y terminar

### 2. Operaciones en paralelo

Ejecutar simultáneamente:

**Security Review (BLOCKING)**

- Iniciar `/agent:security-reviewer` para analizar cambios en branch actual
- Timeout: 80 segundos máximo
- Blocking conditions:
  - HIGH severity findings (confidence >= 8.0): ALWAYS block PR creation
  - MEDIUM severity findings (confidence >= 8.0): Block in production (configurable)
- Success: Sin vulnerabilidades críticas → continuar
- Failure: Mostrar findings + block PR creation + exit error
- Timeout: Show warning + create PR with SECURITY_REVIEW_TIMEOUT flag
- System error: Block PR creation + show retry instructions

**Validar PR existente**

- Ejecutar `gh pr view --json number,state,title,url 2>/dev/null`
- Almacenar resultado para paso 3

**Análisis de commits**

- Comandos git combinados:
  ```bash
  git_data=$(git log --pretty=format:"%h %s" "origin/$target_branch..HEAD")
  files_data=$(git diff --name-only --numstat "origin/$target_branch..HEAD")
  commit_count=$(echo "$git_data" | wc -l)
  files_changed=$(echo "$files_data" | wc -l)
  ```
- Variables preparadas para uso posterior

**Sincronización**

- Esperar completion del security review (timeout: 80s)
- Validar resultados antes de continuar
- Solo proceder si security review pasa o timeout occurs

### 3. Procesar PR existente

- Usar datos del paso 2 para evaluar PR existente
- Si existe PR abierto (`state: "open"`):
  - Mostrar: "⚠️ Esta rama ya tiene un PR abierto (#{number}): {title}"
  - "[1] Actualizar PR #{number} [ENTER]"
  - "[2] Crear nuevo PR"
  - Si elige "1": Ejecutar `git push origin HEAD` + mostrar "✅ PR actualizado: {url}" + terminar
  - Si elige "2": continuar con paso 4
- Si no existe PR o está cerrado: continuar con paso 4

### 4. Completar análisis

- Usar datos del paso 2: `git_data`, `files_data`, `commit_count`, `files_changed`
- Extraer commits: `commits=$(echo "$git_data")`
- Extraer mensajes: `messages=$(echo "$git_data" | cut -d' ' -f2-)`
- Detectar tipo principal: `primary_type` (feat/fix/docs/refactor/style/test/chore)
- Analizar palabras clave: identificar sustantivos y verbos relevantes (ignorar: add, fix, update, implement)
- Detectar tema central: palabra/concepto más frecuente → `tema_central`
- Generar timestamp: `timestamp` formato HHMMSS
- Construir nombre:
  - Si tema claro: `branch_name="${tema_central}-${timestamp}"`
  - Si no tema claro: `branch_name="${primary_type}-improvements-${timestamp}"`
- Validar: `[[ "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "❌ Error: Branch name inválido"; exit 1; }`

### 5. Crear rama temporal

- Ejecutar `git checkout -b "$branch_name"`
- Ejecutar `git push origin "$branch_name" --set-upstream`
- Si algún comando falla, mostrar error y terminar

### 6. Preparar contenido del PR

- Analizar tema común de commits usando variables extraídas
- Generar título:
  - Si commits tienen tema común: usar ese tema
  - Si commits diversos: crear título que unifique el propósito
  - Mantener formato convencional: `{type}({scope}): {description}` cuando aplique
- Usar datos del paso 2: `commit_count`, `files_changed`
- Contar líneas: `echo "$files_data" | awk '{adds+=$1; dels+=$2} END {print adds, dels}'`
- Identificar áreas afectadas: `scope_areas` (directorios del proyecto)
- Detectar breaking changes: buscar keywords BREAKING/deprecated/removed en commits
- Generar summary basado en tema unificado y `primary_type`
- Generar test plan apropiado para el tipo de cambio
- Construir body:

  ```bash
  pr_body="## Summary
  [Generated based on $primary_type and $files_changed]

  ## Changes Made ($commit_count commits)
  [List of all commits with hash + message]

  ## Files & Impact
  - **Files modified**: $files_changed
  - **Lines**: +$additions -$deletions
  - **Areas affected**: $scope_areas

  ## Test Plan
  [Dynamic test plan based on $primary_type]

  ## Breaking Changes
  [Auto-detected breaking commits or \"None\"]"
  ```

### 7. Crear PR

- Ejecutar: `gh pr create --title "$pr_title" --body "$pr_body" --base "$target_branch"`
- Capturar URL del PR del output

### 8. Mostrar resultado

- Mostrar URL del PR creado
- Confirmar: "✅ PR creado: $branch_name → $target_branch"
- Mostrar título del PR

## Logging

Para cada operación, agregar línea al archivo JSONL:

```bash
mkdir -p .claude/logs/$(date +%Y-%m-%d)

# Security review
echo '{"timestamp":"'$(date -Iseconds)'","operation":"security_review","status":"pass|fail|timeout"}' >> .claude/logs/$(date +%Y-%m-%d)/security.jsonl

# PR operations
echo '{"timestamp":"'$(date -Iseconds)'","operation":"pr_create|pr_update|branch_create","status":"success|failed"}' >> .claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl
```

## Notas

- No solicitar confirmación al usuario
- Ejecutar pasos secuencialmente
- Si algún paso falla, detener y mostrar error claro
