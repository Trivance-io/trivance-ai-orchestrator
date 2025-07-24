# Documentation Update Assistant

Asiste en la actualización y mantenimiento de la documentación del repositorio trivance-dev-config.

## Argumentos Disponibles
Usa `$ARGUMENTS` para especificar el foco:
- `architecture` - Actualizar documentación de arquitectura
- `commands` - Actualizar referencia de comandos
- `environments` - Actualizar guía de environments
- `troubleshooting` - Actualizar guía de solución de problemas
- `all` - Revisar toda la documentación

## Proceso de Actualización

### 1. Análisis de Cambios Recientes
Revisa los cambios recientes en el código que podrían requerir actualización de documentación:
- Nuevos scripts en `./scripts/`
- Cambios en configuración (`./config/*.json`)
- Nuevos templates (`./templates/`)
- Modificaciones en Docker (`./docker/`)

### 2. Verificación de Consistencia
Asegúrate de que la documentación esté alineada con:
- **Comandos actuales**: Verificar que todos los comandos documentados existen y funcionan
- **URLs y puertos**: Confirmar que todos los endpoints documentados son correctos
- **Archivos y rutas**: Verificar que todas las rutas mencionadas existen
- **Versiones**: Actualizar versiones de dependencias si es necesario

### 3. Actualización de Templates
Revisa y sugiere actualizaciones para templates en `./templates/`:
- `CLAUDE.md.template` - Configuración de Claude Code
- `README.md.template` - Template de README para repos
- `ecosystem.config.js.template` - Configuración PM2
- Templates de configuración IDE

### 4. Cross-Referencias
Verifica que todas las referencias cruzadas funcionen:
- Links internos entre documentos
- Referencias a archivos y scripts
- Imports en archivos CLAUDE.md
- Enlaces a documentación externa

### 5. Validación de Imports
Específicamente para archivos CLAUDE.md, verificar que todos los imports sean válidos:
```bash
# Verificar que existen todos los archivos referenciados
@./README.md
@./docs/ARCHITECTURE.md
@./docs/COMMANDS.md
# ... etc
```

### 6. Propuestas de Mejora
Basándome en el análisis, proporcionar:
- **Gaps identificados**: Documentación faltante
- **Información obsoleta**: Contenido que necesita actualización  
- **Mejoras de estructura**: Reorganización sugerida
- **Nuevas secciones**: Contenido adicional recomendado

### 7. Implementación de Cambios
Para el foco especificado en `$ARGUMENTS`:
- Editar los archivos de documentación correspondientes
- Actualizar referencias y enlaces
- Mejorar claridad y estructura
- Agregar ejemplos si es necesario

## Ejemplos de Uso

```bash
# Actualizar documentación de arquitectura
/doc-update architecture

# Revisar y actualizar comandos
/doc-update commands

# Actualizar toda la documentación
/doc-update all

# Foco específico en troubleshooting
/doc-update troubleshooting
```

## Resultados Esperados
Al final del proceso, proporcionar:
- ✅ **Lista de archivos actualizados**
- 📝 **Resumen de cambios realizados**
- ⚠️ **Advertencias o issues encontrados**
- 🔗 **Validación de todos los imports y links**
- 💡 **Recomendaciones para mantenimiento futuro**

**Nota**: Siempre verificar que los cambios en documentación no rompan la funcionalidad existente del sistema.