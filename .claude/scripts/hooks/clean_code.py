#!/usr/bin/env python3
"""
Clean Code Hook - Universal Rules

Applies universal clean code rules without subjective numerical limits.
Processes JS/TS files with prettier + eslint. Never blocks Claude workflow.
"""

import sys, json, subprocess, shlex, os, time
from pathlib import Path
from common import read_stdin_json, log_decision, init_session_context

JS_EXTENSIONS = {'.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs'}
EXIT_SUCCESS = 0
PROCESS_TIMEOUT = 30

def extract_file_path():
    """Extract file path from Claude Code hook input"""
    hook_data = read_stdin_json()
    init_session_context(hook_data.get('session_id'))
    
    if not is_target_event(hook_data):
        return None
    
    return parse_tool_input(hook_data.get('tool_input', {}))

def is_target_event(hook_data):
    """Check if this is a file edit event we should process"""
    return (hook_data.get('hook_event_name') == 'PostToolUse' and 
            hook_data.get('tool_name') in ['Edit', 'Write', 'MultiEdit'])

def parse_tool_input(tool_input):
    """Parse tool input to extract file path with security validation"""
    if isinstance(tool_input, str):
        # Limit JSON size to prevent DoS
        if len(tool_input) > 10240:  # 10KB limit
            return None
        try:
            tool_input = json.loads(tool_input)
        except (json.JSONDecodeError, RecursionError):
            return None
    
    file_path = tool_input.get('file_path') if isinstance(tool_input, dict) else None
    return validate_file_path(file_path)

def validate_file_path(file_path):
    """Validate file path for security and format"""
    if not file_path or not isinstance(file_path, str):
        return None
    
    # Basic length and character validation
    if len(file_path) > 4096 or any(c in file_path for c in ['\x00', '\r', '\n']):
        return None
    
    try:
        # Resolve path and check it exists
        resolved_path = Path(file_path).resolve()
        if not resolved_path.exists():
            return None
        
        # Basic project boundary check
        cwd = Path.cwd().resolve()
        if not str(resolved_path).startswith(str(cwd)):
            return None
            
        return str(resolved_path)
    except (OSError, ValueError):
        return None

def is_javascript_file(file_path):
    """Check if file is JavaScript/TypeScript"""
    if not file_path:
        return False
    return Path(file_path).suffix.lower() in JS_EXTENSIONS

def find_project_root(file_path):
    """Find project root with path traversal protection"""
    try:
        current = Path(file_path).resolve().parent
        project_boundary = Path.cwd().resolve()
        max_levels = 10
        
        # Ensure we stay within project boundaries
        if not str(current).startswith(str(project_boundary)):
            return str(project_boundary)
        
        for _ in range(max_levels):
            if has_project_markers(current):
                return str(current)
            if current == project_boundary or current == current.parent:
                break
            current = current.parent
        
        return str(project_boundary)
    except (OSError, ValueError):
        return str(Path.cwd())

def has_project_markers(directory):
    """Check if directory contains project markers"""
    return ((directory / 'package.json').exists() or 
            (directory / '.git').exists())

def is_filesystem_root(directory):
    """Check if we've reached filesystem root"""
    return directory == directory.parent

def count_file_changes(content_before, content_after):
    """Count specific changes made to file"""
    if content_before == content_after:
        return 0, 0
    
    # Count prettier-style changes (formatting, quotes, semicolons)
    prettier_changes = 0
    if len(content_before) != len(content_after):
        prettier_changes += 1
    if content_before.count(';') != content_after.count(';'):
        prettier_changes += 1
    if content_before.count('"') != content_after.count("'"):
        prettier_changes += 1
    
    # Count eslint-style fixes (var changes, line removals)
    eslint_fixes = 0
    var_before = content_before.count('var ')
    var_after = content_after.count('var ')
    if var_before > var_after:
        eslint_fixes += (var_before - var_after)
    
    lines_before = len(content_before.splitlines())
    lines_after = len(content_after.splitlines())
    if lines_before > lines_after:
        eslint_fixes += (lines_before - lines_after)
    
    return prettier_changes, eslint_fixes

def run_prettier(file_path):
    """Format file with prettier"""
    project_root = find_project_root(file_path)
    command = ['npx', 'prettier', '--write', shlex.quote(file_path)]
    
    success = execute_command(command, project_root)
    return success

def run_eslint(file_path):
    """Apply ESLint universal clean code rules"""
    project_root = find_project_root(file_path)
    command = build_eslint_command(file_path)
    
    success = execute_command(command, project_root)
    return success

def build_eslint_command(file_path):
    """Build ESLint command with universal clean code rules"""
    return ['npx', 'eslint', shlex.quote(file_path), '--fix']

def execute_command(command, working_directory):
    """Execute shell command with enhanced security"""
    try:
        # Filter environment for security
        safe_env = {
            'PATH': os.environ.get('PATH', ''),
            'HOME': os.environ.get('HOME', ''),
            'NODE_ENV': 'production'
        }
        
        result = subprocess.run(
            command,
            cwd=working_directory,
            capture_output=True,
            text=True,
            timeout=PROCESS_TIMEOUT,
            shell=False,
            env=safe_env
        )
        return result.returncode == 0
        
    except subprocess.TimeoutExpired:
        return False
    except Exception:
        return False

def get_file_content(file_path):
    """Get file content for comparison"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception:
        return ""

def apply_clean_code_standards(file_path):
    """Apply prettier and eslint with minimal logging"""
    filename = Path(file_path).name
    start_time = time.time()
    
    # Capture content before changes
    content_before = get_file_content(file_path)
    
    # Apply prettier and eslint
    run_prettier(file_path)
    run_eslint(file_path)
    
    # Capture content after changes
    content_after = get_file_content(file_path)
    
    # Calculate duration
    duration_ms = int((time.time() - start_time) * 1000)
    
    # Count changes
    prettier_changes, eslint_fixes = count_file_changes(content_before, content_after)
    
    # Log single entry only if there were actual changes
    if prettier_changes > 0 or eslint_fixes > 0:
        log_decision("clean_code_applied", json.dumps({
            "file": filename,
            "prettier_changes": prettier_changes,
            "eslint_fixes": eslint_fixes,
            "duration_ms": duration_ms
        }, separators=(',', ':')))

def main():
    """Main entry point"""
    try:
        file_path = extract_file_path()
        
        if file_path and is_javascript_file(file_path):
            apply_clean_code_standards(file_path)
        
        sys.exit(EXIT_SUCCESS)
        
    except (ValueError, OSError):
        log_decision("hook_validation_error", "Input validation failed")
        sys.exit(EXIT_SUCCESS)
    except Exception as e:
        log_decision("hook_error", f"Unexpected error: {type(e).__name__}")
        sys.exit(EXIT_SUCCESS)

if __name__ == "__main__":
    main()