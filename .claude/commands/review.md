---
allowed-tools: Bash(gh pr *), Bash(gh api *), Bash(mkdir *), Bash(date *), Bash(echo *), Bash(gh *), Bash(git *), Task, Edit, MultiEdit, Write
description: Motor de revisión de código inteligente con análisis especializado
---

# Revisión Inteligente de Código

Revisaré inteligentemente tu código utilizando agentes especializados.

## Uso

```bash
/review                    # Revisión completa del código con todos los revisores disponibles
/review $ARGUMENTS         # Revisión dirigida basada en tu contexto específico
```

## Ejecución

Al ejecutar este comando con el argumento `$ARGUMENTS`, seguir estos pasos:

### 1. Detección de Contexto

- **Sin argumentos**: Establecer contexto = "contexto completo del workspace"
- **Con argumentos proporcionados**: Establecer contexto = argumentos como alcance específico de análisis

### 2. Revisión y Análisis Inteligente

- Mostrar: "🔍 Iniciando revisión..."
- **Delegación de especialistas**:
  - Si el contexto contiene "pr" + número: Usar `gh pr view <numero> --json` para obtener datos del PR y `gh pr diff <numero>` para el diff
  - Para PR review: Obtener archivos con `gh pr view <numero> --json files`
  - Obtener diff completo con `gh pr diff <numero>`
  - Usar herramienta `Glob` con patrón `.claude/agents/reviewers/*.md` para descubrir revisores disponibles
  - Extraer nombres de agentes eliminando la extensión `.md` de los archivos descubiertos
  - Usar herramienta `Task` para delegar a todos los agentes revisores descubiertos
  - Proporcionar a cada especialista el contexto y alcance determinados
- **Consolidación inteligente**:
  - Capturar hallazgos en bruto de todos los revisores descubiertos
  - Leer README del proyecto, CLAUDE.md y commits recientes para contexto
  - Analizar cada hallazgo contra la arquitectura y convenciones del proyecto
  - Filtrar hallazgos que no aplican a este código base (falsos positivos)
  - Eliminar duplicaciones y fusionar hallazgos relacionados
  - Clasificar por impacto técnico/empresarial real
  - Generar elementos de acción específicos con ubicaciones de archivos y comandos
  - Priorizar por impacto real en los objetivos y estabilidad del proyecto

### 3. Generación de Reporte

- **Crear directorios**: `mkdir -p .claude/reviews .claude/logs/$(date +%Y-%m-%d)`
- **Generar timestamp**: `date '+%Y-%m-%dT%H:%M:%S'`
- **Determinar nombre de archivo**:
  - Sin argumentos: `.claude/reviews/review-$(timestamp).md`
  - Con argumentos: `.claude/reviews/targeted-$(timestamp).md`
- **Escribir reporte ejecutivo** con base en la estructura del punto 4 "Reporte Ejecutivo", análisis y plan de acción con solicitud al usuario.
- **Registrar actividad**: Agregar entrada a `.claude/logs/$(date +%Y-%m-%d)/revision_actividad.jsonl`

### 4. Reporte Ejecutivo

```
📊 **Análisis de Review Completado**

## Resumen
**Impacto:** [Alto/Medio/Bajo] - **Acción Requerida:** [Sí/No] - **Confianza:** [Alta/Media/Baja]

## Hallazgos: <valid_count> válidos, <filtered_count> filtrados, <total_count> total

## Acciones Requeridas
### 🚨 INMEDIATO (1-2 items máximo)
- [ ] [Acción específica con archivo:línea] - [Por qué es crítico] - [Cómo solucionarlo]

### ⚠️ ALTO IMPACTO (3-5 items máximo)
- [ ] [Acción específica con archivo:línea] - [Impacto en negocio] - [Enfoque recomendado]

### 💡 MEJORAS (2-3 items estratégicos)
- [ ] [Oportunidad de mejora] - [Evaluación ROI] - [Sugerencia de implementación]

## Notas de Análisis
**Contexto del Proyecto:** [Patrones/convenciones clave considerados]
**Items Filtrados:** [Falsos positivos principales descartados con justificación]

**Reporte Detallado:** <review_file>

**Próximos Pasos:**
1. Resolver items inmediatos (est: X min)
2. Planificar items de alto impacto para próximo sprint
3. Considerar mejoras estratégicas
```

## Criterios de Éxito

- **Análisis Consciente del Contexto**: Valida hallazgos contra patrones del proyecto con filtrado de falsos positivos
- **Salida Ejecutable**: Elementos de acción ejecutables con ubicaciones específicas de archivos y comandos
- **Detección de Alcance Inteligente**: Análisis específico de PR vs workspace completo basado en contexto
- **Enfoque en Calidad**: Prioriza hallazgos válidos e impactantes sobre volumen bruto
- **Almacenamiento Estructurado**: Reportes organizados en .claude/reviews/ con resúmenes ejecutivos
