# PR Findings to Issues

Extrae findings de los comentarios del PR (única fuente de verdad) y los convierte automáticamente en GitHub Issues que Claude Code puede resolver.

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

# Extraer findings COMPLETOS de issue comments (única fuente de verdad)
extract_complete_findings() {
    local pr_number="$1"
    
    echo "🔍 Extrayendo findings completos de los comentarios del PR..."
    
    # Obtener el cuerpo completo del primer comentario (review de Claude)
    local comment_body=$(gh api "repos/:owner/:repo/issues/$pr_number/comments" --jq '.[0] | .body' 2>/dev/null)
    
    if [ -z "$comment_body" ]; then
        echo "✅ No se encontraron comentarios en PR #$pr_number"
        return 0
    fi
    
    # Detectar cuántos findings hay
    local finding_count=$(echo "$comment_body" | grep -c '^### \*\*[0-9]\+\.')
    
    if [ "$finding_count" -eq 0 ]; then
        echo "📋 No hay findings con formato profesional, buscando patrones básicos..."
        local basic_findings=$(echo "$comment_body" | grep -i -E "(TODO:|FIXME:|BUG:|ISSUE:|PROBLEM:|SECURITY:|PERFORMANCE:|REFACTOR:|\[ \] )" | head -20)
        if [ -z "$basic_findings" ]; then
            echo "✅ No se encontraron findings en PR #$pr_number"
            return 0
        fi
        echo "$basic_findings"
        return 0
    fi
    
    echo "📋 Encontrados $finding_count findings profesionales"
    
    # Extraer números reales de findings (no asumir secuencial)
    local finding_numbers=$(echo "$comment_body" | grep -o '^### \*\*[0-9]\+\.' | grep -o '[0-9]\+')
    
    # Extraer cada finding completo
    local all_findings=""
    for i in $finding_numbers; do
        local next_i=$((i + 1))
        
        if [ $i -eq $finding_count ]; then
            # Último finding: desde ### **N. hasta el final de la sección
            local finding=$(echo "$comment_body" | awk "/^### \*\*$i\./{flag=1} /^## / && flag==1 {flag=0} flag")
        else
            # Findings intermedios: desde ### **N. hasta ### **(N+1).
            local finding=$(echo "$comment_body" | awk "/^### \*\*$i\./{flag=1} /^### \*\*$next_i\./{flag=0} flag")
        fi
        
        if [ -n "$finding" ]; then
            all_findings="$all_findings$finding

FINDING_SEPARATOR

"
        fi
    done
    
    if [ -z "$all_findings" ]; then
        echo "✅ No se pudieron extraer findings en PR #$pr_number"
        return 0
    fi
    
    echo "📋 Findings completos extraídos:"
    echo ""
    
    # CRÍTICO: Garantizar que SIEMPRE se guarde el log
    today=$(date '+%Y-%m-%d')
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
    logs_dir=".claude/logs/$today"
    mkdir -p "$logs_dir"
    
    # Crear entrada JSONL con findings completos
    findings_log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "event": "pr_findings_extracted",
  "pr_number": $pr_number,
  "findings_count": $finding_count,
  "findings": $(printf '%s' "$all_findings" | jq -R -s .),
  "full_content": $(printf '%s' "$comment_body" | jq -R -s .)
}
EOF
)
    
    echo "$findings_log_entry" >> "$logs_dir/pr_findings.jsonl"
    echo "📝 Findings guardados en: $logs_dir/pr_findings.jsonl"
    
    # Retornar findings para procesamiento
    echo "$all_findings"
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


# Crear GitHub issues de los findings COMPLETOS con contenido descriptivo
create_issues_from_complete_findings() {
    local pr_number="$1"
    
    
    echo ""
    echo "🚀 Creando GitHub Issues automáticamente con contenido completo..."
    
    # Obtener el cuerpo completo del comentario de nuevo
    local comment_body=$(gh api "repos/:owner/:repo/issues/$pr_number/comments" --jq '.[0] | .body' 2>/dev/null)
    local finding_count=$(echo "$comment_body" | grep -c '^### \*\*[0-9]\+\.')
    
    if [ "$finding_count" -eq 0 ]; then
        echo "ℹ️  No hay findings para convertir en issues"
        return 0
    fi
    
    # Crear logs de issues creados
    today=$(date '+%Y-%m-%d')
    logs_dir=".claude/logs/$today"
    
    # Procesar cada finding individualmente (sin asumir numeración secuencial)
    local issue_count=0
    
    # Obtener todas las líneas que empiezan con ### **N.
    local finding_lines=$(echo "$comment_body" | grep -n '^### \*\*[0-9]\+\.')
    
    # Usar process substitution para evitar subshell
    while IFS=: read -r line_num finding_header; do
        if [ -n "$finding_header" ]; then
            # Extraer finding completo con awk más robusto
            local next_finding_line=$(echo "$comment_body" | grep -n '^### \*\*[0-9]\+\.' | awk -F: -v current="$line_num" '$1 > current {print $1; exit}')
            
            if [ -n "$next_finding_line" ]; then
                # Hay otro finding después, extraer hasta esa línea
                local end_line=$((next_finding_line - 1))
                complete_finding=$(echo "$comment_body" | sed -n "${line_num},${end_line}p")
            else
                # Es el último finding, extraer hasta final de sección o documento
                complete_finding=$(echo "$comment_body" | sed -n "${line_num},\$p" | sed '/^## /q' | sed '$d')
            fi
            
            if [ -n "$complete_finding" ]; then
                # Extraer título desde la primera línea
                local title_line=$(echo "$complete_finding" | head -1)
                local title=$(echo "$title_line" | sed 's/^### \*\*[0-9]*\. //' | sed 's/\*\*.*//' | cut -c1-60)
                if [ ${#title} -eq 60 ]; then title="${title}..."; fi
                
                # Usar solo labels que existen en el repo
                local labels="bug,enhancement"
                if echo "$complete_finding" | grep -qi "security\|vulnerability\|injection"; then
                    labels="bug"
                elif echo "$complete_finding" | grep -qi "performance\|optimization"; then
                    labels="enhancement"
                fi
                
                # Crear issue body con el CONTENIDO COMPLETO del finding
                issue_body="# Finding from PR #$pr_number

$complete_finding

---

**Auto-extracted from PR review by Claude Bot**

**Resolution needed**: Review and implement the recommended solution above.

**Priority**: $(if echo "$complete_finding" | grep -qi "crítico\|critical"; then echo "HIGH"; else echo "MEDIUM"; fi)

---
*Created automatically from PR findings analysis*"
                
                echo "🏷️  Creating issue: $title"
                
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
  "original_finding": $(echo "$complete_finding" | jq -R .)
}
EOF
)
                    echo "$issue_log_entry" >> "$logs_dir/github_issues.jsonl"
                    
                else
                    echo "❌ Error creando issue: $title"
                fi
            fi
        fi
    done < <(echo "$finding_lines")
    
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
    
    # Extraer findings completos y crearlos como logs
    all_findings=$(extract_complete_findings "$pr_number")
    
    # Crear issues directamente desde el PR number
    create_issues_from_complete_findings "$pr_number"
    
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

Flujo simple: PR → Issue Comments → GitHub Issues → Claude Code los resuelve.

**Ventajas:**
- ✅ Una única fuente de verdad (issue comments)
- ✅ Detecta findings profesionales (### **N. Título**)
- ✅ Creación automática de GitHub Issues
- ✅ Fallback a patrones básicos si no hay formato profesional
- ✅ Sin complejidad innecesaria