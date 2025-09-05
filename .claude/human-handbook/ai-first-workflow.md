# Workflow AI-First

*Guía paso a paso para workflow completo*

## 🎯 Qué aprenderás

- Configurar workspace con worktrees aislados
- Implementar features con comandos de alto valor
- Crear PRs con review automático
- Resolver findings iterativamente
- Cuándo usar agentes especialistas
- Gestión de autorización cuando sea necesaria

---

## 📋 Setup Inicial (OBLIGATORIO)

**⚠️ ANTES DE EMPEZAR**: Este workflow requiere worktree aislado.

**Desde main/develop - dos opciones:**

**A) Flujo directo** (si ya sabes qué implementar):
```bash
# 1. Crear worktree directamente
/worktree:create "implementar OAuth" develop     # Features
/worktree:create "fix bug pagos" main            # Hotfixes

# 2. Cambiar al worktree  
cd ../worktree-implementar-oauth

# 3. Sesión en el worktree
/workflow:session-start
```

**B) Flujo exploración** (si necesitas análisis):
```bash
# 1. Analizar situación actual
/workflow:session-start
# → Te mostrará issues activos y te sugerirá crear worktree

# 2. Crear worktree según recomendación
/worktree:create "feature-name" develop

# 3. Cambiar al worktree
cd ../worktree-feature-name  

# 4. Nueva sesión en el worktree
/workflow:session-start
```

**Validación - estás listo cuando:**
```bash
git branch    # Muestra: * feature-name (NO main/develop)
pwd          # Muestra: .../worktree-feature-name
```
 
### **PASO 1: Implementación Inteligente**

💡 **Confirmación**: Estás en tu worktree de feature (NO en main/develop, etc...)

```bash
# 1. Comprender contexto
/understand                    # Mapea arquitectura y patrones existentes

# 2. Implementación completa (MOTOR CENTRAL)
/implement "autenticación OAuth"  # Planning → APROBACIÓN → Implementation → Testing → Quality Gates

# 3. Crear PR
/commit    # Commit semántico con validaciones
/pr        # Pull request automático
```

**Comandos opcionales solo si necesarios:**
```bash
/test      # Solo si necesitas testing adicional específico
/review    # Solo para review independiente (redundante con /implement)
```

**🎯 Fases de `/implement`:**
- **Planning Phase**: `tech-lead-orchestrator` analiza y planifica
- **Authorization Phase**: Usuario aprueba plan antes de proceder
- **Implementation Phase**: Especialistas del framework ejecutan
- **Quality Phase**: `security-reviewer` + `performance-optimizer` validan
- **Documentation Phase**: Actualiza docs automáticamente

**Auto-delegation interna:**
- **Multi-step features** → `tech-lead-orchestrator` (automático)
- **Security-sensitive** → `security-reviewer` (automático)  
- **Performance-critical** → `performance-optimizer` (automático)

**Manual override disponible:**
```bash
/agent:tech-lead-orchestrator    # Para análisis estratégico específico
/agent:security-reviewer        # Para auditoría de seguridad enfocada
```

---

### **PASO 2: Review Automático y Findings**
El PR generado activa review automático en GitHub. El equipo puede realizar review manual adicional según necesidad.
Tipos de findings:
- SECURITY, BUG, TODO, PERFORMANCE

**Si hay findings:**
```bash
/review pr <number>    # Analizar findings + plan implementación
```
Analiza findings y genera plan organizado por prioridad: CRÍTICO → ALTO → MEDIO → BAJO

**Findings complejos** - usar especialistas:
- **SECURITY findings** → `security-reviewer` → `/agent:security-reviewer`
- **PERFORMANCE issues** → `performance-optimizer` → `/agent:performance-optimizer`
- **LEGACY code problems** → `code-archaeologist` → `/agent:code-archaeologist`

---

### **PASO 3: Resolver Issues (si existen)**

⚠️ **Importante:** Usar el mismo PR, no crear uno nuevo.

**4 opciones:**
- **A:** Ya resueltos automáticamente (solo commitear)
- **B:** Seguir plan como guía  
- **C:** Resolver manualmente
- **D:** 💡 **Delegar a especialista** para issues complejos

**Para issues complejos** - delegar a especialista:
- **Complex architecture** → `tech-lead-orchestrator` → `/agent:tech-lead-orchestrator`
- **Database optimization** → `database-expert` → `/agent:database-expert`
- **API design** → `api-architect` → `/agent:api-architect`
- **Framework-specific** → Usar agente especializado del stack

Siempre usar `Closes #77` en commits para trazabilidad.

---

### **PASO 4: Push y Re-Review**

```bash
git push     # Push directo al branch remoto
# O usar:
/pr          # Detecta branch existente y pushea cambios
```

**Casos posibles:**
- ✅ Todo limpio → Listo para merge (requiere aprobación manual)
- 🔄 Nuevos findings → Repetir pasos 3-4  
- 🚨 Issues persistentes (4-5 iteraciones) → Pedir autorización

---

## 🚨 Casos Especiales

### **Cuándo Pedir Autorización**

**Después de 4-5 iteraciones sin resolver, o cuando hay:**
- Issues de seguridad que requieren cambios arquitectónicos
- Bloqueos críticos de +24 horas  
- Conflictos técnicos complejos
- Decisiones que afectan múltiples servicios

**Antes de escalar** - consultar especialistas:
- **Technical impact** → `tech-lead-orchestrator` → `/agent:tech-lead-orchestrator`
- **Security assessment** → `security-reviewer` → `/agent:security-reviewer`
- **Performance implications** → `performance-optimizer` → `/agent:performance-optimizer`

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
0. Crear worktree (directo o via session-start)  # Setup inicial
1. /understand            # Mapear contexto del proyecto
2. /implement "feature"   # MOTOR CENTRAL - Incluye testing + quality gates
3. /pr                    # Crear PR con metadata completa
4. [Review automático]    # Findings aparecen en GitHub
5. /review pr <number>    # Analizar findings + plan implementación
6. Resolver issues        # Manual o con especialistas
7. /commit + push         # Actualizar PR
8. Re-review             # Validación final
```

**Casos:**
- ✅ Aprobado → Merge → `/workflow:changelog <number>` + `/worktree:cleanup <worktree-name>` 
- 🔄 Nuevos findings → Repetir pasos 6-8
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

**Desde main/develop:**
```bash
/workflow:session-start             # Análisis + orientación
/worktree:create "feature" develop   # Crear worktree directo
```

**Desde worktree (desarrollo activo):**
```bash
/pr [target-branch]              # Crear PR
/commit "fix: Closes #X"         # Commit con referencia  
/review pr <number>              # Analizar + plan implementación
```

**Después de merge (desde worktree):**
```bash
/workflow:changelog <pr_number>  # Actualizar CHANGELOG
/worktree:cleanup <worktree>     # Eliminar worktree (regresa automáticamente a main)
```

**Desde cualquier ubicación:**
```bash
gh pr view [PR]                  # Ver estado
/workflow:switch <base_branch>   # Solo si necesitas cambiar contexto manualmente
```

---

## 🤖 Guía Rápida de Agentes

Los agentes especialistas aceleran la resolución y mejoran la calidad. Son **opcionales** pero **recomendados** para tasks complejos.

### **🎯 Cuándo Usar Agentes**

**Orquestadores** (para coordination):
- `tech-lead-orchestrator`: Multi-step features, decisiones arquitectónicas, coordination compleja

**Core Specialists** (para quality):
- `security-reviewer`: Security issues, code quality, vulnerability assessment
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

## Comandos Principales

### **`/understand` - Context Mapping**
```bash
/understand
```
- Mapea arquitectura completa del proyecto
- Identifica patrones y convenciones existentes  
- Previene inconsistencias costosas en refactoring posterior

### **`/implement` - Implementation Engine**
```bash
/implement "autenticación OAuth con roles"
```
- Planning automático con `tech-lead-orchestrator`
- Implementación con especialistas del stack
- Testing y validación integrados
- Automatiza planning, implementación y validación

### **`/review` - Quality Assurance**
```bash
/review
```
- Detecta issues antes de PR
- Security, performance, code quality simultáneamente
- Detecta issues antes de PR para reducir iteraciones

### **`/test` - Validation Engine**
```bash
/test
```
- Validación completa automatizada
- Auto-fix inteligente de test failures comunes

### **Workflow Principal**
```bash
/understand → /implement → /pr
```