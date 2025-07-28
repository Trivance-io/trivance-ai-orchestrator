---
description: "Intelligent Git workflow with automated pre-commit validations and smart commits"
argument-hint: "commit message or change description"
allowed-tools: ["Bash", "Read", "Grep", "Glob", "TodoWrite", "Task"]
execution-mode: "automated-git-flow"
auto-validation: true
---

# 🚀 Intelligent Git Workflow

## 🎯 Automated Execution Flow

**AI-optimized commit workflow with enterprise-grade validations**

## 🔍 Smart Context Analysis

**Analyzing repository state...**
- Detecting changed files and modification patterns
- Identifying project type and validation requirements  
- Assessing security risks and compliance needs
- Determining optimal commit strategy

## 🛡️ Integrated Validation Engine

### **Security Audit (Always Critical)**
```bash
# Advanced security detection
grep -r -i -E "(password|token|secret|key|api_key|private_key|oauth).*=.*['\"]" . \
    --exclude-dir=.git --exclude-dir=node_modules --exclude="*.md" --exclude="*.lock"

# Environment file detection
git diff --cached --name-only | grep -E "\.env$|\.env\.|\.secret"

# Hardcoded endpoint detection
grep -r -E "https?://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" . \
    --exclude-dir=.git --exclude-dir=node_modules

# Large file detection (>1MB)
find . -type f -size +1M | grep -v -E "(.git|node_modules|dist|build)"
```

### **Code Quality Validation (Conditional)**
```bash
# TypeScript/JavaScript projects
if [ -f "package.json" ]; then
    npm run lint 2>/dev/null || echo "⚠️ Lint validation failed"
    npm run type-check 2>/dev/null || echo "⚠️ Type validation failed"
fi

# Python projects  
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    flake8 . 2>/dev/null || echo "⚠️ Python lint failed"
fi

# Documentation-only changes skip code validation
```

## 🧠 Smart Commit Generation

### **Automated Type Detection**
- `feat:` → New functionality or files
- `fix:` → Bug fixes and corrections
- `refactor:` → Code restructuring without functional changes
- `docs:` → Documentation updates only
- `style:` → Formatting and code style
- `test:` → Test additions or modifications
- `chore:` → Configuration and maintenance
- `perf:` → Performance optimizations

### **Intelligent Scope Detection**
```bash
/api/ → (api)
/components/ → (ui)  
/auth/ → (auth)
/docs/ → (docs)
Multiple areas → (core)
```

### **Atomic Commit Strategy**
- Group logically related changes
- Single responsibility per commit
- Clear business value articulation

## 📊 Execution Summary

```
🔍 VALIDATION RESULTS:
├─ Security Scan: [PASSED/FAILED]
├─ Code Quality: [PASSED/FAILED/SKIPPED]
├─ File Analysis: [X modified, Y new]
└─ Large Files: [NONE/DETECTED]

📝 COMMIT STRATEGY:
├─ Type: [feat/fix/docs/etc]
├─ Scope: [detected area]
├─ Files: [grouped by functionality]
└─ Message: [generated from analysis + arguments]

🚀 EXECUTION:
├─ Branch: [current branch]
├─ Commits: [X created]
└─ Ready for push: [YES/NO]
```

## ⚡ Push Confirmation

**Automated security validation complete**
```
Security: ✅ PASSED
Quality: ✅ VALIDATED  
Commits: [X] CREATED
Target: origin/[branch]

Proceed with push? (requires explicit confirmation)
```

## 🎯 Enterprise Standards Applied

- **Security-first**: Comprehensive security scanning always executed
- **Quality gates**: Automated validation based on project type
- **Atomic commits**: Single responsibility principle enforced
- **Business clarity**: Commit messages explain value, not just changes
- **Risk mitigation**: No accidental pushes without explicit confirmation

---

**🚀 Executing intelligent Git workflow for:** $ARGUMENTS