# 🔔 Claude Code Hooks: Instalación Rápida

## ¿Qué Hace?

Notificaciones automáticas cuando Claude Code:

- Inicia/completa tareas largas
- Necesita tu atención/aprobación
- Modifica archivos importantes

## Instalación por OS

### **macOS**

```bash
brew install terminal-notifier
```

- Ir a **Sistema** → **Notificaciones** → **Terminal** → Habilitar

### **Windows**

❌ **No soportado** - terminal-notifier es solo macOS

- Alternativa: Usar `toast` (requiere instalación adicional)

### **Linux**

```bash
sudo apt install notify-send  # Ubuntu/Debian
```

## Activación

Los hooks ya están en `.claude/settings.json` - solo reinicia Claude Code.

## Verificar Funcionamiento

```bash
terminal-notifier -title "Test" -message "¿Funciona?"
```

## Solución de Problemas

- **No notifica**: Permisos de notificación deshabilitados
- **Error file not found**: Reiniciar Claude Code
- **Hook no ejecuta**: Verificar `python3 --version`

---

**Estado**: ✅ Activo en este proyecto
