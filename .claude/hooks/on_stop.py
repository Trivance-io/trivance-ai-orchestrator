#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Stop / SubagentStop:
- Registra fin de conversación o sub-agente.
- Puede bloquear la detención si deseas continuar (decision:"block" + reason).
- stop_hook_active previene bucles de continuación infinitos.
"""
import sys, json
from common import log_event, read_stdin_json

def main():
    role = (sys.argv[1] if len(sys.argv) > 1 else "main").lower()  # "main" | "subagent"
    data = read_stdin_json()

    log_event("stop.jsonl", {
        "hook_event_name": data.get("hook_event_name"),
        "role": role,
        "stop_hook_active": data.get("stop_hook_active", False),
        "transcript_path": data.get("transcript_path")
    })

    # Claude Code oficial: omitir 'decision' si no bloqueamos, solo usar para 'block'
    print('{"suppressOutput": true}')

if __name__ == "__main__":
    main()
