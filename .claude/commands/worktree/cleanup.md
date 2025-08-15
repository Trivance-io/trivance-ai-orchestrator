---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash(read *), Bash([[ ]])
description: Eliminación segura de worktrees y ramas temporales post-merge
---

# Worktree Cleanup

Eliminación segura de worktrees y ramas temporales siguiendo filosofía de trabajo temporal.

## Uso
```bash
/worktree:cleanup <target>         # Cleanup específico
/worktree:cleanup --auto           # Cleanup automático (todos worktree-*)
/worktree:cleanup <target> --force # Sin confirmación
```

## Ejemplos
```bash
/worktree:cleanup worktree-feature-auth    # Eliminar worktree específico
/worktree:cleanup --auto                   # Limpiar todos los temporales
/worktree:cleanup worktree-hotfix --force  # Eliminar sin confirmar
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación y parsing de argumentos
- Contar argumentos en `$ARGUMENTS` usando expansión de array
- Si no hay argumentos, mostrar error: "❌ Error: Se requiere al menos 1 argumento. Uso: /worktree:cleanup <target|--auto> [--force]"
- Detectar modo de operación:
  - Si primer argumento es `--auto`: `mode="auto"`
  - Si contiene `--force`: `force_mode=true`
  - Sino: `mode="specific"` y `target_name=primer_argumento`
- Mostrar: "Cleanup mode: $mode" y si aplica "Target: $target_name"

### 2. Definir ramas protegidas
- Crear array de ramas oficiales: `protected_branches=("main" "develop" "qa" "staging" "master")`
- Mostrar: "Protected branches: ${protected_branches[*]}"

### 3. Identificar targets para cleanup
**Modo específico:**
- Validar nombre seguro: `[[ "$target_name" =~ ^[a-zA-Z0-9/_-]+$ ]]`
- Si nombre inválido, mostrar error: "❌ Error: Invalid target name. Use only alphanumeric, /, _, - characters" y terminar
- Verificar que `$target_name` NO está en `protected_branches`
- Si está protegida: mostrar error "❌ Error: Cannot cleanup protected branch $target_name" y terminar
- Crear lista: `cleanup_targets=("$target_name")`

**Modo automático:**
- Ejecutar `git worktree list --porcelain | grep worktree | awk '{print $1}' | xargs -I {} basename {}`
- Filtrar solo los que empiecen con "worktree-"
- Crear array `cleanup_targets` con resultados filtrados
- Si array vacío: mostrar "ℹ️ No worktree-* temporales encontrados" y terminar exitosamente

Mostrar: "Targets identified: ${#cleanup_targets[@]} worktrees/branches"

### 4. Validar estado de cada target
Para cada target en `cleanup_targets`:
- **Verificar worktree existe:** `git worktree list | grep "$target"`
- **Si worktree existe:**
  - Obtener path: `worktree_path=$(git worktree list --porcelain | grep -A1 "worktree.*$target" | tail -1)`
  - Si path válido, ejecutar `(cd "$worktree_path" && git status --porcelain)`
  - Si hay cambios sin commitear: agregar a `dirty_targets` array
  - Ejecutar `git log --format='%H' "origin/$target"..HEAD 2>/dev/null | wc -l`
  - Si hay commits sin pushear: agregar a `unpushed_targets` array
- **Verificar rama local:** `git show-ref --verify --quiet refs/heads/$target`
- **Verificar rama remota:** `git show-ref --verify --quiet refs/remotes/origin/$target`

### 5. Validaciones de seguridad
- Si `dirty_targets` no está vacío:
  - Mostrar error: "❌ Error: Los siguientes targets tienen cambios sin commitear:"
  - Listar cada target en `dirty_targets`
  - Mostrar: "Commitea o stash cambios antes de cleanup"
  - TERMINAR proceso completamente
- Si `unpushed_targets` no está vacío y `force_mode=false`:
  - Mostrar warning: "⚠️ Los siguientes targets tienen commits sin pushear:"
  - Listar cada target en `unpushed_targets`
  - Mostrar: "Usa --force para proceder o pushea cambios primero"
  - TERMINAR proceso completamente

### 6. Confirmación (si no force mode)
Si `force_mode=false`:
- Mostrar resumen: "Se eliminarán los siguientes targets:"
- Para cada target, mostrar: "  • Worktree: $target"
- Mostrar: "Esta operación es IRREVERSIBLE. ¿Continuar? (y/N):"
- Ejecutar `read -r confirmation`
- Si `$confirmation` no es "y" o "Y": mostrar "Operación cancelada" y terminar
- Si confirmado, mostrar: "✓ Confirmación recibida, procediendo..."

### 7. Ejecutar cleanup para cada target
Para cada target en `cleanup_targets`:

**7a. Remover worktree si existe:**
- Si `git worktree list | grep -q "$target"`:
  - Ejecutar `git worktree remove "$target" 2>/dev/null || git worktree remove --force "$target"`
  - Si exitoso: mostrar "✅ Worktree removed: $target"
  - Si falla: mostrar "⚠️ Could not remove worktree: $target"

**7b. Eliminar rama local si existe:**
- Ejecutar `git branch -D "$target" 2>/dev/null`
- Si exitoso: mostrar "✅ Local branch removed: $target"
- Si falla: mostrar "ℹ️ Local branch $target not found"

**7c. Eliminar rama remota si existe:**
- Ejecutar `git push origin --delete "$target" 2>/dev/null`
- Si exitoso: mostrar "✅ Remote branch removed: origin/$target"
- Si falla: mostrar "ℹ️ Remote branch origin/$target not found"

### 8. Limpieza adicional
- Ejecutar `git remote prune origin` para limpiar referencias obsoletas
- Ejecutar `git gc --prune=now` para cleanup del repositorio
- Mostrar: "✅ Repository cleanup completed"

### 9. Logging y resultado final
- **Log operación**: Crear directorio `.claude/logs/$(date +%Y-%m-%d)/` si no existe con `mkdir -p .claude/logs/$(date +%Y-%m-%d)/`
- Para cada target eliminado, agregar entrada JSONL usando el template
- Mostrar resultado final:
  ```
  ✅ Cleanup completed successfully:
  - Mode: $mode
  - Targets processed: ${#cleanup_targets[@]}
  - Worktrees removed: [count]
  - Local branches removed: [count]
  - Remote branches removed: [count]

  Repository is now clean of temporal branches.
  ```

## 📊 Logging Format Template

Para cada target eliminado, agregar línea al archivo JSONL:

### Cleanup Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_cleanup","target":"$target","mode":"$mode","force_mode":"$force_mode","user":"$(whoami)","commit_sha":"$(git rev-parse HEAD)"}
```

**IMPORTANTE**:
- NUNCA eliminar ramas protegidas (main, develop, qa, staging, master)
- NUNCA proceder con cambios uncommitted sin --force
- Solicitar confirmación explícita excepto en --force mode
- Crear directorio de logs antes de escribir
- Cleanup completo: worktree + local + remote + repository gc