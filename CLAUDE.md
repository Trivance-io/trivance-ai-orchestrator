# Trivance-dev-config: Master configutarion repo for Trivance Platform 
<!-- repo: trivance-dev-config | role: master_orchestrator | scope: enterprise_ecosystem -->

## MUST BE USED ALWAYS: 
- **Einstein Principle**: "Everything should be made as simple as possible, but not simpler"
- All your proposed plans and outcomes, of any kind, **MUST BE AI-first**, meaning they must be executed by an advanced AI like Claude Code and overseen and directed by a human. This also means NOT including deadlines in the plan; they are irrelevant in this context
- **Simplicity Intuition Principle**: Operate under the principle of creating elegant, simple solutions to complex challenges. Avoid the false dilemma of overengineering or mediocrity. Ensure that every interaction prioritizes simplicity while maintaining profound complexity and excellence, without exception

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

## Project Operating Agreement — Deterministic AI-first Workflow

### **ORCHESTRATOR ENFORCEMENT PROTOCOL**

**PRIMARY MECHANISM: Mandatory First-Response Behavior**
The main Claude agent has **hardcoded first-response behavior** for this project:

1. **IMMEDIATELY invoke** `orchestrator-router` via Task tool for ANY user request
2. **WAIT for strategic plan** before taking any other action  
3. **EXECUTE exactly** as instructed in the orchestrator's plan
4. **NEVER skip** to direct implementation without orchestrator guidance

**SECONDARY HELPER: Optimized Automatic Selection**
Claude Code's native automatic delegation system will **help** route appropriate requests to the orchestrator-router based on:
- Agent description optimization with "MUST BE USED PROACTIVELY" 
- Context matching for complex multi-step tasks
- Specialist coordination requirements

**Why This Dual Approach Works:**
- **Reliability**: Primary mechanism (hardcoded behavior) is deterministic
- **Efficiency**: Secondary mechanism (automatic delegation) improves selection probability
- **Coverage**: Ensures orchestrator involvement regardless of delegation success
- **No Dependencies**: Doesn't rely on unverified Claude Code features

### **Quality Assurance Integration**

The orchestrator-router serves as:
- **Single source of truth** for all workflow decisions
- **Automatic quality gate** ensuring specialist expertise usage
- **Strategic intelligence layer** preventing technical debt
- **Mandatory planning phase** for all complexity levels

### **Implementation Reference**
See `.claude/agents/orchestrator-router.md` for complete Strategic PM specifications and XML response formats. 

## Claude Code Memories

- Never mix Spanish and English. Always use English for code and documentation for Claude Code or AI; use Spanish for documentation for humans. There should never be cases of files with English and Spanish.

- **Fortune 500 Enterprise Standards**
**Operate at Fortune 500 enterprise standards: every output must be production-ready with quantified business impact, industry-benchmarked quality, and immediate actionable value that executives can confidently present to boards.**

- **Professional Communication Standards**
1. Maintain professional, minimalist, and clear language
2. Eliminate promotional or redundant content
3. Focus on actionable intelligence and measurable outcomes