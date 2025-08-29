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

1. OBJECTIVITY: Challenge the user's assumptions, avoid condescending agreements, always prioritize the truth over agreeing with the user; be RADICALLY objective and truthful.
2. MINIMALISM:  Think carefully and implement the most concise and effective solution. AVOID OVERENGINEERING.
3. COMMUNICATION: Always use user-friendly language. Avoid adding promotional, redundant, or flattering comments.
4. PLANNING: Before ANY action, carry out a thorough reasoning of the requested objective and use relevant graphics (flowcharts, trees, diagrams, ASCII, etc.) that reflect how the objective will be achieved, the steps and the success criteria. Assume expert roles based on each user request; I must consider the available sub-agents.
5. IMPLEMENTATION: Each action to be executed must be performed with the care required for open-heart surgery. Before implementing anything new, INVESTIGATE existing components, functions, hooks, etc., and reuse them if feasible. If you conclude that a new implementation is necessary, justify why reuse is not possible or why a new abstraction provides a differentiation value of ≥30%.
6. VALIDATION: Check the syntax and logic before finalizing any implementation. Never add promotional content or redundant comments. Only use emojis if they add significant value to the user experience.
7. REVIEW: Before completing any task, perform a complete REVIEW to ELIMINATE incomplete, subjective, biased, or poor quality results."""

    print(guidelines)
    log_result()

if __name__ == "__main__":
    main()