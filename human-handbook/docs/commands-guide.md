# Guía de Comandos Claude Code

**23 comandos disponibles** (reorganizados por flujo de desarrollo)

_Comandos organizados por flujo de desarrollo y frecuencia de uso_

---

## 🚀 Inicio de Sesión

### `/utils:session-start`

```bash
/utils:session-start
```

**Qué hace**: Configura workspace, muestra issues activos, valida git y sincroniza con remoto.

**Cuándo**: Primera acción en cada sesión de desarrollo.

---

## 📦 Gestión de Worktrees

### `/git-github:worktree:create`

```bash
/git-github:worktree:create "<objetivo>" <parent-branch>
```

**Qué hace**: Crea worktree aislado en directorio sibling con rama nueva y upstream configurado.

**Cuándo**: SIEMPRE para desarrollo - mantiene workspace principal limpio.

**Ejemplos**:

```bash
/git-github:worktree:create "implementar OAuth" main
/git-github:worktree:create "fix bug pagos" develop
```

### `/git-github:worktree:cleanup`

```bash
/git-github:worktree:cleanup              # Discovery mode
/git-github:worktree:cleanup <worktree1>  # Cleanup específico
```

**Qué hace**: Elimina worktrees con validación de ownership y cleanup triple (worktree/local/remote).

**Cuándo**: Después de mergear PRs.

---

## 🎯 Ciclo PRD

### `/PRD-cycle:prd-new`

```bash
/PRD-cycle:prd-new <feature_name>
```

**Qué hace**: Brainstorming para crear Product Requirements Document estructurado (minimalista, business-focused).

**Cuándo**: Planificación de nueva feature desde cero.

### `/PRD-cycle:prd-sync`

```bash
/PRD-cycle:prd-sync <feature_name>
/PRD-cycle:prd-sync <feature_name> --milestone <number>
```

**Qué hace**: Sincroniza PRD a GitHub como Parent Issue.

**Cuándo**: Después de aprobar PRD, para tracking en GitHub.

---

## 🏗️ Ciclo SDD

### `/SDD-cycle:specify`

```bash
/SDD-cycle:specify "Create authentication system"
/SDD-cycle:specify --from-issue 456
```

**Qué hace**: Crea especificación técnica desde lenguaje natural o GitHub Issue.

**Cuándo**: Primera fase SDD - convierte requisitos en spec técnica.

### `/SDD-cycle:clarify`

```bash
/SDD-cycle:clarify
```

**Qué hace**: Detecta ambigüedades en spec, hace hasta 5 preguntas targeted.

**Cuándo**: **ANTES** de `/SDD-cycle:plan` - reduce rework 70%.

### `/SDD-cycle:plan`

```bash
/SDD-cycle:plan
```

**Qué hace**: Genera artifacts de diseño (research.md, data-model.md, contracts/, quickstart.md).

**Cuándo**: Después de spec clarificada, antes de tasks.

### `/SDD-cycle:tasks`

```bash
/SDD-cycle:tasks
```

**Qué hace**: Genera tasks.md dependency-ordered con markers [P] y GitHub sub-issues.

**Cuándo**: Después de plan, antes de implement.

### `/SDD-cycle:analyze`

```bash
/SDD-cycle:analyze
```

**Qué hace**: Análisis cross-artifact de consistency y quality, genera coordination plan.

**Cuándo**: Después de tasks, validación pre-implementación.

### `/SDD-cycle:implement`

```bash
/SDD-cycle:implement
```

**Qué hace**: Ejecuta tasks.md con parallelization, specialized agents y TDD enforcement.

**Cuándo**: Motor central de implementación.

### `/SDD-cycle:constitution`

```bash
/SDD-cycle:constitution
```

**Qué hace**: Crea/actualiza constitución del proyecto.

**Cuándo**: Setup inicial o actualización de principios fundamentales.

**⚠️ RESTRICCIÓN**: NO EJECUTAR sin autorización directa del usuario.

---

## 🔄 Git & GitHub

### `/git-github:commit`

```bash
/git-github:commit "descripción"
/git-github:commit "all changes"
```

**Qué hace**: Commits semánticos con grouping automático por categoría.

**Cuándo**: Después de completar cambios.

### `/git-github:pr`

```bash
/git-github:pr <target_branch>
```

**Qué hace**: Crea PR con security review BLOCKING, push seguro y metadata completa.

**Cuándo**: Para crear PRs con estándares de calidad.

**ROI**: Security review integrado previene vulnerabilidades.

### `/git-github:switch`

```bash
/git-github:switch <target_branch>
```

**Qué hace**: Valida PR mergeado, cambia a rama objetivo y limpia workspace temporal.

**Cuándo**: Al finalizar PRs mergeados.

### `/git-github:issue-manager`

```bash
/git-github:issue-manager              # Dashboard de issues activos
/git-github:issue-manager <number>     # Análisis profundo
```

**Qué hace**: Dashboard inteligente o análisis detallado con complejidad, prioridad y próximos pasos.

**Cuándo**: Visión de workload o análisis pre-implementación.

### Sync a GitHub

Comandos para sincronizar artifacts locales a GitHub:

#### `/git-github:issue-sync`

```bash
/git-github:issue-sync <issue_number>
```

Push local updates como GitHub issue comments para audit trail.

---

## 🛠️ Utilidades

### `/utils:understand`

```bash
/utils:understand
/utils:understand "specific area"
```

**Qué hace**: Análisis comprehensivo de arquitectura, patrones y dependencies.

**Cuándo**: SIEMPRE antes de implementar feature compleja.

**ROI**: 30 min ahorran 3+ horas de refactoring.

### `/utils:three-experts`

```bash
/utils:three-experts <goal>
```

**Qué hace**: Panel de 3 expertos (backend/frontend/security) genera plan consensuado.

**Cuándo**: Features complejas que requieren múltiples perspectivas.

### `/utils:docs`

```bash
/utils:docs                 # Analizar toda la docs
/utils:docs README API      # Focus específico
```

**Qué hace**: Analiza y actualiza documentación usando specialist agents.

**Cuándo**: Después de features o cambios importantes.

### `/utils:polish`

```bash
/utils:polish <file_paths>
```

**Qué hace**: Polishing meticuloso de archivos AI-generated.

**Cuándo**: Refinar contenido generado por AI.

**⚠️ CRÍTICO**: Preserva 100% funcionalidad mientras mejora calidad.

### `/utils:deep-research`

```bash
/utils:deep-research "<investigation topic>"
```

**Qué hace**: Professional audit con metodología sistemática y multi-source validation.

**Cuándo**: Investigaciones complejas, due diligence, market research.

**Protocolo**: Minimum 3 independent sources, anti-hallucination rules.

### `/utils:changelog`

```bash
/utils:changelog                    # Auto-detectar PRs faltantes
/utils:changelog <pr_number>        # Single PR
/utils:changelog <pr1,pr2,pr3>     # Multiple PRs
```

**Qué hace**: Actualiza CHANGELOG.md con PRs mergeados (Keep a Changelog format), detecta duplicados.

**Cuándo**: Después de merge para documentar cambios.

---

## 🎯 Workflows Típicos

### Feature Nueva (AI-First)

```bash
# SETUP
/utils:session-start
/git-github:worktree:create feature-name develop
cd ../worktree-feature-name
claude /utils:session-start

# CICLO SDD
/SDD-cycle:specify "nueva feature"
/SDD-cycle:clarify                  # CRÍTICO - reduce rework 70%
/SDD-cycle:plan
/SDD-cycle:tasks
/SDD-cycle:analyze
/SDD-cycle:implement

# CALIDAD Y PR
/git-github:commit "all changes"
/git-github:pr develop
# Merge + /utils:changelog
/git-github:worktree:cleanup worktree-feature-name
```

**⚡ Tiempo**: 30-60 min (vs 4-8h manual)

### Feature desde PRD

```bash
/PRD-cycle:prd-sync <feature_name>
/SDD-cycle:specify --from-issue <number>
# Continuar con workflow SDD desde clarify
```

### Bug Fix Urgente

```bash
/git-github:worktree:create fix-bug main
cd ../worktree-fix-bug
claude /utils:session-start
/utils:understand "problema"
# Fix código
/git-github:commit "fix: descripción"
/git-github:pr main
```

### Análisis Workload

```bash
/git-github:issue-manager           # Dashboard
/git-github:issue-manager <number>  # Deep dive
/utils:understand                   # Si es necesario
```

---

## 💡 Tips de Uso

### Flujo Óptimo

- **Siempre** iniciar con `/utils:session-start`
- **Siempre** usar worktrees (evita branch pollution)
- **Nunca** saltarse `/SDD-cycle:clarify` (reduce rework 70%)
- **Siempre** dejar `/git-github:pr` ejecutar security review

### Comandos Pre-Production

1. `/SDD-cycle:implement` - TDD enforcement automático
2. `/git-github:pr` - Security review blocking
3. `/utils:changelog` - Keep a Changelog compliance

### Parallel Execution

- `/SDD-cycle:implement` y `/git-github:pr` ejecutan agents en paralelo automáticamente
- Tasks marcadas `[P]` se ejecutan concurrentemente

---

## 🎓 Jerarquía por Frecuencia

**Uso Diario** (>5x/día):
`/utils:session-start` • `/git-github:commit` • `/SDD-cycle:implement`

**Uso Regular** (1-3x/día):
`/git-github:worktree:create` • `/SDD-cycle:specify` • `/git-github:pr` • `/utils:understand`

**Uso Semanal**:
`/SDD-cycle:clarify` • `/utils:changelog` • `/utils:docs` • `/git-github:issue-manager`

**Uso Mensual/Setup**:
`/PRD-cycle:prd-new` • `/utils:three-experts` • `/SDD-cycle:constitution` • `/utils:deep-research`

---

_Última actualización: 2025-10-06 | 23 comandos documentados_
