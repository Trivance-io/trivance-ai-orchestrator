# Smart Implementation Engine

I'll intelligently implement features from any source - adapting them perfectly to your project's architecture while maintaining your code patterns and standards.

Arguments: `$ARGUMENTS` - URLs, paths, or descriptions of what to implement

## Usage Examples

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
- **SCOPE BOUNDARY**: Focus on patterns relevant to requested feature only

**Orchestrated Strategic Process:**
1. Execute `/agent:tech-lead-orchestrator` with:
   - Source URLs/paths and extracted features
   - Project stack (detected via `Glob("**/*.{js,py,rb,go}")`)
   - Existing patterns (detected via `Grep`)
   - Current dependencies and architecture
   - **COMPLEXITY BUDGET**: [S≤80 LOC|M≤250 LOC|L≤600 LOC] based on scope
   - **SIMPLICITY MANDATE**: Implement ONLY requested features, avoid gold-plating
   - **YAGNI PRINCIPLE**: No speculative features, no "might need later" additions
2. Receive comprehensive strategy including:
   - Dream Team Assembly with specialist agent assignments
   - Quality Prevention Strategy from mandatory reviewer consultation
   - Execution timeline with parallel/sequential coordination
   - **IMPLEMENTATION CONSTRAINTS**: Simplest solution that meets requirements
3. Follow orchestrator-recommended implementation approach and specialist assignments

## Phase 2: Plan Documentation & Session Management

Based on strategic planning from Phase 1, I'll create implementation infrastructure:

**Session Management:**
1. Check for existing session in `./claude/implementations/` 
2. If found: Resume from `plan.md` and `state.json`, show progress summary
3. If new: Create session directory and initialize tracking files
4. Document orchestrator strategy in plan file

**Commands**: `/implement resume`, `/implement status` (check progress)

I'll write the strategic plan to `./claude/implementations/plan.md`:

```markdown
# Implementation Plan - [timestamp]

## Source Analysis
- **Source**: [URL/Local/Description]
- **Features**: [list to implement]
- **Dependencies**: [required]

## Strategic Plan
- **Team**: [assigned agents]
- **Tasks**: [prioritized checklist]
- **Risks**: [identified + mitigation]
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
- Update session plan file as I complete each item
- Mark checkpoints in session state file
- Create meaningful git commits at logical points

## Phase 5: Quality Validation

**Validation Steps:**
1. **Technical Validation (Stack-Aware):**
   - **JS/TS**: `npm run lint` || `yarn lint` || `tsc --noEmit`
   - **Python**: `flake8 .` || `pylint .` || `python -m py_compile **/*.py`
   - **Ruby**: `rubocop` || `ruby -c **/*.rb`
   - **Fallback**: Manual code inspection using `Read` tool
   - Run available test suites, skip if none configured

2. **Integration Validation:**
   - Test implemented features work as specified
   - Verify no regressions in existing functionality
   - Confirm integration points function correctly

3. **Quality Review (with Fallbacks):**
   - Try `/agent:code-quality-reviewer` → fallback to manual architectural review
     (Focus: Is solution appropriately simple for the problem scale?)
   - Try `/agent:config-security-expert` → fallback to security pattern analysis
     (Focus: Essential security only, avoid over-engineering auth)
   - Try `/agent:edge-case-detector` → fallback to boundary condition testing
     (Focus: Critical edge cases only, not exhaustive theoretical scenarios)

4. **Simplicity Validation:**
   - **Lines of Code**: Verify within complexity budget (S/M/L limits)
   - **YAGNI Check**: Confirm no unused features or speculative code
   - **Abstraction Audit**: Question each class/interface - is it necessary?
   - **File Count**: Challenge excessive file splitting or over-modularization

**Success Criteria:** New implementation validated successfully (existing issues documented separately)
**Simplicity Criteria:** 
- No unused abstractions or speculative features
- Implementation solves stated problem without gold-plating
- Complexity justified by actual requirements (not imagined ones)



## Execution Guarantee

**My workflow ALWAYS follows this logical order:**

1. **Strategic planning** - Professional orchestration with quality prevention FIRST
2. **Plan documentation** - Write comprehensive strategic plan to session directory
3. **Setup session** - Create/load state files and infrastructure  
4. **Show plan** - Present strategic summary before implementing
5. **Execute systematically** - Follow orchestrated plan with agent coordination
6. **Quality validation** - Final validation through specialist reviewers

**I will NEVER:**
- Start implementing without a written plan
- Skip source or project analysis
- Bypass session file creation
- Begin coding before showing the plan
- Use emojis in commits, PRs, or git-related content
- Add features not explicitly requested (gold-plating)
- Create abstractions "for future use" without current need
- Implement enterprise patterns for simple problems

I'll maintain perfect continuity across sessions, always picking up exactly where we left off with full context preservation.