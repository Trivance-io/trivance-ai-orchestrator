#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilidades comunes para hooks de Claude Code - Enterprise Optimized.

- Logging estructurado JSONL en .claude/logs/YYYY-MM-DD/*.jsonl
- Lectura robusta de stdin como JSON
- ContextCache inteligente con detección de modificaciones
- ResponseFactory para JSON responses consistentes
- Helpers varios optimizados

Claude Code expone CLAUDE_PROJECT_DIR al ejecutar hooks.
Doc: Hooks receive JSON via stdin; environment and paths are available. 
"""
import os, json, sys, datetime, hashlib, glob
from typing import Dict, Optional, List

def _project_dir() -> str:
    return os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()

def _logs_dir() -> str:
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    base = os.path.join(_project_dir(), ".claude", "logs", today)
    os.makedirs(base, exist_ok=True)
    return base

def log_event(filename: str, payload: dict):
    """Escribe una línea JSON en .claude/logs/YYYY-MM-DD/<filename>."""
    path = os.path.join(_logs_dir(), filename)
    payload = dict(payload or {})
    payload.setdefault("ts", datetime.datetime.now().isoformat())
    try:
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(payload, ensure_ascii=False) + "\n")
    except OSError as e:
        sys.stderr.write(f"[hooks][log_event] error escribiendo log: {e}\n")

def read_stdin_json():
    """Lee stdin y parsea JSON; si falla, devuelve diagnóstico."""
    raw = sys.stdin.read()
    try:
        return json.loads(raw) if raw else {}
    except json.JSONDecodeError as e:
        return {"_raw": raw, "_json_error": str(e)}

def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()

def short(text: str, n: int = 4000) -> str:
    return text if len(text) <= n else (text[:n] + f"... [truncated {len(text)-n} chars]")

def sanitize_for_log(cmd: str, max_len: int = 100) -> str:
    """Sanitiza comandos para logging seguro - previene exposición de datos sensibles."""
    # Primero truncar por longitud
    if len(cmd) > max_len:
        cmd = cmd[:max_len] + f"... [truncated {len(cmd)-max_len} chars]"
    
    # Enmascarar posibles secrets o tokens en comandos
    import re
    # Patrones para detectar y enmascarar información sensible
    patterns = [
        (r'(--?token[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?key[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?password[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?secret[=\s]+)([^\s]+)', r'\1***'),
        (r'(-p\s+)([^\s]+)', r'\1***'),  # -p password
        (r'(Bearer\s+)([^\s]+)', r'\1***'),  # Bearer tokens
    ]
    
    for pattern, replacement in patterns:
        cmd = re.sub(pattern, replacement, cmd, flags=re.IGNORECASE)
    
    return cmd
