---
allowed-tools: mcp__github__*, Bash(mkdir *), Bash(date *), Bash(echo *), Bash(gh *), Bash(git *), Task, Edit, MultiEdit, Write
description: AI-powered code review engine with specialist analysis
---

# Smart Code Review

I'll intelligently review your code using specialized agents.

## Usage
```bash
/review                    # Complete codebase review with all available reviewers
/review $ARGUMENTS         # Targeted review based on your specific context
```

## Execution

When executing this command with argument `$ARGUMENTS`, follow these steps:

### 1. Context Detection
- **If no arguments**: Set context = "complete workspace context"
- **If arguments provided**: Set context = arguments as specific analysis scope

### 2. Intelligent Review & Analysis  
- Show: "🔍 Iniciando review..."
- **Specialist delegation**:
  - If context contains "pr" + number: Focus analysis on PR diff only
  - Use `Glob` tool with pattern `.claude/agents/reviewers/*.md` to discover available reviewers
  - Extract agent names by removing `.md` extension from discovered files
  - Use `Task` tool to delegate to all discovered reviewer agents
  - Provide each specialist with determined context and scope
- **Intelligent consolidation**:
  - Capture raw findings from all discovered reviewers
  - Read project README, CLAUDE.md, and recent commits for context
  - Analyze each finding against project architecture and conventions
  - Filter findings that don't apply to this codebase (false positives)
  - Remove duplications and merge related findings
  - Classify by real business/technical impact
  - Generate specific action items with file locations and commands
  - Prioritize by actual impact on project goals and stability

### 3. Report Generation
- **Create directories**: `mkdir -p .claude/reviews .claude/logs/$(date +%Y-%m-%d)`
- **Generate timestamp**: `date '+%Y-%m-%dT%H:%M:%S'`
- **Determine filename**:
  - No arguments: `.claude/reviews/review-$(timestamp).md`
  - With arguments: `.claude/reviews/targeted-$(timestamp).md`
- **Write structured report** with executive summary, analysis, and action plan
- **Log activity**: Append entry to `.claude/logs/$(date +%Y-%m-%d)/review_activity.jsonl`

### 4. Executive Report
```
📊 **Review Analysis Complete**

## Summary
**Impact:** [High/Medium/Low] - **Action Required:** [Yes/No] - **Confidence:** [High/Medium/Low]

## Findings: <valid_count> valid, <filtered_count> filtered, <total_count> total

## Action Items
### 🚨 IMMEDIATE (1-2 items max)
- [ ] [Specific action with file:line] - [Why critical] - [How to fix]

### ⚠️ HIGH IMPACT (3-5 items max)  
- [ ] [Specific action with file:line] - [Business impact] - [Recommended approach]

### 💡 IMPROVEMENTS (2-3 strategic items)
- [ ] [Enhancement opportunity] - [ROI assessment] - [Implementation suggestion]

## Analysis Notes
**Project Context:** [Key patterns/conventions considered]
**Filtered Items:** [Major false positives eliminated with reasoning]

**Detailed Report:** <review_file>

**Next Steps:**
1. Address immediate items (est: X min)
2. Plan high impact items for next sprint
3. Consider strategic improvements
```

## Success Criteria

- **Context-Aware Analysis**: Validates findings against project patterns with false positive filtering
- **Actionable Output**: Executable action items with specific file locations and commands
- **Smart Scope Detection**: PR-specific analysis vs complete workspace based on context
- **Quality Focus**: Prioritizes valid, impactful findings over raw volume
- **Structured Storage**: Organized reports in .claude/reviews/ with executive summaries