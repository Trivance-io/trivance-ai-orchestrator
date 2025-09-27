---
allowed-tools: Bash(git *, gh *, jq *)
description: Actualiza CHANGELOG.md (Keep a Changelog format) con PRs mergeados
---

# Changelog Update

Actualiza CHANGELOG.md con PRs mergeados siguiendo formato [Keep a Changelog](https://keepachangelog.com/), detecta tipos de commit y previene duplicados automáticamente.

## Uso
```bash
/changelog <pr_number>                   # Single PR
/changelog <pr1,pr2,pr3>                # Multiple PRs batch
```

## Ejemplos
```bash
/changelog 130                           # Agregar PR #130
/changelog 128,129,130                  # Agregar múltiples PRs
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada y herramientas
- Si no se proporciona argumento, mostrar error: "❌ Error: Debe especificar número de PR o lista separada por comas"
- Validar herramientas requeridas con comando combinado:
  ```bash
  for tool in gh jq; do
    command -v "$tool" >/dev/null 2>&1 || { echo "❌ Error: $tool requerido"; exit 1; }
  done
  ```
- Validar que CHANGELOG.md existe: `[[ -f CHANGELOG.md ]] || { echo "❌ Error: CHANGELOG.md no encontrado"; exit 1; }`

### 2. Parsing de argumentos
- Si argumento contiene coma:
  - Convertir a array: `IFS=',' read -ra pr_list <<< "$ARGUMENTS"`
  - Validar cada número en array: `[[ "$pr" =~ ^[0-9]+$ ]]` - si alguno falla, mostrar error y terminar
- Si argumento NO contiene coma:
  - Validar que es número: `[[ "$ARGUMENTS" =~ ^[0-9]+$ ]]` - si falla, mostrar error y terminar
  - Crear array: `pr_list=("$ARGUMENTS")`
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
- Filtrar PRs duplicados verificando si cada PR ya existe en CHANGELOG.md
- Para PRs que ya existen, mostrar mensaje informativo y omitir
- Para PRs nuevos, mantener en lista para procesamiento
- Si no quedan PRs por procesar, mostrar mensaje y terminar exitosamente
- Mostrar lista final de PRs a agregar

### 5. Actualización de CHANGELOG (Keep a Changelog format)
- Para cada PR en pr_list:
  - Obtener datos completos: `pr_data=$(gh pr view "$pr" --json title,url --jq '{title, url}')`
  - Extraer título: `pr_title=$(echo "$pr_data" | jq -r '.title')`
  - Detectar sección por tipo de commit (feat: → Added, fix: → Fixed, otros → Changed)
  - Obtener fecha actual para organización por fecha
  - Actualizar CHANGELOG con orden correcto (más recientes primero):
    - Si fecha actual ya existe en CHANGELOG:
      - Si sección (Added/Fixed/Changed) existe en esa fecha: agregar entry después del header de sección
      - Si sección no existe: crear nueva sección en fecha existente
    - Si fecha actual no existe: crear nueva fecha al inicio con su sección correspondiente
  - Mantener formato Keep a Changelog con entries como: `- título (PR #número)`
  - Si sed falla, mostrar error: "❌ Error: Falló actualización para PR #$pr" y terminar

### 6. Validación post-actualización
- Validar que cada PR fue insertado correctamente en CHANGELOG.md
- Para cada PR procesado, verificar que el patrón "(PR #número)" existe en el archivo
- Si algún PR no se encuentra, mostrar error específico y terminar proceso

### 7. Resultado final
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