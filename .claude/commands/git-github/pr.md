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
- Validar formato del target branch:
  ```bash
  if [[ ! "$target_branch" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
      echo "❌ Error: Nombre de target branch inválido"
      exit 1
  fi
  ```
- Ejecutar `git fetch origin`
- Capturar rama actual: `current_branch=\`git branch --show-current\``
- Verificar que el branch objetivo existe: `git branch -r | grep origin/<target_branch>`
- Si no existe, mostrar error y terminar
- Validar que rama actual no sea igual al target:
  ```bash
  if [[ "$current_branch" == "$target_branch" ]]; then
      # Excepción: permitir si es rama protegida (se creará feature branch automáticamente)
      PROTECTED_BRANCHES="^(main|master|develop|dev|staging|production|prod|qa|release/.+|hotfix/.+)$"
      if [[ "$current_branch" =~ $PROTECTED_BRANCHES ]]; then
          echo "⚠️ Rama protegida detectada: $current_branch (igual a target: $target_branch)"
          echo "📍 Se creará una feature branch automáticamente en el siguiente paso..."
      else
          echo "❌ Error: No puedes crear un PR de una rama hacia sí misma"
          echo "   (current: $current_branch, target: $target_branch)"
          exit 1
      fi
  fi
  ```
- Verificar divergencia:
  ```bash
  commits_behind=\`git rev-list --count HEAD..origin/$target_branch 2>/dev/null || echo "0"\`
  if [[ "$commits_behind" -gt 0 ]]; then
      echo "⚠️  Tu rama está $commits_behind commits atrás de origin/$target_branch"
      echo "   GitHub puede detectar conflictos al intentar mergear"
  fi
  ```

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
  git_data=\`git log --pretty=format:'%h %s' "origin/$target_branch..HEAD"\`;
  files_data=\`git diff --numstat "origin/$target_branch..HEAD"\`;
  commit_count=\`git rev-list --count "origin/$target_branch..HEAD"\`;
  git diff --name-only "origin/$target_branch..HEAD" > /tmp/pr_files.txt;
  files_changed=\`wc -l < /tmp/pr_files.txt | tr -d ' '\`
  ```
- Variables preparadas para uso posterior
- Validar que hay commits nuevos:
  ```bash
  if [[ "$commit_count" -eq 0 ]]; then
      echo "❌ Error: No hay commits nuevos entre origin/$target_branch y HEAD"
      exit 1
  fi
  ```

**Sincronización**

- Esperar a que el Task `security-reviewer` termine (máximo 80s)
- Capturar resultado del security review: `security_result`
- Evaluar resultado:

  ```bash
  # Si security_result contiene HIGH severity findings con confidence >= 0.80:
  # Regex simplificado: severity HIGH + confidence 0.8-1.0
  if [[ "$security_result" =~ [Ss]everity.*:.*HIGH ]] && \
     [[ "$security_result" =~ [Cc]onfidence.*:.*(0\.[89]|1\.0) ]]; then
      echo "❌ Security Review BLOQUEÓ el PR: vulnerabilidades críticas encontradas"
      echo "$security_result"
      exit 1
  fi

  # Si timeout (80s excedidos):
  if [[ "$security_timeout" == "true" ]]; then
      echo "⚠️ Security Review timeout - creando PR con flag SECURITY_REVIEW_TIMEOUT"
      security_flag="SECURITY_REVIEW_TIMEOUT"
  fi

  # Si error del sistema (Task falló):
  if [[ "$security_error" == "true" ]]; then
      echo "❌ Security Review falló - reintenta: /pr $target_branch"
      exit 1
  fi
  ```

- Solo proceder si security review pasa (sin HIGH findings) o timeout occurs

### 3. Procesar PR existente

- Usar datos del paso 2 para evaluar PR existente
- Si existe PR abierto (`state: "open"`):
  - Mostrar: "⚠️ Esta rama ya tiene un PR abierto (#{number}): {title}"
  - "[1] Actualizar PR #{number} [ENTER]"
  - "[2] Crear nuevo PR"
  - Si elige "1": Ejecutar `git push origin HEAD` + mostrar "✅ PR actualizado: {url}" + terminar
  - Si elige "2": continuar con paso 4
- Si no existe PR o está cerrado: continuar con paso 4

### 4. Detectar tipo de rama y decidir acción

- Definir ramas protegidas: `PROTECTED_BRANCHES="^(main|master|develop|dev|staging|production|prod|qa|release/.+|hotfix/.+)$"`
- Evaluar tipo de rama usando `current_branch` del paso 1: `[[ "$current_branch" =~ $PROTECTED_BRANCHES ]]`

**SI es rama protegida (main, master, develop, etc.):**

- Mostrar: "⚠️ Rama protegida detectada: $current_branch"
- Mostrar: "📍 Creando nueva feature branch para el PR..."
- Usar datos del paso 2: `git_data`, `files_data`, `commit_count`, `files_changed`
- Validar que git_data tiene contenido:
  ```bash
  if [[ -z "$git_data" ]]; then
      echo "❌ Error: No hay commits para analizar entre origin/$target_branch y HEAD"
      exit 1
  fi
  ```
- Extraer mensajes a archivo temporal:
  ```bash
  echo "$git_data" | sed 's/^[^ ]* //' > /tmp/pr_messages.txt
  ```
- Detectar tipo principal usando conventional commits:
  ```bash
  # Extraer tipos de commits convencionales (feat, fix, docs, etc.)
  cat /tmp/pr_messages.txt | grep -Eo '^(feat|fix|docs|refactor|style|test|chore)' > /tmp/pr_types.txt;
  cat /tmp/pr_types.txt | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > /tmp/primary.txt;
  primary_type=\`cat /tmp/primary.txt\`;
  # Si no se detectó tipo: usar 'feat' por defecto
  [[ -z "$primary_type" ]] && primary_type="feat"
  ```
- Detectar tema central: extraer scope de conventional commits o palabra más frecuente
  ```bash
  # Intentar extraer scope de commits: feat(auth), fix(api), etc.
  cat /tmp/pr_messages.txt | sed -n 's/^[a-z]*(\([^)]*\)).*/\1/p' > /tmp/pr_scopes.txt;
  cat /tmp/pr_scopes.txt | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > /tmp/tema.txt;
  tema_central=\`cat /tmp/tema.txt\`;
  # Si no hay scope, analizar palabras frecuentes (excluir stopwords)
  if [[ -z "$tema_central" ]]; then
      cat /tmp/pr_messages.txt | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '\n' | grep -vE '^(add|fix|update|implement|the|and|or|for|to|in|of|with)$' > /tmp/pr_words.txt;
      cat /tmp/pr_words.txt | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > /tmp/tema.txt;
      tema_central=\`cat /tmp/tema.txt\`
  fi
  ```
- Generar timestamp UTC en formato branch-safe:
  ```bash
  # Formato: YYYYMMDD-HHMMSS (branch-safe, NO es ISO 8601 estándar)
  # ISO 8601 real usa YYYY-MM-DDTHH:MM:SSZ pero los colons no son válidos en branch names
  timestamp=\`date -u +"%Y%m%d-%H%M%S"\`
  ```
- Construir nombre:
  - Si tema claro: `branch_name="${tema_central}-${timestamp}"`
  - Si no tema claro: `branch_name="${primary_type}-improvements-${timestamp}"`
- Validar: `[[ "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "❌ Error: Branch name inválido"; exit 1; }`
- Crear nueva rama con validación y rollback:

  ```bash
  # Guardar rama actual para rollback
  original_branch="$current_branch"

  # Intentar crear nueva rama
  if ! git checkout -b "$branch_name"; then
      echo "❌ Error: No se pudo crear la rama $branch_name"
      exit 1
  fi

  # Intentar push con rollback en caso de fallo
  if ! git push origin "$branch_name" --set-upstream; then
      echo "❌ Error: No se pudo hacer push de la rama $branch_name"
      echo "🔄 Rollback: volviendo a $original_branch"
      git checkout "$original_branch"
      git branch -d "$branch_name" 2>/dev/null
      exit 1
  fi
  ```

**SI NO es rama protegida (feature branch):**

- Mostrar: "📍 Feature branch detectada: $current_branch"
- Mostrar: "✅ Usando rama actual para el PR"
- Asignar: `branch_name="$current_branch"`
- Push a remoto:
  ```bash
  if ! git config "branch.$current_branch.remote" > /dev/null 2>&1; then
      git push origin "$current_branch" --set-upstream
  else
      git push origin "$current_branch"
  fi
  ```

### 5. Preparar contenido del PR

- Generar título:
  - Si commits tienen tema común: usar ese tema
  - Si commits diversos: crear título que unifique el propósito
  - Mantener formato convencional: `{type}({scope}): {description}` cuando aplique
- Usar datos del paso 2: `commit_count`, `files_changed`
- Contar líneas: `echo "$files_data" | awk '{adds+=$1; dels+=$2} END {print adds, dels}'`
- Identificar áreas afectadas: `scope_areas` (directorios del proyecto)
- Detectar breaking changes: buscar keywords BREAKING/deprecated/removed en commits
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

### 6. Crear PR

- Ejecutar: `gh pr create --title "$pr_title" --body "$pr_body" --base "$target_branch"`
- Capturar URL del PR del output

### 7. Mostrar resultado

- Mostrar URL del PR creado
- Confirmar: "✅ PR creado: $branch_name → $target_branch"
- Mostrar título del PR

## Logging

Para cada operación, agregar línea al archivo JSONL:

```bash
mkdir -p .claude/logs/\`date +%Y-%m-%d\`

# Security review
echo '{"timestamp":"'\`date -Iseconds\`'","operation":"security_review","status":"pass|fail|timeout"}' >> .claude/logs/\`date +%Y-%m-%d\`/security.jsonl

# PR operations
echo '{"timestamp":"'\`date -Iseconds\`'","operation":"pr_create|pr_update|branch_create","status":"success|failed"}' >> .claude/logs/\`date +%Y-%m-%d\`/pr_operations.jsonl
```

## Notas

- No solicitar confirmación al usuario
- Ejecutar pasos secuencialmente
- Si algún paso falla, detener y mostrar error claro
