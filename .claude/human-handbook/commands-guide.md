# Guía Práctica de Comandos Claude Code

*Comandos organizados por importancia y impact en productividad*

## ⚡ Comandos de Alto Valor (ESENCIALES)

### 🎯 `/understand` - Context Mapping
```bash
/understand
```
**Qué hace**: Analiza todo el codebase y explica arquitectura, patrones y funcionamiento completo.
**Cuándo usarlo**: SIEMPRE antes de implementar. Primera acción en cualquier proyecto.
**ROI**: 30 min ahorran 3+ horas de refactoring por inconsistencias.

### 🚀 `/implement` - Motor de Implementación Automática
```bash
/implement "nueva feature de dashboard con notificaciones"
```
**Qué hace**: Motor central - planifica e implementa features completas con especialistas automáticos.
**Cuándo usarlo**: Para cualquier implementación nueva. Reemplaza desarrollo manual.
**Flujo**: Planning (tech-lead-orchestrator) → **USER AUTHORIZATION** → Coding (specialists) → Testing → Documentation
**ROI**: Reduce 4+ horas desarrollo manual a 20-30 minutos.

### 🔍 `/review` - Quality Assurance Multi-Especialista
```bash
/review
```
**Qué hace**: Análisis simultáneo de security, performance, code quality con múltiples especialistas.
**Cuándo usarlo**: Después de cualquier implementación, ANTES de hacer PR.
**ROI**: 5 min previenen 2+ horas de fixes post-merge.

### ✅ `/test` - Validation Engine
```bash
/test
```
**Qué hace**: Ejecuta todos los tests, detecta fallos y sugiere/aplica fixes automáticos.
**Cuándo usarlo**: Después de cambios significativos, antes de commits importantes.
**ROI**: Debugging de horas a minutos.

---

## 🚀 Comandos Fundamentales

### 💾 `/commit` - Commits inteligentes
```bash
/commit "descripción del cambio"
```
**Qué hace**: Analiza tus cambios y crea commits semánticos con validaciones automáticas.
**Cuándo usarlo**: Después de completar cualquier cambio en código.
**Ejemplo**: `commit "fix user login validation"` → genera commit con mensaje optimizado.


### `/format` - Formateo consistente
```bash
/format
```
**Qué hace**: Formatea todo el código siguiendo las convenciones del proyecto.
**Cuándo usarlo**: Antes de commits o cuando el código se ve inconsistente.

---

## 🔧 Comandos de Desarrollo

### 🔄 `/refactor` - Refactoring inteligente
```bash
/refactor "mejorar performance de consultas de base de datos"
```
**Qué hace**: Reestructura código manteniendo funcionalidad, mejorando calidad.
**Cuándo usarlo**: Cuando el código funciona pero necesita mejoras estructurales.


### `/make-it-pretty` - Mejora de legibilidad
```bash
/make-it-pretty
```
**Qué hace**: Mejora legibilidad del código preservando funcionalidad exacta (naming, organización).
**Cuándo usarlo**: Cuando el código funciona pero es difícil de leer o mantener.

### `/remove-comments` - Eliminar comentarios obvios
```bash
/remove-comments
```
**Qué hace**: Limpia comentarios redundantes preservando los que añaden valor real.
**Cuándo usarlo**: Para limpiar código con exceso de comentarios obvios o redundantes.

---

## 🔍 Comandos de Análisis


### 🔒 `/security-scan` - Auditoría de seguridad
```bash
/security-scan
```
**Qué hace**: Escanea vulnerabilidades, credenciales expuestas y problemas de seguridad.
**Cuándo usarlo**: Antes de deployments o periódicamente en código crítico.

### 🧠 `/deep` - Razonamiento profundo
```bash
/deep "problema complejo o decisión arquitectónica"
```
**Qué hace**: Activa análisis profundo para problemas complejos y decisiones estratégicas.
**Cuándo usarlo**: Planificación estratégica, decisiones arquitectónicas críticas, auditorías profundas.
**Flujo**: Análisis multi-perspectiva → Investigación de causa raíz → Pensamiento sistémico → Soluciones alternativas



---

## 🧪 Comandos de QA y Testing

### 🎯 `/qa-e2e` - QA End-to-End Automation
```bash
/qa-e2e [target-url] [--browsers=chrome,firefox,safari] [--critical]
```
**Qué hace**: Ejecuta testing funcional completo usando Playwright automation con agent delegation.
**Cuándo usarlo**: Para validación comprehensiva después de features, antes de deployments.
**Flujo**: Analysis → Agent Delegation → Cross-browser Testing → Quality Report
**ROI**: Reduce testing manual de horas a minutos con cross-browser coverage.

---

## 📄 Comandos de Documentación

### 📚 `/docs` - Gestión de documentación
```bash
/docs
```
**Qué hace**: Analiza y actualiza TODA la documentación del proyecto automáticamente (README, CHANGELOG, docs/*).
**Cuándo usarlo**: Después de features, cambios importantes, para mantener documentación actualizada.
**Flujo**: Analiza conversación → Lee documentación existente → Identifica cambios → Actualiza sistemáticamente

---

## 🗂️ Comandos de Workflow

### 🔄 `/workflow:switch` - Cambio seguro de rama validando PR
```bash
/workflow:switch <target_branch>
```
**Qué hace**: Valida PR mergeado, cambia a rama objetivo y limpia workspace temporal.
**Cuándo usarlo**: Al finalizar PRs mergeados para cambiar a main/develop con cleanup completo.
**Flujo**: Bloquea si PR no mergeado → Switch seguro → Limpieza

### 📝 `/workflow:changelog` - Actualización inteligente de changelog
```bash
/workflow:changelog <pr_number>         # Single PR
/workflow:changelog <pr1,pr2,pr3>       # Multiple PRs
```
**Qué hace**: Actualiza CHANGELOG.md con PRs mergeados, detecta duplicados automáticamente.
**Cuándo usarlo**: Después de merge para documentar cambios en proyecto.
**Flujo**: Valida PRs mergeados → Detecta duplicados → Actualización atómica con backup

### `/workflow:session-start` - Iniciar sesión documentada
```bash
/workflow:session-start
```
**Qué hace**: Inicia sesión de código documentada con objetivos claros y tracking.
**Cuándo usarlo**: Al comenzar trabajo significativo para mantener continuidad.


---

## 📋 Gestión de TODOs

### `/todos:create` - Crear TODOs contextuales
```bash
/todos:create
```
**Qué hace**: Convierte hallazgos de análisis en TODOs específicos en el código.
**Cuándo usarlo**: Después de security-scan, review o cuando encuentras issues que no puedes arreglar inmediatamente.

### `/todos:find` - Buscar TODOs existentes
```bash
/todos:find
```
**Qué hace**: Escanea y categoriza todos los TODOs/FIXMEs del proyecto.
**Cuándo usarlo**: Para auditoría de deuda técnica o planificación de sprints.

### `/todos:fix` - Resolver TODOs
```bash
/todos:fix
```
**Qué hace**: Encuentra y resuelve TODOs existentes de forma sistemática.
**Cuándo usarlo**: Cuando quieres limpiar deuda técnica acumulada.

### `/todos:to-issues` - TODOs a issues GitHub
```bash
/todos:to-issues
```
**Qué hace**: Escanea TODOs en código y crea issues profesionales en GitHub automáticamente.
**Cuándo usarlo**: Para convertir deuda técnica en trabajo trackeable y organizado.

---

## 🧹 Comandos de Mantenimiento

### 🧽 `/cleanproject` - Limpieza integral
```bash
/cleanproject
```
**Qué hace**: Limpia dead code, optimiza imports, remueve archivos innecesarios.
**Cuándo usarlo**: Antes de releases o periódicamente para mantener el proyecto limpio.

---

## 🔗 Comandos GitHub


### 🔄 `/pr` - Crear pull requests
```bash
/pr [target-branch]
```
**Qué hace**: Crea PRs con validación automática de branch, push seguro y metadata completa.
**Cuándo usarlo**: Para crear PRs que faciliten review y mantengan estándares de calidad.
**Flujo**: Valida target branch → **SECURITY REVIEW** → Pre-fetch remoto → Crea branch temporal → Push seguro → PR con metadata


### 🎯 `/review pr` - Smart PR Review & Implementation Plan
```bash
/review pr <number>
```
**Qué hace**: Analiza findings de PR reviews con especialistas AI y genera plan técnico detallado para implementación manual.
**Cuándo usarlo**: Para revisar PRs y obtener plan priorizado sin crear issues masivos en GitHub.

### `/issue-manager` - Gestionar y analizar issues de GitHub
```bash
/issue-manager                 # Resumen de issues activos asignados
/issue-manager <issue_number>  # Análisis profundo de issue específico
```
**Qué hace**: Proporciona resumen inteligente de tus issues activos o análisis detallado de un issue individual con contexto, complejidad y próximos pasos.
**Cuándo usarlo**: Para obtener visión general de workload o analizar issue específico antes de implementar.
**Funcionalidades**: Dashboard con priorización inteligente, detección de issues stale, estimación de complejidad, archivos afectados

---

## 🌳 Comandos Worktree

### `/worktree:create` - Crear worktree aislado
```bash
/worktree:create <purpose> <parent-branch>
```
**Qué hace**: Crea worktree en directorio sibling con rama nueva y upstream remoto.
**Cuándo usarlo**: SIEMPRE para desarrollo (features, bugs, refactoring).
**Flujo**: Valida argumentos → Verifica parent branch → Crea worktree → Configura upstream → Guía para cambio de directorio

### `/worktree:cleanup` - Limpiar worktrees
```bash
/worktree:cleanup <worktree1> [worktree2] [...]
```
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
```

**⚡ Tiempo total con comandos de alto valor: 15-30 minutos** (vs 2-4 horas manual)

> 📚 **Para workflow completo de PR + findings + issues:** Ver `ai-first-workflow.md`

### **🏆 Workflow QA Integration: Feature con Testing**
```bash
# DEVELOPMENT (desde worktree)
1. /understand                           # Context mapping
2. /implement "nueva feature"            # Feature implementation  
3. /qa-e2e --critical                    # Critical path validation
4. /review                              # Multi-specialist review
5. /pr                                  # PR con QA evidence

# TESTING ESPECÍFICO
6. /qa-e2e --browsers=chrome,firefox     # Cross-browser testing
7. /agent:playwright-qa-specialist       # Advanced test scenarios
```

### Bug Fix Urgente
```bash
1. /worktree:create fix-bug-name main     # Worktree desde main
2. cd ../worktree-fix-bug-name            # Cambiar al worktree
3. claude /workflow:session-start         # Nueva sesión en worktree
4. /understand                            # Entender el problema
5. Arreglar el código
6. /test                                 # Validar fix
7. /commit "fix: descripción"            # Commit inmediato
```

### Limpieza de Código
```bash
1. /todos:find                  # Ver deuda técnica
2. /todos:fix                   # Resolver pendientes
3. /cleanproject  # Limpiar proyecto
4. /make-it-pretty             # Mejorar legibilidad
5. /format                     # Formatear todo
6. /commit "chore: cleanup"    # Documentar limpieza
```

### Análisis Estratégico Completo
```bash
1. /deep "problema arquitectónico"           # Razonamiento profundo
2. /agent:tech-lead-orchestrator             # Análisis estratégico multi-experto
3. /understand                      # Mapear codebase
4. /review                         # Revisar estado actual
5. Implementar solución
6. /docs                          # Documentar decisiones
```

---

## 💡 Tips de Uso

- **Combina comandos**: Usa flujos secuenciales para mayor eficiencia
- **Iterativo**: Los comandos recuerdan contexto entre ejecuciones
- **Seguridad primero**: Siempre usa /security-scan antes de production
- **Test frecuente**: Ejecuta /test después de cambios significativos
- **QA automation**: Usa /qa-e2e para validación comprehensiva de features críticas
- **Cross-browser testing**: Incluye /qa-e2e --browsers para máxima compatibilidad
- **Documenta cambios**: Usa /docs para mantener documentación actualizada
- **Análisis profundo**: Usa /deep para decisiones arquitectónicas críticas
- **Gestión de deuda**: Convierte TODOs en issues con /todos:to-issues