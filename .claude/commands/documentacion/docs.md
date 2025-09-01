# Documentation Command

I'll analyze your project documentation and invoke the documentation specialist to create or update docs efficiently.

Arguments: `$ARGUMENTS` - specific docs to focus on (optional)

## Workflow

**Phase 1: Documentation Analysis**
I'll scan existing documentation:
- **Glob** all markdown files (README, CHANGELOG, docs/*)
- **Read** key documentation files
- **Identify** gaps and outdated content

**Phase 2: Specialist Invocation**
I'll delegate to the documentation specialist:
- **Task tool** with `documentation-specialist` agent
- **Context**: Current docs analysis + project structure
- **Focus**: Specific areas from `$ARGUMENTS` or comprehensive update

**Phase 3: Result Delivery**
The specialist will:
- Create missing documentation
- Update outdated content  
- Follow project conventions
- Generate actionable docs

## Usage Examples

```bash
/docs                    # Analyze all docs and update
/docs README API         # Focus on README and API docs
/docs CHANGELOG          # Update changelog only
```

## What the Specialist Handles

Based on `.claude/agents/core/documentation-specialist.md`:
- Gap analysis and planning
- Content creation with templates
- Technical accuracy validation
- Delegation to other agents when needed

## Execution Guarantee

**My workflow:**
1. **Analyze** → Scan current documentation state
2. **Delegate** → Invoke documentation-specialist via Task tool
3. **Deliver** → Return specialist's output directly

**I will NEVER:**
- Bypass the specialist agent
- Create complex session management
- Duplicate specialist functionality
- Add unnecessary complexity

This provides clean, specialist-driven documentation management without overengineering.