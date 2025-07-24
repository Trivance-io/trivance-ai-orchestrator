---
description: "Validar consistencia funcional, buenas prácticas y seguridad"
argument-hint: "Área específica (ej: 'security', 'architecture', 'performance') - opcional"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "TodoWrite", "WebSearch"]
---

# Auditoría de Consistencia Funcional y Seguridad

## 1. Contexto del Proyecto
Estructura del proyecto: !`find . -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | head -20`

Archivos de configuración: !`find . -name "package.json" -o -name "tsconfig.json" -o -name "*.config.*" -o -name ".env*" | head -10`

## 2. Enfoque de Auditoría
**Área específica:** $ARGUMENTS (si no se especifica, revisión completa)

## 3. Validaciones Sistemáticas

### A. Consistencia Arquitectónica
Verificar adherencia a patrones de CLAUDE.md:

- **Single Responsibility**: ¿Clases/funciones con propósito único?
- **Composition over Inheritance**: ¿Uso apropiado de composición?
- **Dependency Inversion**: ¿Dependencias apuntan a abstracciones?
- **Repository Pattern**: ¿Acceso a datos correctamente abstraído?
- **Strategy Pattern**: ¿Algoritmos intercambiables sin condicionales?
- **Event-Driven**: ¿Desacoplamiento temporal apropiado?

### B. Seguridad (CRÍTICO)
1. **Gestión de Secretos**:
   - ❌ Hardcoded credentials, API keys, tokens
   - ❌ Secrets en logs o outputs
   - ✅ Uso de variables de entorno
   - ✅ .gitignore apropiado

2. **Validación de Entrada**:
   - ❌ SQL injection vulnerabilities
   - ❌ XSS vulnerabilities  
   - ❌ Input sin sanitizar
   - ✅ Validación en todos los endpoints

3. **Autenticación/Autorización**:
   - ❌ Endpoints sin protección
   - ❌ Tokens inseguros
   - ✅ Principio de mínimo privilegio

### C. Buenas Prácticas de Código
1. **Estándares de CLAUDE.md**:
   - Indentación correcta (2 espacios JS/TS, 4 Python)
   - ES modules vs CommonJS
   - Naming conventions apropiadas
   - Comentarios solo para WHY/edge cases

2. **Patrones de Error**:
   - ✅ Error handling consistente
   - ✅ Fail fast implementation
   - ❌ Silent failures
   - ❌ Exceptions no manejadas

### D. Consistencia Funcional
1. **Coherencia de API**:
   - Naming consistente en endpoints
   - Response formats estandarizados
   - HTTP status codes apropiados

2. **Data Flow**:
   - Validación en boundaries
   - Transformaciones explícitas
   - State management coherente

## 4. Tu Tarea - Auditoría Profunda

**Ejecuta análisis sistemático:**

1. **Escanear codebase completo** para patrones problemáticos
2. **Verificar adherencia a principios arquitectónicos**
3. **Identificar vulnerabilidades de seguridad**
4. **Evaluar consistencia funcional**
5. **Medir calidad según estándares definidos**

### Metodología de Evaluación:
- 🔴 **Crítico**: Vulnerabilidades de seguridad, errores fatales
- 🟡 **Alto**: Violaciones arquitectónicas, inconsistencias mayores  
- 🟢 **Medio**: Mejoras de código, optimizaciones
- ⚪ **Bajo**: Estilo, nomenclatura, documentación

## 5. Entregables Esperados

### Reporte de Consistencia:
1. **Executive Summary** (estado general + score 1-10)
2. **Issues Críticos** (seguridad, funcionalidad)
3. **Violaciones Arquitectónicas** (vs patrones CLAUDE.md)
4. **Inconsistencias Funcionales** (APIs, data flow)
5. **Plan de Remediación** (priorizado por impacto)

### Verificaciones Automáticas:
```bash
# Buscar patrones problemáticos
grep -r "password.*=" . --include="*.js" --include="*.ts"
grep -r "api_key.*=" . --include="*.py"  
grep -r "console.log" . --include="*.js" --include="*.ts"
```

## 6. Criterios de Calidad

### Funcional:
- ✅ **Robustez**: Manejo apropiado de edge cases
- ✅ **Escalabilidad**: Arquitectura que soporta crecimiento
- ✅ **Mantenibilidad**: Código fácil de modificar
- ✅ **Testabilidad**: Diseño que facilita testing

### Seguridad:
- ✅ **Defense in Depth**: Múltiples capas de protección
- ✅ **Least Privilege**: Mínimos permisos necesarios
- ✅ **Secure by Default**: Configuración segura por defecto
- ✅ **Data Protection**: Encriptación y sanitización

## 7. Enfoque Estratégico
- Priorizar problemas que afectan production
- Considerar impacto en usuarios finales
- Evaluar deuda técnica acumulada
- Recomendar refactoring incremental