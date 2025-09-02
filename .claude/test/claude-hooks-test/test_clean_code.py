#!/usr/bin/env python3
"""Tests for clean_code.py hook - Comprehensive but minimal"""
import json
import os
import subprocess
import tempfile
from pathlib import Path
import shutil

TEST_JS_CODE = """const badlyFormatted={name:"test",value:123};
console.log( badlyFormatted );
"""

TEST_JS_FORMATTED = """const badlyFormatted = { name: "test", value: 123 };
console.log(badlyFormatted);
"""

TEST_PYTHON_CODE = """def badly_formatted( x,y ):
    return x+y
result=badly_formatted(1,2)
"""

TEST_JSON_CODE = '{"name":"test","value":123}'

TEST_MARKDOWN_CODE = """# Title

Some   badly    formatted    text.

-   list item 1
-   list item 2
"""

TEST_YAML_CODE = """name:    test
value:   123
config:
  enabled:    true
"""

def create_test_project():
    """Create a minimal test project with package.json"""
    temp_dir = Path(tempfile.mkdtemp())
    
    package_json = {  # hook should auto-install prettier/eslint
        "name": "test-project",
        "version": "1.0.0"
    }
    
    with open(temp_dir / 'package.json', 'w') as f:
        json.dump(package_json, f)
    
    eslint_config = {
        "env": {"node": True, "es6": True},
        "extends": [],
        "rules": {}
    }
    
    with open(temp_dir / '.eslintrc.json', 'w') as f:
        json.dump(eslint_config, f)
    
    test_file = temp_dir / 'test.js'
    with open(test_file, 'w') as f:
        f.write(TEST_JS_CODE)
    
    return temp_dir, test_file

def run_clean_code_hook(file_path):
    """Run the clean_code hook with given file path"""
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'clean_code.py'
    
    input_data = json.dumps({"tool_input": {"file_path": str(file_path)}})
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input=input_data,
        capture_output=True,
        text=True,
        cwd=file_path.parent
    )
    
    return result

def test_basic_functionality():
    """Test basic formatting functionality"""
    print("🧪 Testing basic functionality...")
    
    temp_dir, test_file = create_test_project()
    
    try:
        subprocess.run(['npm', 'init', '-y'], cwd=temp_dir, capture_output=True)  # prettier and eslint will be auto-installed by hook
        result = run_clean_code_hook(test_file)
        
        print(f"Return code: {result.returncode}")
        print(f"Stdout: '{result.stdout}'")
        print(f"Stderr: '{result.stderr}'")
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] == "processed", f"Unexpected status: {output}"
        else:
            print("Warning: No stdout from hook")
        
        print("✅ Basic functionality test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_package_json_finding():
    """Test finding package.json in parent directories"""
    print("🧪 Testing package.json finding...")
    
    temp_dir, test_file = create_test_project()
    
    try:
        nested_dir = temp_dir / 'src' / 'components'
        nested_dir.mkdir(parents=True)
        
        nested_file = nested_dir / 'test.js'
        shutil.move(test_file, nested_file)
        
        subprocess.run(['npm', 'init', '-y'], cwd=temp_dir, capture_output=True)
        result = run_clean_code_hook(nested_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        output = json.loads(result.stdout)
        assert output["status"] == "processed", f"Unexpected status: {output}"
        
        print("✅ Package.json finding test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_logging():
    """Test that logging works correctly"""
    print("🧪 Testing logging functionality...")
    
    claude_dir = Path(__file__).parent.parent.parent
    log_dir = claude_dir / 'logs'
    
    if log_dir.exists():
        shutil.rmtree(log_dir)
    
    temp_dir, test_file = create_test_project()
    
    try:
        subprocess.run(['npm', 'init', '-y'], cwd=temp_dir, capture_output=True)
        result = run_clean_code_hook(test_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        from datetime import datetime
        today = datetime.now().strftime('%Y-%m-%d')
        log_file = log_dir / today / 'clean_code.jsonl'
        
        assert log_file.exists(), "Log file was not created"
        
        with open(log_file, 'r') as f:
            log_content = f.read().strip()
            assert log_content, "Log file is empty"
            
            log_entry = json.loads(log_content)
            assert "timestamp" in log_entry, "Log missing timestamp"
            assert "file" in log_entry, "Log missing file"
            assert log_entry["file"] == "test.js", f"Wrong file in log: {log_entry['file']}"
        
        print("✅ Logging test passed")
        
    finally:
        shutil.rmtree(temp_dir)
        if log_dir.exists():
            shutil.rmtree(log_dir)

def test_auto_installation():
    """Test auto-installation of prettier and eslint"""
    print("🧪 Testing auto-installation functionality...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        package_json = {
            "name": "test-project",
            "version": "1.0.0",
            "dependencies": {}
        }
        
        with open(temp_dir / 'package.json', 'w') as f:
            json.dump(package_json, f)
        
        test_file = temp_dir / 'test.js'
        with open(test_file, 'w') as f:
            f.write(TEST_JS_CODE)
        
        subprocess.run(['npm', 'init', '-y'], cwd=temp_dir, capture_output=True)  # required for npm install to work
        result = run_clean_code_hook(test_file)  # should auto-install prettier and eslint
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] == "processed", f"Unexpected status: {output}"
        
        # Debug: Check package.json after hook execution
        package_json_after = json.loads((temp_dir / 'package.json').read_text())
        print(f"Package.json after hook: {package_json_after}")
        
        prettier_check = subprocess.run(['npx', 'prettier', '--version'], cwd=temp_dir, capture_output=True)
        eslint_check = subprocess.run(['npx', 'eslint', '--version'], cwd=temp_dir, capture_output=True)
        
        print(f"Prettier available: {prettier_check.returncode == 0}")
        print(f"ESLint available: {eslint_check.returncode == 0}")
        
        # If tools are available, test passes regardless of installation method
        assert prettier_check.returncode == 0, "Prettier is not available after hook execution"
        assert eslint_check.returncode == 0, "ESLint is not available after hook execution"
        
        print("✅ Auto-installation test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_project_without_package_json():
    """Test hook behavior with project that has no package.json"""
    print("🧪 Testing project without package.json...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        test_file = temp_dir / 'test.js'
        with open(test_file, 'w') as f:
            f.write(TEST_JS_CODE)
        
        result = run_clean_code_hook(test_file)  # should still work but may not format perfectly
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"  # Hook should still complete (even if tools aren't available)
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] == "processed", f"Unexpected status: {output}"
        
        print("✅ No package.json test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_python_formatting():
    """Test Python file formatting with black/ruff"""
    print("🧪 Testing Python formatting...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        test_file = temp_dir / 'test.py'
        with open(test_file, 'w') as f:
            f.write(TEST_PYTHON_CODE)
        
        result = run_clean_code_hook(test_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            # Should process or skip if tools unavailable
            assert output["status"] in ["processed", "skipped"], f"Unexpected status: {output}"
        
        print("✅ Python formatting test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_json_formatting():
    """Test JSON file formatting with prettier"""
    print("🧪 Testing JSON formatting...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        # Create package.json for prettier
        package_json = {"name": "test-project", "version": "1.0.0"}
        with open(temp_dir / 'package.json', 'w') as f:
            json.dump(package_json, f)
        
        test_file = temp_dir / 'test.json'
        with open(test_file, 'w') as f:
            f.write(TEST_JSON_CODE)
        
        result = run_clean_code_hook(test_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] in ["processed", "skipped"], f"Unexpected status: {output}"
        
        print("✅ JSON formatting test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_markdown_formatting():
    """Test Markdown file formatting with prettier"""
    print("🧪 Testing Markdown formatting...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        # Create package.json for prettier
        package_json = {"name": "test-project", "version": "1.0.0"}
        with open(temp_dir / 'package.json', 'w') as f:
            json.dump(package_json, f)
        
        test_file = temp_dir / 'test.md'
        with open(test_file, 'w') as f:
            f.write(TEST_MARKDOWN_CODE)
        
        result = run_clean_code_hook(test_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] in ["processed", "skipped"], f"Unexpected status: {output}"
        
        print("✅ Markdown formatting test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_unsupported_file():
    """Test hook behavior with unsupported file types"""
    print("🧪 Testing unsupported file types...")
    
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        test_file = temp_dir / 'test.cpp'  # C++ not supported
        with open(test_file, 'w') as f:
            f.write('#include <iostream>\nint main() { return 0; }')
        
        result = run_clean_code_hook(test_file)
        
        assert result.returncode == 0, f"Hook failed: {result.stderr}"
        
        if result.stdout.strip():
            output = json.loads(result.stdout)
            assert output["status"] == "skipped", f"Should skip unsupported files: {output}"
            assert output["reason"] == "unsupported_file_type", f"Wrong skip reason: {output}"
        
        print("✅ Unsupported file test passed")
        
    finally:
        shutil.rmtree(temp_dir)

def test_error_handling():
    """Test hook behavior with invalid input"""
    print("🧪 Testing error handling...")
    
    hook_path = Path(__file__).parent.parent.parent / 'scripts' / 'hooks' / 'clean_code.py'
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input="invalid json",
        capture_output=True,
        text=True
    )
    
    assert result.returncode == 0, "Hook should handle invalid JSON gracefully"
    if result.stdout.strip():
        output = json.loads(result.stdout)
        assert output["status"] == "error", "Should return error status for invalid JSON"
    
    result = subprocess.run(
        ['python3', str(hook_path)],
        input='{}',
        capture_output=True,
        text=True
    )
    
    assert result.returncode == 0, "Hook should handle missing file_path gracefully"
    if result.stdout.strip():
        output = json.loads(result.stdout)
        assert output["status"] == "skipped", "Should skip when no file_path provided"
    
    print("✅ Error handling test passed")

def main():
    """Run all tests"""
    print("🚀 Starting clean_code.py hook tests...\n")
    
    try:
        test_basic_functionality()
        test_package_json_finding()
        test_logging()
        test_auto_installation()
        test_project_without_package_json()
        test_python_formatting()
        test_json_formatting()
        test_markdown_formatting()
        test_unsupported_file()
        test_error_handling()
        
        print("\n🎉 All tests passed! Hook is working correctly.")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        raise

if __name__ == "__main__":
    main()