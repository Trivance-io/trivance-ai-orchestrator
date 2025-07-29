# Claude Code Hooks - Sistema de Supervisión

## Funcionamiento

Claude Code ejecuta hooks automáticamente según eventos específicos definidos en `settings.json`. Cada hook es un script Python independiente que recibe JSON por stdin y responde con JSON por stdout.

## Arquitectura

```
Claude Code → settings.json → Ejecuta hooks según eventos
              ↓
              hook.py recibe JSON → procesa → responde JSON
              ↓
              Claude Code usa respuesta para permitir/denegar/modificar acción
```

## Scripts del Sistema

### `prompt_router.py` - Context Injection
**Evento:** UserPromptSubmit  
**Función:** Detecta prompts estratégicos e inyecta contexto empresarial

```python
# Detecta palabras clave estratégicas
STRATEGIC = r"(?i)\b(deep|plan|architect|strategy|enterprise)\b"

# Si detecta, inyecta contexto empresarial adicional
# Si no, permite prompt normal
```

### `pretool_guard.py` - Security Guard  
**Evento:** PreToolUse  
**Función:** Bloquea operaciones de archivos y comandos peligrosos

```python
# Archivos críticos bloqueados
CRITICAL_SECRETS = (r"\.env$", r"id_rsa$", r"\.key$", r"\.pem$")

# Comandos peligrosos bloqueados  
CRITICAL_BASH = [r"\brm\s+-rf\s+/", r"\bgit\s+push\s+--force"]
```

### `architecture_enforcer.py` - Code Quality
**Evento:** PostToolUse  
**Función:** Detecta credenciales hardcodeadas y patrones peligrosos

```python
# Patrones críticos detectados
CRITICAL_ANTIPATTERNS = [
    {"pattern": r"(password|secret|token|key)\s*=\s*['\"][^'\"]*['\"]", "severity": "blocking"},
    {"pattern": r"eval\s*\(", "severity": "blocking"}
]
```

### `on_stop.py` - Audit Logging
**Evento:** Stop, SubagentStop  
**Función:** Registra eventos de auditoría al finalizar conversaciones

### `common.py` - Shared Utilities
**Función:** Biblioteca compartida con funciones comunes:
- `log_event()` - Crea logs JSONL estructurados
- `read_stdin_json()` - Lee input JSON de Claude Code  
- `sanitize_for_log()` - Protege datos sensibles en logs

## Instalación

```bash
# 1. Copiar carpeta .claude al workspace
cp -r trivance-dev-config/.claude /tu-workspace/

# 2. Hacer scripts ejecutables
chmod +x .claude/hooks/*.py

# 3. Claude Code automáticamente lee settings.json y ejecuta hooks
```

## Configuración

### settings.json
```json
{
  "hooks": {
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "python3 prompt_router.py"}]}],
    "PreToolUse": [{"matcher": "Write|Edit|MultiEdit|Bash", "hooks": [{"type": "command", "command": "python3 pretool_guard.py"}]}],
    "PostToolUse": [{"matcher": "Write|Edit|MultiEdit", "hooks": [{"type": "command", "command": "python3 architecture_enforcer.py"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "python3 on_stop.py main"}]}],
    "SubagentStop": [{"hooks": [{"type": "command", "command": "python3 on_stop.py subagent"}]}]
  }
}
```

## Logs y Debugging

Los logs se crean automáticamente en `.claude/logs/YYYY-MM-DD/`:
- `user_prompt.jsonl` - Eventos de prompt routing
- `security_guard.jsonl` - Decisiones de seguridad  
- `architecture_analysis.jsonl` - Análisis de código
- `stop.jsonl` - Eventos de finalización

```bash
# Ver logs recientes
tail -f .claude/logs/$(date +%Y-%m-%d)/*.jsonl

# Debug hook específico
echo '{"test": "data"}' | python3 .claude/hooks/prompt_router.py
```

## Troubleshooting

**Hook no se ejecuta:**
```bash
# Verificar permisos
ls -la .claude/hooks/*.py
chmod +x .claude/hooks/*.py
```

**Error en hook:**
```bash
# Ejecutar manualmente para ver error
echo '{"hook_event_name": "test"}' | python3 .claude/hooks/HOOK_NAME.py
```

**Logs no se crean:**
```bash
# Verificar que existe directorio de logs
ls -la .claude/logs/
mkdir -p .claude/logs/$(date +%Y-%m-%d)
```

## Testing

```bash
# Ejecutar suite de tests completa
cd .claude/hooks
python3 test_hooks_e2e.py
```

## Customización

### Agregar dominios confiables (pretool_guard.py)
```python
TRUSTED_DOMAINS = (
    r"^https://docs\.anthropic\.com/",
    r"^https://tu-dominio\.com/",  # Agregar aquí
)
```

### Agregar patrones de seguridad (architecture_enforcer.py)  
```python
CRITICAL_ANTIPATTERNS.append({
    "pattern": r"tu_patron_peligroso",
    "message": "Tu mensaje de error",
    "severity": "blocking"
})
```