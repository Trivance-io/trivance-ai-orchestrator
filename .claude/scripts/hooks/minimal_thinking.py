#!/usr/bin/env python3
"""Minimal Thinking Hook - Proactive behavioral guidelines injection"""
import sys, json
from pathlib import Path
from datetime import datetime

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

def log_result():
    """Log behavioral guidelines activation"""
    try:
        claude_root = find_claude_root()
        if not claude_root:
            return
        
        log_dir = claude_root / 'logs' / datetime.now().strftime('%Y-%m-%d')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        with open(log_dir / 'minimal_thinking.jsonl', 'a') as f:
            f.write(json.dumps({
                "timestamp": datetime.now().isoformat(),
                "guidelines_injected": True
            }) + '\n')
    except:
        pass  # Silent fail

def main():
    try:
        data = json.loads(sys.stdin.read(10485760))  # 10MB limit
    except (json.JSONDecodeError, MemoryError):
        sys.exit(0)  # Silent fail, don't block Claude
    
    # Inject behavioral guidelines before Claude processes the prompt
    guidelines = """MUST BE USED PROACTIVELY:

1. OBJECTIVITY: Provide expert analysis. Challenge assumptions. No condescending agreement.
2. MINIMALISM:  Think deeply and carefully and implement the most concise solution that works best. Avoid overengineering.
3. CLARITY: Keep language understandable and relevant. No promotional or redundant comments.
4. VALIDATION: Check the syntax and logic before finalizing any implementation. Never add promotional content or redundant comments. Only use emojis if they add significant value to the user experience.
5. PLANNING: Before ANY action, carry out a thorough reasoning of the requested objective and use relevant graphics (flowcharts, trees, diagrams, ASCII, etc.) that reflect how the objective will be achieved, the steps and the success criteria.
6. EXHAUSTIVE DISCOVERY: Perform a complete validation of ALL information provided to the user as a result of any action, ELIMINATING FROM THE ROOT any assumptions, subjective statements and/or patterns that are not true."""

    print(guidelines)
    log_result()

if __name__ == "__main__":
    main()