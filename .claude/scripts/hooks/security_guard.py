#!/usr/bin/env python3
"""Security Guard Hook"""
import sys, json, os, re
from datetime import datetime
from pathlib import Path

def find_project_root():
    """Find project root by searching upward for .claude directory"""
    path = Path(__file__).resolve()
    while path.parent != path:
        if (path / '.claude').exists():
            return path
        path = path.parent
    raise RuntimeError("Project root with .claude directory not found")

# Security patterns
PATTERNS = [
    # Credentials (blocking)
    {
        "regex": re.compile(r"(password|secret|token|key)\s*=\s*['\"][^'\"]{1,100}['\"]", re.I),
        "message": "CRITICAL: Hardcoded credential detected",
        "severity": "blocking"
    },
    # Dangerous eval (blocking)
    {
        "regex": re.compile(r"eval\s*\(", re.I),
        "message": "SECURITY: eval() is dangerous",
        "severity": "blocking"
    },
    # SQL injection risk (blocking)
    {
        "regex": re.compile(r'f["\'].{0,50}SELECT.{0,50}FROM.{0,50}\{', re.I),
        "message": "SQL INJECTION: f-string in SQL query",
        "severity": "blocking"
    },
    # Command injection risk (blocking)
    {
        "regex": re.compile(r'subprocess\.(run|call|Popen)\s*\([^)]{0,200}\{', re.I),
        "message": "COMMAND INJECTION: subprocess with dynamic input",
        "severity": "blocking"
    },
    # TypeScript any (warning)
    {
        "regex": re.compile(r"\bany\b", re.I),
        "message": "TYPESCRIPT: Avoid 'any', use specific types",
        "severity": "warning"
    },
    # TODO/FIXME (warning)
    {
        "regex": re.compile(r"(TODO|FIXME|HACK|XXX):", re.I),
        "message": "CODE QUALITY: Unresolved TODO/FIXME",
        "severity": "warning"
    },
    # Console.log (warning)
    {
        "regex": re.compile(r"console\.(log|error|warn|info)", re.I),
        "message": "DEBUG: Remove console statements",
        "severity": "warning"
    },
    # Long functions (warning)
    {
        "regex": re.compile(r"^(def|function|const\s+\w+\s*=\s*\()", re.M),
        "message": "COMPLEXITY: Consider splitting large functions",
        "severity": "complexity_check"
    }
]

def analyze(content):
    """Analyze content against security patterns"""
    issues = []
    for pattern in PATTERNS:
        if pattern["severity"] == "complexity_check":
            # Simple line count between function definitions
            lines = content.split('\n')
            func_starts = [i for i, line in enumerate(lines) if pattern["regex"].match(line)]
            # Check each function including the last one
            for i, start in enumerate(func_starts):
                # Calculate end: next function or end of file
                end = func_starts[i+1] if i+1 < len(func_starts) else len(lines)
                func_length = end - start
                if func_length > 50:
                    issues.append({
                        "line": start + 1,
                        "message": f"Function too long ({func_length} lines)",
                        "severity": "warning"
                    })
        else:
            matches = pattern["regex"].finditer(content)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                issues.append({
                    "line": line_num,
                    "message": pattern["message"],
                    "severity": pattern["severity"],
                    "match": match.group()[:50]  # Truncate for security
                })
    return issues

def main():
    try:
        # Read input (max 1MB)
        raw = sys.stdin.read(1048576)
        data = json.loads(raw) if raw else {}
    except (json.JSONDecodeError, MemoryError):
        print(json.dumps({"error": "Invalid input"}))
        sys.exit(2)
    
    content = data.get("content", "")
    if not content:
        print(json.dumps({"status": "success", "issues": []}))
        sys.exit(0)
    
    # Analyze content
    issues = analyze(content)
    
    # Check for blocking issues
    blocking = [i for i in issues if i["severity"] == "blocking"]
    
    # Logging
    try:
        # Find project root
        project_root = find_project_root()
        log_dir = Path(project_root) / '.claude' / 'logs' / datetime.now().strftime('%Y-%m-%d')
        log_dir.mkdir(parents=True, exist_ok=True)
        with open(log_dir / 'security.jsonl', 'a') as f:
            f.write(json.dumps({
                "timestamp": datetime.now().isoformat(),
                "content_size": len(content),
                "issues": len(issues),
                "blocking": len(blocking)
            }) + '\n')
    except:
        pass  # Silent fail for logging
    
    # Output result
    result = {
        "status": "blocked" if blocking else "success",
        "issues": issues[:20],  # Limit output size
        "summary": {
            "total": len(issues),
            "blocking": len(blocking),
            "warnings": len([i for i in issues if i["severity"] == "warning"])
        }
    }
    
    print(json.dumps(result))
    sys.exit(2 if blocking else 0)

if __name__ == "__main__":
    main()