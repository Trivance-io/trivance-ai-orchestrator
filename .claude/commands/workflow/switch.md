---
allowed-tools: Bash(git *)
description: Cambia de rama temporal a rama objetivo y elimina rama temporal
---

# Switch Branch

Cambia de rama temporal a rama objetivo y elimina la rama temporal local.

## Uso
```bash
/switch <target_branch>  # Argumento obligatorio
```

## Ejemplos
```bash
/switch main        # Salir de temporal → ir a main
/switch develop     # Salir de temporal → ir a develop  
/switch feature/123 # Salir de temporal → ir a feature branch
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada
- Si no se proporciona argumento, mostrar error: "❌ Error: Target branch requerido. Uso: /switch <target_branch>"
- Capturar target_branch del argumento
- Mostrar: "Switching from temporal branch to: <target_branch>"

### 2. Validación de cambios pendientes
- Ejecutar: `git status --porcelain` para verificar cambios sin commitear
- Si hay output (cambios pendientes):
  - Mostrar error: "❌ Error: Hay cambios sin commitear. El switch está bloqueado."
  - Mostrar: "Debes resolver los cambios primero:"
  - Mostrar: "  • git add . && git commit -m 'mensaje'  (para guardar cambios)"
  - Mostrar: "  • git stash  (para guardar temporalmente)"
  - Mostrar: "  • git checkout -- .  (para descartar cambios)"
  - TERMINAR proceso completamente
- Si no hay cambios, mostrar: "✓ Working directory clean, proceeding..."

### 3. Captura de rama temporal actual
- Ejecutar: `git branch --show-current` para obtener rama temporal actual
- Capturar nombre de la rama temporal (de donde venimos)
- Mostrar: "Leaving temporal branch: <temporal_branch>"

### 4. Switch a rama objetivo
- Ejecutar: `git checkout "$target_branch"`
- Si el comando falla, mostrar error: "❌ Error: No se pudo cambiar a '$target_branch'" y terminar
- Confirmar: "Switched to: <target_branch>"

### 5. Actualización desde remoto
- Ejecutar: `git pull` para actualizar rama objetivo
- Si pull falla, mostrar warning: "⚠️ No se pudo actualizar desde remoto" pero continuar
- Si pull exitoso, mostrar: "Updated from remote"

### 6. Eliminación de rama temporal
- Ejecutar: `git branch -D "<temporal_branch>"` para eliminar rama temporal local (usando nombre capturado en paso 3)
- Si eliminación exitosa, mostrar: "🗑️ Deleted temporal branch: <temporal_branch>"
- Si falla, mostrar: "⚠️ Could not delete temporal branch: <temporal_branch>"

### 7. Status final
- Verificar branch actual: `git branch --show-current`
- Mostrar estado final:
  ```
  ✅ Switch completed:
  - Current branch: <current_branch>
  - Temporal branch deleted: <temporal_branch>
  ```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso crítico falla, detener ejecución y mostrar error claro
- Comando optimizado para workflow: temporal → objetivo → cleanup