# Trivance-AI-Orchestrator: Master configuration repo for Trivance Platform 
<!-- repo: trivance-ai-orchestrator | role: master_orchestrator | scope: enterprise_ecosystem -->

## MUST BE USED 🔧 SIMPLE-ENOUGH™ OPERATING PROTOCOL
"Everything should be made as simple as possible, but not simpler.”
1. **First principle** your value is measured by the ratio **value / complexity ≥ 2**.
2. **Frame the problem** 
• Restate the goal in ≤ 3 bullet points.  
• Size class: **S** ≤ 2 h · **M** ≤ 1 day · **L** > 1 day.
3. **Complexity budget**
| Size | Δ LOC | New files | New deps | Δ CPU/RAM |
|------|------:|----------:|---------:|----------:|
| S    | ≤ 80  | ≤ 1       | 0        | ≤ 1 %     |
| M    | ≤ 250 | ≤ 3       | ≤ 1      | ≤ 3 %     |
| L    | ≤ 600 | ≤ 5       | ≤ 2      | ≤ 5 %     |

*If you expect to exceed the budget: **stop and ask**.*

4. **Guided exploration**
Propose **2-3** approaches. For each:  
`benefit (1-5) | complexity (1-5) | ROI = benefit − complexity`.  
Choose the highest ROI; tie-break toward the simpler one.
5. **Implementation rules**
 - **Reuse first** — list reused components/functions.  
 - **New abstraction ⇒ justification ≥ 30 % duplication or future-cost reduction.**  
 - **TDD loop** — red → green → refactor.  
 - **Self-audit** — confirm §3 metrics are met.

6. All your proposed plans and outcomes, of any kind, **MUST BE AI-first**, meaning they must be executed by an advanced AI like Claude Code and overseen and directed by a human.

## Interaction Language **ALWAYS MUST BE USED**
1. **Always use Spanish** as the language of communication with the user
2. **Only in the first message of a session**, show: *(You can change the interaction language by asking me whenever you want.)*

## Summary instructions

### Always preserve
- **Project objective** and measurable success criteria.
- **High-level roadmap** (milestones, deadlines).
- **Material code changes**: file paths, diffs, migrations.
- **Open TODO / backlog items** with assignees and due dates.
- **Key file or directory paths** referenced in the conversation.

## Omit or condense
- Casual conversation or small talk.
- Verbose CLI/test logs or stack traces unless directly required.
- Duplicate or trivial messages.

## Strategic Platform Context

**Trivance Platform** delivers competitive advantage through:
- **4-service hybrid architecture** enabling optimized local development environment
- **Sub-2-second hot-reload development** cycle with guaranteed performance
- **Hot-reload development cycle** with automated workspace management
- **Development security** with auto-generated unique secrets per workspace
- **Real-time observability** with centralized logging and performance monitoring

## Master Orchestrator Responsibilities

### Multi-Repository Coordination
1. **Ecosystem Integration**: Manages 4 independent Git repositories as unified workspace
2. **Configuration Authority**: Single source of truth for environment and security settings
3. **Deployment Orchestration**: Coordinates Docker + PM2 + Expo hybrid architecture
4. **Security Management**: Auto-generation and lifecycle management of secrets
5. **Development Workflow**: Unified interface via scripts/start.sh command center
6. **Documentation Hub**: Centralized technical documentation and operational procedures

### Operational Constraints
- **Critical operations**: Require explicit confirmation (scripts/core/orchestrator.sh, scripts/utils/clean-workspace.sh, environment switches)
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

## AI-First Workflow Reference

@.claude/human-handbook/ai-first-workflow.md

Complete workflow from implementation to merge:
- PR creation with Claude Code  
- Converting findings into issues
- Iterative resolution within same PR
- Authorization criteria after 4-5 iterations

## Claude Code Memories

- Never mix Spanish and English. Always use English for code and documentation for Claude Code or AI; use Spanish for documentation for humans. There should never be cases of files with English and Spanish.

- **Production Standards**: Every output must be production-ready with quantified business impact, measurable quality metrics, and immediate actionable value that executives can confidently present to boards.

- **Professional Communication Standards**
1. Maintain professional, minimalist, and clear language
2. Eliminate promotional or redundant content
3. Focus on actionable intelligence and measurable outcomes