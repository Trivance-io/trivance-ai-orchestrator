#!/usr/bin/env python3
"""Pre-Tool Use Hook - Always Works™ methodology injection
Executes after Claude creates tool parameters and before processing the tool call.
Injects validation methodology to ensure quality outcomes."""
import sys, json
from pathlib import Path
from datetime import datetime

def find_project_root():
    """Find project root by searching upward for .claude directory"""
    path = Path(__file__).resolve()
    while path.parent != path:
        if (path / '.claude').exists():
            return path
        path = path.parent
    raise RuntimeError("Project root with .claude directory not found")

def find_aw_md_path():
    """Locate aw.md file in .claude/scripts/utils/"""
    try:
        project_root = find_project_root()
        aw_path = project_root / '.claude' / 'scripts' / 'utils' / 'aw.md'
        
        if aw_path.exists():
            return aw_path
        else:
            # Fallback: search in .claude/commands/ for backward compatibility
            fallback_path = project_root / '.claude' / 'commands' / 'aw.md'
            if fallback_path.exists():
                return fallback_path
                
        return None
    except Exception:
        return None

def log_result(success, aw_path):
    """Log methodology injection result"""
    try:
        project_root = find_project_root()
        log_dir = project_root / '.claude' / 'logs' / datetime.now().strftime('%Y-%m-%d')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        with open(log_dir / 'pre_tool_use.jsonl', 'a') as f:
            f.write(json.dumps({
                "timestamp": datetime.now().isoformat(),
                "methodology_injected": success,
                "aw_md_path": str(aw_path) if aw_path else "not_found",
                "content_size": aw_path.stat().st_size if aw_path and aw_path.exists() else 0
            }) + '\n')
    except Exception:
        pass  # Silent fail for logging

def main():
    try:
        # Read input (not used for this hook, but follows pattern)
        try:
            data = json.loads(sys.stdin.read(1048576)) if sys.stdin.readable() else {}
        except (json.JSONDecodeError, MemoryError):
            data = {}
    except Exception:
        data = {}
    
    # Locate and read aw.md file
    aw_path = find_aw_md_path()
    
    if not aw_path or not aw_path.exists():
        log_result(False, aw_path)
        print("# Always Works™ methodology: aw.md not found")
        sys.exit(0)
    
    try:
        # Read and output aw.md content
        with open(aw_path, 'r', encoding='utf-8') as f:
            content = f.read(1048576)  # 1MB limit
            
        # Output content for Claude Code context injection
        print(content)
        
        log_result(True, aw_path)
        
    except (OSError, UnicodeDecodeError) as e:
        log_result(False, aw_path)
        print(f"# Always Works™ methodology: Error reading aw.md - {str(e)}")
        sys.exit(0)

if __name__ == "__main__":
    main()