---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *), Task
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
- **Auto-detectar repositorio**: Usar `gh repo view --json owner,name` para obtener owner y repo actual del workspace
- Si falla detección, mostrar error "❌ No se pudo detectar repositorio GitHub" y terminar  
- Usar `mcp__github__get_pull_request` con owner/repo detectados para verificar que el PR existe
- Si no existe, mostrar error "❌ PR #<number> no existe" y terminar
- Obtener y mostrar información básica: "PR #<number>: <title>"

### 2. Extracción de issues asociados
- Mostrar: "Extrayendo issues asociados..."
- Analizar body del PR (obtenido en paso 1) para detectar issues asociados
- Buscar patterns: "(Fixes|Closes|Resolves) #[0-9]+" en el PR body
- Extraer números de issues únicos y ordenarlos
- Si no hay issues asociados, mostrar: "❌ No issues asociados al PR #<number>. Ejecuta /findings-to-issues primero" y terminar
- Mostrar: "Encontrados <count> issues asociados: <lista_números>"
- Usar `mcp__github__get_me` para obtener usuario actual y capturar username para asignación

### 3. Análisis técnico completo por code-reviewer
- **OBLIGATORIO**: Usar herramienta `Task` para delegar análisis técnico completo al sub-agent `code-reviewer`
- **OPTIMIZACIÓN**: code-reviewer consulta GitHub directamente - elimina redundancia
- Proporcionar al code-reviewer:
  - Contexto del PR #<number> y su propósito
  - Lista de números de issues asociados: <lista_números>
  - Solicitar que consulte cada issue usando `mcp__github__get_issue` directamente
  - Solicitar análisis de: prioridad técnica, complejidad, riesgos, dependencias, **archivos específicos a modificar**
- El code-reviewer debe retornar:
  - Categorización y priorización inteligente CRÍTICO/ALTO/MEDIO/BAJO
  - Recomendaciones específicas de implementación
  - Estimación de esfuerzo basada en análisis técnico (horas)
  - Identificación de riesgos y dependencias entre issues
  - **CRÍTICO**: Lista específica de archivos y líneas a modificar por cada issue
- Capturar resultados del análisis técnico para usar en pasos siguientes

### 4. Análisis de impacto y recursos (basado en resultados del code-reviewer)
- **Impacto por categoría** (usando análisis técnico del code-reviewer):
  - CRÍTICO: "Acción inmediata requerida - Riesgo de seguridad"
  - ALTO: "Dentro de 24h - Afecta funcionalidad central"
  - MEDIO: "Próximo sprint - Mejora/Documentación"
  - BAJO: "Backlog - Limpieza de deuda técnica"
- **Estimación de esfuerzo**: Usar estimaciones del code-reviewer basadas en análisis técnico
- **Recursos necesarios**: Desarrollador + QA + tiempo según code-reviewer
- **Evaluación de riesgos**: Issues que pueden bloquear otros o crear regresiones según code-reviewer

### 5. Generación de plan enterprise-ready
- Crear directorio de planes: `mkdir -p .claude/issues-review`
- Generar filename: `.claude/issues-review/$(date +%Y-%m-%d)-pr<number>-plan.md`
- Usar template enterprise con secciones:
  ```
  # 🎯 Plan de Implementación - PR #<pr_number> (<timestamp>)
  
  ## 📊 Resumen Ejecutivo
  - **Total de Issues**: <count>
  - **Distribución de Prioridad**: <critico_count> Críticos, <alto_count> Altos, <medio_count> Medios, <bajo_count> Bajos
  - **Esfuerzo Estimado**: <total_estimation>
  - **Meta de Finalización**: <suggested_timeline>
  
  ## 🔥 Matriz de Prioridades
  [Detalles por issue con: prioridad, archivos específicos con rutas completas, líneas, estimación horas]
  
  ## 📋 Hoja de Ruta de Implementación
  ### Fase 1: CRÍTICOS (Inmediato)
  ### Fase 2: ALTOS (24h)
  ### Fase 3: MEDIOS (Sprint)
  ### Fase 4: BAJOS (Backlog)
  
  ## ✅ Criterios de Aceptación
  [Checklist por issue para validación de completitud]
  
  ## 🎯 Próximas Acciones
  [Items específicos accionables para el desarrollador]
  ```

### 6. Auto-asignación y actualización
- Para cada issue analizado por el code-reviewer:
  - Si issue no tiene assignee, usar `mcp__github__update_issue` para asignar a username_actual
  - Agregar comment con link al plan de implementación generado
  - Mantener log de issues actualizados vs errores
- Mostrar progreso: "Asignación actualizada para <count> issues"

### 7. Logging estructurado empresarial
- Crear directorio de logs: `mkdir -p .claude/logs/$(date +%Y-%m-%d)`
- Generar timestamp: `date '+%Y-%m-%dT%H:%M:%S'`
- Crear entrada JSONL con:
  - timestamp, pr_number, issues analizados por code-reviewer, conteos por prioridad
  - plan_file generado, issues_assigned, analysis_errors
- Append a archivo: `.claude/logs/<fecha>/issues_analysis.jsonl`

### 8. Reporte de resultados
- Mostrar resumen ejecutivo:
  ```
  Resumen:
  - PR analizado: #<number>
  - Issues encontrados: <total> (distribución según code-reviewer: <critico_count> Críticos, <alto_count> Altos, <medio_count> Medios, <bajo_count> Bajos)
  - Plan generado: <plan_file>
  - Issues asignados: <assigned_count>
  - Próxima acción: Revisar plan y comenzar con issues de mayor prioridad
  ```

### 9. Entrega de plan y próximos pasos
- Mostrar contenido completo del plan generado
- Proporcionar path del archivo para referencia futura
- Listar próximos pasos accionables priorizados
- Confirmar: "Plan de implementación listo para ejecución"

## 📊 Logging Format Template

```json
{"timestamp":"<ISO_timestamp>","pr_number":<number>,"issues_found":<count>,"issues_analyzed":<count>,"priority_breakdown":{"critico":<count>,"alto":<count>,"medio":<count>,"bajo":<count>},"plan_file":"<path>","issues_assigned":<count>,"analysis_errors":<count>}
```

**IMPORTANTE**:
- No solicitar confirmación al usuario en ningún paso
- Ejecutar todos los pasos secuencialmente
- Si algún paso falla, detener ejecución y mostrar error claro
- Crear directorio .claude/logs/$(date +%Y-%m-%d)/ si no existe antes de escribir logs
- Comando enfocado SOLO en análisis y planificación, NO implementación automática