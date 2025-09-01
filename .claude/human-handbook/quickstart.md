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

---

## 🎯 Tu Primera Sesión AI-First (15 minutos)

**Experimenta el workflow completo en tu primer uso:**

```bash
# 1. Setup Inicial (2 min)
/workflow:session-start
# Elegir: "Desarrollo" → te guía automáticamente a crear worktree

# 2. Context Mapping (3 min) - ESENCIAL  
/understand
# Mapea arquitectura completa del proyecto automáticamente

# 3. Implementation Engine (5 min) - TRANSFORMACIONAL
/implement "pequeña mejora o fix específico"
# Motor completo: planning → coding → testing → documentation

# 4. Quality Assurance (3 min) - CRÍTICO
/review
# Análisis multi-especialista automático (security, performance, code quality)

# 5. Integration (2 min)
/pr
# PR automático con metadata completa
```

**🏆 Resultado esperado:** PR funcional con implementación completa, tests pasando, y quality checks en 15 minutos.

**💡 Lo que aprendes:**
- **Context-awareness**: `/understand` previene horas de refactoring
- **Automation power**: `/implement` reemplaza desarrollo manual  
- **Quality by design**: `/review` previene fixes costosos post-merge
- **Zero friction**: De idea a PR en minutos, no horas

## 🚨 Problemas Comunes

**Claude no responde**: `claude --reset-config`
**MCP GitHub falla**: `gh auth logout && gh auth login`
**Sin notificaciones**: Verificar permisos del sistema

## 📚 Siguiente Paso: Domina el Workflow

### 🎯 **Primero**: [Tu Primera Sesión](#tu-primera-sesión-ai-first-15-minutos) 
**Completa el workflow de 15 minutos** para experimentar el poder de automatización.

### 📖 **Después**: Profundiza tu expertise

#### 🔥 [`ai-first-workflow.md`](ai-first-workflow.md) - **ESENCIAL**
**Workflow completo**: PR → Review → Issues → Resolución → Merge  
**Incluye**: [Comandos de Alto Valor](ai-first-workflow.md#comandos-de-alto-valor) - la clave de productividad 10x

#### ⚡ [`commands-guide.md`](commands-guide.md) - **REFERENCIA COMPLETA**  
**30+ comandos organizados por impacto**: `/understand`, `/implement`, `/review`, `/test` + todos los demás

#### 🧠 [`ai-first-best-practices.md`](ai-first-best-practices.md) - **MASTERY**
**Evolución mental**: De desarrollo manual a orquestación inteligente

### 🎯 Ruta de Aprendizaje Recomendada:
```
1. Completa tu primera sesión (15 min)
2. Lee ai-first-workflow.md (enfócate en Comandos de Alto Valor)
3. Experimenta con comandos de impacto en tu proyecto
4. Consulta commands-guide.md como referencia
5. Lee best-practices.md cuando busques dominio avanzado
```


