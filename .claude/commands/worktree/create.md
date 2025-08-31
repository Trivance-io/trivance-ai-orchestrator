---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash(tr *), Bash(sed *)
description: Crea worktree con rama consistente en directorio sibling
---

# Worktree Create

Crea worktree desde parent branch especificado con naming consistente.

## Uso
```bash
/worktree:create "<objetivo-descripción>" <parent-branch>  # Ambos argumentos obligatorios
```

## Ejemplos
```bash
/worktree:create "implementar autenticacion OAuth" main        # → worktree-implementar-autenticacion-oauth
/worktree:create "fix bug critico en pagos" develop            # → worktree-fix-bug-critico-en-pagos
/worktree:create "refactor dashboard usuarios" main            # → worktree-refactor-dashboard-usuarios
/worktree:create "add API endpoints v2" qa                     # → worktree-add-api-endpoints-v2
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de argumentos
- Contar argumentos en `$ARGUMENTS` usando expansión de array
- Si no hay exactamente 2 argumentos, mostrar error: "❌ Error: Se requieren 2 argumentos. Uso: /worktree:create \"<objetivo>\" <parent-branch>"
- Capturar primer argumento como `objetivo_descripcion` y segundo como `parent_branch`
- Mostrar: "Creando worktree para: <objetivo_descripcion> desde rama padre: <parent_branch>"

### 2. Validación de working directory
- Ejecutar `status_output=$(git status --porcelain)` para capturar cambios pendientes
- Si hay output (cambios sin commitear):
  - Mostrar error: "❌ Error: Working directory no está limpio. Commitea o stash cambios primero"
  - Mostrar contenido: `echo "$status_output"`
  - TERMINAR proceso completamente
- Si no hay cambios, mostrar: "✓ Working directory clean, proceeding..."

### 3. Validación de parent branch
- Ejecutar `git show-ref --verify --quiet refs/heads/$parent_branch` para verificar que existe localmente
- Si el comando falla (exit code != 0):
  - Mostrar error: "❌ Error: Branch '$parent_branch' no existe localmente"
  - Mostrar: "Branches disponibles:"
  - Ejecutar `git branch --list`
  - TERMINAR proceso completamente
- Si existe, mostrar: "✓ Parent branch '$parent_branch' verified"

### 4. Generar nombres consistentes
- Convertir `objetivo_descripcion` a slug válido usando transformación optimizada:
  - Ejecutar `echo "$objetivo_descripcion" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-\|-$//g'`
  - Capturar resultado como `objetivo_slug`
- Construir `worktree_name` como: "worktree-$objetivo_slug"
- Construir `branch_name` idéntico a `worktree_name`
- Construir `worktree_path` como: "../$worktree_name"
- Mostrar: "Generated names from objetivo: '$objetivo_descripcion' → Directory: $worktree_path, Branch: $branch_name"

### 5. Verificar colisiones
- Ejecutar `test -d "$worktree_path"` para verificar si directorio existe
- Si existe (exit code 0):
  - Mostrar error: "❌ Error: Directory $worktree_path ya existe"
  - TERMINAR proceso completamente
- Ejecutar `git show-ref --verify --quiet refs/heads/$branch_name` para verificar si branch existe
- Si existe (exit code 0):
  - Mostrar error: "❌ Error: Branch $branch_name ya existe"
  - TERMINAR proceso completamente
- Mostrar: "✓ No collisions detected"

### 6. Preparar parent branch
- Ejecutar `git checkout "$parent_branch"` para cambiar al parent
- Si falla, mostrar error: "❌ Error: Could not checkout $parent_branch" y terminar
- Ejecutar `git pull origin "$parent_branch"` para actualizar desde remoto
- Si falla, mostrar warning: "⚠️ No se pudo actualizar $parent_branch desde remoto" pero continuar
- Si exitoso, mostrar: "✓ Parent branch updated from remote"

### 7. Crear worktree
- Ejecutar `git worktree add "$worktree_path" -b "$branch_name"`
- Si comando falla, mostrar error: "❌ Error: Failed to create worktree" y terminar
- Mostrar: "✅ Worktree created: $worktree_path with branch $branch_name"

### 8. Configurar rama remota
- Ejecutar `(cd "$worktree_path" && git push -u origin "$branch_name")` para crear rama remota y set upstream
- Si falla, mostrar error: "❌ Error: Failed to create remote branch" pero NO terminar
- Si exitoso, mostrar: "✅ Remote branch created: origin/$branch_name"

### 9. Abrir IDE automáticamente
- Detectar IDE disponible ejecutando comandos en orden:
  - `which code > /dev/null 2>&1` para VS Code
  - `which cursor > /dev/null 2>&1` para Cursor
- Si se encuentra IDE, ejecutar `(cd "$worktree_path" && [IDE_COMMAND] . --new-window)` donde [IDE_COMMAND] es `code` o `cursor`
- Si IDE se abre exitosamente, mostrar: "✅ IDE abierto en nueva ventana: $worktree_path"
- Si no se encuentra IDE disponible, mostrar: "⚠️ No se encontró IDE compatible. Abre manualmente: [IDE] $worktree_path"
- Si falla abrir IDE, mostrar warning: "⚠️ No se pudo abrir IDE automáticamente" pero continuar

### 10. Logging y resultado final
- **Log operación**: Crear directorio de logs con `log_dir=".claude/logs/$(date +%Y-%m-%d)" && mkdir -p "$log_dir"`
- Si falla creación de directorio: mostrar warning pero continuar
- Agregar entrada JSONL a `"$log_dir/worktree_operations.jsonl"` usando el template
- Mostrar estado exitoso:
  ```
  ✅ Worktree created successfully:
  - Directory: $worktree_path
  - Branch: $branch_name (tracking origin/$branch_name)
  - Parent: $parent_branch

  ⚠️  CRÍTICO: IDE abierto automáticamente, pero debes:

  PASO 1 - En la nueva ventana del IDE:
    Abrir Terminal integrado (Cmd+` o View → Terminal)
    
  PASO 2 - Verificar directorio correcto:
    pwd  # Debe mostrar: $worktree_path
    
  PASO 3 - Iniciar nueva sesión Claude Code:
    claude /workflow:session-start
    
  ❌ SI NO HACES ESTO: Claude seguirá trabajando en el directorio 
     anterior y NO funcionará correctamente el worktree.
     
  ✅ SOLO así tendrás sesiones Claude Code paralelas funcionando.
  ```

## 📊 Logging Format Template

Para operación exitosa, agregar línea al archivo JSONL:

### Worktree Creation Log:
```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_create","objetivo_descripcion":"$objetivo_descripcion","parent_branch":"$parent_branch","worktree_path":"$worktree_path","branch_name":"$branch_name","user":"$(whoami)","commit_sha":"$(git rev-parse HEAD)"}
```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso crítico falla, detener ejecución y mostrar error claro
- Crear directorio de logs antes de escribir