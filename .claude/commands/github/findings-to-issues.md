---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *)
description: Convierte findings de PR reviews en GitHub issues categorizados automáticamente
---

# Findings to GitHub Issues

Analiza reviews y comentarios de un PR, filtra contenido actionable y crea issues categorizados automáticamente.

## Uso
```bash
/findings-to-issues <pr_number>  # Argumento obligatorio
```

## Ejemplos
```bash
/findings-to-issues 96     # Analizar PR #96
/findings-to-issues 123    # Analizar PR #123
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada
- Si no se proporciona argumento, mostrar error: "❌ Error: PR number requerido. Uso: /findings-to-issues <pr_number>"
- Validar que el argumento sea un número positivo válido
- Usar `mcp__github__get_pull_request` para verificar que el PR existe
- Si no existe, mostrar error "❌ PR #<number> no existe" y terminar
- Obtener y mostrar información básica: "PR #<number>: <title>"

### 2. Extracción de datos
- Mostrar: "Extracting review findings..."
- Usar `mcp__github__get_pull_request_reviews` para obtener todas las reviews del PR
- Usar `mcp__github__get_pull_request_comments` para obtener todos los comentarios del PR
- Contar reviews y comentarios obtenidos
- Mostrar: "Found <X> reviews and <Y> comments"
- Usar `mcp__github__get_me` para obtener usuario actual (para contexto)

### 3. Filtrado inteligente de reviews
- Para cada review obtenida, analizar:
  - **Filtrar ruido automáticamente**: Skip si estado es "APPROVED" Y no tiene body útil
  - **Filtrar contenido genérico**: Skip si body contiene solo: LGTM, 👍, ✅, Good, Great
  - **Detectar contenido actionable**:
    - Si estado es "CHANGES_REQUESTED" = automáticamente actionable
    - Si body contiene keywords: should, must, need, fix, error, issue, problem, security, performance, test
  - **Capturar contexto**: reviewer + review body completo
  - Agregar a lista de findings: "Actionable review from <reviewer>: <body>"

### 4. Filtrado inteligente de comentarios
- Para cada comentario obtenido, analizar:
  - **Filtrar ruido**: Skip si body vacío o contiene solo: LGTM, 👍, ✅, Good, Great, Thanks
  - **Detectar contenido actionable**: Si body contiene keywords: should, must, need, fix, error, issue, problem, security, performance, test, suggestion, recommend
  - **Capturar contexto**: commenter + comment body completo
  - Agregar a lista de findings: "Actionable comment from <commenter>: <body>"

### 5. Categorización automática
- Para cada finding actionable, determinar categoría basado en keywords:
  - **Security**: Si contiene security, vulnerability, injection → labels="security"
  - **Performance**: Si contiene performance, slow, optimize → labels="performance"  
  - **Testing**: Si contiene test, coverage → labels="testing"
  - **Documentation**: Si contiene documentation, readme, docs → labels="documentation"
  - **Bug**: Categoría default → labels="bug"
- Generar título del issue: "[<Category>] <texto_relevante>"
- Extraer texto relevante (primeros 50 caracteres después de ":")
- Si texto vacío, usar "Review finding" como fallback

### 6. Generación de issues estructurados
- Para cada finding categorizado, construir issue body usando template:
  ```
  ## Finding from PR #<pr_number>
  
  **Source**: <finding_completo>
  
  **Context**: 
  - **PR**: #<pr_number> - <pr_title>
  - **Type**: Review Finding
  - **Category**: <category>
  
  ## Suggested Solution
  Address the concern mentioned in the review comment.
  
  ## Acceptance Criteria
  - [ ] Issue addressed according to review feedback
  - [ ] Tests added/updated if needed
  - [ ] No similar issues remain in codebase
  ```

### 7. Creación de issues
- Para cada issue estructurado:
  - Usar `mcp__github__create_issue` con título, body y labels
  - Capturar número del issue creado
  - Mostrar progreso: "Created issue #<number>: <title>"
  - Mantener lista de issues creados exitosamente
- Si no hay findings actionable, mostrar: "No actionable findings found"

### 8. Auto-vinculación con PR
- Si se crearon issues:
  - Obtener body actual del PR usando `mcp__github__get_pull_request`
  - Construir sección AUTO-CLOSE:
    ```
    <!-- AUTO-CLOSE:START -->
    ## Associated Issues from Findings
    
    - Fixes #<issue1> - <title1>
    - Fixes #<issue2> - <title2>
    <!-- AUTO-CLOSE:END -->
    ```
  - **Actualización idempotente**: Si sección AUTO-CLOSE ya existe, reemplazarla
  - Si no existe, agregarla al final del PR body
  - Usar `mcp__github__update_pull_request` para actualizar el PR
  - Confirmar: "Issues associated to PR #<number>"

### 9. Logging estructurado
- Crear directorio de logs: `mkdir -p .claude/logs/$(date +%Y-%m-%d)`
- Generar timestamp: `date '+%Y-%m-%dT%H:%M:%S'`
- Crear entrada JSONL con:
  - timestamp, pr_number, issues creados
  - conteos: issues_created, reviews_analyzed, comments_analyzed
- Append a archivo: `.claude/logs/<fecha>/findings_activity.jsonl`

### 10. Reporte final
- Mostrar resumen completo:
  ```
  Summary:
  - PR analyzed: #<number>
  - Reviews: <count> | Comments: <count>
  - Issues created: <count>
  - Issues: <lista_números>
  - Log: <ruta_log>
  ```

## 📊 Logging Format Template

```json
{"timestamp":"<ISO_timestamp>","pr_number":<number>,"issues":"<space_separated_numbers>","issues_created":<count>,"reviews_analyzed":<count>,"comments_analyzed":<count>}
```

**IMPORTANTE**: 
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro
- Manejar gracefully casos donde no hay findings actionable