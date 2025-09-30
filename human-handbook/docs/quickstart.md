# 🚀 Quickstart: 15 Minutes to Productive

## Step 1: Validate System (2 min)

```bash
git clone https://github.com/Trivance-io/trivance-ai-orchestrator.git
cd trivance-ai-orchestrator
./scripts/init.sh
```

**What it checks:** Claude Code CLI, Git, Python, GitHub CLI, Node.js, formatters, notifications.

**If something fails:** Follow the links provided. The script tells you exactly what's missing and where to get it.

**Full dependency list:** [README.md](../../README.md#-prerequisites)

---

## Step 2: Configure (5 min)

### GitHub CLI

```bash
gh auth login
```

### MCP Servers

```bash
cp .mcp.json.example .mcp.json
```

Enables Playwright (testing) and Shadcn (UI components).

### Verify

```bash
./scripts/init.sh  # Should show all ✓
```

---

## Step 3: Deploy (3 min)

**For any project:**

```bash
cp -r .claude/ /path/to/your/project/
cd /path/to/your/project
claude
```

**For Trivance multi-repo:**

```bash
./scripts/core/setup.sh
```

---

## Step 4: First Session (5 min)

### Map Context

```
/understand
```

**Why:** Prevents hours of refactoring. Claude learns your entire codebase first.

### Implement Feature

```
/implement "add input validation to registration form"
```

**What happens:** Planning → TDD tests → Implementation → Documentation. Done.

### Quality Check

```
/review
```

**What happens:** Security + Performance + Code Quality analysis with actionable fixes.

### Create PR

```
/commit "feat: add registration validation"
/pr
```

**Result:** Production-ready PR with description, test plan, and CI/CD integration.

---

## Common Issues

| Problem              | Solution                                    |
| -------------------- | ------------------------------------------- |
| "Claude no responde" | `claude --reset-config`                     |
| "GitHub CLI falla"   | `gh auth logout && gh auth login`           |
| "MCPs no funcionan"  | Verify `.mcp.json` exists, restart Claude   |
| "Init script falla"  | `chmod +x scripts/init.sh`, run with `bash` |
| "Sin notificaciones" | Check system notification permissions       |

---

## Next Steps

1. **[ai-first-workflow.md](ai-first-workflow.md)** - Complete workflow patterns
2. **[commands-guide.md](commands-guide.md)** - All 30+ commands
3. **[agents-guide.md](agents-guide.md)** - 40+ specialist agents

---

## Learning Path

```
Week 1: Commands → /understand, /implement, /review
Week 2: Workflow → /commit, /pr, /issue-sync
Week 3: Agents → Explore specialists
Week 4+: Mastery → Multi-agent coordination
```

---

**Need help?** `claude "Help me with [issue]"` - Claude assists with setup, debugging, and workflow patterns.
