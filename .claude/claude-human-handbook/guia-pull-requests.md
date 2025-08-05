# Guía Completa: Pull Requests con Claude Code

*Flujo paso a paso desde desarrollo hasta integración exitosa*

## 🎯 ¿Para qué es esta guía?

Esta guía te enseña cómo usar Claude Code para manejar Pull Requests de forma inteligente:
- Crear PRs con templates automáticos
- Extraer issues de reviews automáticamente  
- Rastrear todo el proceso con logs organizados
- Resolver issues encontrados con Claude Code

---

## 📋 FLUJO COMPLETO PASO A PASO

### **PASO 1: Desarrollo Inicial**
*Aquí es donde Claude Code implementa la funcionalidad*

```
👤 TÚ: "Claude, implementa autenticación con Google OAuth"
🤖 CLAUDE CODE: [Implementa el código necesario]
👤 TÚ: [Revisas y pruebas los cambios localmente]
```

**¿Qué hacer aquí?**
- Revisar que el código funcione como esperabas
- Probar la funcionalidad localmente
- Hacer ajustes si es necesario pidiendo a Claude Code

---

### **PASO 2: Crear Commits**
*Guarda los cambios con descripción clara*

```bash
/commit
```

**¿Qué hace este comando?**
- Claude Code analiza todos los cambios realizados
- Crea commits con mensajes descriptivos siguiendo buenas prácticas
- Organiza los cambios de forma lógica

**Ejemplo de resultado:**
```
✅ Commit creado: "feat: implement Google OAuth authentication"
✅ Commit creado: "docs: update README with OAuth setup instructions"
```

---

### **PASO 3: Crear Pull Request**
*Crea el PR con template automático y logging*

```bash
/pr
```

**¿Qué hace este comando paso a paso?**

1. **Detecta información automáticamente:**
   - Branch actual: `feature/google-oauth`
   - Branch de destino: `main` (detecta automáticamente)
   - Commits incluidos: `feat: implement Google OAuth...`
   - Archivos modificados: `8 archivos`

2. **Genera descripción con template:**
   ```markdown
   ## 🎯 Contexto
   **Tipo**: feature | **Archivos**: 8 | **Commits**: 2
   
   ### Resumen
   feat: implement Google OAuth authentication
   
   ### Cambios incluidos
   - feat: implement Google OAuth authentication
   - docs: update README with OAuth setup instructions
   
   ### Checklist
   - [x] Implementación completada
   - [x] Cambios validados localmente
   - [ ] Review pendiente
   - [ ] Testing en staging
   ```

3. **Hace push seguro:**
   ```bash
   📤 Pushing feature/google-oauth...
   ✅ Push exitoso
   ```

4. **Crea PR en GitHub:**
   ```bash
   🚀 Creando PR...
   ✅ PR creado exitosamente!
   🌐 https://github.com/user/repo/pull/123
   ```

5. **Guarda logs automáticamente:**
   - Ubicación: `.claude/logs/2025-08-05/pr_activity.jsonl`
   - Información: branch, tipo, archivos, URL del PR, timestamp

---

### **PASO 4: Esperar Review del Equipo**
*Otros desarrolladores revisan tu PR*

**¿Qué pasa aquí?**
- Tu equipo recibe notificación del PR
- Revisan el código y dejan comentarios
- Pueden encontrar TODOs, bugs, mejoras, etc.
- Dejan comentarios como:
  - "TODO: Add validation for email format"
  - "SECURITY: This needs input sanitization"  
  - "BUG: Memory leak in this function"
  - "PERFORMANCE: This query is slow"

**Tu trabajo aquí:**
- Esperar feedback
- Responder preguntas si las hay
- Estar atento a notificaciones

---

### **PASO 5: Extraer Issues Automáticamente**
*Convierte findings del PR en GitHub Issues*

```bash
/pr-findings
```

**¿Qué hace este comando paso a paso?**

1. **Detecta el PR automáticamente:**
   ```bash
   🔍 Analizando PR #123 (branch: feature/google-oauth)
   ```

2. **Lee TODO el contenido del PR:**
   - Descripción original del PR
   - Todos los reviews de tu equipo
   - Todos los comentarios de código
   - Toda la conversación general

3. **Extrae findings inteligentemente:**
   ```bash
   📋 Findings encontrados:
   TODO: Add validation for email format
   SECURITY: This needs input sanitization  
   BUG: Memory leak in this function
   PERFORMANCE: This query is slow
   ```

4. **Te pregunta si crear issues:**
   ```bash
   🎯 ¿Crear GitHub Issues de estos findings? [y/N]:
   ```

5. **Si dices 'y', analiza cada finding:**
   - `TODO: Add validation` → Labels: `priority:low,impact:medium,type:improvement,pr:123`
   - `SECURITY: input sanitization` → Labels: `priority:high,impact:high,type:security,pr:123`
   - `BUG: Memory leak` → Labels: `priority:medium,impact:medium,type:bug,pr:123`

6. **Crea issues en GitHub:**
   ```bash
   🏷️ Creating issue with labels: from-pr-finding,priority:high,impact:high,type:security,pr:123
   ✅ Issue creado: This needs input sanitization
   ✅ Issue creado: Add validation for email format
   ✅ Issue creado: Memory leak in this function
   
   🎉 Creados 3 GitHub Issues de PR #123
   ```

7. **Guarda logs:**
   - Ubicación: `.claude/logs/2025-08-05/pr_findings.jsonl`
   - Ubicación: `.claude/logs/2025-08-05/github_issues.jsonl`

---

### **PASO 6: Ver y Organizar Issues Creados**
*Revisa los issues categorizados automáticamente*

```bash
# Ver issues por prioridad (más urgente primero)
gh issue list --label priority:high
gh issue list --label priority:medium
gh issue list --label priority:low

# Ver issues por tipo
gh issue list --label type:security      # Seguridad (más crítico)
gh issue list --label type:bug          # Bugs
gh issue list --label type:performance  # Performance
gh issue list --label type:improvement  # Mejoras

# Ver solo issues de tu PR
gh issue list --label pr:123
```

**¿Qué verás?**
- Issues organizados por prioridad automáticamente
- Cada issue tiene el contexto completo del PR
- Labels que facilitan filtrar y priorizar
- Enlaces al PR original

---

### **PASO 7: Resolver Issues con Claude Code**
*Claude Code puede resolver automáticamente muchos issues*

```bash
# Ejemplo: Claude Code resuelve el issue de seguridad
👤 TÚ: "Claude, resuelve el issue #45 sobre input sanitization"
🤖 CLAUDE CODE: [Implementa la sanitización necesaria]
👤 TÚ: /commit
👤 TÚ: # Push y el issue se cierra automáticamente
```

**Issues que Claude Code puede resolver bien:**
- ✅ Validación de inputs
- ✅ Sanitización de datos
- ✅ TODOs de documentación
- ✅ Refactoring de código
- ✅ Optimizaciones de performance
- ✅ Tests faltantes

---

### **PASO 8: Integración Final del PR**
*El PR se aprueba e integra*

**¿Cuándo está listo para merge?**
- ✅ Todos los issues críticos resueltos
- ✅ Review aprobado por el equipo
- ✅ CI/CD pasando correctamente
- ✅ No hay conflictos con main

**¿Quién hace el merge?**
- Usualmente el autor del PR (tú) o el maintainer
- Se hace desde GitHub interface
- El PR se cierra automáticamente

---

## 🗂️ ¿Dónde se guardan los logs?

**Estructura automática por fechas:**
```
.claude/logs/
├── 2025-08-05/
│   ├── pr_activity.jsonl     # PRs creados hoy
│   ├── pr_findings.jsonl     # Findings extraídos hoy  
│   ├── github_issues.jsonl   # Issues creados hoy
│   └── ... (otros logs del sistema)
├── 2025-08-06/
│   └── ... (logs del día siguiente)
```

**¿Para qué sirven?**
- **Auditoría**: Ver qué PRs se crearon cada día
- **Seguimiento**: Rastrear findings encontrados
- **Métricas**: Entender productividad del equipo
- **Debugging**: Si algo sale mal, revisar qué pasó

---

## 🔍 Comandos Útiles para el Día a Día

### **Consultar Issues**
```bash
# ¿Qué issues de seguridad tengo pendientes?
gh issue list --label type:security

# ¿Qué issues de alta prioridad hay?
gh issue list --label priority:high

# ¿Qué issues salieron de mi último PR?
gh issue list --label pr:123
```

### **Ver Logs del Día**
```bash
# ¿Qué PRs creé hoy?
cat .claude/logs/$(date '+%Y-%m-%d')/pr_activity.jsonl

# ¿Qué findings encontré hoy?
cat .claude/logs/$(date '+%Y-%m-%d')/pr_findings.jsonl

# ¿Qué issues creé hoy?
cat .claude/logs/$(date '+%Y-%m-%d')/github_issues.jsonl
```

---

## ❓ Preguntas Frecuentes

### **"¿Puedo usar esto sin GitHub CLI?"**
No, necesitas `gh` configurado:
```bash
# Instalar GitHub CLI
# macOS: brew install gh
# Linux: sudo apt install gh

# Configurar
gh auth login
```

### **"¿Qué pasa si no hay findings en mi PR?"**
El comando `/pr-findings` te dirá:
```bash
✅ No se encontraron findings en PR #123
```

### **"¿Puedo extraer findings de PRs viejos?"**
Sí:
```bash
/pr-findings 85  # PR específico #85
```

### **"¿Los issues se crean siempre?"**
No, el comando te pregunta:
```bash
🎯 ¿Crear GitHub Issues de estos findings? [y/N]:
```

### **"¿Qué pasa si ya existe un issue similar?"**
GitHub no permite duplicados exactos del título, pero podrían crearse similares. Revisa antes de confirmar.

---

## 🎯 Resumen: Tu Flujo Ideal

```bash
# 1. Claude Code implementa
"Claude, implementa [funcionalidad]"

# 2. Commits automáticos  
/commit

# 3. PR automático
/pr

# 4. Esperar review del equipo
# (ellos dejan comentarios, TODOs, findings)

# 5. Extraer findings → issues
/pr-findings
# → Dices 'y'
# → Issues categorizados creados automáticamente

# 6. Resolver issues
"Claude, resuelve issue #X"
/commit

# 7. Merge del PR
# (desde GitHub cuando esté aprobado)
```

**¡Y listo!** Todo queda rastreado, organizado y listo para el siguiente ciclo.

---

*Esta guía te ayuda a aprovechar al máximo el flujo de PRs con Claude Code. ¿Preguntas? Revisa los logs diarios o consulta los issues por categoría.*