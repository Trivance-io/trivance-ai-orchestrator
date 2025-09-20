# Trivance-AI-Orchestrator: Master configuration repo for Trivance Platform

<!-- repo: trivance-ai-orchestrator | role: master_orchestrator | scope: enterprise_ecosystem -->

## Operating Protocol

"Everything should be made as simple as possible, but not simpler.”

1. **First principle** your value is measured by the ratio **value / complexity ≥ 2**.
2. **Frame the problem**

- Restate the goal in ≤ 3 bullet points.
- Size class: **S** ≤ 2 h · **M** ≤ 1 day · **L** > 1 day.

3. **Complexity budget**
   | Size | Δ LOC | New files | New deps | Δ CPU/RAM |
   |------|------:|----------:|---------:|----------:|
   | S | ≤ 80 | ≤ 1 | 0 | ≤ 1 % |
   | M | ≤ 250 | ≤ 3 | ≤ 1 | ≤ 3 % |
   | L | ≤ 600 | ≤ 5 | ≤ 2 | ≤ 5 % |

_If you expect to exceed the budget: **stop and ask**._

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

## Interaction Language

1. **Always use Spanish** as the language of communication with the user
2. **Only in the first message of a session**, show: _(You can change the interaction language by asking me whenever you want.)_

## Summary instructions

### Always preserve

- **Project objective** and measurable success criteria.
- **High-level roadmap** (milestones, deadlines).
- **Material code changes**: file paths, diffs, migrations.
- **Open TODO / backlog items** with assignees and due dates.
- **Key file or directory paths** referenced in the conversation.

### Omit or condense

- Casual conversation or small talk.
- Verbose CLI/test logs or stack traces unless directly required.
- Duplicate or trivial messages.

## Documentation References

**Essential guides for Claude Code ecosystem:**

**Commands**: @.claude/human-handbook/commands-guide.md

- High-value commands (understand, implement, review, test)
- Workflow commands (session-start, pr, commit)
- Specialized commands (todos, worktree, security-scan)
- Practical usage flows and ROI metrics

**Agents**: @.claude/human-handbook/agents-guide.md

- 33+ specialist agents organized by value and use case
- Strategic orchestration and framework-specific expertise
- Quality assurance and design enhancement capabilities
- Agent combination patterns and selection principles

**Workflow**: @.claude/human-handbook/ai-first-workflow.md

- Complete PR lifecycle from code to merge
- Findings resolution with specialist delegation
- Authorization workflows and iterative improvement
- High-impact command sequences and best practices

**Constitution**: @.specify/memory/constitution.md

- AI-first workflow principles and governance framework
- Value/complexity ratio requirements and complexity budgets
- Test-first development methodology (TDD mandatory)
- Quality standards and implementation rules

## guidelines for code review (claude bot review)

- Priority: **SECURITY**, **BUG**, **RELIABILITY**, **PERFORMANCE** with production impact.
- Ignore style/nits if they do not affect clarity or security.
- Do not suggest repo-wide refactors outside the diff.

### Project conventions

- **JS/TS**: use `camelCase` names, avoid magic numbers, handle errors with `Result` or consistent `try/catch`.
- **Testing**: do not comment on snapshots/coverage unless there are signs of real fragility.

### Exclusions

- `build/`, `dist/`, `vendor/`, `**/*.lock`, assets (`*.png`/`*.jpg`/`*.svg`), `coverage/`, `snapshots/`

## Claude Code Memories

### Project Operations

- **Complexity Budget**: Validate against Size S/M/L metrics before exceeding scope.
- **AI-First Principle**: All plans must be executable by AI with human oversight.

### Quality Standards

- **Language Consistency**: English for code/AI documentation, Spanish for human documentation. Never mix languages in same file.
- **Communication Style**: Professional, minimalist, clear language. Eliminate promotional content.
- **Output Quality**: Production-ready with quantified business impact and executive-presentable value.
- **Quality Gates**: Use code-quality-reviewer proactively for security and performance validation.

### Agent Integration

- **Contextual Suggestions**: Suggest proactively specialists based on challenge type, never mandate usage.
- **Orchestrator Priority**: Use `tech-lead-orchestrator` for multi-step challenges and strategic coordination.
- **Specialist Selection**: Core specialists for quality, framework specialists for implementation.

### Documentation Site Context

- **GitHub Pages Setup**: Documentation site hosted via Jekyll on GitHub Pages from `/docs` directory.
- **Content Source**: Documentation files located in `.claude/human-handbook/docs/` converted to responsive web format.
- **Jekyll Structure**: Standard Jekyll layout with \_layouts, \_includes, assets/css, assets/js for responsive documentation site.
- **Search Implementation**: Client-side JavaScript search with JSON index generated at build time.
- **Performance Targets**: <3s load time, Lighthouse score >90, mobile-first responsive design.
- **Build Pipeline**: Automatic GitHub Pages deployment on push to main branch, Jekyll 4.x compatible.
