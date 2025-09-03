#!/usr/bin/env python3
"""Pre-Tool Use Hook - Always Works™ methodology injection
Executes after Claude creates tool parameters and before processing the tool call.
Injects validation methodology to ensure quality outcomes."""
import sys, json
from pathlib import Path
from datetime import datetime

def find_project_root():
    """Find project root by searching upward for directory that contains .claude"""
    path = Path(__file__).resolve()
    
    # Special handling: if we're inside .claude directory, go up until we're outside it
    while '.claude' in str(path):
        path = path.parent
        
    # Now search upward for directory that CONTAINS .claude
    while path.parent != path:
        if (path / '.claude').exists() and (path / '.claude').is_dir():
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
    """Log methodology injection result with descriptive context"""
    try:
        project_root = find_project_root()
        log_dir = project_root / '.claude' / 'logs' / datetime.now().strftime('%Y-%m-%d')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate more descriptive log entry
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "hook": "pre-tool-use",
            "action": "always_works_methodology_injection",
            "status": "success" if success else "failed",
            "methodology_injected": success,
            "aw_md_path": str(aw_path) if aw_path else "not_found",
            "content_size": aw_path.stat().st_size if aw_path and aw_path.exists() else 0,
            "reason": "file_found_and_loaded" if success else "aw_md_file_not_accessible"
        }
        
        with open(log_dir / 'pre_tool_use.jsonl', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    except Exception as e:
        # Fallback logging to stderr for observability
        try:
            import sys
            fallback_log = {
                "timestamp": datetime.now().isoformat(),
                "hook": "pre-tool-use", 
                "error": "logging_failed",
                "reason": str(e)[:100]  # Truncate error message
            }
            sys.stderr.write(f"HOOK_LOG_ERROR: {json.dumps(fallback_log)}\n")
        except:
            pass  # Ultimate fallback - truly silent only if stderr also fails

def main():
    try:
        # Read input with reasonable limits for hook input
        try:
            stdin_content = sys.stdin.read(8192) if sys.stdin.readable() else ""  # 8KB limit
            data = json.loads(stdin_content) if stdin_content else {}
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
        # Read and output aw.md content with reasonable limit
        with open(aw_path, 'r', encoding='utf-8') as f:
            content = f.read(65536)  # 64KB limit (sufficient for methodology files)
            
        # Output content for Claude Code context injection
        print(content)
        
        log_result(True, aw_path)
        
    except (OSError, UnicodeDecodeError) as e:
        log_result(False, aw_path)
        # Log error for observability
        try:
            sys.stderr.write(f"HOOK_ERROR: Failed to read {aw_path}: {str(e)}\n")
        except:
            pass
        print(f"# Always Works™ methodology: Error reading aw.md - {str(e)}")
        sys.exit(0)

if __name__ == "__main__":
    main()