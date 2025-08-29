# Smart Implementation Engine

I'll intelligently implement features from any source - adapting them perfectly to your project's architecture while maintaining your code patterns and standards.

Arguments: `$ARGUMENTS` - URLs, paths, or descriptions of what to implement

## Session Intelligence

I'll check for existing implementation sessions to continue seamlessly:

**Session Files (in current project directory):**
- `.claude/implementations/plan.md` - Current implementation plan and progress
- `.claude/implementations/state.json` - Session state and checkpoints

**Session Management:**
- **Auto-resume**: If session files exist, I'll load existing plan and state, show progress summary, continue from last checkpoint
- **New session**: If no session exists, I'll create new implementation plan and tracking
- **Commands**: `/implement resume` (explicit), `/implement status` (check progress)

**IMPORTANT:** Session files stored in `.claude/implementations/` folder in current project root, NOT home directory or parent folders.

## Phase 1: Strategic Planning with Quality Prevention

First, I'll establish strategic direction through professional orchestration:

**Source & Context Analysis:**
I'll examine what you've provided and your project structure:

**Source Detection:**
- Web URLs (GitHub, GitLab, CodePen, JSFiddle, documentation sites)
- Local paths (files, folders, existing code)
- Implementation plans (.md files with checklists)
- Feature descriptions for research

**Project Understanding:**
- Architecture patterns using **Glob** and **Read**
- Existing dependencies and their versions
- Code conventions and established patterns
- Testing approach and quality standards

**Orchestrated Strategic Process:**
1. **Invoke tech-lead-orchestrator** with source analysis and project context
2. **Receive comprehensive strategy** including:
   - Dream Team Assembly with specialist agent assignments
   - Quality Prevention Strategy from mandatory reviewer consultation
   - Execution timeline with parallel/sequential coordination
3. **Establish implementation roadmap** with integrated quality checkpoints

## Phase 2: Plan Documentation & Setup

Based on strategic planning from Phase 1, I'll create implementation infrastructure:

**Session Setup:**
1. Check if `.claude/implementations` directory exists in current working directory
2. If directory exists, check for session files:
   - Look for `.claude/implementations/state.json`
   - Look for `.claude/implementations/plan.md` 
   - If found, resume from existing session
3. If no directory or session exists:
   - Create implementation infrastructure
   - Initialize tracking files with strategic plan
4. Document the orchestrated strategy received from tech-lead-orchestrator

**Critical:** Use `.claude/implementations` folder in current directory. Do NOT use `$HOME/.claude/implementations` or parent directory paths

I'll write this enhanced plan to `.claude/implementations/plan.md`:

```markdown
# Implementation Plan - [timestamp]

## Source Analysis
- **Source Type**: [URL/Local/Description]
- **Core Features**: [identified features to implement]
- **Dependencies**: [required libraries/frameworks]
- **Complexity**: [estimated effort]

## Strategic Coordination (tech-lead-orchestrator)
- **Challenge Type**: [ANALYSIS|BUG|REFACTOR|API|IMPLEMENTATION]
- **Dream Team**: [selected specialist agents]
- **SubAgent Assignments**: [task delegation with timeline]
- **Execution Order**: [parallel/sequential coordination]

## Quality Prevention Strategy
- **Code Quality Risks**: [preventive measures from code-quality-reviewer]
- **Security Considerations**: [preventive measures from config-security-expert]
- **Edge Case Mitigation**: [preventive measures from edge-case-detector]
- **Integrated Checkpoints**: [quality gates during implementation]

## Implementation Tasks
[Prioritized checklist with progress tracking and quality gates]

## Risk Mitigation
- **Technical Risks**: [identified technical issues]
- **Quality Risks**: [prevention strategy per reviewer domain]
- **Rollback Strategy**: [git checkpoints and recovery plan]
```

## Phase 3: Intelligent Adaptation

I'll transform the source to fit your project perfectly:

**Dependency Resolution:**
- Map source libraries to your existing ones
- Reuse your utilities instead of adding duplicates
- Convert patterns to match your codebase
- Update deprecated approaches to modern standards

**Code Transformation:**
- Match your naming conventions
- Follow your error handling patterns
- Maintain your state management approach
- Preserve your testing style

**Repository Analysis Strategy:**
For large repositories, I'll use smart sampling:
- Core functionality first (main features, critical paths)
- Supporting code as needed
- Skip generated files, test data, documentation
- Focus on actual implementation code

## Phase 4: Implementation Execution

I'll implement features incrementally:

**Execution Process:**
1. Implement core functionality
2. Add supporting utilities
3. Integrate with existing code
4. Update tests to cover new features
5. Validate everything works correctly

**Progress Tracking:**
- Update `.claude/implementations/plan.md` as I complete each item
- Mark checkpoints in `.claude/implementations/state.json`
- Create meaningful git commits at logical points

## Phase 5: Implementation Quality Validation

**Pre-Certification Validation:**
- Run existing lint commands and execute test suite
- Check for type errors and verify integration points
- Confirm no regressions in existing functionality



## Practical Examples

**Single Source:**
```
/implement https://github.com/user/feature
/implement ./legacy-code/auth-system/
/implement "payment processing like Stripe"
```

**Multiple Sources:**
```
/implement https://github.com/projectA ./local-examples/
```

**Resume Session:**
```
/implement              # Auto-detects and resumes
/implement resume       # Explicit resume
/implement status       # Check progress
```

## Execution Guarantee

**My workflow ALWAYS follows this logical order:**

1. **Strategic planning** - Professional orchestration with quality prevention FIRST
2. **Plan documentation** - Write comprehensive strategic plan to `.claude/implementations/plan.md`
3. **Setup session** - Create/load state files and infrastructure  
4. **Show plan** - Present strategic summary before implementing
5. **Execute systematically** - Follow orchestrated plan with agent coordination
6. **QA certification** - Final validation through specialist reviewers

**I will NEVER:**
- Start implementing without a written plan
- Skip source or project analysis
- Bypass session file creation
- Begin coding before showing the plan
- Use emojis in commits, PRs, or git-related content

## Phase 6: QA Certification

Final quality certification through specialist reviewer delegation:

**QA Certification Process:**
1. **Delegate to code-quality-reviewer**: Architectural review, maintainability assessment, technical debt analysis
2. **Delegate to config-security-expert**: Security audit, configuration safety, production readiness
3. **Delegate to edge-case-detector**: Boundary condition testing, integration failure scenarios, resilience validation
4. **Consolidate findings**: Unified quality certification report with severity classification

**Quality Certification Report:**
```
QA CERTIFICATION RESULTS
├── Code Quality: [PASS/ISSUES] - Architectural soundness and maintainability
├── Security Audit: [PASS/ISSUES] - Vulnerability assessment and config safety  
├── Edge Case Coverage: [PASS/ISSUES] - Boundary conditions and failure scenarios
├── Integration Validation: [PASS/ISSUES] - System integration and compatibility
└── Production Readiness: [CERTIFIED/CONDITIONAL/BLOCKED]

CRITICAL FINDINGS:
[Issues that must be resolved before deployment]

HIGH PRIORITY:
[Issues that should be addressed]

SUGGESTIONS:
[Improvement opportunities for consideration]
```

**Certification Actions:**
- Address all CRITICAL findings before deployment
- Document HIGH PRIORITY items for next iteration  
- Implement suggestions based on team priorities
- Generate final certification status and production readiness assessment

I'll maintain perfect continuity across sessions, always picking up exactly where we left off with full context preservation.