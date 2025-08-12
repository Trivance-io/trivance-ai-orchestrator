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
        file_path = data["file_path"]
    except (json.JSONDecodeError, KeyError, MemoryError):
        print(json.dumps({"status": "error", "reason": "invalid_input"}))
        sys.exit(1)
    
    try:
        file_path = str(Path(file_path).resolve())
        if not Path(file_path).exists() or not Path(file_path).is_file():
            print(json.dumps({"status": "error", "reason": "invalid_file"}))
            sys.exit(1)
    except (OSError, ValueError):
        print(json.dumps({"status": "error", "reason": "invalid_path"}))
        sys.exit(1)
    
    project_root = find_package_json(file_path)
    ensure_tools_installed(project_root)
    
    subprocess.run(['npx', 'prettier', '--write', file_path], cwd=project_root, capture_output=True)
    subprocess.run(['npx', 'eslint', '--fix', file_path], cwd=project_root, capture_output=True)
    
    log_result(file_path)
    print(json.dumps({"status": "processed"}))

if __name__ == "__main__":
    main()