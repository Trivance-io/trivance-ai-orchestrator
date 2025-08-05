#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI-First PR Analyzer - Enterprise Intelligence (80 lines)
• Análisis contextual de commits para PR generation
• Integración completa con arquitectura existente
• Cache inteligente y performance tracking
• Business impact assessment automático
"""
import re, os, json, subprocess, sys
from typing import Dict, List, Tuple, Any
from common import (
    log_event, track_performance, get_cached_analysis, 
    init_session_context, log_decision, _project_dir
)

# Configuration patterns for intelligent analysis
PR_TYPE_PATTERNS = {
    'feat': r'\b(feat|feature|add|implement|create|new)\b',
    'fix': r'\b(fix|bug|resolve|correct|patch)\b', 
    'docs': r'\b(doc|docs|readme|documentation)\b',
    'refactor': r'\b(refactor|cleanup|reorganize|optimize)\b',
    'chore': r'\b(chore|update|upgrade|dependency|dep)\b',
    'test': r'\b(test|testing|spec|coverage)\b',
    'perf': r'\b(perf|performance|optimize|speed)\b',
    'security': r'\b(security|auth|permission|validate)\b'
}

BUSINESS_IMPACT = {
    'critical': r'\b(critical|urgent|hotfix|security|outage)\b',
    'high': r'\b(performance|database|api|auth|payment)\b', 
    'medium': r'\b(feature|enhancement|improvement|ui|ux)\b',
    'low': r'\b(docs|comment|format|cleanup|refactor)\b'
}

def run_git_command(cmd: str) -> Tuple[str, bool]:
    """Execute git command safely with error handling."""
    try:
        result = subprocess.run(
            cmd.split(), 
            capture_output=True, 
            text=True, 
            cwd=_project_dir(),
            timeout=30
        )
        return result.stdout.strip(), result.returncode == 0
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
        return "", False

def analyze_commits_intelligence(base_branch: str = "main") -> Dict[str, Any]:
    """Intelligent analysis of commits with business context."""
    
    # Get commit data
    commits_cmd = f"git log --oneline {base_branch}..HEAD"
    commits_raw, success = run_git_command(commits_cmd)
    
    if not success or not commits_raw:
        return {"error": "No commits found for analysis"}
    
    commits = commits_raw.split('\n')
    
    # Get file changes
    files_cmd = f"git diff --name-only {base_branch}..HEAD"
    files_raw, _ = run_git_command(files_cmd)
    files_changed = files_raw.split('\n') if files_raw else []
    
    # Get diff stats
    stats_cmd = f"git diff --stat {base_branch}..HEAD"
    stats_raw, _ = run_git_command(stats_cmd)
    
    # Intelligent PR type detection
    combined_text = ' '.join(commits).lower()
    pr_type = 'feat'  # default
    for ptype, pattern in PR_TYPE_PATTERNS.items():
        if re.search(pattern, combined_text, re.IGNORECASE):
            pr_type = ptype
            break
    
    # Business impact assessment
    impact = 'medium'  # default
    for impact_level, pattern in BUSINESS_IMPACT.items():
        if re.search(pattern, combined_text, re.IGNORECASE):
            impact = impact_level
            break
    
    # Smart title generation from first significant commit
    first_commit = commits[0] if commits else ""
    commit_msg = ' '.join(first_commit.split()[1:]) if first_commit else "Update"
    
    # Generate contextual questions based on changes
    technical_questions = []
    business_questions = []
    
    if any('.py' in f for f in files_changed):
        technical_questions.append("¿Los cambios en Python mantienen la compatibilidad de API?")
    if any('.ts' in f or '.js' in f for f in files_changed):
        technical_questions.append("¿Se actualizaron los tipos TypeScript correspondientes?")
    if any('config' in f.lower() for f in files_changed):
        technical_questions.append("¿Los cambios de configuración son backward compatible?")
        business_questions.append("¿Necesita comunicación a usuarios sobre cambios de configuración?")
    
    if pr_type == 'feat':
        business_questions.append("¿Esta funcionalidad requiere documentación de usuario?")
    elif pr_type == 'fix':
        business_questions.append("¿Necesita comunicarse este fix a usuarios afectados?")
    
    # Generate file context
    files_context = []
    for file in files_changed[:8]:  # Limit to prevent huge descriptions
        if file:
            file_type = "📄"
            if file.endswith(('.py', '.js', '.ts')):
                file_type = "🐍" if file.endswith('.py') else "⚡"
            elif file.endswith(('.md', '.txt')):
                file_type = "📝"
            elif file.endswith(('.json', '.yaml', '.yml')):
                file_type = "⚙️"
            
            files_context.append(f"{file_type} `{file}`")
    
    return {
        "pr_type": pr_type,
        "business_impact": impact,
        "title": commit_msg,
        "commits_count": len(commits),
        "files_count": len([f for f in files_changed if f]),
        "commits_list": commits,
        "files_changed": files_context,
        "technical_questions": technical_questions,
        "business_questions": business_questions,
        "stats_summary": stats_raw,
        "why_description": f"Este cambio {pr_type} tiene impacto {impact} en el sistema.",
        "technical_changes": f"Modificaciones en {len(files_changed)} archivos con enfoque en {pr_type}.",
        "architecture_decisions": "Sin cambios arquitectónicos significativos detectados." if pr_type != 'refactor' else "Refactorización que mejora la estructura del código."
    }

def generate_pr_content(base_branch: str = "main", template_path: str = None) -> str:
    """Generate complete PR content using template and intelligent analysis."""
    
    # Use cache for analysis to improve performance
    cache_key = f"{base_branch}-pr-analysis"
    
    with track_performance("pr_content_generation", base_branch=base_branch) as correlation_id:
        analysis = get_cached_analysis(cache_key, lambda _: analyze_commits_intelligence(base_branch))
    
    if "error" in analysis:
        return f"Error: {analysis['error']}"
    
    # Load template
    if not template_path:
        template_path = os.path.join(_project_dir(), ".claude", "templates", "pr-template.md")
    
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            template = f.read()
    except FileNotFoundError:
        return "Error: PR template not found"
    
    # Replace template variables
    replacements = {
        '{{PR_TYPE}}': analysis['pr_type'],
        '{{BUSINESS_IMPACT}}': analysis['business_impact'], 
        '{{FILES_COUNT}}': str(analysis['files_count']),
        '{{BUSINESS_CONTEXT}}': f"Cambio tipo **{analysis['pr_type']}** con impacto **{analysis['business_impact']}**",
        '{{WHY_DESCRIPTION}}': analysis['why_description'],
        '{{TECHNICAL_CHANGES}}': analysis['technical_changes'],
        '{{FILES_LIST}}': '\n'.join(f"- {f}" for f in analysis['files_changed']),
        '{{ARCHITECTURE_DECISIONS}}': analysis['architecture_decisions'],
        '{{MANUAL_TESTING_CHECKLIST}}': "- [ ] Testing manual completado\n- [ ] Validación de casos edge\n- [ ] Performance verificado",
        '{{DOCUMENTATION_IMPACT}}': "Sin impacto en documentación detectado" if analysis['pr_type'] != 'docs' else "Actualizaciones de documentación incluidas",
        '{{TECHNICAL_QUESTIONS}}': '\n'.join(f"- {q}" for q in analysis['technical_questions']) or "- ¿La implementación sigue nuestros patrones establecidos?",
        '{{BUSINESS_QUESTIONS}}': '\n'.join(f"- {q}" for q in analysis['business_questions']) or "- ¿El cambio entrega el valor esperado?",
        '{{COMMIT_HISTORY}}': '\n'.join(analysis['commits_list']),
        '{{LINES_ADDED}}': "Calculando...",
        '{{LINES_DELETED}}': "Calculando...",
        '{{ANALYSIS_TIME}}': f"{correlation_id}",
        '{{SESSION_ID}}': correlation_id[:8],
        '{{ANALYSIS_ID}}': correlation_id
    }
    
    # Apply replacements
    content = template
    for placeholder, value in replacements.items():
        content = content.replace(placeholder, str(value))
    
    return content

def main():
    """Main entry point for PR analysis."""
    base_branch = sys.argv[1] if len(sys.argv) > 1 else "main"
    
    # Initialize session context
    init_session_context()
    
    # Generate PR content
    pr_content = generate_pr_content(base_branch)
    
    # Log decision
    log_decision(
        decision="generate_pr_content",
        reason=f"PR analysis completed for base: {base_branch}",
        confidence="high"
    )
    
    # Output result
    print(pr_content)

if __name__ == "__main__":
    main()