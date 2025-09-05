---
allowed-tools: Bash(git *), Bash(gh *), mcp__github__*, Read, Glob, Grep, Task
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

### 4. Generar nombre de rama semántico
- Obtener todos los commits del PR: `commits=$(git log --oneline "origin/$target_branch..HEAD")`
- Analizar tipos de commits: extraer tipos (feat/fix/docs/refactor/style/test/chore) de todos los commits
- Determinar tipo principal: el tipo más frecuente en el conjunto de commits
- Si no hay tipos explícitos, usar "update" como default
- Generar descriptor: basado en el tipo principal + contador de commits (ej: "feat-5commits", "fix-3commits")
- Generar timestamp con formato HHMMSS  
- Construir nombre de rama: `{tipo_principal}-{descriptor}-{timestamp}`

### 5. Crear rama temporal  
- Ejecutar `git checkout -b {tipo_principal}-{descriptor}-{timestamp}`
- Ejecutar `git push origin {tipo_principal}-{descriptor}-{timestamp} --set-upstream`
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl` 
- Si algún comando falla, mostrar error y terminar

### 6. Preparar contenido del PR
- Capturar datos del cambio: `title=$(git log -1 --pretty=format:"%s")`
- Obtener commits: `commits=$(git log --oneline "origin/$target_branch..HEAD")`
- Contar commits: `commit_count=$(git rev-list --count "origin/$target_branch..HEAD")`
- Calcular impacto: `files_changed=$(git diff --name-only "origin/$target_branch..HEAD" | wc -l)`
- Contar líneas: `additions` y `deletions` usando `git diff --numstat`
- Detectar tipo principal de cambios: `primary_type` (feat/fix/docs/refactor/style/test/chore)
- Identificar áreas afectadas: `scope_areas` (directorios del proyecto)
- Detectar breaking changes: buscar keywords BREAKING/deprecated/removed en commits
- Generar summary basado en tipo de cambio
- Generar test plan apropiado para el tipo de cambio
- Construir body del PR con template dinámico:
  ```
  ## Summary
  [Generated based on primary_type and files_changed]
  
  ## Changes Made ([commit_count] commits)
  [List of all commits with hash + message]
  
  ## Files & Impact
  - **Files modified**: [files_changed]
  - **Lines**: +[additions] -[deletions]
  - **Areas affected**: [scope_areas]
  
  ## Test Plan
  [Dynamic test plan based on change type]
  
  ## Breaking Changes
  [Auto-detected breaking commits or "None"]
  ```

### 7. Crear el PR
- Usar herramienta MCP GitHub create_pull_request con:
  - base: target_branch
  - head: nueva rama creada
  - title: mensaje del último commit
  - body: contenido preparado
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl`

### 8. Mostrar resultado
- Mostrar URL del PR creado
- Confirmar: "✅ PR creado: {tipo_principal}-{descriptor}-{timestamp} → {target_branch}"

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

