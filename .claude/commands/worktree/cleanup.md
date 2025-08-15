---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash([[ ]])
description: Eliminación segura de worktrees específicos con validación de ownership
---

# Worktree Cleanup

Eliminación segura de worktrees específicos con validación de ownership.

## Uso
```bash
/worktree:cleanup <worktree1> [worktree2] [worktree3] [...]  # Argumentos obligatorios
```

## Ejemplos
```bash
/worktree:cleanup worktree-feature-auth                      # Eliminar uno específico
/worktree:cleanup worktree-hotfix worktree-refactor         # Eliminar múltiples
/worktree:cleanup worktree-feature-payment worktree-bug-fix # Cleanup batch
```

## Restricciones
- Solo elimina worktrees y ramas creados por ti
- Nunca toca ramas protegidas (main, develop, qa, staging, master)
- Requiere estado limpio (sin cambios uncommitted o unpushed)

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de argumentos
- Si no hay argumentos: error y terminar
- Crear array `target_worktrees` con argumentos
- Validar nombres seguros: `[[ "$worktree" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]`
- Si nombre inválido: error y terminar
- Mostrar targets solicitados

### 2. Verificar ramas protegidas
- Array: `protected_branches=("main" "develop" "qa" "staging" "master")`
- Para cada target: verificar que NO está protegida
- Si protegida: error y terminar

### 3. Validaciones de ownership (CRÍTICO)
Para cada worktree en `target_worktrees`:

**3a. Verificar existencia y ownership:**
- Obtener path: `worktree_path=$(git worktree list --porcelain | grep -A1 "worktree.*$worktree$" | tail -1)`
- Si no existe: agregar a `nonexistent_targets`
- Verificar ownership real: `path_owner=$(stat -c %U "$worktree_path" 2>/dev/null)`
- Si `$path_owner != $(whoami)`: agregar a `unauthorized_targets`

**3b. Validar ownership de rama:**
- Si rama remota existe: `git ls-remote origin "refs/heads/$worktree" >/dev/null 2>&1`
- Obtener commit SHA: `branch_sha=$(git rev-parse "origin/$worktree" 2>/dev/null)`
- Verificar autor principal: `git log --format='%ae' "$branch_sha" | head -1`
- Si autor != `$(git config user.email)`: agregar a `unauthorized_branches`

**3c. Terminar si hay errores de ownership:**
- Si `unauthorized_targets` o `unauthorized_branches` no vacíos: mostrar errores y terminar

### 4. Validaciones de seguridad
Para cada worktree válido y autorizado:

**4a. Verificar estado limpio:**
- Cambios uncommitted: `(cd "$worktree_path" && git status --porcelain 2>/dev/null)`
- Commits unpushed: `git rev-list --count "origin/$worktree".."$worktree" 2>/dev/null`
- Si hay cambios dirty o unpushed: agregar a arrays correspondientes

**4b. Terminar si no está limpio:**
- Si `dirty_targets` o `unpushed_targets` no vacíos: mostrar errores y terminar

### 5. Confirmación del usuario
- Crear lista final `cleanup_targets` solo con worktrees válidos, autorizados y limpios
- Si `cleanup_targets` está vacío:
  - Mostrar: "ℹ️ No hay worktrees válidos para eliminar"
  - TERMINAR exitosamente
- Mostrar resumen de targets válidos
- Solicitar confirmación: "Escribir 'ELIMINAR' para confirmar:"
- Leer respuesta: `read -r confirmation`
- Si `$confirmation != "ELIMINAR"`: cancelar y terminar

### 6. Cleanup triple y logging
Para cada target en `cleanup_targets`:

**6a. Eliminar worktree:**
- `git worktree remove "$target" 2>/dev/null`
- Si falla: reportar error, continuar con siguiente

**6b. Eliminar rama local:**
- `git branch -D "$target" 2>/dev/null`

**6c. Eliminar rama remota (si existe y es del usuario):**
- Verificar existencia: `git ls-remote origin "refs/heads/$target"`
- Si existe: `git push origin --delete "$target" 2>/dev/null`

**6d. Logging y limpieza:**
- Log JSONL de operación
- `git remote prune origin`
- Reporte final de resultados

## 📊 Logging Format Template

Para cada target procesado, agregar línea al archivo JSONL:

### Cleanup Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_cleanup","target":"$target","user":"$(whoami)","my_email":"$(git config user.email)","worktree_removed":"$worktree_removed","local_removed":"$local_removed","remote_removed":"$remote_removed","commit_sha":"$(git rev-parse HEAD)"}
```

**PRINCIPIOS**:
- Solo eliminar elementos propios del usuario
- Nunca tocar ramas protegidas
- Siempre requerir confirmación y estado limpio