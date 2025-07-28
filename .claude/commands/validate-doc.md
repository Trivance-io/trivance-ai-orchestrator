---
description: "Intelligent consistency validation with automated documentation updates"
argument-hint: "validation scope: security|architecture|ecosystem|all"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Edit", "MultiEdit", "TodoWrite", "Task"]
execution-mode: "intelligent-validation"
auto-context: true
---

# 🔍 Intelligent Validation & Documentation Engine

## 🎯 AI-Optimized Validation Flow

**Enterprise-grade consistency validation with proactive documentation**

## 🤖 Smart Context Detection

**Analyzing ecosystem automatically...**
- Detecting Trivance Platform components and configurations
- Identifying validation scope from arguments and context
- Assessing documentation currency and consistency needs
- Determining optimal validation and update strategy

## 🛡️ Multi-Layer Validation Engine

### **Security & Compliance Validation**
```bash
# Advanced credential detection
grep -r -i -E "(password|token|secret|key|api_key|private_key|oauth|jwt_secret).*=" . \
    --include="*.js" --include="*.ts" --include="*.py" --include="*.yml" --include="*.yaml" \
    --exclude-dir=.git --exclude-dir=node_modules

# Environment file exposure check
git ls-files | grep -E "\.(env|secret|key)$" | grep -v "\.example$"

# Sensitive data in logs
grep -r "console.log.*\(password\|token\|secret\)" . --include="*.js" --include="*.ts"

# Hardcoded endpoints and credentials
grep -r -E "mongodb://.*:.*@|postgresql://.*:.*@" . --exclude-dir=node_modules
```

### **Architecture & Standards Validation**
```bash
# Trivance ecosystem consistency
# - Environment file structure validation
# - Service integration patterns
# - Docker configuration consistency
# - API endpoint standardization

# Code quality patterns (Claude Code standards)
# - Import/export consistency
# - Error handling patterns
# - Naming conventions
# - TypeScript compliance where applicable
```

### **Documentation Integrity Validation**
```bash
# Cross-reference validation
# - @import paths in CLAUDE.md files
# - Internal link functionality
# - Port and URL consistency
# - Configuration examples accuracy

# Documentation currency
# - Recent changes vs documentation updates
# - Feature completeness in docs
# - Troubleshooting guide coverage
```

## 📊 Intelligent Risk Assessment

### **Automated Severity Classification**
- **🔴 CRITICAL**: Security exposures, credential leaks, system vulnerabilities
- **🟡 HIGH**: Architecture violations, inconsistent patterns, broken references  
- **🟢 MEDIUM**: Documentation gaps, style inconsistencies, optimization opportunities

### **Smart Decision Engine**
- Critical issues → Immediate halt with detailed remediation guidance
- High issues → Risk assessment with business impact analysis
- Medium issues → Informational with optimization recommendations

## 📝 Proactive Documentation Updates

### **Context-Aware Documentation Generation**
```bash
# Automatic detection of documentation needs:
# - New scripts in ./scripts/ → Update COMMANDS.md
# - Configuration changes → Update ENVIRONMENTS.md  
# - Docker modifications → Update DOCKER.md
# - Architecture changes → Update ARCHITECTURE.md

# Cross-ecosystem validation:
# - Service URLs and ports consistency
# - Environment configuration accuracy
# - Integration point documentation
# - Troubleshooting guide completeness
```

### **Intelligent Content Updates**
- Real-time validation of code examples in documentation
- Automatic URL and port verification
- Configuration template synchronization
- Cross-reference link validation

## 🎯 Execution Intelligence Summary

```
🔍 VALIDATION ANALYSIS:
├─ Security Scan: [PASSED/CRITICAL ISSUES FOUND]
├─ Architecture Compliance: [SCORE/10 vs Trivance standards]
├─ Documentation Currency: [CURRENT/OUTDATED/MISSING]
└─ Integration Consistency: [VALIDATED/ISSUES DETECTED]

📊 RISK ASSESSMENT:
├─ Critical Issues: [X found - BLOCKING]
├─ High Priority: [Y found - REVIEW REQUIRED]  
├─ Medium Priority: [Z found - OPTIMIZATION]
└─ Business Impact: [QUANTIFIED RISK LEVEL]

📝 DOCUMENTATION STATUS:
├─ Files Analyzed: [X files]
├─ Updates Required: [Y files need updates]
├─ New Content: [Z sections added]
└─ Cross-References: [VALIDATED/FIXED]
```

## ⚡ Automated Resolution Engine

**For Critical Issues:**
```
🚨 CRITICAL SECURITY EXPOSURE DETECTED
├─ Location: [file:line]
├─ Issue: [specific vulnerability]
├─ Business Risk: [impact assessment]
├─ Remediation: [specific steps]
└─ Verification: [validation method]

❌ PROCESS HALTED - Resolve critical issues before proceeding
```

**For Successful Validation:**
```
✅ VALIDATION COMPLETED
├─ Security: PASSED
├─ Architecture: [SCORE/10]
├─ Documentation: UPDATED
└─ Consistency: VERIFIED

📝 DOCUMENTATION UPDATES APPLIED:
├─ [File] → [Changes made]
├─ [File] → [Content synchronized]
└─ [File] → [Cross-references validated]

🎯 ECOSYSTEM HEALTH: [EXCELLENT/GOOD/NEEDS ATTENTION]
```

## 🎯 Enterprise Standards Applied

- **Security-first validation**: Comprehensive security scanning with business impact assessment
- **Trivance ecosystem awareness**: Context-specific validation for platform components
- **Proactive documentation**: Intelligent updates based on code and configuration changes
- **Business risk quantification**: Clear impact assessment for decision-making
- **Automation-first**: Minimal manual intervention required

---

**🚀 Executing intelligent validation and documentation for:** $ARGUMENTS