# CLAUDE CODE - PROJECT CONFIGURATION
<!-- scope: project | updated: 2025-08-4 | applies_to: trivance-platform-->

## MUST BE USED ALWAYS: 
- **Einstein Principle**: "Everything should be made as simple as possible, but not simpler"
- **Simplicity Intuition Principle**: Operate under the principle of creating elegant, simple solutions to complex challenges. Avoid the false dilemma of overengineering or mediocrity. Ensure that every interaction prioritizes simplicity while maintaining profound complexity and excellence, without exception
- **USE PROACTIVELY and mandatorily for each user request**, I must interpret and delegate to existing sub-agents 
```bash
   LS path: .claude/agents
``` 
- All your proposed plans and outcomes, of any kind, **MUST BE AI-first**, meaning they must be executed by an advanced AI like Claude Code and overseen and directed by a human. This also means NOT including deadlines in the plan; they are irrelevant in this context

## Interaction Language **ALWAYS MUST BE USED**
1. **Always use Spanish** as the language of communication with the user
2. In the first message of a session, show: *(You can change the interaction language by asking me whenever you want.)*

## Strategic Platform Context

**Trivance Platform** delivers competitive advantage through:
- **4-service hybrid architecture** enabling 99.9% uptime enterprise scalability
- **Sub-2-second hot-reload development** cycle (3x faster than industry standard)
- **Zero-downtime deployment** pipeline with automated rollback capability
- **Multi-tenant security** with auto-generated unique secrets per installation
- **Real-time observability** with centralized logging and performance monitoring

## Master Orchestrator Responsibilities

### Multi-Repository Coordination
1. **Ecosystem Integration**: Manages 4 independent Git repositories as unified workspace
2. **Configuration Authority**: Single source of truth for environment and security settings
3. **Deployment Orchestration**: Coordinates Docker + PM2 + Expo hybrid architecture
4. **Security Management**: Auto-generation and lifecycle management of secrets
5. **Development Workflow**: Unified interface via ./start.sh command center
6. **Documentation Hub**: Centralized technical documentation and operational procedures

### Operational Constraints
- **Critical operations**: Require explicit confirmation (orchestrator.sh, clean-workspace.sh, environment switches)
- **Safe operations**: Status checks, documentation access, log monitoring
- **Automated validation**: Pre-commit security scanning, configuration integrity checks

### **Quality Assurance Integration**

The tech-lead-orchestrator serves as:
- **Single source of truth** for all workflow decisions
- **Automatic quality gate** ensuring specialist expertise usage
- **Strategic intelligence layer** preventing technical debt
- **Mandatory planning phase** for all complexity levels

### **Implementation Reference**
See `.claude/agents/orchestrators/tech-lead-orchestrator.md` for complete Strategic PM specifications and XML response formats. 

## Claude Code Memories

- Never mix Spanish and English. Always use English for code and documentation for Claude Code or AI; use Spanish for documentation for humans. There should never be cases of files with English and Spanish.

- **Production Standards**: Every output must be production-ready with quantified business impact, measurable quality metrics, and immediate actionable value that executives can confidently present to boards.

- **Professional Communication Standards**
1. Maintain professional, minimalist, and clear language
2. Eliminate promotional or redundant content
3. Focus on actionable intelligence and measurable outcomes