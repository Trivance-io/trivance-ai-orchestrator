#!/usr/bin/env python3
"""Clean Code Hook - Automatic formatting with prettier and eslint"""
import sys, json, subprocess
from pathlib import Path
from datetime import datetime

def find_package_json(file_path):
    """Find nearest package.json going up from file"""
    current = Path(file_path).parent
    max_levels = 20  # Prevent infinite loops from circular symlinks
    
    for _ in range(max_levels):
        if (current / 'package.json').exists():
            return current
        if current == current.parent:
            break
        current = current.parent
    return Path.cwd()

def find_claude_root():
    """Find .claude directory going up from this script"""
    current = Path(__file__).parent
    max_levels = 20  # Prevent infinite loops from circular symlinks
    
    for _ in range(max_levels):
        if (current / '.claude').exists():
            return current / '.claude'
        if current == current.parent:
            break
        current = current.parent
    return None

def get_formatters_for_ext(file_ext):
    """Get available formatters for file extension"""
    formatters_map = {
        '.js': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.jsx': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.ts': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.tsx': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.vue': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.svelte': [['npx', 'prettier', '--write'], ['npx', 'eslint', '--fix']],
        '.json': [['npx', 'prettier', '--write']],
        '.md': [['npx', 'prettier', '--write']],
        '.yml': [['npx', 'prettier', '--write']],
        '.yaml': [['npx', 'prettier', '--write']],
        '.sh': [['shfmt', '-w']],
        '.bash': [['shfmt', '-w']],
        '.py': [['black'], ['ruff', '--fix']]
    }
    return formatters_map.get(file_ext, [])

def check_tool_available(tool_cmd):
    """Check if a formatting tool is available"""
    try:
        result = subprocess.run(
            tool_cmd + ['--version'], 
            capture_output=True, 
            timeout=5
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError, PermissionError):
        return False

def ensure_tools_installed(project_root):
    """Auto-install prettier and eslint if not available"""
    try:
        if not (project_root / 'package.json').exists():
            return False
        
        npm_check = subprocess.run(
            ['npm', '--version'], 
            capture_output=True
        )
        if npm_check.returncode != 0:
            return False
        
        prettier_result = subprocess.run(
            ['npx', 'prettier', '--version'], 
            cwd=project_root, 
            capture_output=True,
            timeout=10
        )
        
        eslint_result = subprocess.run(
            ['npx', 'eslint', '--version'], 
            cwd=project_root, 
            capture_output=True,
            timeout=10
        )
        
        if prettier_result.returncode != 0 or eslint_result.returncode != 0:
            install_result = subprocess.run(
                ['npm', 'install', '--save-dev', 'prettier', 'eslint'],
                cwd=project_root,
                capture_output=True,
                timeout=60  # 60 second timeout for installation
            )
            
            if install_result.returncode != 0:
                return False
                
        return True
        
    except (subprocess.TimeoutExpired, FileNotFoundError, PermissionError, Exception):
        return False

def log_result(file_path):
    """Log the formatting result"""
    try:
        claude_root = find_claude_root()
        if not claude_root:
            return
        
        log_dir = claude_root / 'logs' / datetime.now().strftime('%Y-%m-%d')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        with open(log_dir / 'clean_code.jsonl', 'a') as f:
            f.write(json.dumps({
                "timestamp": datetime.now().isoformat(),
                "file": Path(file_path).name
            }) + '\n')
    except:
        pass  # Silent fail

def main():
    try:
        data = json.loads(sys.stdin.read(1048576))  # 1MB limit
        
        # Extract file_path from Claude Code's PostToolUse JSON structure
        tool_input = data.get("tool_input", {})
        file_path = tool_input.get("file_path")
        
        if not file_path:
            # Silent fail - don't block Claude for non-file operations
            print(json.dumps({"status": "skipped", "reason": "no_file_path"}))
            sys.exit(0)
            
    except (json.JSONDecodeError, KeyError, MemoryError):
        # Silent fail - don't block Claude for invalid input
        print(json.dumps({"status": "error", "reason": "invalid_input"}))
        sys.exit(0)
    
    try:
        file_path = str(Path(file_path).resolve())
        if not Path(file_path).exists() or not Path(file_path).is_file():
            print(json.dumps({"status": "skipped", "reason": "invalid_file"}))
            sys.exit(0)
    except (OSError, ValueError):
        print(json.dumps({"status": "skipped", "reason": "invalid_path"}))
        sys.exit(0)
    
    # Process common development files for formatting
    file_ext = Path(file_path).suffix.lower()
    supported_exts = {'.js', '.jsx', '.ts', '.tsx', '.vue', '.svelte', '.json', '.md', '.sh', '.bash', '.yml', '.yaml', '.py'}
    
    if file_ext not in supported_exts:
        print(json.dumps({"status": "skipped", "reason": "unsupported_file_type"}))
        sys.exit(0)
    
    project_root = find_package_json(file_path)
    
    # Get formatters for this file type
    formatters = get_formatters_for_ext(file_ext)
    if not formatters:
        print(json.dumps({"status": "skipped", "reason": "no_formatters"}))
        sys.exit(0)
    
    # For JS/TS files, ensure npm tools are installed
    if file_ext in {'.js', '.jsx', '.ts', '.tsx', '.vue', '.svelte', '.json', '.md', '.yml', '.yaml'}:
        if not ensure_tools_installed(project_root):
            print(json.dumps({"status": "skipped", "reason": "tools_unavailable"}))
            sys.exit(0)
    
    # Run available formatting tools silently
    tools_used = []
    for formatter_cmd in formatters:
        tool_name = formatter_cmd[0]
        if check_tool_available(formatter_cmd[:1]):
            subprocess.run(formatter_cmd + [file_path], cwd=project_root, capture_output=True)
            tools_used.append(tool_name.split('/')[-1])  # Get tool name without path
    
    log_result(file_path)
    if tools_used:
        print(json.dumps({"status": "processed", "tools": tools_used}))
    else:
        print(json.dumps({"status": "skipped", "reason": "no_tools_available"}))

if __name__ == "__main__":
    main()