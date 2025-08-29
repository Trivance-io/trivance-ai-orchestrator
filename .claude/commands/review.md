# Code Review

I'll review your code for potential issues.

Let me create a checkpoint before detailed analysis:
```bash
git add -A  
git commit -m "Pre-review checkpoint" || echo "No changes to commit"
```

I'll delegate comprehensive analysis to specialist reviewers for professional-grade assessment:

**Specialist Review Delegation:**
I'll delegate analysis to specialized reviewers from `.claude/agents/reviewers/` directory for comprehensive domain-specific assessment.

**Available Specialist Reviewers:**
From `.claude/agents/reviewers/` directory:
- **code-quality-reviewer**: Code architecture, maintainability, technical debt prevention
- **config-security-expert**: Security vulnerabilities, configuration risks, production safety
- **edge-case-detector**: Boundary conditions, integration failures, error handling gaps

**Comprehensive Analysis Process:**
- Each specialist conducts domain-specific analysis using their expertise
- Findings are automatically consolidated with severity classification
- Results stored in `.claude/reviews/review-[timestamp].md` for traceability
- Unified report presented with actionable priorities

**Review Results Storage:**
Findings are stored in `.claude/reviews/review-[timestamp].md` maintaining traceability without polluting project management.

**Available Actions:**
- Address findings directly in current development
- Ask the user if they want to create GitHub issues for items that require formal follow-up. If the review originates from a PR with GitHub issues created, disregard this instruction.
- Use findings to guide immediate improvements before PR submission

**Important**: I will NEVER:
- Add "Co-authored-by" or any Claude signatures to commits
- Add "Created by Claude" or any AI attribution to issues
- Include "Generated with Claude Code" in any output
- Modify git config or repository settings
- Add any AI/assistant signatures or watermarks
- Use emojis in commits, PRs, issues, or git-related content

**Review Report Format:**
```
COMPREHENSIVE CODE REVIEW RESULTS
├── Code Quality: [PASS/ISSUES] - Architectural soundness and maintainability
├── Security Audit: [PASS/ISSUES] - Vulnerability assessment and config safety  
├── Edge Case Coverage: [PASS/ISSUES] - Boundary conditions and failure scenarios
└── Overall Assessment: [EXCELLENT/GOOD/NEEDS_IMPROVEMENT/CRITICAL]

🚨 CRITICAL FINDINGS:
[Issues requiring immediate attention]

⚠️ HIGH PRIORITY:
[Issues that should be addressed soon]

💡 SUGGESTIONS:
[Improvement opportunities]
```

**Findings stored in**: `.claude/reviews/review-[timestamp].md`

This approach focuses on actionable findings that improve code quality while maintaining clean project management separation.