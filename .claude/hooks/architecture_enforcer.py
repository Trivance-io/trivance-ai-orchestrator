#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI-First Architecture Advisor - Enterprise Optimized (60 lines)
• Universal anti-patterns only
• Trust Claude's architectural knowledge  
• Zero false positives
• Business impact focus
"""
import re, json, sys
from common import log_event, read_stdin_json

# Universal enterprise anti-patterns only
CRITICAL_ANTIPATTERNS = [
    {
        "pattern": r"(password|secret|token|key)\s*=\s*['\"][^'\"]*['\"]",
        "message": "🔒 CRÍTICO: Credencial hardcodeada detectada",
        "severity": "blocking"
    },
    {
        "pattern": r"eval\s*\(",
        "message": "⚠️ SEGURIDAD: eval() es peligroso",
        "severity": "blocking"  
    },
    {
        "pattern": r"dangerouslySetInnerHTML",
        "message": "🛡️ XSS RISK: Validar contenido HTML",
        "severity": "warning"
    }
]

def analyze_code_content(content: str) -> list:
    """Analyze code for universal enterprise anti-patterns only."""
    issues = []
    
    # Check only critical universal patterns
    for antipattern in CRITICAL_ANTIPATTERNS:
        if re.search(antipattern["pattern"], content, re.IGNORECASE):
            issues.append({
                "severity": antipattern["severity"],
                "message": antipattern["message"]
            })
    
    return issues

def main():
    data = read_stdin_json()
    tool = data.get("tool_name")
    tin = data.get("tool_input", {})
    
    # Only analyze code changes
    if tool not in ("Write", "Edit", "MultiEdit"):
        return
    
    file_path = tin.get("file_path", "")
    content = tin.get("new_string", "") or tin.get("content", "")
    
    # Only analyze code files
    if not any(file_path.endswith(ext) for ext in ['.ts', '.tsx', '.js', '.jsx', '.py']):
        return
    
    if not content:
        return
    
    # Analyze for critical patterns only
    issues = analyze_code_content(content)
    
    # Log analysis
    log_event("architecture_analysis.jsonl", {
        "hook_event_name": "PostToolUse", 
        "file_path": file_path,
        "issues_count": len(issues),
        "has_blocking": any(i["severity"] == "blocking" for i in issues)
    })
    
    # Block only critical issues with proper PostToolUse format
    blocking_issues = [i for i in issues if i["severity"] == "blocking"]
    if blocking_issues:
        reasons = [issue["message"] for issue in blocking_issues]
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": f"🚨 Issues críticos detectados:\n" + "\n".join(f"• {r}" for r in reasons)
            },
            "suppressOutput": True
        }, ensure_ascii=False))
        sys.exit(1)  # Exit with error code to signal blocking

if __name__ == "__main__":
    main()