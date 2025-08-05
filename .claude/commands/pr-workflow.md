# PR Workflow Simple

Flujo completo para PRs con findings automáticos.

## Caso de Uso Completo

### 1. Claude Code Implementa Funcionalidad
```bash
# Claude Code desarrolla la feature
# Usuario valida cambios
```

### 2. Usuario Solicita Commits
```bash
/commit  # Comando existente de Claude
```

### 3. Usuario Solicita PR  
```bash
/pr      # Crea PR con template + logging
```

### 4. Extraer Findings del PR
```bash
/pr-findings              # PR del branch actual
/pr-findings 123          # PR específico
```

### 5. Claude Code Resuelve Issues
```bash
# Los issues creados aparecen en GitHub
# Claude Code puede procesarlos con comandos existentes
gh issue list --label from-pr-finding
```

## Archivos Generados (Estructura por Fechas)

### PRs Creados
- `.claude/logs/YYYY-MM-DD/pr_activity.jsonl`
- Contiene: eventos de PR creación, branch, tipo, URL, etc.

### Findings Extraídos  
- `.claude/logs/YYYY-MM-DD/pr_findings.jsonl`
- Contiene: findings extraídos, PR asociado, contenido completo

### Issues Creados
- `.claude/logs/YYYY-MM-DD/github_issues.jsonl`
- Contiene: issues creados, labels aplicados, títulos, etc.

## Comandos Disponibles

| Comando | Función |
|---------|---------|
| `/pr` | Crear PR con template, logging automático |
| `/pr-findings` | Extraer findings → GitHub Issues |

## GitHub Issues Creados (Con Labels Inteligentes)

- **Título**: `[PR#] Finding description...`
- **Labels Aplicados**:
  - `from-pr-finding` (identificación de origen)
  - `priority:high|medium|low` (basado en palabras clave)
  - `impact:high|medium|low` (basado en tipo de finding)
  - `type:bug|security|performance|documentation|testing|improvement`
  - `pr:123` (PR específico de origen)
- **Contenido**: Contexto del PR + finding específico + labels aplicados

### Ejemplos de Labeling
- `"TODO: Add validation"` → `priority:low,impact:medium,type:improvement`
- `"SECURITY: SQL injection risk"` → `priority:high,impact:high,type:security`
- `"BUG: Performance issue"` → `priority:medium,impact:medium,type:bug`

## Permisos Añadidos

Solo los mínimos necesarios:
- `git push origin *` (push seguro)
- `gh pr/issue create/view/list` (GitHub CLI)
- `gh api repos/:owner/:repo/pulls/*/reviews|comments` (leer PRs)
- `mkdir -p .claude/logs/*` (logging estructura por fechas)
- `jq *` (procesamiento JSON para logs)

## Comandos de Consulta Útiles

```bash
# Ver issues por prioridad
gh issue list --label priority:high
gh issue list --label priority:medium
gh issue list --label priority:low

# Ver issues por tipo
gh issue list --label type:security
gh issue list --label type:bug
gh issue list --label type:performance

# Ver issues de un PR específico
gh issue list --label pr:123

# Ver todos los issues de findings
gh issue list --label from-pr-finding

# Ver logs del día actual
cat .claude/logs/$(date '+%Y-%m-%d')/pr_activity.jsonl
cat .claude/logs/$(date '+%Y-%m-%d')/pr_findings.jsonl
cat .claude/logs/$(date '+%Y-%m-%d')/github_issues.jsonl
```

---

**Flujo completo en 3 comandos:**
1. `/commit` (existente)
2. `/pr` (nuevo - simple)  
3. `/pr-findings` (nuevo - extrae issues)

Simple, elegante, sin complejidad innecesaria.