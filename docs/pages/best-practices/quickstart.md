---
---
layout: docs
title: "\U0001F680 Ecosistema AI-First: Guía de Instalación\n\n## \U0001F4CB Requisitos\n\n-
  Claude Code CLI instalado\n- Python 3.8+\n- Git configurado\n- Acceso a GitHub\n\n##
  ⚡ Instalación\n\n### 1. \U0001F916 Modelo\n\nEl proyecto usa `\"model\": \"opusplan\"`
  (Opus 4.1 para planificación, Sonnet 4 para ejecución)\n\n### 2. \U0001F517 MCP
  GitHub\n\n```bash\ngh auth login\ngh auth status\n```\n\nHabilita herramientas GitHub
  nativas (`mcp__github__*`)\n\n### 3. \U0001F514 Notificaciones\n\n#### macOS\n\n```bash\nbrew
  install terminal-notifier\n```\n\n**Sistema** → **Notificaciones** → **Terminal**
  → Habilitar\n\n#### Windows\n\n```powershell\nwinget install Microsoft.PowerToys\n```\n\n####
  Linux\n\n```bash\nsudo apt install notify-send libnotify-bin  # Ubuntu/Debian\nsudo
  dnf install notify-send libnotify      # Fedora\n```\n\n### 4. \U0001F527 GitHub
  Workflows\n\n**⚠️ CRÍTICO**: Copiar estos archivos a tu proyecto para activar el
  ecosistema AI-first completo:\n\n```bash\n# Crear directorio workflows\nmkdir -p
  .github/workflows\n\n# Copiar configuraciones desde este repo\ncp .github/workflows/claude-code-review.yml
  tu-proyecto/.github/workflows/\ncp .github/workflows/claude.yml tu-proyecto/.github/workflows/\ncp
  .github/workflows/security.yml tu-proyecto/.github/workflows/\n```\n\n**Configurar
  secret**: `CLAUDE_CODE_OAUTH_TOKEN` en GitHub repo settings.\n\n**Resultado**:\n\n-
  \U0001F916 Review automático en PRs (Opus 4.1)\n- \U0001F4AC Interacción `@claude`
  en issues/comments\n- \U0001F512 Security scanning automático\n\n### 5. ✅ Verificación\n\n```bash\nclaude
  --version\ngh repo view\nterminal-notifier -title \"Test\" -message \"Funcionando\"
  \ # macOS\nnotify-send \"Test\" \"Funcionando\"                        # Linux\n\n#
  Test completo en directorio del proyecto\nclaude \"dame un resumen del proyecto\"\nclaude
  \"lista los últimos 3 PRs\"\necho \"test\" > test.txt && claude \"/commit\"\n```\n\n**Esperado**:
  Claude responde con información del proyecto, PRs, y notificación de commit\n\n---\n\n##
  \U0001F3AF Tu Primera Sesión AI-First (15 minutos)\n\n**Experimenta el workflow
  completo en tu primer uso:**\n\n```bash\n# 1. Setup Inicial (2 min)\n/workflow:session-start\n#
  Elegir: \"Desarrollo\" → te guía automáticamente a crear worktree\n\n# 2. Context
  Mapping (3 min) - ESENCIAL\n/understand\n# Mapea arquitectura completa del proyecto
  automáticamente\n\n# 3. Implementation Engine (5 min)\n/implement \"pequeña mejora
  o fix específico\"\n# Motor completo: planning → coding → testing → documentation\n\n#
  4. Quality Assurance (3 min) - CRÍTICO\n/review\n# Análisis multi-especialista automático
  (security, performance, code quality)\n\n# 5. Integration (2 min)\n/pr\n# PR automático
  con metadata completa\n```\n\n**\U0001F3C6 Resultado esperado:** PR funcional con
  implementación completa, tests pasando, y quality checks en 15 minutos.\n\n**\U0001F4A1
  Lo que aprendes:**\n\n- **Context-awareness**: `/understand` previene horas de refactoring\n-
  **Automation power**: `/implement` reemplaza desarrollo manual\n- **Quality by design**:
  `/review` previene fixes costosos post-merge\n- **Zero friction**: De idea a PR
  en minutos, no horas\n\n## \U0001F6A8 Problemas Comunes\n\n**Claude no responde**:
  `claude --reset-config`\n**MCP GitHub falla**: `gh auth logout && gh auth login`\n**Sin
  notificaciones**: Verificar permisos del sistema\n\n## \U0001F4DA Siguiente Paso:
  Domina el Workflow\n\n### \U0001F3AF **Primero**: [Tu Primera Sesión](#tu-primera-sesión-ai-first-15-minutos)\n\n**Completa
  el workflow de 15 minutos** para experimentar el poder de automatización.\n\n###
  \U0001F4D6 **Después**: Profundiza tu expertise\n\n#### \U0001F525 [`ai-first-workflow.md`](ai-first-workflow.md)
  - **ESENCIAL**\n\n**Workflow completo**: PR → Review → Issues → Resolución → Merge
  \ \n**Incluye**: [Comandos de Alto Valor](ai-first-workflow.md#-comandos-de-alto-valor)
  - la clave de productividad 10x\n\n#### ⚡ [`commands-guide.md`](commands-guide.md)
  - **REFERENCIA COMPLETA**\n\n**30+ comandos organizados por impacto**: `/understand`,
  `/implement`, `/review`, `/test` + todos los demás\n\n#### \U0001F9E0 [`ai-first-best-practices.md`](ai-first-best-practices.md)
  - **MASTERY**\n\n**Evolución mental**: De desarrollo manual a orquestación inteligente\n\n###
  \U0001F3AF Ruta de Aprendizaje Recomendada:\n\n```\n1. Completa tu primera sesión
  (15 min)\n2. Lee ai-first-workflow.md (enfócate en Comandos de Alto Valor)\n3. Experimenta
  con comandos de impacto en tu proyecto\n4. Consulta commands-guide.md como referencia\n5.
  Lee ai-first-best-practices.md cuando busques dominio avanzado\n```"
category: best-practices
permalink: "/quickstart/"
description: '- Claude Code CLI instalado - Python 3.8+ - Git configurado - Acceso
  a GitHub El proyecto usa `"model": "opusplan"` (Opus 4.1 para planificación, Sonnet
  4 para ejecución)'
tags:
- inicio
- configuración
- guía
- implement
- review
toc: true
search: true
last_modified_at: '2025-09-20'
---

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
```bash

Habilita herramientas GitHub nativas (`mcp__github__*`)

### 3. 🔔 Notificaciones

#### macOS

```bash
brew install terminal-notifier
```bash

**Sistema** → **Notificaciones** → **Terminal** → Habilitar

#### Windows

```powershell
winget install Microsoft.PowerToys
```bash

#### Linux

```bash
sudo apt install notify-send libnotify-bin  # Ubuntu/Debian
sudo dnf install notify-send libnotify      # Fedora
```bash

### 4. 🔧 GitHub Workflows

**⚠️ CRÍTICO**: Copiar estos archivos a tu proyecto para activar el ecosistema AI-first completo:

```bash
# Crear directorio workflows
mkdir -p .github/workflows

# Copiar configuraciones desde este repo
cp .github/workflows/claude-code-review.yml tu-proyecto/.github/workflows/
cp .github/workflows/claude.yml tu-proyecto/.github/workflows/
cp .github/workflows/security.yml tu-proyecto/.github/workflows/
```bash

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
```bash

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

# 3. Implementation Engine (5 min)
/implement "pequeña mejora o fix específico"
# Motor completo: planning → coding → testing → documentation

# 4. Quality Assurance (3 min) - CRÍTICO
/review
# Análisis multi-especialista automático (security, performance, code quality)

# 5. Integration (2 min)
/pr
# PR automático con metadata completa
```bash

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

#### 🔥 [`ai-first-workflow.md`](/workflows/) - **ESENCIAL**

**Workflow completo**: PR → Review → Issues → Resolución → Merge  
**Incluye**: [Comandos de Alto Valor](ai-first-workflow.md#-comandos-de-alto-valor) - la clave de productividad 10x

#### ⚡ [`commands-guide.md`](/commands/) - **REFERENCIA COMPLETA**

**30+ comandos organizados por impacto**: `/understand`, `/implement`, `/review`, `/test` + todos los demás

#### 🧠 [`ai-first-best-practices.md`](/best-practices/) - **MASTERY**

**Evolución mental**: De desarrollo manual a orquestación inteligente

### 🎯 Ruta de Aprendizaje Recomendada:

```bash
1. Completa tu primera sesión (15 min)
2. Lee ai-first-workflow.md (enfócate en Comandos de Alto Valor)
3. Experimenta con comandos de impacto en tu proyecto
4. Consulta commands-guide.md como referencia
5. Lee ai-first-best-practices.md cuando busques dominio avanzado
```bash


---

_📝 [Editar esta página en GitHub](https://github.com/trivance-ai/trivance-ai-orchestrator/edit/main/.claude/human-handbook/docs/quickstart.md)_
