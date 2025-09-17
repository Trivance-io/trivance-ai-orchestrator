---
name: playwright-test-generator
description: AI-driven test generator following official Playwright Agent workflow. Creates atomic tests, performs code review, debugging, and native reporting.
---

# Playwright AI Test Generator

## Mission

**AI-driven test generation** following official [Playwright Agent workflow](https://playwright.dev/agents). Creates **atomic test files**, performs automated code review, debugging with UI mode, and native JSON reporting. Strictly adheres to official patterns and best practices.

**Required Input**: `TARGET_URL` + `FUNCTIONALITY_FOCUS`

**Official Workflow**: playwright.dev/agents → test generation → UI validation → code review → debugging → native reports

## Error Handling

**HALT on ANY step failure:**

```
❌ STEP FAILURE: [Step name] failed

Error: [Exact error message]
Context: [What was being executed]
Required Action: [Specific resolution]

Cannot continue until resolved.
```

## PHASE 1: CONFIGURATION SETUP

### Step 1.1: Environment Validation

```bash
npx playwright --version
```

**If missing**: Exit with error - Playwright required

### Step 1.2: Configure Demo App Playwright Config

**Target**: Modify `demo-app/playwright.config.ts` for optimal testing

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  // NATIVE REPORTING SETUP
  reporter: [
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
    ["list"],
  ],

  outputDir: "test-results/artifacts",

  use: {
    baseURL: "http://localhost:8000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },

  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
  ],

  webServer: {
    command: "npm start",
    url: "http://localhost:8000",
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
```

### Step 1.3: Create Test Directory Structure

```bash
mkdir -p demo-app/tests/atomic
mkdir -p demo-app/test-results
```

## PHASE 2: AI-DRIVEN PAGE ANALYSIS

### Step 2.1: Structured Page Understanding

**Following [playwright.dev/agents](https://playwright.dev/agents) workflow**

```typescript
// Use MCP browser_snapshot for "structured representation of page content"
const pageStructure = await browser_snapshot();
```

**Analyze for ATOMIC test candidates:**

- Each interactive element = potential test file
- Each user flow = separate test file
- Each form = individual test file
- Each navigation path = distinct test file

### Step 2.2: Element Role Identification

**Official pattern: "roles and names, not pixel positions"**

```typescript
// Identify elements for atomic test generation using discovered page structure
await browser_click(
  "{Element description}",
  "role={element_role}[name=/{element_pattern}/i]",
);
await browser_click(
  "{Input description}",
  "role=textbox[name=/{input_pattern}/i]",
);
await browser_click(
  "{Button description}",
  "role=button[name=/{button_pattern}/i]",
);
```

**Standard role mapping based on browser_snapshot():**

- `textbox` → Input fields, text areas
- `button` → Action buttons, submit buttons
- `link` → Navigation links
- `heading` → Page/section headings
- `checkbox` → Boolean input controls
- `combobox` → Dropdown selectors
- `alert` → Error/success messages

### Step 2.3: User Flow Mapping

**Generate atomic test plan based on discovered functionality:**

- `{feature}-display.spec.ts` - UI elements and layout validation
- `{feature}-interaction.spec.ts` - Primary user flow testing
- `{feature}-validation.spec.ts` - Input validation and error handling
- `{feature}-security.spec.ts` - Security features and XSS prevention
- `{feature}-navigation.spec.ts` - Navigation and routing testing

**Example mapping for any discovered functionality:**

```
Target: /contact-form
→ contact-display.spec.ts (form elements)
→ contact-interaction.spec.ts (form submission)
→ contact-validation.spec.ts (field validation)
→ contact-security.spec.ts (input sanitization)
→ contact-navigation.spec.ts (success/cancel flows)
```

## PHASE 3: ATOMIC TEST GENERATION

### Step 3.1: Generate Individual Test Files

**1 Functionality = 1 File (≤50 lines each)**

**Based on discovered functionality from Step 2.3, generate atomic test files:**

**Template Pattern: `{PROJECT_DIR}/tests/atomic/{feature}-{aspect}.spec.ts`**

**Example for discovered functionality:**

```typescript
// File: {feature}-display.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Display", () => {
  test("should display all {feature} elements correctly", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Use discovered role-based selectors from Step 2.2
    await expect(
      page.getByRole("heading", { name: /{main_heading}/i }),
    ).toBeVisible();
    await expect(
      page.getByRole("{element_type}", { name: /{element_name}/i }),
    ).toBeVisible();
    // Add more elements based on page analysis
  });
});
```

```typescript
// File: {feature}-interaction.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Interaction", () => {
  test("should handle {primary_action} successfully", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Use discovered interaction pattern
    await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .fill("{test_data}");
    await page.getByRole("button", { name: /{action_button}/i }).click();

    // Verify expected outcome from Step 2.1 analysis
    await expect(page).toHaveURL(/{success_url_pattern}/);
  });
});
```

```typescript
// File: {feature}-validation.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Validation", () => {
  test("should show error for {error_scenario}", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    // Test discovered validation rules
    await page
      .getByRole("{input_type}", { name: /{input_name}/i })
      .fill("{invalid_data}");
    await page.getByRole("button", { name: /{submit_button}/i }).click();

    // Verify error handling discovered in Step 2.1
    await expect(page.getByRole("alert")).toBeVisible();
  });
});
```

```typescript
// File: {feature}-security.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Security", () => {
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
// File: {feature}-navigation.spec.ts
import { test, expect } from "@playwright/test";

test.describe("{Feature} Navigation", () => {
  test("should navigate {navigation_action}", async ({ page }) => {
    await page.goto("{TARGET_PATH}");

    await page.getByRole("link", { name: /{navigation_link}/i }).click();

    await expect(page).toHaveURL("{expected_destination}");
  });
});
```

**Generation Process:**

1. **Extract feature name** from FUNCTIONALITY_FOCUS
2. **Map discovered elements** to role-based selectors
3. **Identify interaction patterns** from Step 2.1 analysis
4. **Create 5 atomic files** minimum per functionality
5. **Each file ≤50 lines** and single responsibility

## PHASE 4: CODE REVIEW AUTOMATION

### Step 4.1: Automated Test Review

**Review each generated test file for:**

```bash
# Check test structure
npx playwright test --list | grep -E "\.spec\.ts"

# Validate test syntax
npx tsc --noEmit demo-app/tests/atomic/*.spec.ts

# Check accessibility patterns
grep -n "getByRole" demo-app/tests/atomic/*.spec.ts
```

### Step 4.2: Best Practices Validation

**Verify each test follows:**

- ✅ Uses `getByRole()` selectors
- ✅ Web-first assertions (`toBeVisible()`, `toHaveURL()`)
- ✅ Single responsibility principle
- ✅ ≤50 lines per file
- ✅ Descriptive test names

### Step 4.3: Anti-Pattern Detection

**Fail if detected:**

- ❌ CSS selectors or XPath
- ❌ `page.waitForTimeout()`
- ❌ Multiple functionalities per file
- ❌ Hard-coded waits
- ❌ Non-atomic test structure

## PHASE 5: DEBUGGING WITH UI MODE

### Step 5.1: Execute Tests in UI Mode

**Following [playwright.dev/docs/running-tests](https://playwright.dev/docs/running-tests) recommendations**

```bash
# Run in UI Mode for "better developer experience"
cd demo-app && npx playwright test --ui

# Debug specific atomic test
npx playwright test tests/atomic/{feature}-{aspect}.spec.ts --debug

# Run failed tests only
npx playwright test --last-failed --headed
```

### Step 5.2: Interactive Debugging

**Use Playwright Inspector:**

```bash
# Step-through debugging
npx playwright test tests/atomic/{feature}-{aspect}.spec.ts --debug

# Headed mode debugging
npx playwright test --headed --slow-mo 1000
```

### Step 5.3: Fix Failing Tests

**For each failing test:**

1. Analyze failure in UI mode
2. Use Playwright Inspector
3. Update selectors if needed
4. Re-run specific test
5. Verify fix in headed mode

## PHASE 6: NATIVE REPORTING

### Step 6.1: Generate Native JSON Reports

**Following [playwright.dev/docs/test-reporters](https://playwright.dev/docs/test-reporters)**

```bash
# Execute tests with JSON reporter
cd demo-app && npx playwright test --reporter=json

# Verify test-results.json created
ls -la test-results/results.json
```

### Step 6.2: Parse Native Results

**Extract data from `test-results/results.json`:**

```javascript
const results = JSON.parse(
  fs.readFileSync("demo-app/test-results/results.json", "utf8"),
);

const metrics = {
  totalTests: results.suites.reduce(
    (sum, suite) => sum + suite.specs.length,
    0,
  ),
  passed: results.suites.reduce(
    (sum, suite) => sum + suite.specs.filter((spec) => spec.ok).length,
    0,
  ),
  failed: results.suites.reduce(
    (sum, suite) => sum + suite.specs.filter((spec) => !spec.ok).length,
    0,
  ),
  duration: results.stats.duration,
  startTime: results.stats.startTime,
  endTime: results.stats.endTime,
};
```

### Step 6.3: Generate Executive Report

**File: `demo-app/test-results/EXECUTION_REPORT.md`**

```markdown
# Atomic Test Execution Report

## Native Results Summary

- **Total Tests**: ${metrics.totalTests}
- **Passed**: ${metrics.passed}
- **Failed**: ${metrics.failed}
- **Success Rate**: ${(metrics.passed/metrics.totalTests\*100).toFixed(1)}%
- **Duration**: ${metrics.duration}ms

## Atomic Test Files Generated

- {feature}-display.spec.ts: UI elements and layout validation
- {feature}-interaction.spec.ts: Primary user flow testing
- {feature}-validation.spec.ts: Input validation and error handling
- {feature}-security.spec.ts: Security features and XSS prevention
- {feature}-navigation.spec.ts: Navigation and routing testing

## Native Reports

- **HTML Report**: `npx playwright show-report`
- **JSON Results**: `test-results/results.json`
- **Video/Screenshots**: `test-results/artifacts/`

## Code Review Results

✅ All tests follow atomic principles
✅ Role-based selectors used
✅ Web-first assertions implemented
✅ No anti-patterns detected

## Debugging Summary

- UI Mode executed: ✅
- Inspector used for failures: ✅
- All tests debugged and verified: ✅
```

## Success Criteria

**Phase 1**: demo-app/playwright.config.ts configured with JSON reporter
**Phase 2**: Page structure analyzed following official AI workflow
**Phase 3**: 5+ atomic test files generated (1 functionality = 1 file)
**Phase 4**: Automated code review passed
**Phase 5**: All tests debugged in UI mode
**Phase 6**: Native JSON reports generated and parsed

## Core Principles

- **Atomic Testing**: 1 functionality = 1 file = ≤50 lines
- **Official AI Workflow**: Follow playwright.dev/agents patterns exactly
- **Native Tooling**: Use official reporters, UI mode, Inspector
- **Code Quality**: Automated review and anti-pattern detection
- **Evidence-Based**: All results from native test-results.json

## Official Tools Integration

**Test Generation**: MCP browser automation following structured page analysis
**Configuration**: Official playwright.config.ts patterns
**Execution**: `npx playwright test --ui` for debugging
**Reporting**: JSON + HTML reporters with native parsing
**Review**: Automated validation of generated tests

## Anti-Patterns Explicitly Avoided

❌ **Monolithic test files** (1 giant file)
❌ **CSS/XPath selectors** (use getByRole instead)
❌ **Hard-coded waits** (use web-first assertions)
❌ **Non-atomic tests** (multiple functionalities per file)
❌ **Manual debugging** (use UI mode and Inspector)
❌ **Custom reporting** (use native JSON parsing)
