---
allowed-tools: Task
argument-hint: [PR_NUMBER] (optional - defaults to current branch PR)
description: Extract Claude Code review findings from PR comments and create GitHub issues automatically
---

Extract professional findings from Claude Code PR reviews and create GitHub issues efficiently.

**Process:**
1. Detectar PR → `gh pr list --head BRANCH --json number`
2. Extraer comentarios → `gh pr view PR_NUM --json comments`  
3. Parsear hallazgos → `grep -E "^### \*\*[0-9]+\."`
4. Crear issues → `gh issue create` por cada hallazgo
5. Logging → JSONL con timestamps correctos en formato ISO 8601

**Logging Format:**
```json
{"timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)", "command": "pr-findings", "pr_number": $PR_NUMBER, "findings_count": $FINDINGS_COUNT, "issues_created": $ISSUES_CREATED, "status": "completed"}
{"timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)", "issue": $ISSUE_NUMBER, "title": "[$PR_NUMBER] $FINDING_TITLE", "priority": "$PRIORITY", "type": "$TYPE", "url": "$ISSUE_URL"}
```

I'll use the general-purpose agent to handle this complex multi-step task efficiently, generating proper timestamps and logging with actual runtime values.