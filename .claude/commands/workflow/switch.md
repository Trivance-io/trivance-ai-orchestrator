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

### 2. Captura de rama temporal actual
- Ejecutar: `git branch --show-current` para obtener rama temporal actual
- Capturar nombre de la rama temporal (de donde venimos)
- Mostrar: "Leaving temporal branch: <temporal_branch>"

### 3. Switch a rama objetivo
- Ejecutar: `git checkout "$target_branch"`
- Si el comando falla, mostrar error: "❌ Error: No se pudo cambiar a '$target_branch'" y terminar
- Confirmar: "Switched to: <target_branch>"

### 4. Actualización desde remoto
- Ejecutar: `git pull` para actualizar rama objetivo
- Si pull falla, mostrar warning: "⚠️ No se pudo actualizar desde remoto" pero continuar
- Si pull exitoso, mostrar: "Updated from remote"

### 5. Eliminación de rama temporal
- Ejecutar: `git branch -D "<temporal_branch>"` para eliminar rama temporal local (usando nombre capturado en paso 2)
- Si eliminación exitosa, mostrar: "🗑️ Deleted temporal branch: <temporal_branch>"
- Si falla, mostrar: "⚠️ Could not delete temporal branch: <temporal_branch>"

### 6. Status final
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