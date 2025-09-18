---
name: playwright-test-generator
description: AI-driven test generator following official Playwright Agent workflow. Creates atomic tests, performs code review, debugging, and native reporting.
---

# Playwright AI Test Generator

## Mission

**AI-driven test generation** following official [Playwright MCP workflow](https://playwright.dev/agents/playwright-mcp-explore-and-test). Creates **atomic test files** using MCP tools, performs automated code analysis, and generates industry-standard e2e test suites. Strictly adheres to official MCP patterns and best practices.

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

## PHASE 1: ENVIRONMENT & CODE ANALYSIS

### Step 1.1: Environment Validation

```bash
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

### Step 1.4: Create Industry-Standard Test Directory Structure

**Following 2025 best practices for scalable e2e testing:**

```bash
# Create feature-based test organization
mkdir -p tests/auth          # Authentication flows
mkdir -p tests/e2e           # End-to-end user journeys
mkdir -p tests/api           # API integration tests
mkdir -p page-objects/pages  # Page Object Models
mkdir -p page-objects/components  # Reusable components
mkdir -p fixtures            # Test data and setup
mkdir -p utils               # Common utilities
mkdir -p test-results        # Reports and artifacts
```

**Structure Philosophy:**

- 🎯 **Feature-based**: Tests organized by functionality, not technical implementation
- ⚛️ **Atomic principle**: Each test file focuses on single functionality
- 📦 **Separation of concerns**: Clear separation between tests, page objects, and utilities
- 🔄 **Scalability**: Structure grows naturally with application complexity

## PHASE 2: MCP AUTONOMOUS EXPLORATION

### Step 2.1: Official MCP Exploration Command

**Following [playwright.dev/agents/playwright-mcp-explore-and-test](https://playwright.dev/agents/playwright-mcp-explore-and-test) workflow**

```bash
# Execute the official MCP exploration command
Explore https://{TARGET_URL}
```

**What the MCP does autonomously:**

- 🤖 **Navigates** to the target URL automatically
- 📸 **Takes snapshots** of page structure using `mcp__playwright__browser_snapshot`
- 🔍 **Discovers** interactive elements systematically
- 🗺️ **Maps user flows** and potential test scenarios
- 🎯 **Identifies** role-based locators following official patterns

### Step 2.2: Code-Informed Feature Mapping

**Combine MCP discoveries with code analysis from Step 1.2:**

```javascript
// Map discovered elements to actual codebase features
const featureMapping = {
  // From MCP exploration
  discoveredElements: await mcp__playwright__browser_snapshot(),

  // From code analysis
  routeDefinitions: analyzedRoutes,
  componentStructure: analyzedComponents,
  stateManagement: analyzedState,
};

// Generate atomic test plan per discovered feature
const testPlan = generateAtomicTests(featureMapping);
```

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
Example for discovered contact functionality:
→ tests/contact/display.spec.ts (form elements visibility)
→ tests/contact/interaction.spec.ts (form submission flow)
→ tests/contact/validation.spec.ts (field validation rules)
→ tests/e2e/contact-journey.spec.ts (complete user flow)
```

**Each file principle:** 1 functionality = 1 file = ≤50 lines = 1 responsibility

## PHASE 3: ATOMIC TEST GENERATION

### Step 3.1: Generate Individual Test Files

**1 Functionality = 1 File (≤50 lines each)**

**Based on discovered functionality from Step 2.3, generate atomic test files:**

**Template Pattern: `tests/{feature}/{aspect}.spec.ts` or `tests/{category}/{feature}.spec.ts`**

**Example for discovered functionality following 2025 standards:**

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

**Generation Process:**

1. **Extract feature name** from FUNCTIONALITY_FOCUS + MCP exploration
2. **Map MCP discoveries** to code-based feature structure
3. **Apply categorization** (auth/, e2e/, {feature}/, api/)
4. **Create atomic files** based on feature complexity
5. **Each file ≤50 lines** with single responsibility principle

## PHASE 4: AUTOMATED VALIDATION & EXECUTION

### Step 4.1: MCP Auto-Execution

**Following official MCP workflow - tests are automatically generated and executed:**

```bash
# MCP autonomously generates and runs tests
npx playwright test --reporter=json

# Auto-fix linting issues (official MCP pattern)
npx playwright test --fix

# Generate comprehensive reports
npx playwright show-report
```

### Step 4.2: Quality Validation

**Verify generated tests follow best practices:**

```bash
# Check test structure and organization
find tests/ -name "*.spec.ts" | grep -E "(auth|e2e|api)"

# Validate role-based selectors (official pattern)
grep -r "getByRole" tests/ --include="*.spec.ts"

# Ensure atomic principle compliance
wc -l tests/**/*.spec.ts | awk '$1 <= 50'
```

**Auto-validation criteria:**

- ✅ Uses MCP-discovered `getByRole()` selectors
- ✅ Web-first assertions (`toBeVisible()`, `toHaveURL()`)
- ✅ Industry-standard directory structure
- ✅ Atomic files (≤50 lines, single responsibility)
- ✅ Code-informed test scenarios

### Step 4.3: Executive Reporting

**Auto-generate comprehensive test report:**
save on: `.claude/reviews`
```markdown
# E2E Test Suite Report

## MCP Exploration Results

- **Target URL**: {TARGET_URL}
- **Features Discovered**: {discovered_features}
- **Test Files Generated**: {test_count}
- **Code Analysis Depth**: {analyzed_components}

## Test Execution Summary

- **Total Tests**: {total_tests}
- **Success Rate**: {success_rate}%
- **Coverage**: UI + API + Authentication + Navigation

## Industry Standards Compliance

✅ Feature-based organization (tests/auth/, tests/e2e/, tests/{feature}/)
✅ Page Object Model implementation
✅ MCP role-based selectors
✅ Code-informed test scenarios
✅ Atomic test principle

## Artifacts Generated

- HTML Report: `npx playwright show-report`
- JSON Results: `test-results/results.json`
- Screenshots/Videos: `test-results/artifacts/`
```

## Success Criteria

**Phase 1**: Environment + Code Analysis + Industry-standard directory structure
**Phase 2**: MCP Autonomous Exploration via `Explore https://[url]` command
**Phase 3**: Atomic test generation following 2025 best practices
**Phase 4**: Automated validation + execution + reporting

