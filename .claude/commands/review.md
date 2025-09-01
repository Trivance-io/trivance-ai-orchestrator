---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *), Bash(gh *), Bash(git *), Task, Edit, MultiEdit, Write
description: AI-powered code review engine with specialist analysis for complete codebase or targeted PR review with implementation plans
---

# Smart Code Review

I'll intelligently review your code using specialized agents - analyzing the complete codebase or generating targeted implementation plans from PR reviews.

## Usage
```bash
/review                  # Complete codebase review with 3 specialists
/review pr <number>      # PR-specific review + implementation plan  
/review help             # Show usage instructions
```

## Examples
```bash
/review                  # Full analysis with code-quality, security, and edge-case specialists
/review pr 96            # Analyze PR #96 findings + generate actionable plan
/review help             # Display detailed help
```

## Execution

When executing this command with argument `$ARGUMENTS`, follow these steps:

### 1. Argument validation and mode selection
- **If no arguments** → CODEBASE mode: Continue with step 2 (Complete review)
- **If first argument is "help"** → Show usage instructions and terminate:
  ```
  📖 **Comando Review Unificado - Instrucciones de Uso**
  
  **Modos disponibles:**
  
  🔍 **Complete Codebase Review:**
     /review
     
     - Analyzes all code in current workspace
     - Uses 3 specialists in parallel:
       • code-quality-reviewer (architecture, technical debt)
       • config-security-expert (dangerous configurations)  
       • edge-case-detector (edge cases, silent failures)
     - Generates consolidated report with priorities
     - Storage: .claude/reviews/review-[timestamp].md
  
  🎯 **PR-Specific Review + Plan:**
     /review pr <number>
     
     - Extracts specific findings from PR via GitHub
     - Technical analysis with code-quality-reviewer
     - Generates detailed implementation plan
     - Storage: .claude/reviews/pr<number>-resolve-[timestamp].md
  
  ❓ **Help:**
     /review help
  ```
- **If first argument is "pr" with valid numeric second argument** → PR mode: Continue with step 3
- **If first argument is "pr" without second argument or non-numeric** → Show error:
  ```
  ❌ Error: Número de PR requerido
  
  Uso: /review pr <number>
  Ejemplo: /review pr 96
  Ayuda: /review help
  ```
- **Unrecognized arguments** → Show error and terminate:
  ```
  ❌ Error: Argumento no reconocido
  
  Uso válido:
  - /review              (complete analysis)
  - /review pr <number>  (PR-specific analysis)
  - /review help         (show help)
  ```

### 2. CODEBASE Mode - Complete Review (No arguments)
- Mostrar: "🔍 Iniciando review completo del codebase..."
- **Mandatory pre-checkpoint**:
  - Use `git add -A` to add changes
  - Use `git commit -m "Pre-review checkpoint" || echo "No changes to commit"`
- **Parallel delegation to specialists**:
  - Use `Task` tool to delegate to `code-quality-reviewer`
  - Use `Task` tool to delegate to `config-security-expert`  
  - Use `Task` tool to delegate to `edge-case-detector`
  - Provide each specialist with complete workspace context
  - Each specialist will analyze according to their specialized domain
- **Result consolidation**:
  - Capture findings from 3 specialists
  - Classify by severity: CRITICAL/HIGH/SUGGESTIONS
  - Combine into unified report
- Continue with step 7 (Storage and reporting)

### 3. PR Mode - Specific Review (Only "pr <number>" mode)
- Mostrar: "🎯 Iniciando review específico de PR #<número>..."
- **Auto-detect repository**: Use `gh repo view --json owner,name` to get owner and repo
- If detection fails, show error "❌ No se pudo detectar repositorio GitHub" and terminate  
- **Validate PR exists**: Use `mcp__github__get_pull_request` with detected owner/repo
- If not exists, show error "❌ PR #<number> no existe" and terminate
- Get and show: "🔍 Analizando PR #<number>: <title>"
- Mostrar: "📥 Extrayendo findings de PR reviews y comentarios..."
- Use `mcp__github__get_pull_request_reviews` to get all PR reviews
- Use `mcp__github__get_pull_request_comments` to get all PR comments
- Use `mcp__github__get_issue_comments` to get PR conversation comments
- Analyze PR body to detect actionable Claude Code Review content
- Count and show: "✅ Encontrados <X> reviews, <Y> comments, <Z> issue comments y análisis de PR body"
- Use `mcp__github__get_me` to get current user

### 4. Intelligent filtering of actionable content (PR mode only)
- **For each review obtained**:
  - **Filter noise**: Skip if state is "APPROVED" AND has no useful body
  - **Filter generic**: Skip if body contains only: LGTM, 👍, ✅, Good, Great  
  - **Detect actionable**: If state is "CHANGES_REQUESTED" OR body contains keywords: should, must, need, fix, error, issue, problem, security, performance, test
  - Agregar a findings: "Review from <reviewer>: <body>"

- **Para comentarios e issue comments**:
  - **Filtrar ruido**: Skip si body vacío o solo: LGTM, 👍, ✅, Good, Great, Thanks
  - **Detectar actionable**: Si body contiene keywords: should, must, need, fix, error, issue, problem, security, performance, test, suggestion, recommend, consider, enhancement
  - Agregar a findings: "Comment from <commenter>: <body>"

- **Para PR body**:
  - **Detectar Claude Code Review**: Buscar secciones con findings, recomendaciones, issues identificados
  - Agregar a findings: "PR body analysis: <content>"

- **Si no hay findings actionables**: Mostrar "ℹ️ No se encontraron findings actionables en el PR" y terminar

### 5. Technical analysis for specific PR (PR mode only)
- **Delegation to code-quality-reviewer**:
  - Use `Task` tool to delegate technical analysis to `code-quality-reviewer` sub-agent
  - Show: "🔬 Delegando análisis técnico al code-quality-reviewer..."
  - Provide PR #<number> context and complete list of actionable findings
  - Request specific analysis: technical priority, complexity, files to modify, implementation plan
  - The code-quality-reviewer must consult the PR directly for complete context
- **Capture results**: CRITICAL/HIGH/MEDIUM/LOW prioritization, estimates, detailed technical plan
- Mostrar: "✅ Análisis técnico completado"

### 6. Enterprise plan generation for PR (PR mode only)
- Create directory: `mkdir -p .claude/reviews`
- Generate timestamp: `date '+%Y-%m-%dT%H:%M:%S'`
- Generate filename: `.claude/reviews/pr<number>-resolve-<timestamp>.md`
- Use template based on code-quality-reviewer analysis:
  ```
  # 🎯 Plan de Resolución PR #<pr_number>
  
  ## 📊 Resumen
  - **PR**: #<pr_number> - <pr_title>
  - **Findings**: <count> total (<critico_count> críticos, <alto_count> altos)
  - **Estimación**: <total_hours> horas
  
  ## 🔥 Implementación por Prioridad
  
  [For each finding:]
  ### <PRIORIDAD> - <finding_summary>
  - **Archivos**: <files_to_modify>
  - **Plan**: <implementation_steps>
  - **Tiempo**: <hours>h
  
  ## ✅ Checklist Final
  - [ ] Críticos implementados
  - [ ] Tests actualizados  
  - [ ] Commit con referencia al PR
  - [ ] Solicitar nueva revisión
  ```
- Write plan to file using `Write`
- Mostrar: "📋 Plan generado: <plan_file>"

### 7. Unified storage and logging
- **For both modes**: Create directory `mkdir -p .claude/logs/$(date +%Y-%m-%d)`
- **For CODEBASE mode**:
  - Filename: `.claude/reviews/review-$(date '+%Y-%m-%dT%H:%M:%S').md`
  - Generate consolidated report with findings from 3 specialists
  - Log entry: timestamp, mode="codebase", specialists=3, findings_total
- **For PR mode**:
  - Filename already generated in step 6
  - Log entry: timestamp, mode="pr", pr_number, findings_actionable, priority_breakdown
- Append log to: `.claude/logs/<date>/review_activity.jsonl`

### 8. Final report
- **For CODEBASE mode**:
  ```
  📊 **Review Completo Finalizado**
  
  **Especialistas ejecutados:**
  ├─ code-quality-reviewer: <findings_count> findings
  ├─ config-security-expert: <findings_count> findings  
  └─ edge-case-detector: <findings_count> findings
  
  **Clasificación consolidada:**
  ├─ 🚨 CRÍTICOS: <count> (requieren atención inmediata)
  ├─ ⚠️ ALTA PRIORIDAD: <count> (deberían resolverse pronto)
  └─ 💡 SUGERENCIAS: <count> (mejoras opcionales)
  
  **Resultados:** <review_file>
  **Logs:** <log_file>
  
  **Próximos pasos:**
  - Revisar findings críticos primero
  - Priorizar según impacto en producción
  - Considerar crear issues para seguimiento formal
  ```

- **For PR mode**:
  ```
  📊 **Review PR #<pr_number> Finalizado**
  
  **Extracción:**
  ├─ Reviews analizados: <count>
  ├─ Comentarios analizados: <count>
  └─ Findings actionables: <count>
  
  **Análisis técnico:**
  ├─ Priorización: <critico_count> Críticos, <alto_count> Altos, <medio_count> Medios, <bajo_count> Bajos
  ├─ Estimación total: <total_hours> horas
  └─ Archivos afectados: <files_count>
  
  **Plan generado:** <plan_file>
  
  **Próximos pasos:**
  - Revisar plan detallado
  - Implementar findings por prioridad
  - Commitear cambios con referencias
  - Solicitar nueva revisión del PR
  
  **Logs:** <log_file>
  ```

## Success Criteria

- **Codebase Mode**: Complete multi-specialist review with intelligent consolidation
- **PR Mode**: Precise extraction + detailed technical implementation plan  
- **Argument Handling**: Robust validation with clear help messages
- **Unified Architecture**: Complete reuse of existing specialist infrastructure
- **Storage**: Organized files in .claude/reviews/ with unique timestamps

**IMPORTANT**: 
- Validate arguments before any operation
- Show help messages for incorrect usage
- Execute pre-checkpoint only in codebase mode
- Do not implement automatically in PR mode (only generate plan)
- Create necessary directories before writing files