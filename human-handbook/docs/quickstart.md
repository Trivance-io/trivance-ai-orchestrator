# 🚀 Claude Code Ecosystem: Installation & First Session

**Complete setup guide** from zero to productive AI-first development in 30 minutes.

---

## 📋 Step 1: Validate Your System (5 min)

Clone the repository and run the initialization validator:

```bash
git clone https://github.com/Trivance-io/trivance-ai-orchestrator.git
cd trivance-ai-orchestrator
./scripts/init.sh
```

The script validates **all dependencies** and categorizes them:

### **CRITICAL** (Blockers - Must Install)

| Dependency          | Installation                                        | Official Docs                                                                        |
| ------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------ |
| **Claude Code CLI** | Platform-specific installer                         | [📖 Installation Guide](https://docs.anthropic.com/en/docs/claude-code/installation) |
| **Git**             | `brew install git` / `sudo apt install git`         | [📖 Downloads](https://git-scm.com/downloads)                                        |
| **Python 3.8+**     | `brew install python3` / `sudo apt install python3` | [📖 Downloads](https://www.python.org/downloads/)                                    |

### **ESSENTIAL** (Full Functionality - Strongly Recommended)

| Dependency            | Installation                                    | Official Docs                                                                     |
| --------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------- |
| **GitHub CLI**        | `brew install gh` / `sudo apt install gh`       | [📖 Installation](https://cli.github.com/)                                        |
| **Node.js 18+**       | `brew install node` / `sudo apt install nodejs` | [📖 Downloads](https://nodejs.org/)                                               |
| **terminal-notifier** | `brew install terminal-notifier` (macOS only)   | [📖 GitHub](https://github.com/julienXX/terminal-notifier#install)                |
| **notify-send**       | `sudo apt install libnotify-bin` (Linux only)   | [📖 Arch Wiki](https://wiki.archlinux.org/title/Desktop_notifications)            |
| **Black**             | `pip install black` or `pipx install black`     | [📖 Getting Started](https://black.readthedocs.io/en/stable/getting_started.html) |

### **RECOMMENDED** (Enhanced Experience)

| Dependency | Installation                                                        | Official Docs                                        |
| ---------- | ------------------------------------------------------------------- | ---------------------------------------------------- |
| **shfmt**  | `brew install shfmt` / `go install mvdan.cc/sh/v3/cmd/shfmt@latest` | [📖 GitHub](https://github.com/mvdan/sh#shfmt)       |
| **jq**     | `brew install jq` / `sudo apt install jq`                           | [📖 Download](https://jqlang.github.io/jq/download/) |

### **OPTIONAL** (Specific Use Cases)

**Playwright MCP** - Web testing & automation

- Already configured in `.mcp.json`
- Uses `npx @playwright/mcp@latest` (no install needed)
- [📖 Playwright MCP Docs](https://github.com/microsoft/playwright-mcp)

**Shadcn MCP** - UI component development

- Already configured in `.mcp.json`
- Uses `npx @jpisnice/shadcn-ui-mcp-server` (no install needed)
- [📖 Shadcn/ui Official](https://ui.shadcn.com)

---

## ⚡ Step 2: System Configuration (10 min)

### **2.1 GitHub CLI Authentication**

```bash
gh auth login
gh auth status  # Verify authentication
```

**Why required:** Enables git/github slash commands (`/pr`, `/commit`, `/issue-sync`)

### **2.2 Enable System Notifications**

#### macOS

```bash
# Install notifier
brew install terminal-notifier

# Enable in System Settings
# → Notifications → Terminal → Enable
```

#### Windows

```powershell
winget install Microsoft.PowerToys
```

#### Linux

```bash
sudo apt install libnotify-bin notify-send  # Ubuntu/Debian
sudo dnf install libnotify notify-send      # Fedora
```

**Why required:** Get notified when Claude finishes tasks or needs input.

### **2.3 Verify Installation**

Re-run the validator to confirm all dependencies:

```bash
./scripts/init.sh
```

Expected output:

```
✓ All critical and essential dependencies are installed!
✓ All recommended dependencies installed!

Your Claude Code ecosystem is ready to use! 🚀
```

---

## 📦 Step 3: Deploy to Your Project (5 min)

### **Option A: General Project**

Copy `.claude/` to your project:

```bash
cp -r .claude/ /path/to/your/project/
cd /path/to/your/project
claude  # Start Claude Code
```

### **Option B: Trivance Community (Multi-Repo)**

Run the Trivance-specific setup:

```bash
./scripts/core/setup.sh
```

This creates a multi-repo workspace with shared `.claude/` configuration.

---

## 🎯 Step 4: Your First AI-First Session (15 min)

**Experience the complete workflow** from zero to production-ready PR.

### **4.1 Context Mapping (3 min) - CRITICAL**

```bash
claude
> /understand
```

**What it does:**

- Maps entire project architecture
- Identifies patterns, dependencies, and entry points
- Prevents hours of refactoring by understanding context first

**Output:** Complete project analysis with component map and integration points.

### **4.2 Implementation Engine (5 min)**

```bash
> /implement "add input validation to user registration form"
```

**What it does:**

- Automated planning → coding → testing → documentation
- TDD enforcement (tests first, then implementation)
- Constitutional compliance (complexity budget, ROI validation)

**Output:** Complete feature with tests passing and documentation.

### **4.3 Quality Assurance (3 min) - CRITICAL**

```bash
> /review
```

**What it does:**

- Multi-specialist analysis (security, performance, code quality)
- Architectural integrity validation
- Edge case detection

**Output:** Comprehensive review with actionable improvements.

### **4.4 Integration (2 min)**

```bash
> /commit "feat: add registration form validation with tests"
> /pr
```

**What it does:**

- Smart commit with conventional commit format
- Auto-generated PR with complete metadata
- Links to issues, generates test plan

**Output:** Production-ready PR with GitHub Actions integration.

### **4.5 Verify End-to-End (2 min)**

Check your PR on GitHub:

- ✅ CI/CD running (Claude Code Review, security scan)
- ✅ Complete description with test plan
- ✅ All checks passing

---

## 💡 What You've Learned

| Capability            | Value                                         |
| --------------------- | --------------------------------------------- |
| **Context-awareness** | `/understand` prevents costly refactoring     |
| **Automation power**  | `/implement` replaces manual development      |
| **Quality by design** | `/review` prevents expensive post-merge fixes |
| **Zero friction**     | Idea → PR in 15 minutes, not hours            |

---

## 🚨 Common Issues & Solutions

### **"Claude no responde"**

```bash
claude --reset-config
```

### **"GitHub CLI falla"**

```bash
gh auth logout && gh auth login
```

### **"Sin notificaciones"**

- macOS: Check System Settings → Notifications → Terminal
- Linux: Run `notify-send "Test" "Works"` to verify
- Windows: Check PowerToys notification settings

### **"MCPs no funcionan"**

1. Verify `.mcp.json` exists in project root
2. Restart Claude Code completely
3. Check Node.js is installed: `node -v`

### **"Script init.sh falla"**

- Make sure it's executable: `chmod +x scripts/init.sh`
- Run with verbose output: `bash -x scripts/init.sh`
- Ask Claude for help: `claude "Help me debug init.sh"`

---

## 📚 Next Steps: Deep Dive

### **🔥 Essential Reading (Priority Order)**

1. **[ai-first-workflow.md](ai-first-workflow.md)** - Complete workflow from PR to merge
   - Focus on: [Comandos de Alto Valor](ai-first-workflow.md#-comandos-de-alto-valor)
   - 10x productivity multipliers

2. **[commands-guide.md](commands-guide.md)** - 30+ commands organized by impact
   - High-impact commands you'll use daily
   - Complete reference for all slash commands

3. **[agents-guide.md](agents-guide.md)** - 40+ specialized AI agents
   - When to use each agent type
   - Orchestration strategies

4. **[ai-first-best-practices.md](ai-first-best-practices.md)** - Advanced mastery
   - Mental model evolution
   - Expert orchestration techniques

### **🎯 Recommended Learning Path**

```
Week 1: Master high-impact commands
├── /understand (context mapping)
├── /implement (feature development)
└── /review (quality assurance)

Week 2: Integrate workflow commands
├── /commit (smart commits)
├── /pr (automated PRs)
└── /issue-sync (GitHub integration)

Week 3: Explore specialist agents
├── Use agents proactively in /implement
├── Experiment with specialized workflows
└── Develop orchestration strategies

Week 4+: Master advanced patterns
├── Multi-agent coordination
├── Custom workflow optimization
└── Constitutional governance
```

---

## 🎓 Support & Community

**Need help?**

```bash
claude "Help me with [specific issue]"
```

Claude Code can assist with:

- Debugging installation issues
- Configuring specific dependencies
- Understanding workflow patterns
- Troubleshooting errors

**Trivance Community members:** Commercial support available via dedicated channels.

---

**🎉 Congratulations!** You're now part of the AI-First development revolution.
