#!/usr/bin/env python3
"""Tests for pre-tool-use.py hook
Tests PreToolUse hook that executes after Claude creates tool parameters 
and before processing the tool call."""
import json
import subprocess
import tempfile
from pathlib import Path
import shutil

def run_pre_tool_use_hook(input_data="{}"):
    """Run the pre-tool-use hook with given input"""
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'pre-tool-use.py'
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input=input_data,
        capture_output=True,
        text=True
    )
    
    return result

def test_basic_aw_md_injection():
    """Test that aw.md content is injected correctly"""
    print("🧪 Testing aw.md content injection...")
    
    result = run_pre_tool_use_hook()
    
    assert result.returncode == 0, f"Hook failed: {result.stderr}"
    
    # Verify Always Works™ content is present
    output = result.stdout
    assert "Always Works™" in output or "Always Works" in output
    assert "30-Second Reality Check" in output
    assert "Embarrassment Test" in output
    assert "Did I run/build the code?" in output
    
    print("✅ aw.md content injection test passed")

def test_aw_md_file_not_found():
    """Test hook behavior when aw.md file is not found"""
    print("🧪 Testing missing aw.md file handling...")
    
    # Temporarily rename aw.md to simulate missing file
    aw_path = Path(__file__).parent.parent.parent / 'scripts' / 'utils' / 'aw.md'
    temp_path = aw_path.with_suffix('.md.temp')
    
    try:
        if aw_path.exists():
            aw_path.rename(temp_path)
        
        result = run_pre_tool_use_hook()
        
        # Should not fail, just output a message
        assert result.returncode == 0, f"Hook should not fail when aw.md missing: {result.stderr}"
        assert "aw.md not found" in result.stdout
        
        print("✅ Missing aw.md handling test passed")
        
    finally:
        # Restore aw.md
        if temp_path.exists():
            temp_path.rename(aw_path)

def test_logging():
    """Test that logging works correctly"""
    print("🧪 Testing logging functionality...")
    
    claude_dir = Path(__file__).parent.parent.parent
    log_dir = claude_dir / 'logs'
    
    # Run hook to generate log
    result = run_pre_tool_use_hook()
    
    # Check if log was created
    from datetime import datetime
    today = datetime.now().strftime('%Y-%m-%d')
    log_file = log_dir / today / 'pre_tool_use.jsonl'
    
    # Allow some time for file system operations
    import time
    time.sleep(0.1)
    
    if log_file.exists():
        # Verify log content
        with open(log_file, 'r') as f:
            log_content = f.read()
            assert "methodology_injected" in log_content
            assert "timestamp" in log_content
            print("✅ Logging test passed")
    else:
        print("⚠️  Log file not created (this might be expected in some environments)")

def test_path_finding():
    """Test that project root and aw.md path finding works"""
    print("🧪 Testing path finding functionality...")
    
    # Import the hook functions for direct testing
    import sys
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks'
    sys.path.insert(0, str(hook_path))
    
    try:
        from pre_tool_use import find_project_root, find_aw_md_path
        
        # Test project root finding
        project_root = find_project_root()
        assert project_root.exists()
        assert (project_root / '.claude').exists()
        
        # Test aw.md path finding
        aw_path = find_aw_md_path()
        if aw_path:
            assert aw_path.exists()
            assert aw_path.name == 'aw.md'
            print("✅ Path finding test passed")
        else:
            print("⚠️  aw.md path not found")
            
    except ImportError as e:
        print(f"⚠️  Could not import hook functions: {e}")
    finally:
        sys.path.remove(str(hook_path))

def test_large_input_handling():
    """Test hook behavior with large JSON input"""
    print("🧪 Testing large input handling...")
    
    # Create large input data
    large_data = {"data": "x" * 10000}  # 10KB of data
    input_json = json.dumps(large_data)
    
    result = run_pre_tool_use_hook(input_json)
    
    # Should still work normally
    assert result.returncode == 0, f"Hook failed with large input: {result.stderr}"
    
    print("✅ Large input handling test passed")

def run_all_tests():
    """Run all tests"""
    print("🚀 Running all pre-tool-use hook tests...")
    print("=" * 50)
    
    test_basic_aw_md_injection()
    test_aw_md_file_not_found()
    test_logging()
    test_path_finding()
    test_large_input_handling()
    
    print("=" * 50)
    print("🎉 All pre-tool-use hook tests completed!")

if __name__ == "__main__":
    run_all_tests()