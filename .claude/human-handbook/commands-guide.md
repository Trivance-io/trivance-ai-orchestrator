# Guía Práctica de Comandos Claude Code

## 🚀 Comandos Básicos

### 💾 `/commit` - Commits inteligentes
```bash
/commit "descripción del cambio"
```
**Qué hace**: Analiza tus cambios y crea commits semánticos con validaciones automáticas.
**Cuándo usarlo**: Después de completar cualquier cambio en código.
**Ejemplo**: `commit "fix user login validation"` → genera commit con mensaje optimizado.

### ✅ `/test` - Ejecutar tests con auto-fix
```bash
/test
```
**Qué hace**: Ejecuta todos los tests, detecta fallos y sugiere fixes automáticos.
**Cuándo usarlo**: Antes de commits importantes o después de cambios significativos.

### `/format` - Formateo consistente
```bash
/format
```
**Qué hace**: Formatea todo el código siguiendo las convenciones del proyecto.
**Cuándo usarlo**: Antes de commits o cuando el código se ve inconsistente.

---

## 🔧 Comandos de Desarrollo

### ⚙️ `/implement` - Motor de implementación
```bash
/implement "nueva feature de dashboard con notificaciones"
```
**Qué hace**: Planifica e implementa features completas paso a paso.
**Cuándo usarlo**: Para implementar nuevas funcionalidades desde cero.
**Flujo**: Analiza → Planifica → Implementa → Valida → Documenta

### `/scaffold` - Generar estructuras
```bash
/scaffold "API para gestión de usuarios"
```
**Qué hace**: Genera estructura completa de archivos siguiendo patrones del proyecto.
**Cuándo usarlo**: Al empezar nuevos módulos, APIs o componentes.

### 🔄 `/refactor` - Refactoring inteligente
```bash
/refactor "mejorar performance de consultas de base de datos"
```
**Qué hace**: Reestructura código manteniendo funcionalidad, mejorando calidad.
**Cuándo usarlo**: Cuando el código funciona pero necesita mejoras estructurales.

### `/fix-imports` - Reparar imports rotos
```bash
/fix-imports
```
**Qué hace**: Encuentra y repara sistemáticamente imports rotos por file moves o renames.
**Cuándo usarlo**: Después de refactoring, reestructuración de carpetas o cuando hay errores de imports.

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

### 🔄 `/switch` - Cambio seguro de rama con limpieza
```bash
/switch <target_branch>
```
**Qué hace**: Cambia a rama objetivo, actualiza desde remoto y elimina ramas temporales de PR con confirmación.
**Cuándo usarlo**: Al finalizar PRs para cambiar a main/develop y limpiar workspace.
**Flujo**: Validación seguridad → Checkout/actualización → Limpieza temporal confirmada

---

## 🔍 Comandos de Análisis

### 🧪 `/understand` - Comprensión profunda
```bash
/understand
```
**Qué hace**: Analiza todo el codebase y explica arquitectura, patrones y funcionamiento.
**Cuándo usarlo**: Al empezar en un proyecto nuevo o cuando necesitas entender código complejo.

### 🔎 `/review` - Revisión de código
```bash
/review
```
**Qué hace**: Revisa cambios recientes y sugiere mejoras de calidad, seguridad y performance.
**Cuándo usarlo**: Después de implementar features importantes o antes de hacer merge.

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
**Qué hace**: Activa capacidades máximas de análisis para problemas complejos y decisiones estratégicas.
**Cuándo usarlo**: Planificación estratégica, decisiones arquitectónicas críticas, auditorías profundas.
**Flujo**: Análisis multi-perspectiva → Investigación de causa raíz → Pensamiento sistémico → Soluciones alternativas

### `/e-team` - Análisis de equipo experto
```bash
/e-team "challenge técnico o arquitectónico"
```
**Qué hace**: Análisis estratégico con equipos de expertos virtuales especializados.
**Cuándo usarlo**: Evaluación de challenges complejos, validación de enfoques técnicos.
**Flujo**: Claude Code Strategist → Security Architect → Technical Architect → Strategic Director

### `/explain-like-senior` - Explicación nivel senior
```bash
/explain-like-senior
```
**Qué hace**: Explica código como desarrollador senior, enfocándose en el por qué detrás de las decisiones.
**Cuándo usarlo**: Para mentorización, entendimiento profundo de arquitectura y patrones de código.

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

## 📝 Comandos de Gestión

### `/create-todos` - Crear TODOs contextuales
```bash
/create-todos
```
**Qué hace**: Convierte hallazgos de análisis en TODOs específicos en el código.
**Cuándo usarlo**: Después de security-scan, review o cuando encuentras issues que no puedes arreglar inmediatamente.

### `/fix-todos` - Resolver TODOs
```bash
/fix-todos
```
**Qué hace**: Encuentra y resuelve TODOs existentes de forma sistemática.
**Cuándo usarlo**: Cuando quieres limpiar deuda técnica acumulada.

### `/find-todos` - Buscar TODOs existentes
```bash
/find-todos
```
**Qué hace**: Escanea y categoriza todos los TODOs/FIXMEs del proyecto.
**Cuándo usarlo**: Para auditoría de deuda técnica o planificación de sprints.

### `/todos-to-issues` - TODOs a issues GitHub
```bash
/todos-to-issues
```
**Qué hace**: Escanea TODOs en código y crea issues profesionales en GitHub automáticamente.
**Cuándo usarlo**: Para convertir deuda técnica en trabajo trackeable y organizado.

### `/session-start` - Iniciar sesión documentada
```bash
/session-start
```
**Qué hace**: Inicia sesión de código documentada con objetivos claros y tracking.
**Cuándo usarlo**: Al comenzar trabajo significativo para mantener continuidad.

### `/session-end` - Cerrar sesión documentada
```bash
/session-end
```
**Qué hace**: Cierra sesión con summary completo y handoff para futuras sesiones.
**Cuándo usarlo**: Al finalizar trabajo para documentar progreso y facilitar continuidad.

---

## 🏢 Comandos Enterprise

### `/contributing` - Preparar contribuciones
```bash
/contributing
```
**Qué hace**: Prepara PRs completos con análisis de issues, tests y documentación.
**Cuándo usarlo**: Antes de contribuir a repos, especialmente open source.

### 🔄 `/pr` - PRs enterprise-grade
```bash
/pr [target-branch]
```
**Qué hace**: Crea PRs siguiendo estándares enterprise con branch validation automática, security hardening y retry logic optimizado.
**Cuándo usarlo**: Para crear PRs profesionales que facilitan review y cumplan standards enterprise.
**Flujo**: Valida target branch → Pre-fetch remoto → Crea branch temporal → Push seguro → PR con metadata

### 🧽 `/cleanproject` - Limpieza integral
```bash
/cleanproject
```
**Qué hace**: Limpia dead code, optimiza imports, remueve archivos innecesarios.
**Cuándo usarlo**: Antes de releases o periódicamente para mantener el proyecto limpio.

### 🎯 `/findings-to-issues` - Hallazgos a issues GitHub
```bash
/findings-to-issues
```
**Qué hace**: Convierte hallazgos de PR reviews en issues GitHub trackeable con categorización inteligente.
**Cuándo usarlo**: Después de reviews importantes para gestionar deuda técnica y seguimiento.

### `/issues-to-solved` - Resolver issues de PR automáticamente
```bash
/issues-to-solved <pr_number>
```
**Qué hace**: Extrae issues asociados a PR, analiza prioridades, genera plan de implementación y ejecuta fixes seguros automáticamente.
**Cuándo usarlo**: Después de crear issues con findings-to-issues, para planificar y resolver sistemáticamente.
**Flujo**: Extrae issues → Prioriza (CRITICAL/HIGH/MEDIUM/LOW) → Plan estructurado → Ejecución opcional

---

## 🎯 Flujos Típicos

### Desarrollo de Feature Nueva
```bash
1. /session-start                 # Documentar objetivos
2. /understand                    # Entender contexto
3. /implement "nueva feature"     # Implementar
4. /test                         # Validar funcionamiento  
5. /review                       # Revisar calidad
6. /security-scan                # Verificar seguridad
7-10. Seguir workflow AI-First    # Ver: ai-firts-workflow.md
```

> 📚 **Para workflow completo de PR + findings + issues:** Ver `ai-firts-workflow.md`

### Bug Fix Urgente
```bash
1. /understand                   # Entender el problema
2. Arreglar el código
3. /test                        # Validar fix
4. /commit "fix: descripción"   # Commit inmediato
```

### Limpieza de Código
```bash
1. /find-todos                  # Ver deuda técnica
2. /fix-todos                   # Resolver pendientes
3. /cleanproject               # Limpiar proyecto
4. /make-it-pretty             # Mejorar legibilidad
5. /format                     # Formatear todo
6. /commit "chore: cleanup"    # Documentar limpieza
```

### Análisis Estratégico Completo
```bash
1. /deep "problema arquitectónico"  # Razonamiento profundo
2. /e-team "challenge complejo"     # Análisis multi-experto
3. /understand                      # Mapear codebase
4. /review                         # Revisar estado actual
5. Implementar solución
6. /docs                           # Documentar decisiones
```

---

## 💡 Tips de Uso

- **Combina comandos**: Usa flujos secuenciales para máximo valor
- **Iterativo**: Los comandos recuerdan contexto entre ejecuciones
- **Seguridad primero**: Siempre usa security-scan antes de production
- **Test frecuente**: Ejecuta /test después de cambios significativos
- **Documenta cambios**: Usa /docs para mantener documentación actualizada
- **Análisis profundo**: Usa /deep para decisiones arquitectónicas críticas
- **Gestión de deuda**: Convierte TODOs en issues con /todos-to-issues