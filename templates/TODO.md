# Templates TODO List

## 🔄 Pendientes de Sincronización

### **Actualizar Templates con Nueva Arquitectura .claude/**

**Prioridad**: Media  
**Descripción**: Actualizar todos los templates para reflejar la nueva estructura de agentes y configuraciones .claude/

#### **Archivos a actualizar:**

1. **CLAUDE.md.template**
   - Actualizar referencias de agentes según nueva jerarquía
   - Sincronizar con mejoras hechas en CLAUDE.md actual
   - Validar todas las referencias @.claude/

2. **README.md.template** 
   - Actualizar sección de arquitectura con nueva estructura .claude/
   - Agregar información sobre sistema de agentes
   - Sincronizar comandos Claude Code disponibles

3. **ecosystem.config.js.template**
   - Validar que coincida con configuración actual
   - Actualizar paths si es necesario

4. **workspace.code-workspace.template**
   - Actualizar configuraciones VS Code
   - Sincronizar settings con mejores prácticas actuales

#### **Validaciones requeridas:**
- [ ] Todas las referencias @.claude/ funcionan
- [ ] Agentes referenciados existen realmente  
- [ ] Comandos mencionados están disponibles
- [ ] Paths y configuraciones son correctas

#### **Contexto:**
Los templates son para generar el **workspace completo de Trivance** (4 repositorios), NO para este repo específico. Deben reflejar la arquitectura actual de .claude/ pero aplicada al contexto del workspace generado.

---

**Nota**: Este TODO se creó durante la auditoría de consistencia del 2025-01-14. Los templates necesitan sincronización con las mejoras implementadas en la estructura .claude/ y CLAUDE.md.