#!/usr/bin/env python3
"""Tests for security_guard.py hook"""
import json
import subprocess
import tempfile
from pathlib import Path
import shutil

def run_security_guard_hook(content):
    """Run the security_guard hook with given content"""
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'security_guard.py'
    
    input_data = json.dumps({"content": content})
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input=input_data,
        capture_output=True,
        text=True
    )
    
    return result

def test_basic_functionality():
    """Test hook with clean content"""
    print("🧪 Testing basic functionality...")
    
    clean_content = """
def hello_world():
    return "Hello, World!"
    
const message: string = "Hello";
"""
    
    result = run_security_guard_hook(clean_content)
    
    assert result.returncode == 0, f"Hook failed: {result.stderr}"
    
    output = json.loads(result.stdout)
    assert output["status"] == "success", f"Expected success, got: {output}"
    assert output["summary"]["blocking"] == 0, "No blocking issues expected"
    
    print("✅ Basic functionality test passed")

def test_critical_patterns_blocking():
    """Test critical security patterns that should block"""
    print("🧪 Testing critical blocking patterns...")
    
    # Test hardcoded credentials
    credential_content = 'password = "secret123"'
    result = run_security_guard_hook(credential_content)
    assert result.returncode == 2, "Credentials should block"
    output = json.loads(result.stdout)
    assert output["status"] == "blocked"
    assert output["summary"]["blocking"] > 0
    
    # Test eval()
    eval_content = "eval(user_input)"
    result = run_security_guard_hook(eval_content)
    assert result.returncode == 2, "eval() should block"
    output = json.loads(result.stdout)
    assert output["status"] == "blocked"
    
    # Test SQL injection
    sql_content = 'query = f"SELECT * FROM users WHERE id = {user_id}"'
    result = run_security_guard_hook(sql_content)
    assert result.returncode == 2, "SQL injection should block"
    output = json.loads(result.stdout)
    assert output["status"] == "blocked"
    
    # Test command injection
    cmd_content = "subprocess.run([f'ls {user_input}'], shell=True)"
    result = run_security_guard_hook(cmd_content)
    assert result.returncode == 2, "Command injection should block"
    output = json.loads(result.stdout)
    assert output["status"] == "blocked"
    
    print("✅ Critical patterns blocking test passed")

def test_warning_patterns():
    """Test patterns that generate warnings but don't block"""
    print("🧪 Testing warning patterns...")
    
    # Test TypeScript any
    any_content = "function test(param: any): void {}"
    result = run_security_guard_hook(any_content)
    assert result.returncode == 0, "any should warn, not block"
    output = json.loads(result.stdout)
    assert output["status"] == "success"
    assert output["summary"]["warnings"] > 0
    
    # Test TODO/FIXME
    todo_content = "// TODO: Fix this later"
    result = run_security_guard_hook(todo_content)
    assert result.returncode == 0, "TODO should warn, not block"
    output = json.loads(result.stdout)
    assert output["summary"]["warnings"] > 0
    
    # Test console.log
    console_content = "console.log('debug info')"
    result = run_security_guard_hook(console_content)
    assert result.returncode == 0, "console.log should warn, not block"
    output = json.loads(result.stdout)
    assert output["summary"]["warnings"] > 0
    
    print("✅ Warning patterns test passed")

def test_complexity_patterns():
    """Test complexity detection for long functions"""
    print("🧪 Testing complexity patterns...")
    
    # Create a function with >50 lines
    long_function = "def long_function():\n" + "\n".join([f"    line_{i} = {i}" for i in range(60)])
    
    result = run_security_guard_hook(long_function)
    assert result.returncode == 0, "Long function should warn, not block"
    
    output = json.loads(result.stdout)
    assert output["status"] == "success"
    
    # Should detect the long function
    has_complexity_warning = any(
        "Function too long" in issue.get("message", "") 
        for issue in output["issues"]
    )
    assert has_complexity_warning, "Should detect long function"
    
    print("✅ Complexity patterns test passed")

def test_logging():
    """Test that logging works correctly"""
    print("🧪 Testing logging functionality...")
    
    claude_dir = Path(__file__).parent.parent.parent
    log_dir = claude_dir / 'logs'
    
    # Clean up old logs
    if log_dir.exists():
        shutil.rmtree(log_dir)
    
    test_content = 'password = "test123"'  # Should trigger blocking
    result = run_security_guard_hook(test_content)
    
    assert result.returncode == 2, f"Hook should block: {result.stderr}"
    
    # Check logging
    from datetime import datetime
    today = datetime.now().strftime('%Y-%m-%d')
    log_file = log_dir / today / 'security.jsonl'
    
    assert log_file.exists(), "Log file was not created"
    
    with open(log_file, 'r') as f:
        log_content = f.read().strip()
        assert log_content, "Log file is empty"
        
        log_entry = json.loads(log_content)
        assert "timestamp" in log_entry, "Log missing timestamp"
        assert "content_size" in log_entry, "Log missing content_size"
        assert "issues" in log_entry, "Log missing issues count"
        assert "blocking" in log_entry, "Log missing blocking count"
        assert log_entry["blocking"] > 0, "Should log blocking issues"
    
    print("✅ Logging test passed")
    
    # Clean up
    if log_dir.exists():
        shutil.rmtree(log_dir)

def test_error_handling():
    """Test hook behavior with invalid input"""
    print("🧪 Testing error handling...")
    
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'security_guard.py'
    
    # Test with invalid JSON
    result = subprocess.run(
        ['python3', str(hook_path)],
        input="invalid json",
        capture_output=True,
        text=True
    )
    
    assert result.returncode == 2, "Hook should fail with invalid JSON"
    output = json.loads(result.stdout)
    assert "error" in output, "Should return error for invalid JSON"
    
    # Test with empty input
    result = subprocess.run(
        ['python3', str(hook_path)],
        input="",
        capture_output=True,
        text=True
    )
    
    assert result.returncode == 0, "Empty input should succeed"
    output = json.loads(result.stdout)
    assert output["status"] == "success", "Empty content should succeed"
    assert len(output["issues"]) == 0, "No issues expected for empty content"
    
    print("✅ Error handling test passed")

def test_output_limiting():
    """Test that output is properly limited"""
    print("🧪 Testing output limiting...")
    
    # Create content with many issues (more than 20)
    many_issues = "\n".join([f'password = "secret{i}"' for i in range(25)])
    
    result = run_security_guard_hook(many_issues)
    
    assert result.returncode == 2, "Should block with many credentials"
    
    output = json.loads(result.stdout)
    assert len(output["issues"]) <= 20, f"Should limit to 20 issues, got {len(output['issues'])}"
    assert output["summary"]["total"] > 20, "Summary should show actual total"
    
    print("✅ Output limiting test passed")

def main():
    """Run all tests"""
    print("🚀 Starting security_guard.py hook tests...\n")
    
    try:
        test_basic_functionality()
        test_critical_patterns_blocking()
        test_warning_patterns()
        test_complexity_patterns()
        test_logging()
        test_error_handling()
        test_output_limiting()
        
        print("\n🎉 All tests passed! Hook is working correctly.")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        raise

if __name__ == "__main__":
    main()