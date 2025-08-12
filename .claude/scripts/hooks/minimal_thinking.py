#!/usr/bin/env python3
"""
Minimal Thinking Enhancer - Prevents superficial agreement and over-engineering
"""
import json
import re
from pathlib import Path
from common import read_stdin_json, log_event

# Detection patterns
AGREEMENT_PATTERNS = [
    r"(?i)\byou('re|'re|'s|r|re)?\s+(right|correct|absolutely)",
    r"(?i)\byou\s+are\s+(right|correct|absolutely)",
    r"(?i)\btienes?\s+razón",
    r"(?i)\b(exacto|correcto|así es)\b"
]

OVERENGINEERING_INDICATORS = [
    r"(?i)\b(enterprise|scalable|robust|powerful|optimized)\b",
    r"(?i)\b(state-of-the-art|production-ready|battle-tested)\b",
    r"🚀{2,}|✨{2,}|💡{2,}"  # Excessive emojis
]

def check_recent_responses(transcript_path):
    """Analyze recent assistant responses for problematic patterns"""
    if not transcript_path or not Path(transcript_path).exists():
        return {"agreement": False, "verbose": False}
    
    try:
        with open(transcript_path, 'r') as f:
            content = f.read()
            
        # Get last 5 assistant messages
        assistant_msgs = []
        for line in content.split('\n'):
            if '"role":"assistant"' in line and line.strip():
                try:
                    msg = json.loads(line)
                    # Handle different message formats
                    if msg.get('type') == 'text':
                        assistant_msgs.append(msg.get('text', ''))
                    elif 'message' in msg and 'content' in msg['message']:
                        # Claude transcript format
                        content_item = msg['message']['content'][0] if isinstance(msg['message']['content'], list) else msg['message']['content']
                        if isinstance(content_item, dict) and content_item.get('type') == 'text':
                            assistant_msgs.append(content_item.get('text', ''))
                except:
                    continue
        
        recent = assistant_msgs[-5:] if assistant_msgs else []
        
        # Check for agreement patterns
        agreement = any(
            re.search(pattern, text[:200]) 
            for text in recent 
            for pattern in AGREEMENT_PATTERNS
        )
        
        # Check for verbosity/marketing
        verbose = any(
            len(re.findall(pattern, text)) > 2
            for text in recent
            for pattern in OVERENGINEERING_INDICATORS
        )
        
        return {"agreement": agreement, "verbose": verbose}
    except:
        return {"agreement": False, "verbose": False}

def generate_reminder(issues):
    """Generate contextual reminder based on detected issues"""
    # ALWAYS include minimal philosophy
    base_reminder = """
PHILOSOPHY: Minimal, simple, deep
- Simplest working solution > complex abstractions
- Comments only for non-obvious logic  
- No marketing language or excessive emojis
- Direct technical responses, no empty agreement"""
    
    additional = []
    
    if issues["agreement"]:
        additional.append("⚠️ Recent 'you're right' detected - provide technical analysis instead")
    
    if issues["verbose"]:
        additional.append("⚠️ Recent over-engineering detected - simplify approach")
    
    # Always return philosophy, with warnings if issues detected
    extras = "\n".join(additional) if additional else ""
        
    return f"""<system-reminder>
{base_reminder}
{extras}

Good: "Map avoids O(n²)" | "Null check for edge case"
Avoid: "You're right!" | "Enterprise solution" | "// i++"
</system-reminder>"""

def main():
    data = read_stdin_json()
    transcript_path = data.get("transcript_path")
    prompt = data.get("prompt", "")[:100]  # First 100 chars for logging
    
    issues = check_recent_responses(transcript_path)
    
    # ALWAYS generate reminder (philosophy + warnings if needed)
    reminder = generate_reminder(issues)
    
    # Log what we detected and applied
    log_event("minimal_thinking.jsonl", {
        "hook_event_name": "UserPromptSubmit",
        "prompt_preview": prompt,
        "issues_detected": issues,
        "reminder_applied": "minimal_philosophy",
        "warnings_added": {
            "agreement": issues.get("agreement", False),
            "verbose": issues.get("verbose", False)
        }
    })
    
    print(json.dumps({
        "suppressOutput": True,
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": reminder
        }
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()