---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash([[ ]])
description: Eliminación segura de worktrees específicos con validación de ownership y discovery mode
---

# Worktree Cleanup

Eliminación segura de worktrees específicos con validación de ownership y discovery mode.

## Uso
```bash
/worktree:cleanup                                        # Discovery mode: lista worktrees disponibles
/worktree:cleanup <worktree1> [worktree2] [worktree3]   # Cleanup mode: eliminar específicos
```

## Ejemplos
```bash
/worktree:cleanup                                        # Lista tus worktrees con comandos sugeridos
/worktree:cleanup worktree-feature-auth                 # Eliminar uno específico  
/worktree:cleanup worktree-hotfix worktree-refactor     # Eliminar múltiples
```

## Restricciones
- Solo elimina worktrees y ramas creados por ti
- Nunca toca ramas protegidas (main, develop, qa, staging, master)
- Requiere estado limpio (sin cambios uncommitted o unpushed)

## Ejecución

### Discovery Mode (sin argumentos)
Si no proporcionas argumentos, el comando lista tus worktrees disponibles con comandos sugeridos.

### Cleanup Mode (con argumentos)
Cuando ejecutes con argumentos específicos, sigue estos pasos:

### 1. Validación y preparación
- Validar cada target usando single-pass validation
- Crear lista de targets válidos (skip inválidos con warnings)
- Si no hay targets válidos: mostrar "ℹ️ No hay worktrees válidos para eliminar" y terminar

### 2. Validaciones por target (pasos individuales)
Para cada worktree target, ejecutar validaciones en orden:

**2a. Validación de formato:**
- Verificar nombre usando regex: `[[ "$target" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]`
- Si falla: skip con mensaje "Formato de nombre inválido"

**2b. Validación de rama protegida:**
- Verificar que no esté en array: `("main" "develop" "qa" "staging" "master")`
- Si está protegida: skip con mensaje "Rama protegida"

**2c. Validación de directorio actual:**
- Ejecutar validación definida en sección 3
- Si coincide con directorio actual: skip con error específico

**2d. Validación de existencia:**
- Verificar que existe como worktree usando `git worktree list --porcelain`
- Si no existe: skip con mensaje "Worktree no encontrado"

**2e. Validación de ownership:**
- Verificar ownership usando lógica cross-platform de sección 4
- Si no es del usuario: skip con mensaje "No es tu worktree"

**2f. Validación de estado limpio:**
- Verificar sin cambios uncommitted: `git status --porcelain` en el worktree
- Verificar sin commits unpushed: `git rev-list --count origin/rama..rama`
- Si no está limpio: skip con mensaje específico del problema

### 3. Validación de directorio actual (SEGURIDAD CRÍTICA)
Para cada worktree target, verificar que el usuario no esté intentando eliminar el worktree donde está parado:
- Obtener canonical path del directorio actual: `current_dir="$(realpath "$(pwd)" 2>/dev/null)"`
- Si falla obtener path actual: mostrar error "❌ Error: No se pudo resolver directorio actual" y terminar
- Obtener path del worktree target usando parsing seguro: `git worktree list --porcelain | awk` con validación estricta
- Si no se encuentra el target: continuar (será manejado por otra validación)
- Obtener canonical path del target: `target_path="$(realpath "$target_path" 2>/dev/null)"`
- Si falla obtener path del target: mostrar error "❌ Error: No se pudo resolver path del worktree target" y skip
- Comparar paths canónicos: si `"$current_dir" == "$target_path"` entonces:
  - Mostrar error: "❌ Error: No puedes eliminar el worktree donde estás actualmente"
  - Mostrar ubicación actual y solución específica
  - Skip este target con warning

### 4. Cross-platform compatibility
Para verificar ownership de archivos, usar detección automática de OS:
- Si `"$OSTYPE"` empieza con "darwin": usar comando `stat -f %Su "$path"`
- Si no (Linux/otros): usar comando `stat -c %U "$path"`
- Comparar resultado con `$(whoami)` para verificar ownership
- Si no coincide: skip este target con warning de ownership

### 5. Confirmación del usuario
- Mostrar resumen de targets válidos
- Solicitar confirmación: "Escribir 'ELIMINAR' para confirmar:"
- Si confirmación != "ELIMINAR": cancelar y terminar

### 6. Cleanup triple atómico
Para cada target confirmado:
- Eliminar worktree: `git worktree remove "$target"`
- Eliminar rama local: `git branch -D "$branch_name"`  
- Eliminar rama remota (si existe): `git push origin --delete "$branch_name"`

### 7. Logging y limpieza final
- Registrar operación en formato JSONL
- Ejecutar `git remote prune origin`
- Mostrar reporte final de resultados

## Implementación del Discovery Mode

Cuando se ejecuta sin argumentos, seguir estos pasos:
- Mostrar: "🔍 Tus worktrees disponibles para eliminar:"
- Obtener canonical path del directorio actual: `current_canonical="$(realpath "$(pwd)" 2>/dev/null)"`
- Si falla obtener path actual: mostrar error y terminar
- Ejecutar `git worktree list --porcelain` y procesar cada línea:
  - Para líneas que empiecen con "worktree": extraer path como `worktree_path`
  - Obtener canonical path del worktree: `worktree_canonical="$(realpath "$worktree_path" 2>/dev/null)"`
  - Si falla obtener canonical path: skip este worktree
  - Si `worktree_canonical` es igual a `current_canonical`: skip (es el directorio actual)
  - Verificar ownership básico usando función cross-platform
  - Si el owner es el usuario actual: mostrar comando sugerido con formato `"   /worktree:cleanup $worktree_name"`

## Logging Format Template

Para cada target procesado, agregar línea al archivo JSONL:

```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_cleanup","target":"$target","user":"$(whoami)","my_email":"$(git config user.email)","worktree_removed":"$worktree_removed","local_removed":"$local_removed","remote_removed":"$remote_removed","commit_sha":"$(git rev-parse HEAD)"}
```

## Principios de Implementación
- **Single-pass validation**: Una función, una pasada, graceful degradation
- **Current-directory protection**: No permite eliminar el worktree donde está parado
- **Cross-platform**: Auto-detección macOS/Linux
- **Discovery-first**: Ayuda al usuario a encontrar worktrees
- **Backward compatibility**: Argumentos existentes funcionan igual
- **Atomic operations**: Cleanup completo o skip con warning