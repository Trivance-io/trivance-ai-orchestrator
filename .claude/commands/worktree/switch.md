---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash([[ ]])
description: Cambio seguro de rama sin pérdida de contexto de trabajo
---

# Worktree Switch

Cambio seguro de rama preservando contexto y trabajo actual.

## Uso
```bash
/worktree:switch <target-branch>  # Rama destino obligatoria
```

## Ejemplos
```bash
/worktree:switch main              # Cambio rápido a main
/worktree:switch develop           # Revisar develop branch  
/worktree:switch feature/hotfix    # Context switching seguro
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de argumentos
- Contar argumentos en `$ARGUMENTS` usando expansión de array
- Si no hay exactamente 1 argumento, mostrar error: "❌ Error: Se requiere 1 argumento. Uso: /worktree:switch <target-branch>"
- Capturar argumento como `target_branch`
- Mostrar: "Switching to branch: $target_branch"

### 2. Validación de working directory
- Ejecutar `git status --porcelain` para verificar cambios pendientes
- Si hay output (cambios sin commitear):
  - Mostrar error: "❌ Error: Working directory no está limpio. Opciones:"
  - Mostrar: "  • Commitear cambios: git add . && git commit -m 'wip: save progress'"
  - Mostrar: "  • Stash temporal: git stash -u"
  - TERMINAR proceso completamente
- Si no hay cambios, mostrar: "✓ Working directory clean, proceeding..."

### 3. Validación de rama destino y nombres seguros
- Validar nombre seguro: `[[ "$target_branch" =~ ^[a-zA-Z0-9/_-]+$ ]]`
- Si nombre inválido, mostrar error: "❌ Error: Invalid branch name. Use only alphanumeric, /, _, - characters" y terminar
- Verificar rama local: `git show-ref --verify --quiet "refs/heads/$target_branch"`
- Verificar rama remota: `git show-ref --verify --quiet "refs/remotes/origin/$target_branch"`
- Si ninguna existe:
  - Mostrar error: "❌ Error: Branch '$target_branch' no existe ni local ni remotamente"
  - Mostrar: "Branches disponibles:"
  - Ejecutar `git branch -a --list | grep -v HEAD`
  - TERMINAR proceso completamente
- Si existe remota, mostrar: "✓ Remote branch found: origin/$target_branch"
- Si existe local, mostrar: "✓ Local branch verified: $target_branch"

### 4. Verificar rama actual
- Ejecutar `git branch --show-current` para obtener rama actual
- Capturar resultado como `current_branch`
- Si `$current_branch` es igual a `$target_branch`:
  - Mostrar: "ℹ️ Already on branch $target_branch"
  - TERMINAR proceso (exitoso, no error)
- Mostrar: "Switching from $current_branch to $target_branch"

### 5. Checkout seguro
- Si rama local existe, ejecutar: `git checkout "$target_branch"`
- Si solo existe remota, ejecutar: `git checkout -b "$target_branch" "origin/$target_branch"`
- Si comando falla, mostrar error: "❌ Error: Failed to checkout $target_branch" y terminar
- Mostrar: "✅ Successfully switched to branch: $target_branch"

### 6. Actualizar desde remoto (opcional)
- Ejecutar `git show-ref --verify --quiet refs/remotes/origin/$target_branch` para verificar rama remota
- Si existe remota:
  - Ejecutar `git fetch origin "$target_branch" && git merge --ff-only "origin/$target_branch"` para actualizar seguro
  - Si exitoso, mostrar: "✅ Branch updated from remote"
  - Si falla, mostrar warning: "⚠️ Could not update from remote, but checkout successful"
- Si no existe remota, mostrar: "ℹ️ No remote branch to sync"

### 7. Logging y resultado final
- **Log operación**: Crear directorio `.claude/logs/$(date +%Y-%m-%d)/` si no existe con `mkdir -p .claude/logs/$(date +%Y-%m-%d)/`
- Agregar entrada JSONL a `.claude/logs/$(date +%Y-%m-%d)/worktree_operations.jsonl` usando el template
- Mostrar estado exitoso:
  ```
  ✅ Branch switch completed:
  - From: $current_branch
  - To: $target_branch
  - Status: Ready for work

  Current branch info:
    git log --oneline -3
  ```

## 📊 Logging Format Template

Para operación exitosa, agregar línea al archivo JSONL:

### Branch Switch Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_switch","from_branch":"$current_branch","to_branch":"$target_branch","user":"$(whoami)","commit_sha":"$(git rev-parse HEAD)"}
```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Priorizar seguridad: NUNCA perder trabajo
- Si hay dudas sobre seguridad, fallar con mensaje claro
- Crear directorio de logs antes de escribir