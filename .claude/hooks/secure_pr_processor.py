#!/usr/bin/env python3
"""
Secure PR Findings Processor
Security-first implementation without command injection vulnerabilities
"""

import json
import subprocess
import sys
import re
import tempfile
import os
import time
from pathlib import Path

# Security constraints
MAX_FINDINGS_PER_PR = 50
MAX_FINDING_LENGTH = 5000
MAX_TITLE_LENGTH = 200
VALID_SEVERITIES = {'critical', 'high', 'medium', 'low'}
RATE_LIMIT_SECONDS = 10

# Performance tracking
LAST_EXECUTION = 0

def is_rate_limited():
    """Check if we're within rate limit"""
    global LAST_EXECUTION
    current_time = time.time()
    if current_time - LAST_EXECUTION < RATE_LIMIT_SECONDS:
        return True
    LAST_EXECUTION = current_time
    return False

def validate_gh_cli():
    """Validate GitHub CLI availability"""
    try:
        result = subprocess.run(['gh', '--version'], 
                              capture_output=True, 
                              text=True, 
                              timeout=5)
        return result.returncode == 0
    except (subprocess.SubprocessError, FileNotFoundError):
        return False

def sanitize_string(text, max_length=None):
    """Sanitize string for safe command execution"""
    if not isinstance(text, str):
        return ""
    
    # Remove/escape dangerous characters
    text = text.replace('\x00', '').strip()
    
    if max_length:
        text = text[:max_length]
    
    return text

def parse_findings_secure(text):
    """Securely parse Claude review findings"""
    if not text or len(text) > 100000:  # Max 100KB input
        return []
    
    findings = []
    
    # Compiled regex for better performance
    pattern = re.compile(r'\[FINDING\]\s*\[(\w+)\]\s*(.+?)(?=\[FINDING\]|$)', re.DOTALL)
    matches = pattern.findall(text)
    
    for severity, content in matches[:MAX_FINDINGS_PER_PR]:
        severity = sanitize_string(severity.lower())
        if severity not in VALID_SEVERITIES:
            severity = 'medium'
        
        content = sanitize_string(content, MAX_FINDING_LENGTH)
        lines = content.strip().split('\n')
        
        title = sanitize_string(lines[0].strip(), MAX_TITLE_LENGTH)
        description = sanitize_string('\n'.join(lines[1:]).strip(), MAX_FINDING_LENGTH - len(title))
        
        if title:  # Only add if we have a valid title
            findings.append({
                'severity': severity,
                'title': title,
                'description': description
            })
    
    return findings

def create_github_issue_secure(title, body, labels):
    """Create GitHub issue using secure subprocess execution"""
    try:
        # Validate inputs
        title = sanitize_string(title, MAX_TITLE_LENGTH)
        if not title:
            return None
            
        # Use temporary file for body to avoid command line injection
        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', prefix='claude-pr-', delete=False) as temp_file:
            temp_file.write(sanitize_string(body, MAX_FINDING_LENGTH))
            temp_file_path = temp_file.name
        
        try:
            # Secure subprocess execution without shell=True
            cmd = [
                'gh', 'issue', 'create',
                '--title', title,
                '--body-file', temp_file_path,
                '--label', ','.join(labels)
            ]
            
            result = subprocess.run(cmd, 
                                  capture_output=True, 
                                  text=True, 
                                  timeout=30)
            
            if result.returncode == 0:
                print(f"✅ Created issue: {title}")
                return result.stdout.strip()
            else:
                print(f"❌ Failed to create issue: {result.stderr}", file=sys.stderr)
                return None
                
        finally:
            # Clean up temporary file
            try:
                os.unlink(temp_file_path)
            except OSError:
                pass
                
    except Exception as e:
        print(f"Error creating issue: {e}", file=sys.stderr)
        return None

def should_process_hook_data(hook_data):
    """Intelligent filtering to determine if we should process this hook"""
    tool_name = hook_data.get('tool_name', '')
    tool_output = hook_data.get('tool_output', '')
    
    # Only process Bash commands
    if tool_name != 'Bash':
        return False
    
    # Quick pre-filtering for performance
    if not tool_output:
        return False
    
    # Must contain both PR references and findings
    has_pr_ref = any(keyword in tool_output for keyword in ['pull request', 'PR #', '#pr', 'github.com'])
    has_findings = '[FINDING]' in tool_output
    
    return has_pr_ref and has_findings

def extract_pr_number(text):
    """Extract PR number from text with validation"""
    pr_match = re.search(r'#(\d{1,5})', text)  # Limit to reasonable PR numbers
    if pr_match:
        pr_number = pr_match.group(1)
        # Additional validation
        if 1 <= int(pr_number) <= 99999:
            return pr_number
    return 'unknown'

def main():
    """Main execution with comprehensive error handling"""
    try:
        # Rate limiting check
        if is_rate_limited():
            sys.exit(0)
        
        # Validate environment
        if not validate_gh_cli():
            print("Warning: GitHub CLI not available", file=sys.stderr)
            sys.exit(0)
        
        # Read and validate hook input
        try:
            hook_data = json.load(sys.stdin)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
            sys.exit(1)
        
        # Intelligent filtering
        if not should_process_hook_data(hook_data):
            sys.exit(0)
        
        tool_output = hook_data.get('tool_output', '')
        print("🔍 Processing Claude review findings...")
        
        # Parse findings securely
        findings = parse_findings_secure(tool_output)
        
        if not findings:
            print("No valid findings to process")
            sys.exit(0)
        
        # Extract PR number securely
        pr_number = extract_pr_number(tool_output)
        
        # Create issues for each finding
        created_count = 0
        for finding in findings:
            title = f"[PR-{pr_number}] {finding['title']}"
            
            body = f"""## Finding from PR Review

{finding['description']}

---
📝 Source: PR #{pr_number}
🤖 Found by: Claude Code Review
⚡ Severity: {finding['severity'].upper()}
"""
            
            labels = [
                'pr-finding',
                f'severity-{finding["severity"]}'
            ]
            
            if create_github_issue_secure(title, body, labels):
                created_count += 1
        
        print(f"✅ Created {created_count} issues from {len(findings)} findings")
        
    except KeyboardInterrupt:
        print("Operation cancelled by user", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()