---
allowed-tools: Bash(git *), Bash(mkdir *), Bash(date *), Bash(echo *)
description: Cambia de rama y limpia ramas temporales automáticamente
---

# Switch Branch

Cambia de rama PR a rama objetivo y limpia ramas temporales automáticamente.

## Uso
```bash
/switch <target_branch>  # Argumento obligatorio
```

## Ejemplos
```bash
/switch main        # Cambiar a main
/switch develop     # Cambiar a develop
/switch feature/123 # Cambiar a feature branch
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada
- Si no se proporciona argumento, mostrar error: "❌ Error: Target branch requerido. Uso: /switch <target_branch>"
- Validar que el argumento no esté vacío y sea un nombre de branch válido
- Usar validación git nativa en lugar de regex custom para mayor robustez
- Si branch contiene caracteres inválidos, git fallará de forma natural
- Capturar target_branch y mostrar: "Switching to branch: <target_branch>"

### 2. Gestión inteligente de branch objetivo
- **Verificar si branch existe localmente**: `git show-ref --verify --quiet "refs/heads/$target_branch"`
- **Si NO existe localmente**:
  - Ejecutar: `git fetch origin --timeout=30s` con manejo de errores
  - Verificar si existe en remoto: `git show-ref --verify --quiet "refs/remotes/origin/$target_branch"`
  - Si existe en remoto: crear y trackear con `git checkout -b "$target_branch" "origin/$target_branch"`
  - Si no existe en ninguna parte: mostrar error "❌ Branch '$target_branch' no existe" y terminar
- **Si existe localmente**: hacer checkout directo con `git checkout "$target_branch"`
- **Manejo de errores**: Si cualquier operación git falla, mostrar mensaje claro y terminar

### 3. Actualización desde remoto
- Verificar si branch tiene tracking remoto: `git show-ref --verify --quiet "refs/remotes/origin/$target_branch"`
- Si existe remoto: ejecutar `git pull origin "$target_branch" --timeout=30s`
- Si pull falla: mostrar warning pero continuar (no es error crítico)
- Mostrar status: "Branch actualizado desde remoto" o "Sin cambios desde remoto"

### 4. Detección automática de ramas temporales
- **SIMPLIFICADO**: Usar un solo patrón temporal optimizado en lugar de 3 regex
- **Patrón unificado**: Detectar branches que contienen timestamps o PR patterns:
  - Contienen secuencias numéricas largas (10+ dígitos) = generados automáticamente
  - Nombres con pattern `pr/` o `pull-` seguidos de números
  - Pattern: `(pr/|pull-|.*-[0-9]{10,})`
- **Protección**: Lista de branches protegidos: ["main", "master", "develop", "staging", "production", target_branch]
- Usar: `git branch --format='%(refname:short)'` para listar todas las branches
- Filtrar candidates excluyendo branches protegidos
- Mostrar: "Detectadas <count> ramas temporales para limpieza"

### 5. Limpieza automática de ramas temporales
- **AI-FIRST**: Eliminar confirmación manual - ejecutar limpieza automáticamente
- Para cada rama temporal detectada:
  - Verificar que no sea la branch actual ni esté protegida
  - Ejecutar: `git branch -D "$branch_name"` con captura de errores
  - Contar exitosas vs fallidas
- **Logging individual**: Por cada rama eliminada, registrar en logs estructurados
- Mostrar progreso: "Eliminando ramas temporales: <count>/<total>"

### 6. Logging estructurado empresarial
- Crear directorio de logs: `mkdir -p .claude/logs/$(date +%Y-%m-%d)`
- Generar timestamp: `date '+%Y-%m-%dT%H:%M:%S'`
- Crear entrada JSONL con:
  - timestamp, target_branch, branches_detected, branches_deleted, status
  - errores si los hay, tiempo de ejecución, estado final del workspace
- Append a archivo: `.claude/logs/<fecha>/workflow_activity.jsonl`

### 7. Status final y validación
- Verificar branch actual: `git branch --show-current`
- Mostrar estado del working directory: `git status --porcelain | wc -l`
- Si hay cambios sin commit, mostrar: `git status --short`
- **Reporte final**:
  ```
  ✅ Switch completado:
  - Branch actual: <current_branch>
  - Ramas limpiadas: <deleted_count>
  - Cambios pendientes: <uncommitted_count>
  - Log: <log_path>
  ```

## 📊 Logging Format Template

```json
{"timestamp":"<ISO_timestamp>","target_branch":"<branch_name>","branches_detected":<count>,"branches_deleted":<count>,"uncommitted_changes":<count>,"execution_time_ms":<ms>,"status":"success|error","error_message":"<if_any>"}
```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro
- Crear directorio .claude/logs/$(date +%Y-%m-%d)/ si no existe antes de escribir logs
- Manejar gracefully casos donde no hay ramas temporales para limpiar