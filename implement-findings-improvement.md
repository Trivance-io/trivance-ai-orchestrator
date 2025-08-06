# Plan de Mejora: Comando /pr-findings

## Objetivo
Mejorar el comando `/pr-findings` para automatizar la creación de GitHub issues desde hallazgos de PRs, manteniendo simplicidad y potencia.

## Alcance (Sin Cambios)
- Detectar PRs existentes en el branch actual
- Extraer comentarios de revisión de Claude Code
- Generar issues automáticamente con formato estandarizado
- Crear logs auditables con estructura por fecha

## Plan de Implementación Paso a Paso

### 1. Preparación del Entorno
```bash
# Verificar herramientas necesarias
- Confirmar gh CLI instalado y autenticado
- Verificar repositorio Git con remote GitHub
- Crear estructura de logs si no existe
```

### 2. Estructura del Comando Mejorado

#### 2.1 Validaciones Iniciales (Inspirado en /commit y /pr)
```bash
# Verificar gh CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) no encontrado"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &>/dev/null; then
    echo "❌ No autenticado con GitHub"
    exit 1
fi

# Verificar repositorio
if ! git remote -v | grep -q github.com; then
    echo "❌ No es un repositorio GitHub"
    exit 1
fi
```

#### 2.2 Detección de Pull Requests
```bash
# Obtener branch actual
current_branch=$(git branch --show-current)

# Detectar PR del branch actual o usar argumento
if [ -n "$1" ]; then
    pr_number=$1
else
    pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null)
fi

# Validar PR existe
if [ -z "$pr_number" ]; then
    echo "❌ No se encontró PR"
    exit 1
fi
```

### 3. Sistema de Categorización con Labels

#### 3.1 Definir Categorías y Prioridades
```bash
# Labels de tipo (inspirado en /todos-to-issues)
- bug (🐛 problemas, errores)
- enhancement (✨ mejoras, features)
- security (🔒 vulnerabilidades)
- performance (⚡ optimización)
- documentation (📚 docs)
- tech-debt (🔧 deuda técnica)

# Labels de prioridad
- P0-critical (🔴 bloqueante)
- P1-high (🟠 importante)
- P2-medium (🟡 normal)
- P3-low (🟢 menor)
```

#### 3.2 Parser de Hallazgos Mejorado
```bash
# Extraer comentarios del PR
comments=$(gh pr view $pr_number --json comments --jq '.comments[]')

# Parsear hallazgos con estructura:
# - Detectar patrones de Claude Code reviews
# - Extraer: título, descripción, severidad
# - Determinar tipo automáticamente por keywords
```

### 4. Generación de Issues

#### 4.1 Formato de Issue (Inspirado en /pr template)
```markdown
## What this issue addresses:
[Descripción del hallazgo]

**Source:** PR #[número] | **Type:** [tipo] | **Priority:** [prioridad]

## Context:
- File: [archivo afectado]
- Line: [líneas específicas]

## Suggested resolution:
[Recomendación de Claude Code]

## Related PR:
- #[número PR origen]

---
*Created from PR findings*
```

#### 4.2 Creación Batch de Issues
```bash
# Por cada hallazgo identificado:
for finding in "${findings[@]}"; do
    # Crear issue con labels apropiados
    gh issue create \
        --title "[PR#$pr_number] $finding_title" \
        --body "$issue_body" \
        --label "$type_label,$priority_label,from-pr-review"
done
```

### 5. Sistema de Logging Auditable

#### 5.1 Estructura de Logs (Igual que /pr)
```bash
# Crear directorio por fecha
today=$(date '+%Y-%m-%d')
timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
logs_dir=".claude/logs/$today"
mkdir -p "$logs_dir"
```

#### 5.2 Formato JSONL
```json
# Entrada de ejecución
{
  "timestamp": "2025-08-06T10:30:00",
  "event": "pr_findings_start",
  "pr_number": 123,
  "branch": "feature/xyz"
}

# Por cada issue creado
{
  "timestamp": "2025-08-06T10:30:01",
  "event": "issue_created",
  "pr_number": 123,
  "issue_number": 456,
  "issue_url": "https://github.com/...",
  "type": "bug",
  "priority": "P1-high",
  "title": "[PR#123] Fix authentication timeout"
}

# Resumen final
{
  "timestamp": "2025-08-06T10:30:10",
  "event": "pr_findings_complete",
  "pr_number": 123,
  "findings_processed": 5,
  "issues_created": 5,
  "issues_skipped": 0,
  "status": "success"
}
```

### 6. Manejo de Errores Simple

```bash
# Try-catch pattern simple
if ! result=$(gh issue create ...); then
    echo "⚠️ Error creando issue: $finding_title"
    # Log error pero continuar con siguientes
    echo "{\"timestamp\": \"$timestamp\", \"event\": \"issue_error\", \"title\": \"$finding_title\"}" >> "$logs_dir/pr-findings.jsonl"
else
    echo "✅ Issue creado: $result"
fi
```

### 7. Output Final al Usuario

```bash
echo "📊 Resumen de Ejecución:"
echo "  • PR analizado: #$pr_number"
echo "  • Hallazgos encontrados: $findings_count"
echo "  • Issues creados: $issues_created"
echo "  • Log guardado en: $logs_dir/pr-findings.jsonl"

# Mostrar URLs de issues creados
echo ""
echo "🔗 Issues creados:"
for url in "${issue_urls[@]}"; do
    echo "  • $url"
done
```

## Archivos a Modificar

### 1. `/Users/dariarcos/G-Lab/experiments_dev/trivance-dev-config/.claude/commands/pr-findings.md`

**Cambios principales:**
- Eliminar dependencia de Task/Agent para ejecución directa
- Agregar lógica completa en bash siguiendo patrones de /pr y /commit
- Implementar parser robusto de comentarios
- Agregar sistema de labels automático
- Mejorar formato de issues con template profesional

## Consideraciones de Implementación

### Simplicidad Mantenida
- Sin frameworks externos ni dependencias complejas
- Uso de herramientas nativas: gh, git, bash, jq
- Lógica lineal y fácil de seguir
- Mensajes claros y concisos

### Potencia Agregada
- Categorización automática inteligente
- Priorización basada en severidad
- Logging completo para auditoría
- Manejo robusto de errores
- Output informativo al usuario

### Compatibilidad
- Mantiene estructura de logs existente
- Usa mismo formato JSONL que otros comandos
- Sigue convenciones de labels del proyecto
- Compatible con flujo actual de trabajo

## Secuencia de Ejecución para Claude Code

1. **Leer archivo actual** de pr-findings.md
2. **Crear backup** del archivo actual
3. **Escribir nueva versión** con mejoras implementadas
4. **Validar sintaxis** del bash script
5. **Crear test manual** con PR de prueba
6. **Verificar logs** generados correctamente
7. **Documentar cambios** realizados

## Validación Post-Implementación

```bash
# Test 1: Sin argumentos (usa PR del branch actual)
/pr-findings

# Test 2: Con número de PR específico
/pr-findings 123

# Test 3: Verificar logs creados
ls -la .claude/logs/$(date '+%Y-%m-%d')/pr-findings.jsonl

# Test 4: Verificar issues en GitHub
gh issue list --label "from-pr-review"
```

## Notas Finales

- **NO agregar** complejidad innecesaria
- **NO usar** emojis en commits o PRs (solo en labels para claridad visual)
- **NO incluir** atribución de AI/Claude en ningún lugar
- **MANTENER** filosofía minimalista pero poderosa
- **SEGUIR** patrones existentes de otros comandos exitosos