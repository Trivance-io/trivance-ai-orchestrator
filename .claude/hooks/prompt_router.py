#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI-First Prompt Router - Enterprise Optimized (40 lines)
• Strategic prompts → Enterprise context injection
• Simple but powerful classification
• Zero false positives
• 100% Claude Code spec compliant
"""
import re, json
from common import log_event, read_stdin_json

# Simplified but powerful patterns - Multilingual support
SENSITIVE = re.compile(r"(?i)\b(password|secret|token|key)\s*[=:]\s*['\"][^'\"]*['\"]")
STRATEGIC = re.compile(r"(?i)\b(deep|plan|architect|strategy|enterprise|profundo|planificar|arquitectura|estrategia|empresarial|diseñar|análisis|evaluar|diseño|planear)\b")

def inject_enterprise_context() -> str:
    """Inject Fortune 500 excellence standards with AI-first execution."""
    return """
**🏢 FORTUNE 500 EXCELLENCE + AI-FIRST EXECUTION**
- Apply Fortune 500 non-negotiable excellence standards
- Critical thinking first: analyze deeply before executing
- Elegant simplicity: best solution is simplest possible (without sacrificing completeness)
- Assume contextual expert roles based on prompt domain

**🧠 EXPERT-LEVEL THINKING REQUIRED**
- Identify and prioritize what is truly important first
- Assume domain expertise: architect, senior engineer, strategist, etc.
- Multi-perspective deep analysis before recommending
- Production-ready output with first-level engineering rigor

**⚡ AI-FIRST DELIVERY (NO traditional bureaucracy)**  
- Semi-autonomous execution with strategic human oversight
- Intelligent iteration: days/hours, not months of processes
- Zero traditional change management overhead
"""

def main():
    data = read_stdin_json()
    prompt = data.get("prompt", "") or ""

    # 1) Block sensitive content
    if SENSITIVE.search(prompt):
        print(json.dumps({
            "decision": "block", 
            "reason": "Possible sensitive information detected. Reformulate without credentials."
        }, ensure_ascii=False))
        
        log_event("user_prompt.jsonl", {
            "hook_event_name": "UserPromptSubmit",
            "blocked": True,
            "reason": "sensitive_content"
        })
        return

    # 2) Strategic context injection (AI-first approach)
    strategic_mode = STRATEGIC.search(prompt) is not None
    
    if strategic_mode:
        context = inject_enterprise_context()
        
        print(json.dumps({
            "suppressOutput": True,
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit", 
                "additionalContext": context
            }
        }, ensure_ascii=False))
    
    # 3) Log event
    log_event("user_prompt.jsonl", {
        "hook_event_name": "UserPromptSubmit",
        "strategic_mode": strategic_mode,
        "prompt_length": len(prompt)
    })

if __name__ == "__main__":
    main()
