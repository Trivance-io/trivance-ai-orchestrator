# PR Findings to Issues

Leo PRs de GitHub para identificar findings, TODOs, issues mencionados en reviews y los convierto en GitHub Issues que Claude Code puede resolver.

## Funcionalidad

```bash
# Obtener PR actual o específico
get_pr_number() {
    local pr_number="$1"
    
    if [ -z "$pr_number" ]; then
        # Detectar PR del branch actual
        current_branch=$(git branch --show-current)
        pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null)
        
        if [ -z "$pr_number" ] || [ "$pr_number" = "null" ]; then
            echo "❌ No se encontró PR para branch actual: $current_branch"
            echo "💡 Usa: /pr-findings [PR_NUMBER]"
            exit 1
        fi
        
        echo "🔍 Analizando PR #$pr_number (branch: $current_branch)"
    else
        echo "🔍 Analizando PR #$pr_number"
    fi
    
    echo "$pr_number"
}

# Leer contenido completo del PR
read_pr_content() {
    local pr_number="$1"
    
    echo "📖 Leyendo contenido del PR #$pr_number..."
    
    # Obtener descripción del PR
    pr_body=$(gh pr view "$pr_number" --json body --jq '.body')
    
    # Obtener reviews
    reviews=$(gh api "repos/:owner/:repo/pulls/$pr_number/reviews" --jq '.[] | "**@" + .user.login + ":** " + .body')
    
    # Obtener comentarios
    comments=$(gh api "repos/:owner/:repo/pulls/$pr_number/comments" --jq '.[] | "**@" + .user.login + ":** " + .body')
    
    # Obtener issue comments (conversación general)
    issue_comments=$(gh api "repos/:owner/:repo/issues/$pr_number/comments" --jq '.[] | "**@" + .user.login + ":** " + .body')
    
    # Combinar todo el contenido
    all_content=$(cat <<EOF
# PR DESCRIPTION
$pr_body

# REVIEWS
$reviews

# PR COMMENTS  
$comments

# DISCUSSION COMMENTS
$issue_comments
EOF
)
    
    echo "$all_content"
}

# Extraer findings del contenido
extract_findings() {
    local content="$1"
    local pr_number="$2"
    
    echo "🔍 Extrayendo findings..."
    
    # Patrones para identificar findings/issues/todos
    findings=$(echo "$content" | grep -i -E "(TODO:|FIXME:|BUG:|ISSUE:|PROBLEM:|SECURITY:|PERFORMANCE:|REFACTOR:|\[ \] )" | head -20)
    
    if [ -z "$findings" ]; then
        echo "✅ No se encontraron findings en PR #$pr_number"
        return 0
    fi
    
    echo "📋 Findings encontrados:"
    echo "$findings"
    echo ""
    
    # Guardar findings en logs JSONL con estructura por fechas
    today=$(date '+%Y-%m-%d')
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
    logs_dir=".claude/logs/$today"
    mkdir -p "$logs_dir"
    
    # Crear entrada JSONL
    findings_log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "event": "pr_findings_extracted",
  "pr_number": $pr_number,
  "findings_count": $(echo "$findings" | wc -l),
  "findings": $(echo "$findings" | jq -R -s .),
  "full_content": $(echo "$content" | jq -R -s .)
}
EOF
)
    
    echo "$findings_log_entry" >> "$logs_dir/pr_findings.jsonl"
    echo "📝 Findings guardados en: $logs_dir/pr_findings.jsonl"
    echo "$findings"
}

# Analizar finding para determinar labels apropiados
analyze_finding_labels() {
    local finding="$1"
    local pr_number="$2"
    
    # Análisis de prioridad basado en palabras clave
    local priority="medium"  # default
    if echo "$finding" | grep -qi "critical\|urgent\|security\|vulnerability\|exploit"; then
        priority="high"
    elif echo "$finding" | grep -qi "performance\|bug\|error\|fail"; then
        priority="medium"
    elif echo "$finding" | grep -qi "todo\|cleanup\|refactor\|docs\|comment"; then
        priority="low"
    fi
    
    # Análisis de impacto basado en tipo de finding
    local impact="medium"  # default
    if echo "$finding" | grep -qi "security\|auth\|permission\|sql\|injection"; then
        impact="high"
    elif echo "$finding" | grep -qi "performance\|database\|api\|user.*experience"; then
        impact="medium"
    elif echo "$finding" | grep -qi "docs\|comment\|format\|style"; then
        impact="low"
    fi
    
    # Análisis de categoría/tipo
    local category="improvement"  # default
    if echo "$finding" | grep -qi "bug\|error\|fail\|broken"; then
        category="bug"
    elif echo "$finding" | grep -qi "security\|auth\|permission"; then
        category="security"
    elif echo "$finding" | grep -qi "performance\|slow\|optimize"; then
        category="performance"
    elif echo "$finding" | grep -qi "docs\|documentation\|comment"; then
        category="documentation"
    elif echo "$finding" | grep -qi "test\|testing\|spec"; then
        category="testing"
    fi
    
    # Generar labels finales
    local labels="from-pr-finding,priority:$priority,impact:$impact,type:$category,pr:$pr_number"
    echo "$labels"
}

# Crear GitHub issues de los findings con labels inteligentes
create_issues_from_findings() {
    local findings="$1"
    local pr_number="$2"  
    
    if [ -z "$findings" ]; then
        echo "ℹ️  No hay findings para convertir en issues"
        return 0
    fi
    
    echo ""
    echo "🎯 ¿Crear GitHub Issues de estos findings? [y/N]:"
    read -r create_issues
    
    if [[ ! "$create_issues" =~ ^[Yy]$ ]]; then
        echo "📋 Findings guardados. Créalos manualmente cuando quieras."
        return 0
    fi
    
    echo "🚀 Creando GitHub Issues con labels inteligentes..."
    
    # Crear logs de issues creados
    today=$(date '+%Y-%m-%d')
    logs_dir=".claude/logs/$today"
    
    # Procesar cada finding
    issue_count=0
    while IFS= read -r finding; do
        if [ -n "$finding" ]; then
            # Crear título limpio del finding
            title=$(echo "$finding" | sed -E 's/^[^A-Za-z]*//' | cut -c1-60)
            if [ ${#title} -eq 60 ]; then title="${title}..."; fi
            
            # Analizar finding para obtener labels apropiados
            labels=$(analyze_finding_labels "$finding" "$pr_number")
            
            # Crear issue body con más contexto
            issue_body="**From PR #$pr_number**

Original finding:
\`\`\`
$finding
\`\`\`

**Context**: This issue was automatically extracted from PR review/comments.

**Labels Applied**: \`$labels\`

**Action needed**: Review and resolve this finding based on its priority and impact.

---
*Created from PR findings analysis*"
            
            echo "🏷️  Creating issue with labels: $labels"
            
            if gh issue create \
                --title "[$pr_number] $title" \
                --body "$issue_body" \
                --label "$labels"; then
                
                echo "✅ Issue creado: $title"
                ((issue_count++))
                
                # Log issue creado
                issue_log_entry=$(cat <<EOF
{
  "timestamp": "$(date '+%Y-%m-%dT%H:%M:%S')",
  "event": "github_issue_created",
  "pr_number": $pr_number,
  "issue_title": "$title",
  "labels": "$labels",
  "original_finding": $(echo "$finding" | jq -R .)
}
EOF
)
                echo "$issue_log_entry" >> "$logs_dir/github_issues.jsonl"
                
            else
                echo "❌ Error creando issue: $title"
            fi
        fi
    done <<< "$findings"
    
    echo ""
    echo "🎉 Creados $issue_count GitHub Issues de PR #$pr_number"
    echo "🔍 Ver issues por prioridad: gh issue list --label priority:high"
    echo "🔍 Ver issues de este PR: gh issue list --label pr:$pr_number"
    echo "🔍 Ver todos los findings: gh issue list --label from-pr-finding"
}
```

## Flujo Principal

```bash
main() {
    local pr_number="$1"
    
    # Validar que gh está configurado
    if ! gh auth status >/dev/null 2>&1; then
        echo "❌ GitHub CLI no configurado"
        echo "Ejecuta: gh auth login"
        exit 1
    fi
    
    # Obtener número de PR
    pr_number=$(get_pr_number "$pr_number")
    
    # Leer contenido completo
    content=$(read_pr_content "$pr_number")
    
    # Extraer findings
    findings=$(extract_findings "$content" "$pr_number")
    
    # Crear issues si hay findings
    create_issues_from_findings "$findings" "$pr_number"
    
    echo ""
    echo "✅ Análisis de PR #$pr_number completado"
}

main "$@"
```

## Uso

```bash
# Analizar PR del branch actual
/pr-findings

# Analizar PR específico
/pr-findings 123

# Ver issues creados
gh issue list --label from-pr-finding
```

Flujo simple: PR → Findings → GitHub Issues → Claude Code los resuelve.