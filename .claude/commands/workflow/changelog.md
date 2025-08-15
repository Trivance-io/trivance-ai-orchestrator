---
allowed-tools: Bash(git *, gh *, jq *)
description: Actualiza CHANGELOG.md (Keep a Changelog format) con PRs mergeados
---

# Changelog Update

Actualiza CHANGELOG.md con PRs mergeados siguiendo formato [Keep a Changelog](https://keepachangelog.com/), detecta tipos de commit y previene duplicados automáticamente.

## Uso
```bash
/changelog --pr <pr_number>              # Single PR
/changelog --prs <pr1,pr2,pr3>          # Multiple PRs batch
```

## Ejemplos
```bash
/changelog --pr 130                      # Agregar PR #130
/changelog --prs 128,129,130            # Agregar múltiples PRs
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada y herramientas
- Si no se proporciona argumento, mostrar error: "❌ Error: Debe especificar --pr <number> o --prs <n1,n2,n3>"
- Ejecutar: `command -v gh >/dev/null 2>&1` - si falla, mostrar error: "❌ Error: gh CLI requerido" y terminar
- Ejecutar: `command -v jq >/dev/null 2>&1` - si falla, mostrar error: "❌ Error: jq requerido" y terminar
- Validar que CHANGELOG.md existe, si no existe mostrar error: "❌ Error: CHANGELOG.md no encontrado" y terminar

### 2. Parsing de argumentos
- Si argumento contiene "--pr ":
  - Extraer número: `pr_number=$(echo "$ARGUMENTS" | sed 's/--pr //')`
  - Validar que es número: `[[ "$pr_number" =~ ^[0-9]+$ ]]` - si falla, mostrar error y terminar
  - Crear array: `pr_list=("$pr_number")`
- Si argumento contiene "--prs ":
  - Extraer números: `pr_numbers=$(echo "$ARGUMENTS" | sed 's/--prs //')`
  - Convertir a array: `IFS=',' read -ra pr_list <<< "$pr_numbers"`
  - Validar cada número en array: `[[ "$pr" =~ ^[0-9]+$ ]]` - si alguno falla, mostrar error y terminar
- Si no coincide ningún patrón, mostrar error de uso y terminar
- Mostrar: "Procesando PR(s): ${pr_list[*]}"

### 3. Validación de PRs en GitHub
- Para cada PR en pr_list:
  - Ejecutar: `pr_data=$(gh pr view "$pr" --json number,state,title,url 2>/dev/null)`
  - Si comando falla o pr_data vacío:
    - Mostrar error: "❌ Error: PR #$pr no encontrado en GitHub"
    - TERMINAR proceso completamente
  - Ejecutar: `pr_state=$(echo "$pr_data" | jq -r '.state')`
  - Si pr_state != "MERGED":
    - Mostrar error: "❌ Error: PR #$pr no está mergeado (estado: $pr_state)"
    - TERMINAR proceso completamente
  - Ejecutar: `pr_title=$(echo "$pr_data" | jq -r '.title')`
  - Mostrar: "✓ PR #$pr validado: $pr_title"

### 4. Detección de duplicados en CHANGELOG
- Para cada PR en pr_list:
  - Ejecutar: `grep -q "(PR #$pr)" CHANGELOG.md`
  - Si encuentra match:
    - Mostrar warning: "⚠️  PR #$pr ya existe en CHANGELOG.md, omitiendo"
    - Remover PR de pr_list para procesamiento
- Si pr_list queda vacío después de filtrado:
  - Mostrar: "ℹ️  Todos los PRs ya están en CHANGELOG.md, nada que actualizar"
  - TERMINAR proceso exitosamente
- Mostrar: "PRs a agregar: ${pr_list[*]}"

### 5. Actualización de CHANGELOG (Keep a Changelog format)
- Para cada PR en pr_list:
  - Obtener título: `pr_title=$(gh pr view "$pr" --json title --jq '.title')`
  - Detectar sección por tipo de commit:
    ```bash
    case "$pr_title" in
      feat:*) section="Added" ;;
      fix:*) section="Fixed" ;;
      *) section="Changed" ;;  # docs, refactor, perf, style, test, chore
    esac
    ```
  - Verificar si sección existe bajo `## [Unreleased]`:
    ```bash
    if grep -q "^### $section" CHANGELOG.md; then
      # Agregar a sección existente
      sed "/^### $section/a\\
- $pr_title (PR #$pr)" CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md
    else
      # Crear nueva sección después de [Unreleased]
      sed "/^## \[Unreleased\]/a\\
\\
### $section\\
- $pr_title (PR #$pr)" CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md
    fi
    ```
  - Si sed falla, mostrar error: "❌ Error: Falló actualización para PR #$pr" y terminar

### 7. Validación post-actualización
- Para cada PR en pr_list:
  - Ejecutar: `grep -q "(PR #$pr)" CHANGELOG.md`
  - Si no encuentra match:
    - Mostrar error: "❌ Error: Validación falló para PR #$pr"
    - TERMINAR proceso completamente

### 8. Resultado final
- Mostrar: "✅ CHANGELOG.md actualizado exitosamente"
- Mostrar: "PRs agregados: ${pr_list[*]}"
- Mostrar cambios: `git diff --no-index /dev/null CHANGELOG.md | head -20`
- Mostrar: "💡 Recuerda hacer commit de los cambios: git add CHANGELOG.md && git commit -m 'docs: update CHANGELOG with PR(s) ${pr_list[*]}'"

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente con validaciones robustas
- Si algún paso crítico falla, restaurar estado y mostrar error claro
- Comando optimizado para actualizaciones batch y validación de integridad
- Detectar y prevenir duplicados automáticamente