#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Architecture Enforcer

Detects critical security vulnerabilities and blocks unsafe code patterns.
"""
import re, json, sys
from common import log_event, read_stdin_json, track_performance, get_cached_analysis, init_session_context, log_decision

FUNCTION_COMPLEXITY_THRESHOLD = 50

# Safe precompiled regex patterns - ReDoS resistant
FUNCTION_START_PATTERNS = [
    re.compile(r'^def\s+\w+\s*\('),
    re.compile(r'^function\s+\w+\s*\('),
    re.compile(r'^const\s+\w+\s*=\s*\(')
]

CRITICAL_ANTIPATTERNS = [
    # Security vulnerabilities
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
    
    # Injection attacks
    {
        "pattern": r'f["\'].*SELECT.*FROM.*\{.*\}.*["\']',
        "message": "🚨 SQL INJECTION: f-string en query SQL detectado",
        "severity": "blocking"
    },
    {
        "pattern": r'subprocess\.(run|call|Popen)\s*\([^)]*\{.*\}',
        "message": "🚨 COMMAND INJECTION: subprocess con input dinámico",
        "severity": "blocking"
    },
    
    # Code quality
    {
        "pattern": r"\bany\b",
        "message": "📝 TYPESCRIPT: Evitar tipo 'any', usar tipos específicos",
        "severity": "warning"
    },
    
    # XSS risks
    {
        "pattern": r"dangerouslySetInnerHTML",
        "message": "🛡️ XSS RISK: Validar contenido HTML",
        "severity": "warning"
    }
]

def analyze_code_content(content: str) -> list:
    """Analyze code for critical security anti-patterns."""
    issues = []
    for antipattern in CRITICAL_ANTIPATTERNS:
        if re.search(antipattern["pattern"], content, re.IGNORECASE):
            issues.append({
                "severity": antipattern["severity"],
                "message": antipattern["message"]
            })
    
    # Function complexity analysis
    if content.strip():
        lines = content.split('\n')
        in_function = False
        function_lines = 0
        function_name = ""
        
        def is_function_start(line_text):
            """Safe function detection using precompiled patterns."""
            return any(pattern.match(line_text) for pattern in FUNCTION_START_PATTERNS)
        
        for line in lines:
            line = line.strip()
            if is_function_start(line):
                if in_function and function_lines > FUNCTION_COMPLEXITY_THRESHOLD:
                    issues.append({
                        "severity": "warning",
                        "message": f"📏 COMPLEJIDAD: Función '{function_name}' tiene {function_lines} líneas (>{FUNCTION_COMPLEXITY_THRESHOLD})"
                    })
                in_function = True
                function_lines = 1
                # Safe name extraction
                parts = line.split('(')[0].split()
                function_name = parts[-1] if parts else "unknown"
                function_name = function_name[:20]  # Limit length
            elif in_function:
                if line and not line.startswith('#') and not line.startswith('//'):
                    function_lines += 1
                elif line == '' or is_function_start(line):
                    if function_lines > FUNCTION_COMPLEXITY_THRESHOLD:
                        issues.append({
                            "severity": "warning", 
                            "message": f"📏 COMPLEJIDAD: Función '{function_name}' tiene {function_lines} líneas (>{FUNCTION_COMPLEXITY_THRESHOLD})"
                        })
                    in_function = False
    
    return issues

def main():
    data = read_stdin_json()
    
    # Initialize session context for logging
    session_id = data.get("session_id") or data.get("correlation_id")
    init_session_context(session_id)
    
    tool = data.get("tool_name")
    tin = data.get("tool_input", {})
    
    if tool not in ("Write", "Edit", "MultiEdit"):
        return
    
    file_path = tin.get("file_path", "")
    content = tin.get("new_string", "") or tin.get("content", "")
    
    if not any(file_path.endswith(ext) for ext in ['.ts', '.tsx', '.js', '.jsx', '.py']):
        return
    
    if not content:
        return
    
    # Analyze for critical patterns with performance tracking and cache
    with track_performance("architecture_analysis", file_path=file_path, content_size=len(content)) as correlation_id:
        issues = get_cached_analysis(content, analyze_code_content)
    
    # Log analysis with enriched context
    log_event("architecture_analysis.jsonl", {
        "hook_event_name": "PostToolUse", 
        "file_path": file_path,
        "issues_count": len(issues),
        "has_blocking": any(i["severity"] == "blocking" for i in issues),
        "content_size": len(content),
        "analysis_correlation_id": correlation_id
    })
    
    blocking_issues = [i for i in issues if i["severity"] == "blocking"]
    if blocking_issues:
        reasons = [issue["message"] for issue in blocking_issues]
        log_decision(
            decision="block_code_change",
            reason=f"Security issues detected: {len(blocking_issues)} critical",
            confidence="high"
        )
        
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": f"🚨 Issues críticos detectados:\n" + "\n".join(f"• {r}" for r in reasons)
            },
            "suppressOutput": True
        }, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()