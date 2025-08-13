# 🚀 Ecosistema AI-First: Guía de Instalación

## 📋 Requisitos

- Claude Code CLI instalado
- Python 3.8+ 
- Git configurado
- Acceso a GitHub

## ⚡ Instalación

### 1. 🤖 Modelo
El proyecto usa `"model": "opusplan"` (Opus 4.1 para planificación, Sonnet 4 para ejecución)

### 2. 🔗 MCP GitHub
```bash
gh auth login
gh auth status
```
Habilita herramientas GitHub nativas (`mcp__github__*`)

### 3. 🔔 Notificaciones

#### macOS
```bash
brew install terminal-notifier
```
**Sistema** → **Notificaciones** → **Terminal** → Habilitar

#### Windows
```powershell
winget install Microsoft.PowerToys
```

#### Linux
```bash
sudo apt install notify-send libnotify-bin  # Ubuntu/Debian
sudo dnf install notify-send libnotify      # Fedora
```

### 4. ✅ Verificación

```bash
claude --version
gh repo view
terminal-notifier -title "Test" -message "Funcionando"  # macOS
notify-send "Test" "Funcionando"                        # Linux

# Test completo en directorio del proyecto
claude "dame un resumen del proyecto"
claude "lista los últimos 3 PRs"
echo "test" > test.txt && claude "/commit"
```

**Esperado**: Claude responde con información del proyecto, PRs, y notificación de commit

## 🚨 Problemas Comunes

**Claude no responde**: `claude --reset-config`
**MCP GitHub falla**: `gh auth logout && gh auth login`
**Sin notificaciones**: Verificar permisos del sistema

## 📚 Siguiente: Workflows

#### 🔥 [`ai-first-workflow.md`](.claude/human-handbook/ai-first-workflow.md)
Flujo completo: PR → Review → Issues → Resolución → Merge

#### ⚡ [`commands-guide.md`](.claude/human-handbook/commands-guide.md)  
30+ comandos: `/implement`, `/pr`, `/security-scan`, etc.


