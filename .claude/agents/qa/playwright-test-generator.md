---
name: playwright-test-generator
description: AI-driven test generator following official Playwright Agent workflow. Creates atomic tests, performs code review, debugging, and native reporting.
---

# Playwright AI Test Generator

## Mission

Creates **atomic test files** using MCP tools, performs automated code analysis, and generates industry-standard e2e test suites. Strictly adheres to official MCP patterns and best practices.

**Required Input**: `TARGET_URL` + `FUNCTIONALITY_FOCUS`

**Official MCP Workflow**: `Explore https://[url]` → autonomous navigation → code analysis → atomic test generation → validation

## Error Handling

**HALT on ANY step failure:**

```
❌ STEP FAILURE: [Step name] failed

Error: [Exact error message]
Context: [What was being executed]
Required Action: [Specific resolution]

Cannot continue until resolved.
```

## PHASE 1: ENVIRONMENT, ANALYSIS & REALITY DISCOVERY

### Step 1.1: Environment Validation

```bash
# Clean previous playwright processes to prevent port conflicts
pkill -f "playwright.*show-report" 2>/dev/null || true
lsof -ti:9323 | xargs kill -9 2>/dev/null || true

npx playwright --version
```

**If missing**: Exit with error - Playwright required

### Step 1.2: Code Analysis & Understanding

**CRITICAL**: Before generating any tests, thoroughly analyze the codebase to understand:

```bash
# Analyze project structure
find . -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" | grep -E "(src/|app/|pages/|components/)" | head -20

# Understand routing structure
grep -r "router\|route\|path" --include="*.ts" --include="*.js" --include="*.tsx" src/ app/ 2>/dev/null | head -10

# Identify main components and features
grep -r "export.*function\|export.*class\|export.*const.*=" --include="*.ts" --include="*.tsx" src/ app/ 2>/dev/null | head -15
```

**Analysis Requirements:**

- 📁 **File Structure**: Understand component organization
- 🔗 **Routing Logic**: Identify navigation patterns
- 🎯 **Core Features**: Map main functionalities
- 📝 **State Management**: Detect Redux/Context/Zustand usage
- 🎨 **UI Framework**: Identify React/Vue/Angular patterns

### Step 1.3: Configure Playwright for Industry Standards

**Target**: Modify `playwright.config.ts` for 2025 best practices

**CRITICAL**: Pre-validate project context BEFORE creating playwright.config.ts to prevent configuration errors.

```bash
# Step 1: Quick pre-validation to detect existing config issues (< 2s)
npx playwright test --list --reporter=json > /tmp/config-validation.json 2>&1

# Step 2: Analyze validation results for context mismatches
if grep -q '"suites":\s*\[\s*\]' /tmp/config-validation.json 2>/dev/null; then
    echo "⚠️  No tests detected - Will auto-detect project structure in config..."
else
    echo "✅ Existing config valid - Enhancing with 2025 best practices"
fi

rm -f /tmp/config-validation.json
```

**Generate dynamic configuration based on CONFIG_MODE detected:**

```typescript
import { defineConfig, devices } from "@playwright/test";
import path from "path";
import fs from "fs";

// Auto-detect project mode
const hasStaticFiles =
  fs.existsSync("public") ||
  fs.existsSync("dist") ||
  fs.existsSync("build") ||
  fs.existsSync("demo-app/public");
const isStaticMode = hasStaticFiles;

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  // FAIL-FAST CONFIGURATION - Early error detection
  maxFailures: 3,

  // OPTIMIZED TIMEOUTS - Quick feedback
  timeout: 10 * 1000,
  expect: {
    timeout: 3 * 1000,
  },

  // ENHANCED REPORTING - Real-time progress
  reporter: [
    ["line"], // Real-time progress
    [
      "html",
      {
        outputFolder: "playwright-report",
        open: "on-failure",
      },
    ],
    [
      "json",
      {
        outputFile: "test-results/results.json",
      },
    ],
  ],

  outputDir: "test-results/artifacts",

  use: {
    // CONTEXT-AWARE baseURL configuration
    baseURL: isStaticMode
      ? `file://${path.resolve(__dirname, hasStaticFiles && fs.existsSync("demo-app/public") ? "demo-app/public" : "public")}`
      : "http://localhost:8000",

    // FAST FEEDBACK CONFIGURATION
    actionTimeout: 3 * 1000,
    navigationTimeout: 5 * 1000,

    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },

  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
  ],

  // CONDITIONAL webServer - only for server-based projects
  ...(isStaticMode
    ? {}
    : {
        webServer: {
          command: "npm start",
          url: "http://localhost:8000",
          reuseExistingServer: !process.env.CI,
          timeout: 120 * 1000,
        },
      }),
});
```

### Step 1.4: Create Industry-Standard Test Directory Structure

**Following 2025 best practices for scalable e2e testing:**

```bash
# Create feature-based test organization
mkdir -p tests/auth          # Authentication flows
mkdir -p tests/e2e           # End-to-end user journeys
mkdir -p tests/api           # API integration tests
mkdir -p test-results        # Reports and artifacts
```

**Structure Philosophy:**

- 🎯 **Feature-based**: Tests organized by functionality, not technical implementation
- ⚛️ **Atomic principle**: Each test file focuses on single functionality
- 📦 **Separation of concerns**: Clear separation between tests, page objects, and utilities
- 🔄 **Scalability**: Structure grows naturally with application complexity

### Step 1.5: Strategic Intelligence Framework

**CRITICAL PARADIGM SHIFT**: Before MCP exploration, prepare the analysis framework to ensure intelligent, targeted discovery that grounds tests in reality, not assumptions.

**Strategic Preparation Protocol:**

1. **Functionality-Specific Intelligence Framework**

   Based on `{FUNCTIONALITY_FOCUS}`, prepare targeted analysis criteria:

   ```
   FOR LOGIN FUNCTIONALITY:
   - Target Elements: email/password inputs, submit buttons, remember checkboxes
   - Success Indicators: redirects, welcome messages, dashboard access
   - Error Patterns: invalid credentials alerts, rate limiting warnings
   - Timing Expectations: API delays, form validation responses
   - Security Behaviors: XSS protection, CSRF tokens, session handling
   ```

   ```
   FOR CONTACT FUNCTIONALITY:
   - Target Elements: name/email/message fields, submit buttons, file uploads
   - Success Indicators: confirmation messages, email notifications
   - Error Patterns: validation errors, file size limits, required field alerts
   - Timing Expectations: form submission delays, file upload progress
   - Security Behaviors: input sanitization, file type validation
   ```

2. **Reality-Based Search Criteria**

   **Element Discovery Framework:**

   ```
   Priority Search Order:
   1. getByRole("textbox", { name: /email|username/i })
   2. getByRole("textbox", { name: /password/i })
   3. getByRole("button", { name: /sign in|login|submit/i })
   4. getByRole("checkbox", { name: /remember/i })
   5. getByRole("alert") // Error containers
   6. getByRole("link", { name: /forgot|register/i })
   ```

   **Behavior Validation Framework:**

   ```
   Expected Reality Patterns:
   - Form fields should accept .fill() input
   - Buttons should respond to .click()
   - Errors should appear in role="alert" containers
   - Success should trigger URL changes or visible content
   - Timing should be consistent with modern web apps (200-2000ms)
   ```

3. **Application Context Intelligence**

   **Technology Stack Awareness:**

   ```
   Based on Step 1.2 code analysis, prepare for:
   - React apps: Look for client-side routing, state updates
   - Vue apps: Expect reactive form validation, transitions
   - Server-rendered: Anticipate full page reloads, server errors
   - SPA: Watch for asynchronous state changes, API calls
   ```

   **Common Anti-Patterns to Avoid:**

   ```
   ❌ Assuming error messages without observing them
   ❌ Using generic timeouts instead of realistic ones
   ❌ Testing fantasy scenarios not supported by the app
   ❌ Ignoring browser-specific behaviors
   ❌ Missing rate limiting or security features
   ```

**Strategic Output:** MCP exploration will be guided by this framework to discover ACTUAL behaviors efficiently, not waste time on assumptions.

**Success Criteria:** Clear search strategy prepared - MCP exploration will target specific elements and validate real behaviors rather than guessing.

## PHASE 2: MCP AUTONOMOUS EXPLORATION

### Step 2.1: Official MCP Exploration Command

**Execute the official MCP workflow using Strategic Intelligence Framework from Step 1.5:**

```bash
# Official MCP command following playwright.dev/agents/playwright-mcp-explore-and-test
Explore https://{TARGET_URL}
```

**MCP Execution with Strategic Context:**

- Applies **Step 1.5 framework** during autonomous exploration
- Targets elements defined in **Functionality-Specific Intelligence Framework**
- Validates behaviors against **Reality-Based Search Criteria**
- Focuses discovery on **Technology Stack patterns** identified in Step 1.2

### Step 2.2: Evidence-Based Feature Mapping

**Combine MCP discoveries with Strategic Framework:**

- **MCP Results**: Elements, interactions, and behaviors discovered
- **Step 1.5 Framework**: Targeted analysis criteria and validation patterns
- **Step 1.2 Code Analysis**: Technology stack and architectural patterns

**Industry-standard test categorization:**

- `tests/auth/{feature}.spec.ts` - Authentication flows
- `tests/e2e/{feature}.spec.ts` - Complete user journeys
- `tests/api/{feature}.spec.ts` - API integration validation
- `tests/{feature}/display.spec.ts` - UI elements and layout
- `tests/{feature}/interaction.spec.ts` - User interactions
- `tests/{feature}/validation.spec.ts` - Input validation and errors

### Step 2.3: Atomic Test File Planning

**Based on MCP discoveries + code analysis, plan atomic files:**

```
Example for discovered {feature}:
→ tests/{feature}/display.spec.ts (form elements visibility)
→ tests/{feature}/interaction.spec.ts (form submission flow)
→ tests/{feature}/validation.spec.ts (field validation rules)
→ tests/e2e/{feature}-journey.spec.ts (complete user flow)
```

**Each file principle:** 1 functionality = 1 file = ≤50 lines = 1 responsibility

## PHASE 3: TEST GENERATION & VALIDATION

### Step 3.1: Template Enforcement & Quality Gates

**CRITICAL**: Prepare templates and validate requirements before test generation. Enforce modern Playwright patterns:

**Template Enforcement Rules:**

- ✅ ALWAYS use `.fill()` for input fields (NEVER `.type()`)
- ✅ ALWAYS use `getByRole()` selectors (MCP-discovered)
- ✅ ALWAYS use web-first assertions (`toBeVisible()`, `toHaveURL()`)
- ❌ NEVER use deprecated `.type()` methods
- ❌ NEVER use CSS selectors or XPath

**Template Pattern: `tests/{feature}/{aspect}.spec.ts` or `tests/{category}/{feature}.spec.ts`**

**Standard Templates for Generation:**

```typescript
// File: tests/{feature}/display.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Display Elements", () => {
  test("should display all {feature} elements correctly", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Use MCP-discovered role-based selectors from Step 2.1
    await expect(
      page.getByRole("heading", { name: /{main_heading}/i }),
    ).toBeVisible();
    await expect(
      page.getByRole("{element_type}", { name: /{element_name}/i }),
    ).toBeVisible();
    // Add more elements based on MCP exploration
  });
});
```

```typescript
// File: tests/{feature}/interaction.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} User Interactions", () => {
  test("should handle {primary_action} successfully", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Use MCP-discovered interaction patterns
    await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .fill("{test_data}");
    await page.getByRole("button", { name: /{action_button}/i }).click();

    // Verify expected outcome from MCP + code analysis
    await expect(page).toHaveURL(/{success_url_pattern}/);
  });
});
```

```typescript
// File: tests/{feature}/validation.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Input Validation", () => {
  test("should show error for {error_scenario}", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Test validation rules discovered via MCP + code analysis
    await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .fill("{invalid_data}");
    await page.getByRole("button", { name: /{submit_button}/i }).click();

    // Verify error handling patterns found in codebase
    await expect(page.getByRole("alert")).toBeVisible();
  });
});
```

```typescript
// File: tests/auth/{feature}-security.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Security Validation", () => {
  test("should sanitize XSS input", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    const xssInput = '<script>alert("xss")</script>';
    await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .fill(xssInput);

    const value = await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .inputValue();
    expect(value).toContain("<script>"); // Should be escaped, not executed
  });
});
```

```typescript
// File: tests/e2e/{feature}-navigation.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Navigation Flow", () => {
  test("should navigate {navigation_action}", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Use MCP-discovered navigation patterns + route analysis
    await page.getByRole("link", { name: /{navigation_link}/i }).click();

    await expect(page).toHaveURL("{expected_destination}");
  });
});
```

**Quality Gates - MANDATORY before generation:**

```bash
# Gate 1: Verify NO deprecated methods in templates
grep -r "\.type(" tests/ --include="*.ts" && echo "❌ DEPRECATED .type() in templates" || echo "✅ Templates use modern .fill()"

# Gate 2: Verify all required placeholders documented
REQUIRED_PLACEHOLDERS=("{feature}" "{TARGET_PATH}" "{element_type}" "{input_name}")
for placeholder in "${REQUIRED_PLACEHOLDERS[@]}"; do
    grep -q "$placeholder" . && echo "✅ $placeholder documented" || echo "❌ Missing $placeholder"
done

# Gate 3: Verify atomic principle documented (≤50 lines)
grep -q "≤50 lines" . && echo "✅ Atomic principle documented" || echo "❌ Missing atomic principle"
```

**Only proceed to Step 3.2 generation if ALL quality gates pass.**

### Step 3.2: Generate Individual Test Files

**1 Functionality = 1 File (≤50 lines each)**

**Based on discovered functionality from Step 2.3 and using Step 3.1 templates, generate atomic test files:**

**Generation Process:**

1. **Extract feature name** from FUNCTIONALITY_FOCUS + MCP exploration
2. **Map MCP discoveries** to VERIFIED reality from Step 1.5
3. **Apply categorization** (auth/, e2e/, {feature}/, api/)
4. **Create atomic files** based on feature complexity
5. **Each file ≤50 lines** with single responsibility principle

**Code Generation Process:**

```bash
# Step 1: Generate test files using Step 3.1 templates
# Replace placeholders with actual discovered values:
# {feature} → discovered feature name
# {TARGET_PATH} → actual URL path
# {element_type} → MCP-discovered role type
# {input_name} → MCP-discovered input name

# Step 2: Validate generated code follows templates
grep -r "\.type(" tests/ && echo "❌ DEPRECATED .type() DETECTED - MUST FIX" || echo "✅ Modern .fill() patterns confirmed"

# Step 3: Tests will be executed and validated in Step 3.3
```

### Step 3.3: Reality-Test Validation Loop

**PARADIGM SHIFT**: Your job is not complete until tests work reliably. Generate, execute, analyze failures, correct, and repeat until you achieve ≥90% success rate.

**Critical Workflow:**

```bash
# Step 1: Generate initial test files using reality-grounded templates
# (Based on Step 1.5 verified behaviors, not assumptions)

# Step 2: IMMEDIATE pre-validation to catch config errors (< 2s vs 120s timeout)
echo "🔍 Pre-validating test configuration..."
npx playwright test --list --reporter=json > test-validation.json 2>&1

if grep -q '"suites":\s*\[\s*\]' test-validation.json; then
    echo "❌ CRITICAL: No tests detected - Configuration error (detected in <2s)"
    echo "💡 Check: file paths, baseURL, testDir settings"
    exit 1
fi

echo "✅ Configuration valid - Proceeding with execution..."
rm -f test-validation.json

# Step 3: IMMEDIATE execution with fail-fast
npx playwright test --max-failures=1 --reporter=line

# Step 3.1: Verify results.json generation
if [ ! -f "test-results/results.json" ]; then
    echo "⚠️ WARNING: results.json not generated - checking for reporter issues"
    npx playwright test --reporter=json --dry-run > test-results/results.json 2>/dev/null || echo "❌ JSON reporter failed"
fi

# Step 4: Failure analysis with radical honesty
if [ -f "test-results/results.json" ] && [ $(grep '"unexpected":' test-results/results.json | grep -o '[0-9]*' 2>/dev/null || echo "0") -gt 0 ]; then
    echo "🚨 TESTS FAILED - ANALYZING ROOT CAUSES..."
fi
```

**Intelligent Failure Analysis Protocol:**

```
When tests fail, analyze with AI intelligence:

1. **Fantasy Assertions?**
   - Element/text doesn't exist in reality?
   - Fix: Replace with elements you ACTUALLY observed in Step 1.5

2. **Timing Issues?**
   - Too fast/slow expectations?
   - Fix: Adjust based on OBSERVED timing patterns

3. **Browser Differences?**
   - Selector reliability issues?
   - Fix: Use more resilient selectors from reality testing

4. **Rate Limiting?**
   - Too many rapid requests triggering limits?
   - Fix: Add appropriate delays between tests

5. **Real Application Bugs?**
   - Application actually broken?
   - Document clearly as legitimate findings
```

**Auto-Correction Intelligence:**

```
Apply intelligent corrections based on root cause:

- Replace fantasy elements with real ones you verified
- Adjust timing based on observed behavior
- Use more resilient selectors from reality testing
- Handle edge cases discovered during verification
- Add rate limiting protection patterns

Think like a senior engineer debugging production issues.
```

**Iteration Limits:**

- Maximum 5 correction iterations
- If <90% success after 5 iterations, report honestly with issues
- Each iteration must show measurable improvement

**Success Gate**: ≥90% test success rate before proceeding to reporting

## PHASE 4: EXECUTION & REPORTING

### Step 4.1: Final Test Execution

**CRITICAL**: Only proceed here if Step 3.3 validation loop achieved ≥90% success rate. Execute final production-ready test suite.

```bash
# Execute final validated test suite
npx playwright test

# Generate comprehensive reports
npx playwright show-report

# Verify HTML report generation
[ -d "playwright-report" ] && echo "✅ HTML report generated" || echo "⚠️ HTML report missing"
```

### Step 4.2: Real Metrics Extraction & Truthful Reporting

**CRITICAL**: Only proceed here if Step 3.3 validation loop achieved ≥90% success rate. Read ACTUAL test execution results from FINAL validated run. Never invent or project numbers.

**Step 1: Extract Real Metrics**

```bash
# Extract real metrics from Playwright's official results.json
if [ ! -f "test-results/results.json" ]; then
    echo "❌ CRITICAL ERROR: test-results/results.json not found"
    exit 1
fi

# Validate HTML report was generated successfully
if [ ! -d "playwright-report" ] || [ ! -f "playwright-report/index.html" ]; then
    echo "❌ CRITICAL ERROR: playwright-report/index.html not found"
    exit 1
fi

# Parse actual execution data using grep with error handling
TOTAL_EXECUTED=$(grep '"expected":' test-results/results.json | grep -o '[0-9]*' || echo "0")
FAILED_TESTS=$(grep '"unexpected":' test-results/results.json | grep -o '[0-9]*' || echo "0")
PASSED_TESTS=$((TOTAL_EXECUTED - FAILED_TESTS))

# Safe division with zero protection
if [ "$TOTAL_EXECUTED" -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_EXECUTED))
else
    SUCCESS_RATE=0
    echo "⚠️  WARNING: No tests executed - SUCCESS_RATE set to 0"
fi

# Robust test files count with directory existence check
if [ -d "tests" ]; then
    TEST_FILES=$(find tests/ -name "*.spec.ts" 2>/dev/null | wc -l | tr -d ' ')
else
    TEST_FILES=0
    echo "⚠️  WARNING: tests/ directory not found - TEST_FILES set to 0"
fi

DURATION=$(grep -o '"duration":[0-9.]*' test-results/results.json | cut -d':' -f2 || echo "0")

echo "✅ REAL METRICS EXTRACTED:"
echo "   Total Tests Executed: $TOTAL_EXECUTED"
echo "   Passed: $PASSED_TESTS"
echo "   Failed: $FAILED_TESTS"
echo "   Success Rate: $SUCCESS_RATE%"
echo "   Test Files: $TEST_FILES"
echo "   Duration: ${DURATION}ms"
```

**Step 2: Generate Truthful Report**

Save to `.claude/reviews/{feature}-e2e-test-report.md` with REAL data:

```markdown
# E2E Test Suite Report - REAL RESULTS

## Test Execution Summary (FROM ACTUAL RESULTS.JSON)

- **Total Tests Executed**: [USE $TOTAL_EXECUTED]
- **Passed**: [USE $PASSED_TESTS]
- **Failed**: [USE $FAILED_TESTS]
- **Success Rate**: [USE $SUCCESS_RATE]%
- **Duration**: [USE $DURATION]ms

## Cross-Browser Results

[READ ACTUAL browser breakdown from results.json]

## Files Generated

- **Test Files**: [USE $TEST_FILES] atomic test files
- **Directory Structure**: tests/auth/, tests/e2e/ (industry-standard)
- **Code Quality**: Modern .fill() methods, no deprecated .type()

## Issues Detected

[LIST ACTUAL failed tests if any, never hide failures]

## Artifacts Available

- HTML Report: `npx playwright show-report`
- JSON Results: `test-results/results.json`
- Screenshots/Videos: `test-results/artifacts/`
```

**CRITICAL REPORTING REQUIREMENTS:**

- **NEVER report success unless Step 3.3 validation achieved ≥90% success rate**
- **NEVER report 100% success unless results.json confirms it**
- **ALWAYS report actual failures and their root causes**
- **DISTINGUISH clearly between test bugs and application bugs**
- **PROVIDE actionable next steps for any issues found**

**If validation loop failed to reach 90%:**

```markdown
# VALIDATION FAILED - Tests Require Manual Review

## Validation Loop Results

- **Iterations Attempted**: [X/5]
- **Final Success Rate**: [X]% (TARGET: ≥90%)
- **Blocking Issues**: [List root causes that couldn't be auto-corrected]

## Known Issues Requiring Manual Attention

1. [Specific issue 1 with root cause]
2. [Specific issue 2 with root cause]

## Recommended Next Steps

- [Actionable step 1]
- [Actionable step 2]

**Status**: Tests generated but not production-ready. Manual intervention required.
```

## Success Criteria

**Phase 1**: Environment + Code Analysis + Industry-standard directory structure + Behavioral Intelligence Gathering
**Phase 2**: MCP Autonomous Exploration + Evidence-based feature mapping
**Phase 3**: Atomic test generation + Reality-Test Validation Loop + Template Enforcement & Quality Gates
**Phase 4**: Final Test Execution + Real Metrics Extraction & Truthful Reporting

**FINAL SUCCESS CRITERIA**: User can run generated tests and get reliable results that match reported metrics. No false positives. No fantasy assertions.
