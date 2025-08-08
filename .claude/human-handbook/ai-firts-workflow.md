# Workflow AI-First

*Paso a paso: desde código hasta merge sin fricción*

## 🎯 Qué aprenderás

- Crear PR con Claude Code
- Manejar findings de reviews automáticamente  
- Resolver issues sin crear PRs nuevos
- Gestionar iteraciones hasta validación limpia
- Cuándo un humano puede autorizar pasar issues

---

## 📋 FLUJO COMPLETO (5 PASOS)

### **PASO 1: Crear PR Inicial**

```bash
# Claude Code implementa tu funcionalidad
"Claude, implementa autenticación OAuth"

# Cuando estés satisfecho, crea commits y PR
/commit
/pr
```

**Resultado:**
- PR se crea automáticamente con template
- Se hace push a GitHub
- Queda listo para review

```
✅ PR creado: #123 "feat: implement OAuth authentication" 
🌐 https://github.com/tu-proyecto/pull/123
```

---

### **PASO 2: Review → Aparecen Findings**

**¿Quién revisa tu PR?**
- **Claude Code** (usando `/review` o comandos automáticos)
- **Tu equipo humano** (reviewers asignados)  
- **Ambos** (review automático + validación humana)

**¿Qué tipos de findings aparecen?**
- `SECURITY: This needs input validation`
- `BUG: Memory leak in line 45`  
- `TODO: Add error handling here`
- `PERFORMANCE: This query is slow`

**Tu trabajo:**
- Esperar el review
- **NO crear PR nuevo** - seguiremos en el mismo

---

### **PASO 3: Convertir Findings en Issues**

```bash
/findings-to-issues
```

**El comando:**
1. Lee TODO el PR (descripción, comments, reviews)
2. Encuentra findings inteligentemente
3. Crea issues organizados por prioridad

```
✅ Issue #77 [SECURITY] Input validation needed (CRÍTICO)
✅ Issue #78 [BUG] Fix memory leak (ALTO)
✅ Issue #79 [TODO] Add error handling (MEDIO)  
✅ Issue #80 [PERFORMANCE] Optimize query (MEDIO)
```

---

### **PASO 4: Resolver Issues en el MISMO PR**

**⚠️ IMPORTANTE: NO crear PR nuevo - actualizar el mismo**

```bash
# Para cada issue crítico:
"Claude, resuelve el issue #77 sobre input validation"
"Claude, resuelve el issue #78 sobre memory leak"  

# Commit con referencias a issues:
/commit "fix: resolve security and performance issues

- Fix input validation vulnerability (#77)
- Resolve memory leak in authentication (#78)  
- Add proper error handling (#79)
- Optimize database query performance (#80)

Closes #77, Fixes #78, Resolves #79, Addresses #80"
```

**¿Qué pasa al commitear con "Closes #77"?**
- El commit se agrega al MISMO PR #123
- Cuando se mergee el PR, los issues se cerrarán automáticamente
- Trazabilidad completa: PR → Issues → Fixes → Merge

---

### **PASO 5: Re-Review y Decisión Final**

```bash
gh pr comment 123 --body "✅ Issues críticos resueltos:
- #77 SECURITY: Input validation implementada  
- #78 BUG: Memory leak corregido
- #79 TODO: Error handling añadido
- #80 PERFORMANCE: Query optimizada

Listo para re-review."
```

**Posibles resultados:**

**✅ CASO 1: Todo limpio**
- Re-review → Aprobado → Merge → Issues se cierran automáticamente

**🔄 CASO 2: Quedan issues menores**
- Repite PASO 4 → Commit al mismo PR → Re-review
- **Repite hasta que esté limpio**

**🚨 CASO 3: Issues críticos persistentes**
- **DECISIÓN HUMANA requerida**

---

## 🚨 CASOS ESPECIALES: Errores Persistentes

### **Cuándo Pedir Autorización Humana**

**Regla práctica:**
- **1-2 iteraciones:** Normal, seguir resolviendo
- **3-4 iteraciones:** Evaluar complejidad
- **5+ iteraciones:** **OBLIGATORIO pedir autorización humana**

### **Template para Pedir Autorización**

```bash
gh pr comment 123 --body "⚠️ Issue #77 SECURITY persiste después de 3 iteraciones:

**Intentos realizados:**
- Iteración 1: Input validation básica → Insuficiente
- Iteración 2: Regex validation → Regex vulnerable  
- Iteración 3: Sanitization function → Bypass posible

**Problema:** La validación completa requiere librería externa que cambia arquitectura.

**Solicito autorización humana para:**
- [ ] Mergear PR con issue #77 pendiente 
- [ ] Crear issue de seguimiento para implementar solución correcta
- [ ] Implementar fix temporal hasta refactoring mayor

@tech-lead @security-team"
```

### **Posibles Decisiones del Líder Técnico**

**✅ Autoriza pasar:** "OK, crea issue de seguimiento"
```bash
gh issue create --title "[FOLLOWUP] Implement comprehensive input validation"
/commit "fix: implement temporary input validation for #77"
```

**❌ No autoriza:** "Implementa fix básico ahora"
```bash
"Claude, implementa input validation básica pero funcional para issue #77"
/commit "fix: implement basic input validation (temporary solution)"
```

---

## 🔄 FLUJO RESUMIDO

```bash
1. /pr                          # Crear PR inicial
2. [Claude Code/Equipo revisa]  # Aparecen findings  
3. /findings-to-issues          # Convertir a issues
4. "Claude, resuelve #X"        # Resolver en MISMO PR
5. /commit "fix: ... Closes #X" # Commit con referencias
6. [Re-review]                  # Evaluación
7a. ✅ Aprobado → Merge         # Caso ideal
7b. 🔄 Más issues → Repetir 4-6 # Iteración normal
7c. 🚨 No resuelve → Humano     # Autorización requerida
```

---

## ✅ BUENAS PRÁCTICAS

### **DO (Hacer)**
- ✅ Usar MISMO PR para todos los fixes
- ✅ Referencias issues en commits: `Closes #77`
- ✅ Re-review después de cada iteración
- ✅ Pedir autorización humana después de 5 iteraciones
- ✅ Documentar problemas persistentes claramente

### **DON'T (No Hacer)**  
- ❌ Crear PR nuevo para resolver findings
- ❌ Mergear issues críticos sin autorización
- ❌ Iteraciones infinitas sin escalar  
- ❌ Commits sin referencias a issues
- ❌ Resolver issues menores antes que críticos

---

## 🎯 COMANDOS ESENCIALES

```bash
# Flujo básico
/pr                                    # Crear PR inicial
/findings-to-issues                    # Extraer findings → issues

# Resolución iterativa  
"Claude, resuelve issue #X"            # Resolver issue específico
/commit "fix: ... Closes #X"           # Commit con referencia

# Gestión de PR
gh pr comment {PR} --body "mensaje"    # Comunicar estado
gh issue list --label priority:high    # Issues críticos pendientes
```

---

## 📊 EJEMPLO COMPLETO

```bash
# Día 1: PR inicial
/pr
# → PR #123 creado

# Día 2: Review findings  
/findings-to-issues
# → Issues #77(SECURITY), #78(BUG), #79(TODO), #80(PERFORMANCE)

# Día 2: Primera iteración
"Claude, resuelve #78 y #79"
/commit "fix: resolve bug and add error handling. Closes #78, #79"

# Día 3: Segunda iteración  
"Claude, resuelve #80 performance"
/commit "fix: optimize query performance. Closes #80"

# Día 3-4: Tercera/Cuarta iteración (issue #77 persiste)
"Claude, intenta otra vez #77 security"
# → Sigue sin resolverse después de múltiples intentos

# Día 4: Pedir autorización (después de 4 iteraciones)
gh pr comment 123 --body "🚨 Issue #77 SECURITY persiste después de 4 iteraciones.
Requiere refactor arquitectural. Solicito autorización para mergear con issue seguimiento.
@tech-lead"

# Día 5: Autorización + Resolución final
gh issue create --title "[FOLLOWUP] Complete security validation refactor"
/commit "fix: implement temporary input validation for #77"
```

**Resultado:**
- ✅ PR #123 merged  
- ✅ Issues #78, #79, #80 cerrados automáticamente
- ✅ Issue #77 cerrado con fix temporal
- ✅ Issue #81 creado para seguimiento