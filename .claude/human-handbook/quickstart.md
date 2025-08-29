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

### 4. 🔧 GitHub Workflows

**⚠️ CRÍTICO**: Copiar estos archivos a tu proyecto para activar el ecosistema AI-first completo:

```bash
# Crear directorio workflows
mkdir -p .github/workflows

# Copiar configuraciones desde este repo
cp .github/workflows/claude-code-review.yml tu-proyecto/.github/workflows/
cp .github/workflows/claude.yml tu-proyecto/.github/workflows/
cp .github/workflows/security.yml tu-proyecto/.github/workflows/
```

**Configurar secret**: `CLAUDE_CODE_OAUTH_TOKEN` en GitHub repo settings.

**Resultado**: 
- 🤖 Review automático en PRs (Opus 4.1)
- 💬 Interacción `@claude` en issues/comments
- 🔒 Security scanning automático

### 5. ✅ Verificación

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

## 📚 Docs-reference

#### 🔥 [`ai-first-workflow.md`](ai-first-workflow.md)
Flujo completo: PR → Review → Issues → Resolución → Merge

#### ⚡ [`commands-guide.md`](commands-guide.md)  
30+ comandos: `/implement`, `/pr`, `/security-scan`, etc.


