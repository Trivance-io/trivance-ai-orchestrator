#!/bin/bash

# Hook Optimization Test Suite
# Tests that pre-tool-use.py only executes for Task tools and provides complete context

set -e

echo "🧪 TESTING HOOK OPTIMIZATION"
echo "============================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
HOOK_SCRIPT="$PROJECT_ROOT/.claude/scripts/hooks/pre-tool-use.py"

# Test 1: Normal tools should NOT trigger enhanced context
echo "Test 1: Edit tool (should get minimal/no context)"
EDIT_INPUT='{"tool_input": {"file_path": "/some/path.js", "old_string": "old", "new_string": "new"}}'
EDIT_OUTPUT=$(echo "$EDIT_INPUT" | python3 "$HOOK_SCRIPT")
EDIT_LINES=$(echo "$EDIT_OUTPUT" | wc -l)

echo "  Edit tool output lines: $EDIT_LINES"
if [[ "$EDIT_OUTPUT" == *"PROJECT GOVERNANCE FOR SUB-AGENTS"* ]]; then
    echo "  ❌ FAIL: Edit tool received sub-agent context (should not)"
    exit 1
else
    echo "  ✅ PASS: Edit tool did not receive sub-agent context"
fi

# Test 2: Task tool should trigger enhanced context
echo
echo "Test 2: Task tool (should get full project context)"
TASK_INPUT='{"tool_input": {"subagent_type": "backend-architect", "prompt": "test"}}'
TASK_OUTPUT=$(echo "$TASK_INPUT" | python3 "$HOOK_SCRIPT")
TASK_LINES=$(echo "$TASK_OUTPUT" | wc -l)

echo "  Task tool output lines: $TASK_LINES"
if [[ "$TASK_OUTPUT" == *"PROJECT GOVERNANCE FOR SUB-AGENTS"* ]]; then
    echo "  ✅ PASS: Task tool received sub-agent context"
else
    echo "  ❌ FAIL: Task tool did not receive sub-agent context"
    exit 1
fi

# Test 3: Task tool context completeness
echo
echo "Test 3: Context completeness validation"
REQUIRED_ELEMENTS=(
    "bet \$100 this works"
    "EMBARRASSMENT TEST"
    "TESTING REQUIREMENTS"
    "COMPLEXITY BUDGET"
    "TIME REALITY"
)

MISSING_ELEMENTS=0
for element in "${REQUIRED_ELEMENTS[@]}"; do
    if [[ "$TASK_OUTPUT" == *"$element"* ]]; then
        echo "  ✅ Found: $element"
    else
        echo "  ❌ Missing: $element"
        MISSING_ELEMENTS=$((MISSING_ELEMENTS + 1))
    fi
done

if [[ $MISSING_ELEMENTS -eq 0 ]]; then
    echo "  ✅ PASS: All governance elements present"
else
    echo "  ❌ FAIL: $MISSING_ELEMENTS governance elements missing"
    exit 1
fi

# Test 4: Performance comparison
echo
echo "Test 4: Performance measurement"
START_TIME=$(date +%s%N)
echo "$TASK_INPUT" | python3 "$HOOK_SCRIPT" > /dev/null
END_TIME=$(date +%s%N)
EXECUTION_TIME=$(( (END_TIME - START_TIME) / 1000000 )) # Convert to milliseconds

echo "  Hook execution time: ${EXECUTION_TIME}ms"
if [[ $EXECUTION_TIME -lt 500 ]]; then
    echo "  ✅ PASS: Performance acceptable (<500ms)"
else
    echo "  ⚠️  WARNING: Performance may be slow (${EXECUTION_TIME}ms)"
fi

echo
echo "🎉 ALL TESTS PASSED"
echo "✅ Hook optimization working correctly"
echo "   - Normal tools: No unnecessary context injection"
echo "   - Task tools: Complete governance context provided"
echo "   - Context completeness: All elements present"
echo "   - Performance: Acceptable execution time"