#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🛡️ SENIOR AI SECURITY GUARD
Enfoque: Consistencia arquitectónica + seguridad crítica únicamente.
Principio: Trust but verify - Block only proven dangerous patterns.

OBJETIVO: Actuar como Senior Developer supervisando a IA Junior.
- Prevenir exposición de credenciales
- Mantener consistencia arquitectónica  
- Permitir desarrollo ágil sin fricción innecesaria
"""
import os, re, sys, json
from common import log_event, read_stdin_json, _project_dir, sanitize_for_log

# 🔒 CRITICAL SECURITY ONLY - Minimal but Effective
CRITICAL_SECRETS = (
    r"\.env$",           # Environment files
    r"\.env\.",          # .env.local, .env.production, etc.
    r"id_rsa$",          # SSH private keys
    r"\.key$",           # Any key files
    r"\.pem$",           # Certificate files
    r"\.p12$",           # Certificate files
    r"config/.*secret",  # Secret configuration files
)

# 🌐 TRUSTED DOMAINS - Expandable
TRUSTED_DOMAINS = (
    r"^https://docs\.anthropic\.com/",
    r"^https://docs\.claude\.ai/",
    r"^https://pypi\.org/",
    r"^https://npmjs\.com/",
    r"^https://pkg\.go\.dev/",
    r"^https://nodejs\.org/",
    r"^https://developer\.mozilla\.org/",
    r"^https://stackoverflow\.com/",
    r"^https://github\.com/",
)

# ⚠️ HIGH-RISK COMMANDS ONLY - Proven dangerous in production
CRITICAL_BASH_PATTERNS = [
    r"\brm\s+-rf\s+/",           # rm -rf / (system destruction)
    r"\bgit\s+push\s+--force",   # Force push (data loss)
    r"\bdocker\s+rmi\s+--force", # Force remove images
    r"\bkill\s+-9\s+1\b",        # Kill init process
    r"\bchmod\s+777\s+/",        # Unsafe permissions on root
    r">\s*/dev/sda",             # Direct disk write
]

def output_permission(decision: str, reason: str, suppress: bool = True):
    """Output standard Claude Code permission response."""
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,  # allow | deny | ask
            "permissionDecisionReason": reason
        },
        "suppressOutput": suppress
    }, ensure_ascii=False))

def deny(reason: str, payload: dict):
    """Block operation with clear reasoning."""
    payload.update({"blocked": True, "reason": reason})
    log_event("security_guard.jsonl", payload)
    output_permission("deny", f"🛡️ SEGURIDAD: {reason}")
    sys.exit(0)

def allow(reason: str, payload: dict):
    """Allow operation with logging."""
    payload.update({"blocked": False, "reason": reason})
    log_event("security_guard.jsonl", payload)
    output_permission("allow", reason)
    sys.exit(0)

def is_development():
    """Detección agnóstica de entorno en 3 líneas."""
    import getpass, socket
    user = getpass.getuser()
    hostname = socket.gethostname()
    
    # Producción: usuarios de sistema O hostnames de producción
    return not (user in ['www-data', 'nginx', 'app', 'root', 'deploy'] or 
               any(x in hostname.lower() for x in ['.com', '.org', '.net', 'prod', 'server']))

def main():
    data = read_stdin_json()
    event = data.get("hook_event_name")
    tool = data.get("tool_name")
    tin = data.get("tool_input", {}) or {}
    cwd = data.get("cwd") or _project_dir()

    payload = {"hook_event_name": event, "tool_name": tool, "cwd": cwd}
    
    # Add sanitized command info for Bash commands
    if tool == "Bash" and "command" in tin:
        payload["command"] = sanitize_for_log(tin["command"])

    # 🔒 CRITICAL SECURITY CHECK: File Operations
    if tool in ("Write", "Edit", "MultiEdit"):
        path = tin.get("file_path") or ""
        
        # Check for critical secrets in filename
        for secret_pattern in CRITICAL_SECRETS:
            if re.search(secret_pattern, path):
                deny(f"Archivo de credenciales detectado: {os.path.basename(path)}", payload)

        # DEFAULT: ALLOW - Trust-based approach
        allow("Operación de archivo permitida", payload)

    # ⚠️ CRITICAL BASH COMMANDS CHECK
    if tool == "Bash":
        cmd = tin.get("command", "")
        
        # Only block PROVEN dangerous commands
        for pattern in CRITICAL_BASH_PATTERNS:
            if re.search(pattern, cmd):
                deny(f"Comando de alto riesgo bloqueado: {sanitize_for_log(cmd)}", payload)
        
        # DEFAULT: ALLOW - Most commands are safe
        allow("Comando bash permitido", payload)

    # 🌐 WEB FETCH VALIDATION
    if tool in ("WebFetch", "WebSearch"):
        url = tin.get("url", "")
        
        # En desarrollo: acceso libre, en producción: restrictivo
        if is_development():
            allow("Desarrollo: acceso web libre", payload)
        
        # En producción: solo dominios confiables
        if url and not any(re.match(pattern, url) for pattern in TRUSTED_DOMAINS):
            deny(f"Producción: dominio no autorizado: {url}", payload)
        
        allow("Producción: dominio autorizado", payload)

    # 🎯 DEFAULT POLICY: ALLOW
    # Trust by default, verify only critical operations
    allow("Operación estándar permitida", payload)

if __name__ == "__main__":
    main()
