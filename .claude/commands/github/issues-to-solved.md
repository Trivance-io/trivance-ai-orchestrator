---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *)
description: Analiza issues asociados a un PR y genera plan priorizado de implementación
---

# Issues to Implementation Plan

Analiza issues asociados a un PR específico y genera plan priorizado enterprise-ready para implementación.

## Uso
```bash
/issues-to-solved <pr_number>  # Argumento obligatorio
```

## Ejemplos
```bash
/issues-to-solved 96     # Analizar issues de PR #96
/issues-to-solved 123    # Analizar issues de PR #123
```

## Ejecución

Cuando ejecutes este comando con el argumento `$ARGUMENTS`, sigue estos pasos:

### 1. Validación de entrada
- Si no se proporciona argumento, mostrar error: "❌ Error: PR number requerido. Uso: /issues-to-solved <pr_number>"
- Validar que el argumento sea un número positivo válido
- Usar `mcp__github__get_pull_request` para verificar que el PR existe
- Si no existe, mostrar error "❌ PR #<number> no existe" y terminar
- Obtener y mostrar información básica: "PR #<number>: <title>"

### 2. Extracción de issues asociados
- Mostrar: "Extracting associated issues..."
- Analizar body del PR (obtenido en paso 1) para detectar issues asociados
- Buscar patterns: "(Fixes|Closes|Resolves) #[0-9]+" en el PR body
- Extraer números de issues únicos y ordenarlos
- Si no hay issues asociados, mostrar: "❌ No issues asociados al PR #<number>. Ejecuta /findings-to-issues primero" y terminar
- Mostrar: "Found <count> associated issues: <lista_números>"
- Usar `mcp__github__get_me` para obtener usuario actual y capturar username para asignación

### 3. Recolección de datos detallados
- Para cada issue asociado:
  - Usar `mcp__github__get_issue` para obtener título, body, estado, labels, assignees
  - **Extraer prioridad del título**: Buscar [Security] → CRITICAL, [Bug] → HIGH, [Testing] → LOW, [Documentation] → MEDIUM
  - **Extraer información de archivos**: Buscar patterns "**File**: <path>", "**Lines**: <range>" en body
  - **Detectar categoría principal**: Basado en labels y keywords en título/body
  - **Validar accesibilidad**: Si issue no accesible, log y continuar con siguiente
- Contar issues exitosamente procesados vs total
- Mostrar: "Processed <processed>/<total> issues successfully"

### 4. Categorización y priorización inteligente
- Para cada issue procesado, determinar:
  - **Prioridad**: CRITICAL (Security) > HIGH (Bug) > MEDIUM (Documentation/Enhancement) > LOW (Testing/Cleanup)
  - **Complejidad estimada**: Basada en cantidad de archivos mencionados y keywords de alcance
  - **Dependencias**: Detectar si issues relacionados por archivos comunes o referencias cruzadas
  - **Orden de implementación**: Prioridad + dependencias + complejidad
- Agrupar issues por prioridad para reporte estructurado
- Generar recomendaciones de orden de ejecución

### 5. Análisis de impacto y recursos
- **Impacto por categoría**:
  - CRITICAL: "Immediate action required - Security risk"
  - HIGH: "Within 24h - Affects core functionality"
  - MEDIUM: "Next sprint - Enhancement/Documentation"
  - LOW: "Backlog - Technical debt cleanup"
- **Estimación de esfuerzo**: Basada en complejidad detectada y número de archivos
- **Recursos necesarios**: Desarrollador + QA + tiempo estimado
- **Risk assessment**: Issues que pueden bloquear otros o crear regresiones

### 6. Generación de plan enterprise-ready
- Crear directorio de logs: `mkdir -p .claude/logs/$(date +%Y-%m-%d)`
- Generar filename: `.claude/logs/<fecha>/implementation-plan-pr<number>.md`
- Usar template enterprise con secciones:
  ```
  # 🎯 Implementation Plan - PR #<pr_number> (<timestamp>)
  
  ## 📊 Executive Summary
  - **Total Issues**: <count>
  - **Priority Breakdown**: <critical_count> Critical, <high_count> High, <medium_count> Medium, <low_count> Low
  - **Estimated Effort**: <total_estimation>
  - **Completion Target**: <suggested_timeline>
  
  ## 🔥 Priority Matrix
  [Details per issue with priority, files, estimation]
  
  ## 📋 Implementation Roadmap
  ### Phase 1: CRITICAL (Immediate)
  ### Phase 2: HIGH (24h)
  ### Phase 3: MEDIUM (Sprint)
  ### Phase 4: LOW (Backlog)
  
  ## ✅ Acceptance Criteria
  [Checklist per issue for completion validation]
  
  ## 🎯 Next Actions
  [Specific actionable items for developer]
  ```

### 7. Auto-asignación y actualización
- Para cada issue procesado:
  - Si issue no tiene assignee, usar `mcp__github__update_issue` para asignar a username_actual
  - Agregar comment con link al plan de implementación generado
  - Mantener log de issues actualizados vs errores
- Mostrar progreso: "Updated assignment for <count> issues"

### 8. Logging estructurado empresarial
- Generar timestamp: `date '+%Y-%m-%dT%H:%M:%S'`
- Crear entrada JSONL con:
  - timestamp, pr_number, issues procesados, conteos por prioridad
  - plan_file generado, issues_assigned, processing_errors
- Append a archivo: `.claude/logs/<fecha>/issues_analysis.jsonl`

### 9. Reporte de resultados
- Mostrar resumen ejecutivo:
  ```
  Summary:
  - PR analyzed: #<number>
  - Issues found: <total> (<critical> Critical, <high> High, <medium> Medium, <low> Low)
  - Plan generated: <plan_file>
  - Issues assigned: <assigned_count>
  - Next action: Review plan and start Phase 1 (Critical issues)
  ```

### 10. Entrega de plan y próximos pasos
- Mostrar contenido completo del plan generado
- Proporcionar path del archivo para referencia futura
- Listar próximos pasos accionables priorizados
- Confirmar: "Implementation plan ready for execution"

## 📊 Logging Format Template

```json
{"timestamp":"<ISO_timestamp>","pr_number":<number>,"issues_found":<count>,"issues_processed":<count>,"priority_breakdown":{"critical":<count>,"high":<count>,"medium":<count>,"low":<count>},"plan_file":"<path>","issues_assigned":<count>,"processing_errors":<count>}
```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro
- Crear directorio .claude/logs/$(date +%Y-%m-%d)/ si no existe antes de escribir logs
- Comando enfocado SOLO en análisis y planificación, NO implementación automática