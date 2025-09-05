---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *), Bash(gh *), Bash(git *), Task, Edit, MultiEdit, Write
description: AI-powered code review engine with specialist analysis
---

# Smart Code Review

I'll intelligently review your code using specialized agents.

## Usage
```bash
/review                    # Complete codebase review with 3 specialists
/review $ARGUMENTS         # Targeted review based on your specific context
```

## Execution

When executing this command with argument `$ARGUMENTS`, follow these steps:

### 1. Context Detection
- **If no arguments**: Set context = "complete workspace context"
- **If arguments provided**: Set context = arguments as specific analysis scope

### 2. Unified Review Process
- Show: "🔍 Iniciando review..."
- **Mandatory pre-checkpoint**:
  - Use `git add -A` to add changes
  - Use `git commit -m "Pre-review checkpoint" || echo "No changes to commit"`
- **Parallel delegation to specialists**:
  - Use `Task` tool to delegate to `code-quality-reviewer`
  - Use `Task` tool to delegate to `config-security-expert`  
  - Use `Task` tool to delegate to `edge-case-detector`
  - Provide each specialist with the determined context
  - Each specialist will analyze according to their specialized domain
- **Result consolidation**:
  - Capture findings from 3 specialists
  - Classify by severity: CRITICAL/HIGH/SUGGESTIONS
  - Combine into unified report
- Continue with step 3

### 3. Unified Storage and Reporting
- **Create directories**: `mkdir -p .claude/reviews .claude/logs/$(date +%Y-%m-%d)`
- **Generate timestamp**: `date '+%Y-%m-%dT%H:%M:%S'`
- **Determine filename**:
  - No arguments: `.claude/reviews/review-$(timestamp).md`
  - With arguments: `.claude/reviews/targeted-$(timestamp).md`
- **Write consolidated report** using `Write` tool with findings and recommendations
- **Log activity**: Append entry to `.claude/logs/$(date +%Y-%m-%d)/review_activity.jsonl`

### 4. Final Report
```
📊 **Review Finalizado**

**Especialistas ejecutados:**
├─ code-quality-reviewer: <findings_count> findings
├─ config-security-expert: <findings_count> findings  
└─ edge-case-detector: <findings_count> findings

**Clasificación consolidada:**
├─ 🚨 CRÍTICOS: <count> (requieren atención inmediata)
├─ ⚠️ ALTA PRIORIDAD: <count> (deberían resolverse pronto)
└─ 💡 SUGERENCIAS: <count> (mejoras opcionales)

**Resultados:** <review_file>

**Próximos pasos:**
- Revisar findings críticos primero
- Priorizar según impacto
```

## Success Criteria

- **Unified Process**: Single delegation flow to 3 specialists with context-dependent analysis
- **Consistent Architecture**: Same specialist delegation regardless of arguments
- **Smart Context**: Complete workspace vs targeted scope based on user input
- **Storage**: Organized files in .claude/reviews/ with unique timestamps