# Workflow AI-First

*Paso a paso: desde código hasta merge sin fricción*

## 🎯 Qué aprenderás

- **Prerequisito**: Worktree activo via `/workflow:session-start`
- Crear PR con Claude Code
- Convertir findings en issues
- Resolver issues en el mismo PR
- 💡 **Cuándo usar agentes especialistas** para acelerar resolución
- Gestionar iteraciones hasta validación
- Cuándo pedir autorización

---

## 📋 Flujo Completo

**Prerequisito**: usar `/workflow:session-start` → si tu flujo de trabajo sera desarollo/bugs/refactor → crear worktree automáticamente para tu feature con `/worktree:create`.

**⚠️ CONTEXTO CRÍTICO**: Los siguientes comandos se ejecutan desde tu worktree (NO desde main/develop). 

**Validación de contexto antes de proceder:**
```bash
git branch          # Debe mostrar tu feature branch (NO main/develop)  
pwd                # Debe mostrar: .../worktree-[feature-name]
```

**Si estás en main/develop:** regresa a [session-start](#paso-1-implementación-inteligente) primero.

**Importante**: al finalizar usar `/workflow:switch <base_branch>` (cambiar contexto) + `/worktree:cleanup <worktree-name>` (eliminar worktree). Usar `/workflow:changelog <number>` para actualizar CHANGELOG.md después de merge.
 
### **PASO 1: Implementación Inteligente**

💡 **Confirmación**: Estás en tu worktree de feature (NO en main/develop, etc...)

```bash
# 1. Comprender contexto (ESENCIAL)
/understand                    # Mapea arquitectura y patrones existentes

# 2. Implementación automática (MOTOR CENTRAL)
/implement "autenticación OAuth"  # Planning → Coding → Testing → Documentation

# 3. Validación (CRÍTICO)
/test                         # Ejecuta tests y valida funcionamiento
/review                       # Análisis multi-especialista

# 4. Crear PR
/commit    # Commit semántico con validaciones
/pr        # Pull request automático
```

**🎯 Flujo automático de `/implement`:**
- **Planning Phase**: `tech-lead-orchestrator` analiza y planifica
- **Implementation Phase**: Especialistas del framework ejecutan
- **Quality Phase**: `code-reviewer` + `performance-optimizer` validan
- **Documentation Phase**: Actualiza docs automáticamente

💡 **Comando `/implement` - Motor de Automatización:**
- **Integra automáticamente** especialistas según el tipo de challenge
- **Flujo completo** desde planning hasta documentación  
- **Zero-friction implementation** - de idea a código funcionando

**Auto-delegation interna:**
- **Multi-step features** → `tech-lead-orchestrator` (automático)
- **Security-sensitive** → `code-reviewer` (automático)  
- **Performance-critical** → `performance-optimizer` (automático)

**Manual override disponible:**
```bash
/agent:tech-lead-orchestrator    # Para análisis estratégico específico
/agent:code-reviewer             # Para auditoría de seguridad enfocada
```

---

### **PASO 2: Review Automático**
*Al momento de generar el PR se realiza un code review automatico en Github, a consideración del equipo lider, se realiza un code review manual tambien*
Tipos de findings:
- SECURITY, BUG, TODO, PERFORMANCE

💡 **Smart Delegation**: Findings complejos se benefician de especialistas:
- **SECURITY findings** → `code-reviewer` → `/agent:code-reviewer --security-audit`
- **PERFORMANCE issues** → `performance-optimizer` → `/agent:performance-optimizer`
- **LEGACY code problems** → `code-archaeologist` → `/agent:code-archaeologist`

⚠️ **Importante:** No crear PR nuevo, usar el mismo

---

### **PASO 3: Convertir Findings en Issues**

```bash
/review pr <number>
```

Analiza findings y genera plan de implementación organizado por prioridad: CRÍTICO → ALTO → MEDIO → BAJO

---

### **PASO 4: Resolver Issues**

⚠️ **Importante:** Usar el mismo PR, no crear uno nuevo.

**4 opciones:**
- **A:** Ya resueltos automáticamente (solo commitear)
- **B:** Seguir plan como guía  
- **C:** Resolver manualmente
- **D:** 💡 **Delegar a especialista** para issues complejos

💡 **Specialist Assistance**: Cuando un issue requiere expertise específico:
- **Complex architecture** → `tech-lead-orchestrator` → `/agent:tech-lead-orchestrator`
- **Database optimization** → `database-expert` → `/agent:database-expert`
- **API design** → `api-architect` → `/agent:api-architect`
- **Framework-specific** → Usar agente especializado del stack

Siempre usar `Closes #77` en commits para trazabilidad.

---

### **PASO 5: Push y Re-Review**

```bash
git push     # Push directo al branch remoto
# O usar:
/pr          # Detecta branch existente y pushea cambios
```

**Casos posibles:**
- ✅ Todo limpio → Merge automático
- 🔄 Nuevos findings → Repetir pasos 4-7  
- 🚨 Issues persistentes (4-5 iteraciones) → Pedir autorización

---

## 🚨 Casos Especiales

### **Cuándo Pedir Autorización**

**Después de 4-5 iteraciones sin resolver, o cuando hay:**
- Issues de seguridad que requieren cambios arquitectónicos
- Bloqueos críticos de +48 horas
- Conflictos técnicos complejos
- Decisiones que afectan múltiples servicios

💡 **Expert Panel Consultation**: Antes de escalar, considera consultar especialistas:
- **Technical impact** → `tech-lead-orchestrator` → `/agent:tech-lead-orchestrator --impact-analysis`
- **Security assessment** → `code-reviewer` → `/agent:code-reviewer --vulnerability-assessment`
- **Performance implications** → `performance-optimizer` → `/agent:performance-optimizer --cost-analysis`

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
1. /understand            # Mapear contexto COMPLETO (ESENCIAL)
2. /implement "feature"   # MOTOR CENTRAL - Planning → Coding → Testing → Docs
3. /test                  # Validación de funcionamiento (FUNDAMENTAL)
4. /review                # Análisis multi-especialista (CRÍTICO)
5. /pr                    # Crear PR con metadata completa
6. [Review automático]    # Findings aparecen en GitHub
7. /review pr <number>    # Analizar findings + plan implementación
8. Resolver issues        # Manual o con especialistas
9. /commit + push         # Actualizar PR
10. Re-review             # Validación final
```

**Casos:**
- ✅ Aprobado → Merge → `/workflow:changelog <number>` + `/workflow:switch <base_branch>` + `/worktree:cleanup <worktree-name>` (documentar + cambiar contexto + eliminar worktree)
- 🔄 Nuevos findings → Repetir 4-7
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
/review pr <number>              # Analizar + plan implementación
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

---

## 🤖 Guía Rápida de Agentes

Los agentes especialistas aceleran la resolución y mejoran la calidad. Son **opcionales** pero **recomendados** para tasks complejos.

### **🎯 Cuándo Usar Agentes**

**Orquestadores** (para coordination):
- `tech-lead-orchestrator`: Multi-step features, decisiones arquitectónicas, coordination compleja

**Core Specialists** (para quality):
- `code-reviewer`: Security issues, code quality, vulnerability assessment
- `performance-optimizer`: Bottlenecks, optimization, cost analysis
- `code-archaeologist`: Legacy code, complex codebase exploration

**Framework Specialists** (para implementation):
- `react-component-architect`, `nestjs-backend-expert`, `database-expert`, etc.

### **💡 Pattern de Uso**

```bash
# Identificar challenge type
"Claude, implementa OAuth con roles"

# 💡 Suggestion aparece automáticamente
Challenge: IMPLEMENTATION + Security → usar tech-lead-orchestrator

# One-click activation
/agent:tech-lead-orchestrator

# Continuar con workflow normal
/pr
```

**Tip**: Los agentes se integran naturalmente en el workflow. Las suggestions aparecen contextualmente - simplemente úsalas cuando aporten value.

---

## ⚡ Comandos de Alto Valor

Los siguientes comandos transforman tu productividad de horas a minutos:

### **🎯 `/understand` - Context Mapping (ESENCIAL)**
```bash
/understand  # SIEMPRE ejecutar ANTES de implementar
```
**Por qué es crítico:**
- Mapea arquitectura completa del proyecto
- Identifica patrones y convenciones existentes  
- Previene inconsistencias antes de escribir código
- **ROI**: 30 min de análisis ahorran 3+ horas de refactoring

### **🚀 `/implement` - Motor Central (TRANSFORMACIONAL)**
```bash
/implement "autenticación OAuth con roles"  # De idea a código funcionando
```
**Por qué cambia todo:**
- Planning automático con `tech-lead-orchestrator`
- Implementación con especialistas del stack
- Testing y validación integrados
- **ROI**: Reduce 4+ horas de desarrollo manual a 20-30 minutos

### **🔍 `/review` - Quality Assurance (CRÍTICO)**
```bash
/review  # Análisis multi-especialista automático
```
**Por qué es indispensable:**
- Detecta issues antes de PR
- Security, performance, code quality simultáneamente
- Previene findings costosos en review manual
- **ROI**: 5 min de review previenen 2+ horas de fixes post-merge

### **✅ `/test` - Validation Engine (FUNDAMENTAL)**
```bash
/test  # Ejecuta + autofix de failures
```
**Por qué es esencial:**
- Validación completa automatizada
- Auto-fix inteligente de test failures
- Confidence para hacer PR
- **ROI**: Reduce debugging de horas a minutos

**🏆 Workflow de Alto Impacto:**
```bash
/understand → /implement → /test → /review → /pr
# Total: 15-30 min para feature completa vs 4+ horas manual
```

