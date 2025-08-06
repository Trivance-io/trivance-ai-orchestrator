# Guía Práctica de Comandos Claude Code

## 🚀 Comandos Básicos (Úsalos diario)

### `/commit` - Commits inteligentes
```bash
/commit "descripción del cambio"
```
**Qué hace**: Analiza tus cambios y crea commits semánticos con validaciones automáticas.
**Cuándo usarlo**: Después de completar cualquier cambio en código.
**Ejemplo**: `commit "fix user login validation"` → genera commit con mensaje optimizado.

### `/test` - Ejecutar tests con auto-fix
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

### `/implement` - Motor de implementación
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

### `/refactor` - Refactoring inteligente
```bash
/refactor "mejorar performance de consultas de base de datos"
```
**Qué hace**: Reestructura código manteniendo funcionalidad, mejorando calidad.
**Cuándo usarlo**: Cuando el código funciona pero necesita mejoras estructurales.

---

## 🔍 Comandos de Análisis

### `/understand` - Comprensión profunda
```bash
/understand
```
**Qué hace**: Analiza todo el codebase y explica arquitectura, patrones y funcionamiento.
**Cuándo usarlo**: Al empezar en un proyecto nuevo o cuando necesitas entender código complejo.

### `/review` - Revisión de código
```bash
/review
```
**Qué hace**: Revisa cambios recientes y sugiere mejoras de calidad, seguridad y performance.
**Cuándo usarlo**: Después de implementar features importantes o antes de hacer merge.

### `/security-scan` - Auditoría de seguridad
```bash
/security-scan
```
**Qué hace**: Escanea vulnerabilidades, credenciales expuestas y problemas de seguridad.
**Cuándo usarlo**: Antes de deployments o periódicamente en código crítico.

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

---

## 🏢 Comandos Enterprise

### `/contributing` - Preparar contribuciones
```bash
/contributing
```
**Qué hace**: Prepara PRs completos con análisis de issues, tests y documentación.
**Cuándo usarlo**: Antes de contribuir a repos, especialmente open source.

### `/pr` - PRs enterprise-grade
```bash
/pr [--draft] [target-branch]
```
**Qué hace**: Crea PRs siguiendo estándares de Google, Netflix y Shopify con estructura automática.
**Cuándo usarlo**: Para crear PRs profesionales que facilitan review y cumplan standards enterprise.

### `/cleanproject` - Limpieza integral
```bash
/cleanproject
```
**Qué hace**: Limpia dead code, optimiza imports, remueve archivos innecesarios.
**Cuándo usarlo**: Antes de releases o periódicamente para mantener el proyecto limpio.

---

## 🎯 Flujos Típicos

### Desarrollo de Feature Nueva
```bash
1. /understand                    # Entender contexto
2. /implement "nueva feature"     # Implementar
3. /test                         # Validar funcionamiento  
4. /review                       # Revisar calidad
5. /security-scan                # Verificar seguridad
6. /commit                       # Commit limpio
```

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
4. /format                     # Formatear todo
5. /commit "chore: cleanup"    # Documentar limpieza
```

---

## 💡 Tips de Uso

- **Combina comandos**: Usa flujos secuenciales para máximo valor
- **Iterativo**: Los comandos recuerdan contexto entre ejecuciones
- **Seguridad primero**: Siempre usa security-scan antes de production
- **Test frecuente**: Ejecuta /test después de cambios significativos
- **Documenta cambios**: Usa commits descriptivos para historial claro

*Esta guía cubre los 25 comandos disponibles organizados por frecuencia de uso y complejidad.*