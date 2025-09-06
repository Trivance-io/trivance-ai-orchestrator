# Trivance Workspace Setup

Clona repositorios Trivance y configura workspace Claude Code.

## Funcionalidad

1. Clona repositorios listados en `docs/trivance-repos.md`
2. Copia configuración `.claude/` al workspace
3. Verifica integridad de la copia

## Uso

```bash
git clone https://github.com/Trivance-io/trivance-ai-orchestrator.git
cd trivance-ai-orchestrator
./setup.sh
```

## Prerequisitos

- Git instalado
- Permisos de escritura en directorio padre

## Estructura Resultante

```
workspace/
├── trivance-ai-orchestrator/
│   ├── .claude/
│   ├── docs/trivance-repos.md
│   └── setup.sh
├── trivance-mobile/
├── trivance_auth/
├── trivance_management/
├── trivance_backoffice/
└── .claude/                     # Configuración Claude Code
```

## Comportamiento

**Repositorio no existe**: Lo clona
**Repositorio existe**: Ejecuta `git pull`
**Falla actualización**: Continúa con advertencia

## Claude Code

El setup copia la configuración completa:
- Agentes especializados
- Comandos personalizados  
- Scripts de automatización
- Configuración workspace

Abre Claude Code en el directorio workspace después del setup.

## Solución de Problemas

**"Git not found"**
→ Instalar Git desde https://git-scm.com/downloads

**"docs/trivance-repos.md not found"**
→ Ejecutar desde directorio `trivance-ai-orchestrator`

**".claude directory not found"**
→ Clonar repositorio completo con subdirectorios

**Error clonando repositorio**
→ Verificar conexión y acceso a repositorios Trivance-io

## Documentación AI-First

Después del setup, consultar `.claude/human-handbook/`:

- **`quickstart.md`** - Inicio rápido con comandos y agentes
- **`commands-guide.md`** - Comandos especializados organizados por importancia
- **`agents-guide.md`** - Agentes AI especializados por casos de uso
- **`ai-first-workflow.md`** - Workflow completo de desarrollo AI-first
- **`ai-first-best-practices.md`** - Mejores prácticas para desarrollo con AI