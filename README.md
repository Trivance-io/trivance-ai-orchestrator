# Trivance Workspace Setup

Clona repositorios Trivance y configura workspace Claude Code.

## Funcionalidad

1. Clona repositorios listados en `docs/trivance-repos.md`
2. Actualiza repositorios existentes con `git fetch && git pull --ff-only`
3. Copia configuración `.claude/` al workspace usando operación atómica

## Uso

```bash
git clone https://github.com/Trivance-io/trivance-ai-orchestrator.git
cd trivance-ai-orchestrator
./scripts/core/setup.sh
```

## Prerequisitos

**Básicos (obligatorios):**
- Git instalado
- Permisos de escritura en directorio padre

**Claude Code (esencial):**
- Claude Code CLI
- GitHub CLI: `gh auth login`
- Python 3.8+

**MCP GitHub (opcional):**
- Docker + curl
- GitHub Personal Access Token

**Utilidades (opcional):**
- `jq`, `terminal-notifier`/`notify-send`

## Estructura Resultante

```
workspace/
├── trivance-ai-orchestrator/
│   ├── .claude/
│   ├── docs/trivance-repos.md
│   └── scripts/core/setup.sh
├── trivance-mobile/
├── trivance_auth/
├── trivance_management/
├── trivance_backoffice/
└── .claude/                     # Configuración Claude Code
```

## Comportamiento

**Repositorio no existe**: Lo clona
**Repositorio existe**: Ejecuta `git fetch && git pull --ff-only`
**Falla actualización**: Continúa con advertencia

## Instalación de Dependencias

### Herramientas Esenciales
```bash
# GitHub CLI
brew install gh                    # macOS
sudo apt install gh                # Ubuntu/Debian  
winget install GitHub.cli          # Windows

gh auth login                       # Autenticación

# Python 3.8+
brew install python3               # macOS
sudo apt install python3-pip       # Ubuntu/Debian
winget install Python.Python.3     # Windows
```

### MCP GitHub (Opcional)
```bash
# Setup automático
./.claude/mcp-servers/github/setup.sh

# O instalación manual:
brew install --cask docker         # macOS + Docker
# Crear Personal Access Token en: https://github.com/settings/tokens
# Scopes: repo, read:org, read:user, actions:read
```

## Solución de Problemas

| Error | Solución |
|-------|----------|
| "Git not found" | Instalar Git: https://git-scm.com/downloads |
| "docs/trivance-repos.md not found" | Ejecutar desde `scripts/core/` |
| ".claude directory not found" | Clonar repositorio completo |
| "MCP GitHub falla" | `gh auth logout && gh auth login` |
| "Claude no responde" | `claude --reset-config` |

## Documentación AI-First

Después del setup, consultar `.claude/human-handbook/`:

- **`quickstart.md`** - Inicio rápido con comandos y agentes
- **`commands-guide.md`** - Comandos especializados organizados por importancia
- **`agents-guide.md`** - Agentes AI especializados por casos de uso
- **`ai-first-workflow.md`** - Workflow completo de desarrollo AI-first
- **`ai-first-best-practices.md`** - Mejores prácticas para desarrollo con AI