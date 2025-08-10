---
allowed-tools: Bash(git *), mcp__github__*
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

### 2. Obtener información para el nuevo PR
- Usar herramienta MCP GitHub para listar todos los PRs del repositorio
- Obtener el número máximo de PR existente (o 0 si no hay PRs)
- Calcular próximo número: max_pr + 1
- Generar timestamp con formato HHMMSS
- Construir nombre de rama: `pr-{número}-{timestamp}`

### 3. Crear rama temporal
- Ejecutar `git checkout -b pr-{número}-{timestamp}`
- Ejecutar `git push origin pr-{número}-{timestamp} --set-upstream`
- Si algún comando falla, mostrar error y terminar

### 4. Preparar contenido del PR
- Obtener título del último commit con `git log -1 --pretty=format:"%s"`
- Obtener lista de commits con `git log --oneline origin/{target_branch}..HEAD`
- Construir body del PR:
  ```
  ## Changes
  - [lista de commits máximo 3]
  
  ## Testing
  - [ ] Tests pass
  - [ ] No breaking changes
  ```

### 5. Crear el PR
- Usar herramienta MCP GitHub create_pull_request con:
  - base: target_branch
  - head: nueva rama creada
  - title: mensaje del último commit
  - body: contenido preparado

### 6. Mostrar resultado
- Mostrar URL del PR creado
- Confirmar: "✅ PR creado: {rama} → {target}"

**IMPORTANTE**: 
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro