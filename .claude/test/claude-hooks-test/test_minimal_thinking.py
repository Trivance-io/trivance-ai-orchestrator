#!/usr/bin/env python3
"""Tests for minimal_thinking.py hook"""
import json
import subprocess
import tempfile
from pathlib import Path
import shutil

def run_minimal_thinking_hook(input_data):
    """Run the minimal_thinking hook with given input"""
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'minimal_thinking.py'
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input=input_data,
        capture_output=True,
        text=True
    )
    
    return result

def test_basic_guidelines_injection():
    """Test that behavioral guidelines are injected correctly"""
    print("🧪 Testing basic guidelines injection...")
    
    input_data = json.dumps({"test": "prompt"})
    result = run_minimal_thinking_hook(input_data)
    
    assert result.returncode == 0, f"Hook failed: {result.stderr}"
    
    # Verify all 4 guidelines are present
    output = result.stdout
    assert "EXPERT BEHAVIORAL GUIDELINES ACTIVATED" in output
    assert "OBJECTIVITY" in output
    assert "MINIMALISM" in output  
    assert "CLARITY" in output
    assert "VALIDATION" in output
    
    print("✅ Basic guidelines injection test passed")

def test_logging():
    """Test that logging works correctly"""
    print("🧪 Testing logging functionality...")
    
    claude_dir = Path(__file__).parent.parent.parent
    log_dir = claude_dir / 'logs'
    
    # Clean up old logs
    if log_dir.exists():
        shutil.rmtree(log_dir)
    
    input_data = json.dumps({"test": "prompt"})
    result = run_minimal_thinking_hook(input_data)
    
    assert result.returncode == 0, f"Hook failed: {result.stderr}"
    
    # Check logging
    from datetime import datetime
    today = datetime.now().strftime('%Y-%m-%d')
    log_file = log_dir / today / 'minimal_thinking.jsonl'
    
    assert log_file.exists(), "Log file was not created"
    
    with open(log_file, 'r') as f:
        log_content = f.read().strip()
        assert log_content, "Log file is empty"
        
        log_entry = json.loads(log_content)
        assert "timestamp" in log_entry, "Log missing timestamp"
        assert "guidelines_injected" in log_entry, "Log missing guidelines_injected"
        assert log_entry["guidelines_injected"] == True, "Guidelines not marked as injected"
    
    print("✅ Logging test passed")
    
    # Clean up
    if log_dir.exists():
        shutil.rmtree(log_dir)

def test_error_handling():
    """Test hook behavior with invalid input"""
    print("🧪 Testing error handling...")
    
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'minimal_thinking.py'
    
    # Test with invalid JSON
    result = subprocess.run(
        ['python3', str(hook_path)],
        input="invalid json",
        capture_output=True,
        text=True
    )
    
    # Should exit gracefully without blocking
    assert result.returncode == 0, "Hook should not block Claude with invalid JSON"
    
    # Test with empty input
    result = subprocess.run(
        ['python3', str(hook_path)],
        input="",
        capture_output=True,
        text=True
    )
    
    # Should exit gracefully without blocking
    assert result.returncode == 0, "Hook should not block Claude with empty input"
    
    print("✅ Error handling test passed")

def test_silent_fail():
    """Test that hook fails silently and doesn't block Claude"""
    print("🧪 Testing silent fail behavior...")
    
    # Test various malformed inputs
    test_inputs = [
        "not json at all",
        '{"malformed": json}',
        ""
    ]
    
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'minimal_thinking.py'
    
    for test_input in test_inputs:
        result = subprocess.run(
            ['python3', str(hook_path)],
            input=test_input,
            capture_output=True,
            text=True
        )
        
        # All should exit with code 0 (silent fail)
        assert result.returncode == 0, f"Hook should fail silently for input: {test_input}"
    
    print("✅ Silent fail test passed")

def main():
    """Run all tests"""
    print("🚀 Starting minimal_thinking.py hook tests...\n")
    
    try:
        test_basic_guidelines_injection()
        test_logging()
        test_error_handling()
        test_silent_fail()
        
        print("\n🎉 All tests passed! Hook is working correctly.")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        raise

if __name__ == "__main__":
    main()