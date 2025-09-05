---
allowed-tools: Bash(git *), Bash(gh *), Read, Glob, Grep, Task
description: Crea PR automáticamente desde rama actual hacia target branch
---

# Pull Request

Crea PR automáticamente usando branch actual hacia el target branch especificado.

## Uso
```bash
/pr <target_branch>  # Argumento obligatorio
```

## Ejemplos
```bash
/pr develop     # Crea PR hacia develop
/pr main        # Crea PR hacia main  
/pr qa          # Crea PR hacia qa
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación del target branch
- Si no se proporciona argumento, mostrar error: "❌ Error: Target branch requerido. Uso: /pr <target_branch>"
- Ejecutar `git fetch origin` para actualizar referencias remotas
- Verificar que el branch objetivo existe en remoto con `git branch -r | grep origin/<target_branch>`
- Si no existe, mostrar error y terminar

### 2. Security Review (BLOCKING)
- Ejecutar `/agent:security-reviewer` para analizar cambios en branch actual
- **Timeout**: 80 segundos máximo con timeout handling
- **Blocking conditions**: 
  - HIGH severity findings (confidence >= 8.0): ALWAYS block PR creation
  - MEDIUM severity findings (confidence >= 8.0): Block in production (configurable)
- **Success case**: Sin vulnerabilidades críticas encontradas → continuar flujo
- **Failure cases**:
  - Security findings found: Mostrar detailed findings + block PR creation + exit error
  - Timeout: Show warning + create PR with SECURITY_REVIEW_TIMEOUT flag  
  - System error: Block PR creation + show retry instructions
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/security.jsonl`
- Solo proceder a step 3 si security review pasa o timeout occurs

### 3. Validar PR existente en rama actual
- Ejecutar `gh pr view --json number,state,title,url 2>/dev/null` para detectar PR asociado a rama actual
- Si el comando devuelve datos JSON válidos y `state: "open"`:
  - Mostrar: "⚠️  Esta rama ya tiene un PR abierto (#{number}): {title}"
  - Mostrar: "¿Quieres actualizar el PR existente o crear uno nuevo?"
  - Mostrar: "[1] Actualizar PR #{number} [ENTER]"
  - Mostrar: "[2] Crear nuevo PR"
  - Leer input del usuario (default: "1" si presiona ENTER)
  - Si elige "1": 
    - Ejecutar `git push origin HEAD` para actualizar PR
    - **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl`
    - Mostrar: "✅ PR actualizado: {url}"
    - Terminar ejecución exitosa
  - Si elige "2": continuar con paso 4 (flujo normal)
- Si no existe PR o está cerrado: continuar con paso 4 (flujo normal)

### 4. Analizar commits y generar variables
- Obtener datos de commits (optimizado): `git_data=$(git log --pretty=format:"%h %s" "origin/$target_branch..HEAD")`
- Extraer commits formateados: `commits=$(echo "$git_data")`
- Extraer solo mensajes: `messages=$(echo "$git_data" | cut -d' ' -f2-)`
- Contar commits: `commit_count=$(echo "$git_data" | wc -l)`
- Detectar tipo principal de cambios: `primary_type` (feat/fix/docs/refactor/style/test/chore)
- Analizar palabras clave: identificar sustantivos y verbos relevantes (ignorar: add, fix, update, implement)
- Detectar tema central: palabra/concepto más frecuente o significativo → `tema_central`
- Generar timestamp con formato HHMMSS para unicidad → `timestamp`
- Construir nombre descriptivo: 
  - Si tema claro: `branch_name="${tema_central}-${timestamp}"`
  - Si no tema claro: `branch_name="${primary_type}-improvements-${timestamp}"`
- **Validar branch name**: `[[ "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "❌ Error: Branch name inválido"; exit 1; }`

### 5. Crear rama temporal
- Ejecutar `git checkout -b "$branch_name"`
- Ejecutar `git push origin "$branch_name" --set-upstream`
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl`
- Si algún comando falla, mostrar error y terminar

### 6. Preparar contenido del PR
- Analizar tema común: identificar el propósito unificado de todos los commits usando variables ya extraídas
- Generar título descriptivo → `pr_title`:
  - Si todos los commits tienen tema común: usar ese tema como título
  - Si commits diversos: crear título que unifique el propósito (ej: "Improve agent system and fix PR workflow")
  - Mantener formato convencional: `{type}({scope}): {description}` cuando aplique
- Usar commit_count ya calculado en paso 4
- Calcular impacto: `files_changed=$(git diff --name-only "origin/$target_branch..HEAD" | wc -l)`
- Contar líneas: `additions` y `deletions` usando `git diff --numstat`
- Identificar áreas afectadas: `scope_areas` (directorios del proyecto)
- Detectar breaking changes: buscar keywords BREAKING/deprecated/removed en commits
- Generar summary basado en el tema unificado y `primary_type`
- Generar test plan apropiado para el tipo de cambio
- Construir body del PR → `pr_body`:
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

### 7. Crear el PR
- Usar comando CLI `gh pr create` con:
  - `--title "$pr_title"` (título descriptivo generado)
  - `--body "$pr_body"` (contenido preparado)
  - `--base "$target_branch"` (rama objetivo)
  - Comando completo: `gh pr create --title "$pr_title" --body "$pr_body" --base "$target_branch"`
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl`
- Capturar URL del PR creado del output del comando

### 8. Mostrar resultado
- Mostrar URL del PR creado
- Confirmar: "✅ PR creado: $branch_name → $target_branch"
- Mostrar título del PR para validación

## 📊 Logging Format Templates

Para cada operación exitosa, agregar una línea al archivo JSONL correspondiente:

### Security Review Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"security_review","status":"pass|fail|timeout"}
```

### PR Operations Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"pr_create|pr_update|branch_create","status":"success|failed"}
```

**IMPORTANTE**: 
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro
- Ejecutar `mkdir -p .claude/logs/$(date +%Y-%m-%d)` para crear estructura de directorios antes de escribir logs

