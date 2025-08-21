# Workflow AI-First

*Paso a paso: desde código hasta merge sin fricción*

## 🎯 Qué aprenderás

- **Prerequisito**: Worktree activo via `/workflow:session-start`
- Crear PR con Claude Code
- Convertir findings en issues
- Resolver issues en el mismo PR
- Gestionar iteraciones hasta validación
- Cuándo pedir autorización

---

## 📋 Flujo Completo

**Prerequisito**: usar `/workflow:session-start` → seleccionar "Desarrollo con código" → crear worktree automáticamente para tu feature.

**Contexto**: Los siguientes comandos se ejecutan desde tu worktree (NO desde main). Si no tienes worktree activo, regresa a session-start primero.

**Recomendado**: al finalizar usar `/workflow:switch <base_branch>` (cambiar contexto) + `/worktree:cleanup <worktree-name>` (eliminar worktree). Usar `/workflow:changelog <number>` para actualizar CHANGELOG.md después de merge.
 
### **PASO 1: Crear PR**

💡 **Confirmación**: Estás en tu worktree de feature (NO en main)

```bash
# Implementar funcionalidad
"Claude, implementa autenticación OAuth"

# Crear commits y PR
/commit    # Crea commit semántico con validaciones
/pr        # Crea pull request automáticamente
```

---

### **PASO 2: Review Automático**

Tipos de findings:
- SECURITY, BUG, TODO, PERFORMANCE

⚠️ **Importante:** No crear PR nuevo, usar el mismo

---

### **PASO 3: Convertir Findings en Issues**

```bash
/github:findings-to-issues
```

Crea issues organizados por prioridad: CRÍTICO → ALTO → MEDIO → BAJO

---

### **PASO 4: Planificar (Opcional)**

```bash
/github:issues-to-solved <pr_number>
```

Genera plan de resolución por prioridades:
- **"Y"**: Ejecución automática 
- **"N"**: Usar como guía manual

---

### **PASO 5: Resolver Issues**

⚠️ **Importante:** Usar el mismo PR, no crear uno nuevo.

**3 opciones:**
- **A:** Ya resueltos automáticamente (solo commitear)
- **B:** Seguir plan como guía  
- **C:** Resolver manualmente

Siempre usar `Closes #77` en commits para trazabilidad.

---

### **PASO 6: Push y Re-Review**

```bash
git push     # Push directo al branch remoto
# O usar:
/pr          # Detecta branch existente y pushea cambios
```

**Casos posibles:**
- ✅ Todo limpio → Merge automático
- 🔄 Nuevos findings → Repetir pasos 3-6  
- 🚨 Issues persistentes (4-5 iteraciones) → Pedir autorización

---

## 🚨 Casos Especiales

### **Cuándo Pedir Autorización**

**Después de 4-5 iteraciones sin resolver, o cuando hay:**
- Issues de seguridad que requieren cambios arquitectónicos
- Bloqueos críticos de +48 horas
- Conflictos técnicos complejos
- Decisiones que afectan múltiples servicios

### **Template Simple para Autorización**

**Elementos obligatorios a incluir:**

```
Asunto: Autorización requerida - PR #[NUMERO] 

Contexto:
- PR: #[NUMERO] - "[DESCRIPCIÓN]"
- Issue crítico: #[NUMERO] [TIPO] [DESCRIPCIÓN]
- Intentos: [NÚMERO] iteraciones sin resolver

Opciones:
A) Merge con fix temporal + issue de seguimiento
B) Bloquear hasta implementación completa  
C) Fix mínimo aceptando riesgo residual

Impacto:
- Opción A: [IMPACTO_TIEMPO]
- Opción B: [IMPACTO_DELAY] 
- Opción C: [IMPACTO_RIESGO]

Recomendación: [TU_RECOMENDACIÓN]

Respuesta esperada: "AUTORIZADO: Opción [A/B/C]"
```

**Nota:** Usa tu propio lenguaje y estilo. Lo importante es incluir todos los elementos.

### **Respuestas Típicas y Siguientes Pasos**

**Si autorizado → implementar:**
```bash
gh issue create --title "[FOLLOWUP] Fix completo para [DESCRIPCIÓN]"
/commit "fix: implementar solución temporal autorizada"
git push
```

**Si denegado → completar:**
```bash
"Claude, implementa la solución completa requerida"
# Continuar hasta resolver completamente
```

### **Después de la Autorización**

1. **Confirmar recepción**
2. **Implementar según decisión autorizada**
3. **Documentar en PR con comentario**
4. **Crear follow-up issues si aplica**

---

## 🔄 Flujo Resumido

```bash
0. /workflow:session-start → "Desarrollo" → worktree  # Setup inicial
1. /pr                    # Crear PR (desde worktree)
2. [Review automático]     # Aparecen findings
3. /github:findings-to-issues    # Convertir a issues
4. /github:issues-to-solved <pr_number> # Planificar (opcional)
5. Resolver issues        # Manual o automático
6. /commit + push         # Actualizar PR
7. Re-review              # Validación final
```

**Casos:**
- ✅ Aprobado → Merge → `/workflow:changelog <number>` + `/workflow:switch <base_branch>` + `/worktree:cleanup <worktree-name>` (documentar + cambiar contexto + eliminar worktree)
- 🔄 Nuevos findings → Repetir 3-6
- 🚨 Issues persistentes → Pedir autorización

---

## ✅ Buenas Prácticas

### **DO (Hacer)**
- ✅ Usar mismo PR para todos los fixes
- ✅ Referencias issues en commits: `Closes #77`
- ✅ Pedir autorización por email después de 4-5 iteraciones
- ✅ Incluir stakeholders relevantes
- ✅ Documentar intentos técnicos

### **DON'T (No Hacer)**  
- ❌ Crear PR nuevo para resolver findings
- ❌ Mergear issues críticos sin autorización formal
- ❌ Pedir autorización por comentarios en PR
- ❌ Iteraciones infinitas sin escalar
- ❌ Commits sin referencias a issues

---

## 🎯 Comandos Esenciales

### **Por Contexto de Trabajo:**

**Desde main (inicio de sesión):**
```bash
/workflow:session-start          # Configurar workspace
```

**Desde worktree (desarrollo activo):**
```bash
/pr [target-branch]              # Crear PR
/commit "fix: Closes #X"         # Commit con referencia  
/github:findings-to-issues       # Convertir findings
/github:issues-to-solved <pr>    # Planificar resolución
```

**Desde cualquier ubicación:**
```bash
/workflow:switch <base_branch>   # Cambiar contexto (regresa a main/develop)
/worktree:cleanup <worktree>     # Eliminar worktree específico completamente
/workflow:changelog <pr_number>  # Actualizar CHANGELOG
gh pr view [PR]                  # Ver estado
```

### **Cleanup: Cuándo usar cada comando:**

| Comando | Propósito | Cuándo usar |
|---------|----------|--------------|
| `/workflow:switch main` | Cambiar contexto de trabajo | Después de merge, para regresar a rama base |
| `/worktree:cleanup <name>` | Eliminar worktree obsoleto | Cuando ya no necesitas el worktree (requiere confirmación) |

