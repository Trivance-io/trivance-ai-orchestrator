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
- Obtener título del último commit con `git log -1 --pretty=format:"%s"`
- Extraer tipo de commit del título (feat/fix/refactor/docs/style/test/chore/merge)
- Si no hay tipo explícito, usar "update" como default
- Generar slug descriptivo: primeras 2-3 palabras significativas, máximo 15 chars, lowercase, guiones
- Generar timestamp con formato HHMMSS
- Construir nombre de rama: `{tipo}-{slug}-{timestamp}`

### 5. Crear rama temporal
- Ejecutar `git checkout -b {tipo}-{slug}-{timestamp}`
- Ejecutar `git push origin {tipo}-{slug}-{timestamp} --set-upstream`
- **Log operación**: Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/pr_operations.jsonl` 
- Si algún comando falla, mostrar error y terminar

### 6. Preparar contenido del PR
- Obtener título del último commit con `git log -1 --pretty=format:"%s"`
- Obtener lista de commits con `git log --oneline origin/{target_branch}..HEAD`  
- Analizar commits para detectar breaking changes (keywords: BREAKING, breaking, deprecated, removed)
- Construir body del PR con template industry-standard:
  ```
  ## What Changed
  - [resumir cambios principales de commits, máximo 3 puntos descriptivos]
  
  ## Test Plan
  - [ ] Command executes without errors
  - [ ] Feature works as expected
  - [ ] No breaking changes
  
  ## Breaking Changes
  [None | Descripción específica si se detectaron]
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
- Confirmar: "✅ PR creado: {tipo}-{slug}-{timestamp} → {target}"

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

