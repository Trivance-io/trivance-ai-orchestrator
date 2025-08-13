# AI-First Session Auto-Configuration

I will automatically configure the workspace according to project specifications.

## 🔍 Automatic Context Analysis

Reading project configuration...

I will automatically read:
- CLAUDE.md and all its references
- Current git state (branch, changes, commits)
- Project structure and dependencies  
- Previous session history

## 🚀 Intelligent Workspace Configuration

Based on detected context, I will automatically activate:
- **project-analyst**: If unknown tech stack or structural changes detected
- **team-configurator**: If CLAUDE.md needs AI configuration updates
- **tech-lead-orchestrator**: Development orchestrator - delegates ANY task (feature, bug, scope) to specialized agents in parallel

## 🎯 Contextual Next Steps

Based on current project state, most likely options are:

**If work in progress:**
- `/pr` - Continue with existing PR
- `git status` - Review pending changes
- `/commit` - Commit completed work

**If new session:**
- `/workflow:switch <branch>` - Switch to clean working branch
- Check pending issues with `gh issue list`
- Start new functionality

**AI-first workflow commands available:**
```bash
/workflow:switch <branch>     # Clean workspace and switch branch
/pr [target]                  # Create/update PR
/github:findings-to-issues    # Convert findings to issues
/commit "message"             # Semantic commit with validations
gh issue list                 # View pending issues
```

## 🔧 Applied Configurations

- **SIMPLE-ENOUGH™ Protocol**: Activated (value/complexity ≥ 2)
- **Interaction language**: Spanish (per CLAUDE.md)
- **Production Standards**: Stable code with measurable impact
- **AI-first Workflow**: Configured per ai-first-workflow.md

**Applied commit restrictions:**
- NEVER add "Co-authored-by" or Claude signatures
- NEVER include "Generated with Claude Code" 
- NEVER modify git config or credentials
- NEVER use emojis in commits or PRs

---

**Workspace is ready. What is your objective for this session?**