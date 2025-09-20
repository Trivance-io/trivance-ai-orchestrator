---
---
layout: docs
title: "Guía Práctica de Comandos Claude Code\n\n_Comandos organizados por importancia
  y impact en productividad_\n\n## ⚡ Comandos de Alto Valor (ESENCIALES)\n\n### \U0001F3AF
  `/understand` - Context Mapping\n\n```bash\n/understand\n```\n\n**Qué hace**: Analiza
  todo el codebase y explica arquitectura, patrones y funcionamiento completo.\n**Cuándo
  usarlo**: SIEMPRE antes de implementar. Primera acción en cualquier proyecto.\n**ROI**:
  30 min ahorran 3+ horas de refactoring por inconsistencias.\n\n### \U0001F680 `/implement`
  - Motor de Implementación Automática\n\n```bash\n/implement \"nueva feature de dashboard
  con notificaciones\"\n```\n\n**Qué hace**: Motor central - planifica e implementa
  features completas con especialistas automáticos.\n**Cuándo usarlo**: Para cualquier
  implementación nueva. Reemplaza desarrollo manual.\n**Flujo**: Planning (tech-lead-orchestrator)
  → **USER AUTHORIZATION** → Coding (specialists) → Testing → Documentation\n**ROI**:
  Reduce 4+ horas desarrollo manual a 20-30 minutos.\n\n### \U0001F50D `/review` -
  Quality Assurance Multi-Especialista\n\n```bash\n/review\n```\n\n**Qué hace**: Análisis
  simultáneo de security, performance, code quality con múltiples especialistas.\n**Cuándo
  usarlo**: Después de cualquier implementación, ANTES de hacer PR.\n**ROI**: 5 min
  previenen 2+ horas de fixes post-merge.\n\n### ✅ `/test` - Validation Engine\n\n```bash\n/test\n```\n\n**Qué
  hace**: Ejecuta todos los tests, detecta fallos y sugiere/aplica fixes automáticos.\n**Cuándo
  usarlo**: Después de cambios significativos, antes de commits importantes.\n**ROI**:
  Debugging de horas a minutos.\n\n---\n\n## \U0001F680 Comandos Fundamentales\n\n###
  \U0001F4BE `/commit` - Commits inteligentes\n\n```bash\n/commit \"descripción del
  cambio\"\n```\n\n**Qué hace**: Analiza tus cambios y crea commits semánticos con
  validaciones automáticas.\n**Cuándo usarlo**: Después de completar cualquier cambio
  en código.\n**Ejemplo**: `commit \"fix user login validation\"` → genera commit
  con mensaje optimizado.\n\n### `/format` - Formateo consistente\n\n```bash\n/format\n```\n\n**Qué
  hace**: Formatea todo el código siguiendo las convenciones del proyecto.\n**Cuándo
  usarlo**: Antes de commits o cuando el código se ve inconsistente.\n\n---\n\n##
  \U0001F527 Comandos de Desarrollo\n\n### \U0001F504 `/refactor` - Refactoring inteligente\n\n```bash\n/refactor
  \"mejorar performance de consultas de base de datos\"\n```\n\n**Qué hace**: Reestructura
  código manteniendo funcionalidad, mejorando calidad.\n**Cuándo usarlo**: Cuando
  el código funciona pero necesita mejoras estructurales.\n\n### `/make-it-pretty`
  - Mejora de legibilidad\n\n```bash\n/make-it-pretty\n```\n\n**Qué hace**: Mejora
  legibilidad del código preservando funcionalidad exacta (naming, organización).\n**Cuándo
  usarlo**: Cuando el código funciona pero es difícil de leer o mantener.\n\n### `/remove-comments`
  - Eliminar comentarios obvios\n\n```bash\n/remove-comments\n```\n\n**Qué hace**:
  Limpia comentarios redundantes preservando los que añaden valor real.\n**Cuándo
  usarlo**: Para limpiar código con exceso de comentarios obvios o redundantes.\n\n---\n\n##
  \U0001F50D Comandos de Análisis\n\n### \U0001F512 `/agent:security-reviewer` - Auditoría
  de seguridad\n\n```bash\n/agent:security-reviewer\n```\n\n**Qué hace**: Escanea
  vulnerabilidades, credenciales expuestas y problemas de seguridad.\n**Cuándo usarlo**:
  Antes de deployments o periódicamente en código crítico.\n\n### \U0001F9E0 `/deep`
  - Razonamiento profundo\n\n```bash\n/deep \"problema complejo o decisión arquitectónica\"\n```\n\n**Qué
  hace**: Activa análisis profundo para problemas complejos y decisiones estratégicas.\n**Cuándo
  usarlo**: Planificación estratégica, decisiones arquitectónicas críticas, auditorías
  profundas.\n**Flujo**: Análisis multi-perspectiva → Investigación de causa raíz
  → Pensamiento sistémico → Soluciones alternativas\n\n---\n\n## \U0001F9EA Comandos
  de QA y Testing\n\n### \U0001F3AD `/agent:qa-playwright` - E2E Testing & Visual
  Analysis\n\n```bash\n/agent:qa-playwright\n```\n\n**Qué hace**: E2E testing con
  herramientas MCP nativas de Playwright, detección sistemática de edge cases y reportes
  ejecutivos.\n**Cuándo usarlo**: Testing visual comprehensivo, validación de workflows
  de usuario, detección de problemas de UI ocultos.\n**Flujo**: Exploración autónoma
  → Detección de edge cases → Reportes ejecutivos con impacto de negocio\n**ROI**:
  Detecta problemas críticos de UX antes de production con análisis cuantificado.\n\n---\n\n##
  \U0001F4C4 Comandos de Documentación\n\n### \U0001F4DA `/docs` - Gestión de documentación\n\n```bash\n/docs\n```\n\n**Qué
  hace**: Analiza y actualiza TODA la documentación del proyecto automáticamente (README,
  CHANGELOG, docs/\\*).\n**Cuándo usarlo**: Después de features, cambios importantes,
  para mantener documentación actualizada.\n**Flujo**: Analiza conversación → Lee
  documentación existente → Identifica cambios → Actualiza sistemáticamente\n\n---\n\n##
  \U0001F5C2️ Comandos de Workflow\n\n### \U0001F504 `/workflow:switch` - Cambio seguro
  de rama validando PR\n\n```bash\n/workflow:switch <target_branch>\n```\n\n**Qué
  hace**: Valida PR mergeado, cambia a rama objetivo y limpia workspace temporal.\n**Cuándo
  usarlo**: Al finalizar PRs mergeados para cambiar a main/develop con cleanup completo.\n**Flujo**:
  Bloquea si PR no mergeado → Switch seguro → Limpieza\n\n### \U0001F4DD `/workflow:changelog`
  - Actualización inteligente de changelog\n\n```bash\n/workflow:changelog <pr_number>
  \        # Single PR\n/workflow:changelog <pr1,pr2,pr3>       # Multiple PRs\n```\n\n**Qué
  hace**: Actualiza CHANGELOG.md con PRs mergeados, detecta duplicados automáticamente.\n**Cuándo
  usarlo**: Después de merge para documentar cambios en proyecto.\n**Flujo**: Valida
  PRs mergeados → Detecta duplicados → Actualización atómica con backup\n\n### `/workflow:session-start`
  - Iniciar sesión documentada\n\n```bash\n/workflow:session-start\n```\n\n**Qué hace**:
  Inicia sesión de código documentada con objetivos claros y tracking.\n**Cuándo usarlo**:
  Al comenzar trabajo significativo para mantener continuidad.\n\n---\n\n## \U0001F4CB
  Gestión de TODOs\n\n### `/todos:create` - Crear TODOs contextuales\n\n```bash\n/todos:create\n```\n\n**Qué
  hace**: Convierte hallazgos de análisis en TODOs específicos en el código.\n**Cuándo
  usarlo**: Después de security-scan, review o cuando encuentras issues que no puedes
  arreglar inmediatamente.\n\n### `/todos:find` - Buscar TODOs existentes\n\n```bash\n/todos:find\n```\n\n**Qué
  hace**: Escanea y categoriza todos los TODOs/FIXMEs del proyecto.\n**Cuándo usarlo**:
  Para auditoría de deuda técnica o planificación de sprints.\n\n### `/todos:fix`
  - Resolver TODOs\n\n```bash\n/todos:fix\n```\n\n**Qué hace**: Encuentra y resuelve
  TODOs existentes de forma sistemática.\n**Cuándo usarlo**: Cuando quieres limpiar
  deuda técnica acumulada.\n\n### `/todos:to-issues` - TODOs a issues GitHub\n\n```bash\n/todos:to-issues\n```\n\n**Qué
  hace**: Escanea TODOs en código y crea issues profesionales en GitHub automáticamente.\n**Cuándo
  usarlo**: Para convertir deuda técnica en trabajo trackeable y organizado.\n\n---\n\n##
  \U0001F9F9 Comandos de Mantenimiento\n\n### \U0001F9FD `/cleanproject` - Limpieza
  integral\n\n```bash\n/cleanproject\n```\n\n**Qué hace**: Limpia dead code, optimiza
  imports, remueve archivos innecesarios.\n**Cuándo usarlo**: Antes de releases o
  periódicamente para mantener el proyecto limpio.\n\n---\n\n## \U0001F517 Comandos
  GitHub\n\n### \U0001F504 `/pr` - Crear pull requests\n\n```bash\n/pr [target-branch]\n```\n\n**Qué
  hace**: Crea PRs con validación automática de branch, push seguro y metadata completa.\n**Cuándo
  usarlo**: Para crear PRs que faciliten review y mantengan estándares de calidad.\n**Flujo**:
  Valida target branch → **SECURITY REVIEW** → Pre-fetch remoto → Crea branch temporal
  → Push seguro → PR con metadata\n\n### \U0001F3AF `Usando /review con PRs` - Smart
  PR Review & Implementation Plan\n\n```bash\n# Usar comando /review existente para
  PRs\n/review\n```\n\n**Qué hace**: El comando /review incluye análisis de PRs con
  especialistas AI y genera plan técnico detallado.\n**Cuándo usarlo**: Para revisar
  código y PRs obteniendo plan priorizado de mejoras.\n\n### `/issue-manager` - Gestionar
  y analizar issues de GitHub\n\n```bash\n/issue-manager                 # Resumen
  de issues activos asignados\n/issue-manager <issue_number>  # Análisis profundo
  de issue específico\n```\n\n**Qué hace**: Proporciona resumen inteligente de tus
  issues activos o análisis detallado de un issue individual con contexto, complejidad
  y próximos pasos.\n**Cuándo usarlo**: Para obtener visión general de workload o
  analizar issue específico antes de implementar.\n**Funcionalidades**: Dashboard
  con priorización inteligente, detección de issues stale, estimación de complejidad,
  archivos afectados\n\n---\n\n## \U0001F333 Comandos Worktree\n\n### `/worktree:create`
  - Crear worktree aislado\n\n```bash\n/worktree:create <purpose> <parent-branch>\n```\n\n**Qué
  hace**: Crea worktree en directorio sibling con rama nueva y upstream remoto.\n**Cuándo
  usarlo**: SIEMPRE para desarrollo (features, bugs, refactoring).\n**Flujo**: Valida
  argumentos → Verifica parent branch → Crea worktree → Configura upstream → Guía
  para cambio de directorio\n\n### `/worktree:cleanup` - Limpiar worktrees\n\n```bash\n/worktree:cleanup
  <worktree1> [worktree2] [...]\n```\n\n**Qué hace**: Elimina worktrees específicos
  con validación de ownership y estado limpio.\n**Cuándo usarlo**: Después de mergear
  PRs o cuando worktrees ya no se necesiten.\n**Flujo**: Valida ownership → Verifica
  estado limpio → Confirmación → Triple cleanup (worktree/local/remote)\n\n**Estándar
  del equipo:**\n\n- Todo desarrollo se hace en worktrees aislados\n- Mantiene workspace
  principal siempre limpio\n- Permite sesiones Claude Code paralelas\n- Rollback instantáneo
  sin conflictos\n\n---\n\n## \U0001F3AF Flujos Típicos\n\n### **\U0001F3C6 Workflow
  de Alto Impacto: Feature Nueva**\n\n```bash\n# SETUP (desde main/develop)\n1. /workflow:session-start
  \              # Configurar workspace\n2. /worktree:create feature-name develop
  # Crear worktree aislado\n3. cd ../worktree-feature-name           # Cambiar al
  worktree\n\n# COMANDOS DE ALTO VALOR (el 80% del impacto)\n4. /understand                           #
  \U0001F3AF Context mapping completo\n5. /implement \"nueva feature\"            #
  \U0001F680 Implementation engine\n6. /review                              # \U0001F50D
  Multi-specialist quality check\n7. /pr                                  # Crear
  PR automático\n\n# ITERACIÓN (si hay findings)\n8. /review pr <number>                  #
  Plan para resolver findings\n9. [Resolver según plan]                # Manual o
  con especialistas\n10. Merge + /workflow:changelog + cleanup\n```\n\n**⚡ Tiempo
  total con comandos de alto valor: 15-30 minutos** (vs 2-4 horas manual)\n\n> \U0001F4DA
  **Para workflow completo de PR + findings + issues:** Ver `ai-first-workflow.md`\n\n###
  **\U0001F3C6 Workflow QA Integration: Feature con Testing**\n\n```bash\n# DEVELOPMENT
  (desde worktree)\n1. /understand                           # Context mapping\n2.
  /implement \"nueva feature\"            # Feature implementation\n3. /agent:qa-playwright
  \                 # E2E testing & visual analysis\n4. /review                              #
  Multi-specialist review\n5. /pr                                  # PR con QA evidence\n\n#
  TESTING ESPECÍFICO\n6. /agent:qa-playwright localhost:3000                       #
  E2E testing & visual analysis\n7. /agent:qa-playwright localhost:3000 # E2E testing
  & visual analysis\n```\n\n### Bug Fix Urgente\n\n```bash\n1. /worktree:create fix-bug-name
  main     # Worktree desde main\n2. cd ../worktree-fix-bug-name            # Cambiar
  al worktree\n3. claude /workflow:session-start         # Nueva sesión en worktree\n4.
  /understand                            # Entender el problema\n5. Arreglar el código\n6.
  /test                                 # Validar fix\n7. /commit \"fix: descripción\"
  \           # Commit inmediato\n```\n\n### Limpieza de Código\n\n```bash\n1. /todos:find
  \                 # Ver deuda técnica\n2. /todos:fix                   # Resolver
  pendientes\n3. /cleanproject  # Limpiar proyecto\n4. /make-it-pretty             #
  Mejorar legibilidad\n5. /format                     # Formatear todo\n6. /commit
  \"chore: cleanup\"    # Documentar limpieza\n```\n\n### Análisis Estratégico Completo\n\n```bash\n1.
  /deep \"problema arquitectónico\"           # Razonamiento profundo\n2. /agent:tech-lead-orchestrator
  \            # Análisis estratégico multi-experto\n3. /understand                      #
  Mapear codebase\n4. /review                         # Revisar estado actual\n5.
  Implementar solución\n6. /docs                          # Documentar decisiones\n```\n\n---\n\n##
  \U0001F4A1 Tips de Uso\n\n- **Combina comandos**: Usa flujos secuenciales para mayor
  eficiencia\n- **Iterativo**: Los comandos recuerdan contexto entre ejecuciones\n-
  **Seguridad primero**: Siempre usa /agent:security-reviewer antes de production\n-
  **Test frecuente**: Ejecuta /test después de cambios significativos\n- **QA automation**:
  Usa /agent:qa-playwright para validación comprehensiva de features críticas\n- **E2E
  testing**: Incluye /agent:qa-playwright para detección sistemática de edge cases\n-
  **Documenta cambios**: Usa /docs para mantener documentación actualizada\n- **Análisis
  profundo**: Usa /deep para decisiones arquitectónicas críticas\n- **Gestión de deuda**:
  Convierte TODOs en issues con /todos:to-issues"
category: commands
permalink: "/commands/"
description: '_Comandos organizados por importancia y impact en productividad_ ```bash
  /understand ``` **Qué hace**: Analiza todo el codebase y explica arquitectura, patrones
  y funcionamiento completo.'
tags:
- comandos
- CLI
- productividad
- implement
- review
toc: true
search: true
last_modified_at: '2025-09-20'
---

# Guía Práctica de Comandos Claude Code

_Comandos organizados por importancia y impact en productividad_

## ⚡ Comandos de Alto Valor (ESENCIALES)

### 🎯 `/understand` - Context Mapping

```bash
/understand
```bash

**Qué hace**: Analiza todo el codebase y explica arquitectura, patrones y funcionamiento completo.
**Cuándo usarlo**: SIEMPRE antes de implementar. Primera acción en cualquier proyecto.
**ROI**: 30 min ahorran 3+ horas de refactoring por inconsistencias.

### 🚀 `/implement` - Motor de Implementación Automática

```bash
/implement "nueva feature de dashboard con notificaciones"
```bash

**Qué hace**: Motor central - planifica e implementa features completas con especialistas automáticos.
**Cuándo usarlo**: Para cualquier implementación nueva. Reemplaza desarrollo manual.
**Flujo**: Planning (tech-lead-orchestrator) → **USER AUTHORIZATION** → Coding (specialists) → Testing → Documentation
**ROI**: Reduce 4+ horas desarrollo manual a 20-30 minutos.

### 🔍 `/review` - Quality Assurance Multi-Especialista

```bash
/review
```bash

**Qué hace**: Análisis simultáneo de security, performance, code quality con múltiples especialistas.
**Cuándo usarlo**: Después de cualquier implementación, ANTES de hacer PR.
**ROI**: 5 min previenen 2+ horas de fixes post-merge.

### ✅ `/test` - Validation Engine

```bash
/test
```bash

**Qué hace**: Ejecuta todos los tests, detecta fallos y sugiere/aplica fixes automáticos.
**Cuándo usarlo**: Después de cambios significativos, antes de commits importantes.
**ROI**: Debugging de horas a minutos.

---

## 🚀 Comandos Fundamentales

### 💾 `/commit` - Commits inteligentes

```bash
/commit "descripción del cambio"
```bash

**Qué hace**: Analiza tus cambios y crea commits semánticos con validaciones automáticas.
**Cuándo usarlo**: Después de completar cualquier cambio en código.
**Ejemplo**: `commit "fix user login validation"` → genera commit con mensaje optimizado.

### `/format` - Formateo consistente

```bash
/format
```bash

**Qué hace**: Formatea todo el código siguiendo las convenciones del proyecto.
**Cuándo usarlo**: Antes de commits o cuando el código se ve inconsistente.

---

## 🔧 Comandos de Desarrollo

### 🔄 `/refactor` - Refactoring inteligente

```bash
/refactor "mejorar performance de consultas de base de datos"
```bash

**Qué hace**: Reestructura código manteniendo funcionalidad, mejorando calidad.
**Cuándo usarlo**: Cuando el código funciona pero necesita mejoras estructurales.

### `/make-it-pretty` - Mejora de legibilidad

```bash
/make-it-pretty
```bash

**Qué hace**: Mejora legibilidad del código preservando funcionalidad exacta (naming, organización).
**Cuándo usarlo**: Cuando el código funciona pero es difícil de leer o mantener.

### `/remove-comments` - Eliminar comentarios obvios

```bash
/remove-comments
```bash

**Qué hace**: Limpia comentarios redundantes preservando los que añaden valor real.
**Cuándo usarlo**: Para limpiar código con exceso de comentarios obvios o redundantes.

---

## 🔍 Comandos de Análisis

### 🔒 `/agent:security-reviewer` - Auditoría de seguridad

```bash
/agent:security-reviewer
```bash

**Qué hace**: Escanea vulnerabilidades, credenciales expuestas y problemas de seguridad.
**Cuándo usarlo**: Antes de deployments o periódicamente en código crítico.

### 🧠 `/deep` - Razonamiento profundo

```bash
/deep "problema complejo o decisión arquitectónica"
```bash

**Qué hace**: Activa análisis profundo para problemas complejos y decisiones estratégicas.
**Cuándo usarlo**: Planificación estratégica, decisiones arquitectónicas críticas, auditorías profundas.
**Flujo**: Análisis multi-perspectiva → Investigación de causa raíz → Pensamiento sistémico → Soluciones alternativas

---

## 🧪 Comandos de QA y Testing

### 🎭 `/agent:qa-playwright` - E2E Testing & Visual Analysis

```bash
/agent:qa-playwright
```bash

**Qué hace**: E2E testing con herramientas MCP nativas de Playwright, detección sistemática de edge cases y reportes ejecutivos.
**Cuándo usarlo**: Testing visual comprehensivo, validación de workflows de usuario, detección de problemas de UI ocultos.
**Flujo**: Exploración autónoma → Detección de edge cases → Reportes ejecutivos con impacto de negocio
**ROI**: Detecta problemas críticos de UX antes de production con análisis cuantificado.

---

## 📄 Comandos de Documentación

### 📚 `/docs` - Gestión de documentación

```bash
/docs
```bash

**Qué hace**: Analiza y actualiza TODA la documentación del proyecto automáticamente (README, CHANGELOG, docs/\*).
**Cuándo usarlo**: Después de features, cambios importantes, para mantener documentación actualizada.
**Flujo**: Analiza conversación → Lee documentación existente → Identifica cambios → Actualiza sistemáticamente

---

## 🗂️ Comandos de Workflow

### 🔄 `/workflow:switch` - Cambio seguro de rama validando PR

```bash
/workflow:switch <target_branch>
```bash

**Qué hace**: Valida PR mergeado, cambia a rama objetivo y limpia workspace temporal.
**Cuándo usarlo**: Al finalizar PRs mergeados para cambiar a main/develop con cleanup completo.
**Flujo**: Bloquea si PR no mergeado → Switch seguro → Limpieza

### 📝 `/workflow:changelog` - Actualización inteligente de changelog

```bash
/workflow:changelog <pr_number>         # Single PR
/workflow:changelog <pr1,pr2,pr3>       # Multiple PRs
```bash

**Qué hace**: Actualiza CHANGELOG.md con PRs mergeados, detecta duplicados automáticamente.
**Cuándo usarlo**: Después de merge para documentar cambios en proyecto.
**Flujo**: Valida PRs mergeados → Detecta duplicados → Actualización atómica con backup

### `/workflow:session-start` - Iniciar sesión documentada

```bash
/workflow:session-start
```bash

**Qué hace**: Inicia sesión de código documentada con objetivos claros y tracking.
**Cuándo usarlo**: Al comenzar trabajo significativo para mantener continuidad.

---

## 📋 Gestión de TODOs

### `/todos:create` - Crear TODOs contextuales

```bash
/todos:create
```bash

**Qué hace**: Convierte hallazgos de análisis en TODOs específicos en el código.
**Cuándo usarlo**: Después de security-scan, review o cuando encuentras issues que no puedes arreglar inmediatamente.

### `/todos:find` - Buscar TODOs existentes

```bash
/todos:find
```bash

**Qué hace**: Escanea y categoriza todos los TODOs/FIXMEs del proyecto.
**Cuándo usarlo**: Para auditoría de deuda técnica o planificación de sprints.

### `/todos:fix` - Resolver TODOs

```bash
/todos:fix
```bash

**Qué hace**: Encuentra y resuelve TODOs existentes de forma sistemática.
**Cuándo usarlo**: Cuando quieres limpiar deuda técnica acumulada.

### `/todos:to-issues` - TODOs a issues GitHub

```bash
/todos:to-issues
```bash

**Qué hace**: Escanea TODOs en código y crea issues profesionales en GitHub automáticamente.
**Cuándo usarlo**: Para convertir deuda técnica en trabajo trackeable y organizado.

---

## 🧹 Comandos de Mantenimiento

### 🧽 `/cleanproject` - Limpieza integral

```bash
/cleanproject
```bash

**Qué hace**: Limpia dead code, optimiza imports, remueve archivos innecesarios.
**Cuándo usarlo**: Antes de releases o periódicamente para mantener el proyecto limpio.

---

## 🔗 Comandos GitHub

### 🔄 `/pr` - Crear pull requests

```bash
/pr [target-branch]
```bash

**Qué hace**: Crea PRs con validación automática de branch, push seguro y metadata completa.
**Cuándo usarlo**: Para crear PRs que faciliten review y mantengan estándares de calidad.
**Flujo**: Valida target branch → **SECURITY REVIEW** → Pre-fetch remoto → Crea branch temporal → Push seguro → PR con metadata

### 🎯 `Usando /review con PRs` - Smart PR Review & Implementation Plan

```bash
# Usar comando /review existente para PRs
/review
```bash

**Qué hace**: El comando /review incluye análisis de PRs con especialistas AI y genera plan técnico detallado.
**Cuándo usarlo**: Para revisar código y PRs obteniendo plan priorizado de mejoras.

### `/issue-manager` - Gestionar y analizar issues de GitHub

```bash
/issue-manager                 # Resumen de issues activos asignados
/issue-manager <issue_number>  # Análisis profundo de issue específico
```bash

**Qué hace**: Proporciona resumen inteligente de tus issues activos o análisis detallado de un issue individual con contexto, complejidad y próximos pasos.
**Cuándo usarlo**: Para obtener visión general de workload o analizar issue específico antes de implementar.
**Funcionalidades**: Dashboard con priorización inteligente, detección de issues stale, estimación de complejidad, archivos afectados

---

## 🌳 Comandos Worktree

### `/worktree:create` - Crear worktree aislado

```bash
/worktree:create <purpose> <parent-branch>
```bash

**Qué hace**: Crea worktree en directorio sibling con rama nueva y upstream remoto.
**Cuándo usarlo**: SIEMPRE para desarrollo (features, bugs, refactoring).
**Flujo**: Valida argumentos → Verifica parent branch → Crea worktree → Configura upstream → Guía para cambio de directorio

### `/worktree:cleanup` - Limpiar worktrees

```bash
/worktree:cleanup <worktree1> [worktree2] [...]
```bash

**Qué hace**: Elimina worktrees específicos con validación de ownership y estado limpio.
**Cuándo usarlo**: Después de mergear PRs o cuando worktrees ya no se necesiten.
**Flujo**: Valida ownership → Verifica estado limpio → Confirmación → Triple cleanup (worktree/local/remote)

**Estándar del equipo:**

- Todo desarrollo se hace en worktrees aislados
- Mantiene workspace principal siempre limpio
- Permite sesiones Claude Code paralelas
- Rollback instantáneo sin conflictos

---

## 🎯 Flujos Típicos

### **🏆 Workflow de Alto Impacto: Feature Nueva**

```bash
# SETUP (desde main/develop)
1. /workflow:session-start               # Configurar workspace
2. /worktree:create feature-name develop # Crear worktree aislado
3. cd ../worktree-feature-name           # Cambiar al worktree

# COMANDOS DE ALTO VALOR (el 80% del impacto)
4. /understand                           # 🎯 Context mapping completo
5. /implement "nueva feature"            # 🚀 Implementation engine
6. /review                              # 🔍 Multi-specialist quality check
7. /pr                                  # Crear PR automático

# ITERACIÓN (si hay findings)
8. /review pr <number>                  # Plan para resolver findings
9. [Resolver según plan]                # Manual o con especialistas
10. Merge + /workflow:changelog + cleanup
```bash

**⚡ Tiempo total con comandos de alto valor: 15-30 minutos** (vs 2-4 horas manual)

> 📚 **Para workflow completo de PR + findings + issues:** Ver `ai-first-workflow.md`

### **🏆 Workflow QA Integration: Feature con Testing**

```bash
# DEVELOPMENT (desde worktree)
1. /understand                           # Context mapping
2. /implement "nueva feature"            # Feature implementation
3. /agent:qa-playwright                  # E2E testing & visual analysis
4. /review                              # Multi-specialist review
5. /pr                                  # PR con QA evidence

# TESTING ESPECÍFICO
6. /agent:qa-playwright localhost:3000                       # E2E testing & visual analysis
7. /agent:qa-playwright localhost:3000 # E2E testing & visual analysis
```bash

### Bug Fix Urgente

```bash
1. /worktree:create fix-bug-name main     # Worktree desde main
2. cd ../worktree-fix-bug-name            # Cambiar al worktree
3. claude /workflow:session-start         # Nueva sesión en worktree
4. /understand                            # Entender el problema
5. Arreglar el código
6. /test                                 # Validar fix
7. /commit "fix: descripción"            # Commit inmediato
```bash

### Limpieza de Código

```bash
1. /todos:find                  # Ver deuda técnica
2. /todos:fix                   # Resolver pendientes
3. /cleanproject  # Limpiar proyecto
4. /make-it-pretty             # Mejorar legibilidad
5. /format                     # Formatear todo
6. /commit "chore: cleanup"    # Documentar limpieza
```bash

### Análisis Estratégico Completo

```bash
1. /deep "problema arquitectónico"           # Razonamiento profundo
2. /agent:tech-lead-orchestrator             # Análisis estratégico multi-experto
3. /understand                      # Mapear codebase
4. /review                         # Revisar estado actual
5. Implementar solución
6. /docs                          # Documentar decisiones
```bash

---

## 💡 Tips de Uso

- **Combina comandos**: Usa flujos secuenciales para mayor eficiencia
- **Iterativo**: Los comandos recuerdan contexto entre ejecuciones
- **Seguridad primero**: Siempre usa /agent:security-reviewer antes de production
- **Test frecuente**: Ejecuta /test después de cambios significativos
- **QA automation**: Usa /agent:qa-playwright para validación comprehensiva de features críticas
- **E2E testing**: Incluye /agent:qa-playwright para detección sistemática de edge cases
- **Documenta cambios**: Usa /docs para mantener documentación actualizada
- **Análisis profundo**: Usa /deep para decisiones arquitectónicas críticas
- **Gestión de deuda**: Convierte TODOs en issues con /todos:to-issues


---

_📝 [Editar esta página en GitHub](https://github.com/trivance-ai/trivance-ai-orchestrator/edit/main/.claude/human-handbook/docs/commands-guide.md)_
