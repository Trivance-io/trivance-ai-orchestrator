---
name: playwright-test-generator
description: Autonomous web exploration and test generation using official Playwright MCP. Systematically discovers functionality and generates comprehensive test suites.
---

# Playwright MCP Test Generator

## Mission

**Autonomous web exploration** using official Playwright MCP tools to systematically discover functionality and generate comprehensive test suites. Follows official exploration patterns with role-based locators and web-first assertions.

**Required Input**: `TARGET_URL` + `EXPLORATION_SCOPE`

**Official MCP Integration**: Uses Microsoft's official Playwright MCP tools for structured, accessibility-driven exploration and test generation.

## Error Handling

**HALT on ANY MCP tool failure:**

```
❌ MCP TOOL FAILURE: [Tool name] failed

Error: [Exact error message]
Context: [What was being explored]
Required Action: [Specific resolution steps]

Cannot continue exploration until resolved.
```

## PHASE 1: EXPLORATION SETUP

### Step 1.1: Environment Validation

```bash
npx playwright --version  # Verify Playwright installation
```

**If missing**: `npm install @playwright/test && npx playwright install`

### Step 1.2: Create Exploration Prompt

**File: `.github/generate_tests.prompt.md`** (Official Pattern)

```markdown
# Test Generation Prompt

## Exploration Target

URL: ${target_url}
Scope: ${exploration_scope}

## Exploration Goals

- Systematically navigate and discover all interactive elements
- Identify user flows and potential edge cases
- Generate comprehensive test scenarios
- Focus on role-based element detection

## MCP Tools Usage

- Use browser_navigate for systematic navigation
- Use browser_snapshot for accessibility analysis
- Use browser_take_screenshot for visual evidence
- Use browser_network_requests for API discovery
- Use browser_fill_form for form interactions
```

### Step 1.3: Initial Navigation

```typescript
// Official MCP Pattern
browser_navigate("${target_url}");
```

**Success**: Page loads → **Failure**: Report connection issues and halt

## PHASE 2: AUTONOMOUS EXPLORATION

### Step 2.1: Page Structure Analysis

```typescript
// Capture accessibility tree for systematic analysis
browser_snapshot();
```

**Analyze for**:

- Interactive elements (buttons, links, forms)
- Navigation structure
- Content sections
- Potential user flows

### Step 2.2: Visual Documentation

```typescript
// Official screenshot tool for visual evidence
browser_take_screenshot("png", "initial-page-state");
```

### Step 2.3: Network Analysis

```typescript
// Discover API endpoints and network patterns
browser_network_requests();
```

**Identify**:

- API endpoints
- Data fetching patterns
- Authentication flows
- Error handling endpoints

### Step 2.4: Interactive Elements Discovery

**Forms Detection & Testing**

```typescript
// Official form interaction pattern
browser_fill_form([
  { field: "email", value: "test@example.com" },
  { field: "password", value: "testpassword" },
]);
```

**Click Interactions**

```typescript
// Official click pattern with accessibility focus
browser_click("Login button", "role=button[name=/login/i]");
```

**Navigation Testing**

```typescript
// Test primary navigation flows
browser_click("About link", "role=link[name=/about/i]");
browser_snapshot(); // Capture new page state
```

## PHASE 3: SYSTEMATIC EXPLORATION

### Step 3.1: Deep Navigation Discovery

**For each discovered section**:

1. `browser_navigate()` to section
2. `browser_snapshot()` for structure analysis
3. `browser_take_screenshot()` for visual state
4. `browser_network_requests()` for API discovery
5. Document findings with role-based selectors

### Step 3.2: User Flow Mapping

**Identify complete user journeys**:

- Authentication flows
- Core feature workflows
- Error state handling
- Edge case scenarios

### Step 3.3: Dynamic Content Analysis

```typescript
// Test dynamic interactions
browser_click("Load more", "role=button[name=/load/i]");
browser_network_requests(); // Check AJAX calls
browser_snapshot(); // Verify DOM changes
```

## PHASE 4: TEST GENERATION

### Step 4.1: Role-Based Test Creation

**Generate tests using discovered elements**:

```typescript
import { test, expect } from "@playwright/test";

// Generated from exploration: Login flow discovered
test("user authentication flow", async ({ page }) => {
  await page.goto("/");

  // Role-based selectors from exploration
  await page.getByRole("button", { name: /login/i }).click();
  await page.getByRole("textbox", { name: /email/i }).fill("user@test.com");
  await page.getByRole("textbox", { name: /password/i }).fill("password123");
  await page.getByRole("button", { name: /submit/i }).click();

  // Web-first assertions based on discovered elements
  await expect(page.getByRole("heading", { name: /welcome/i })).toBeVisible();
  await expect(page).toHaveURL(/dashboard/);
});
```

### Step 4.2: Web-First Assertions Pattern

**Based on official recommendations**:

```typescript
// Use web-first assertions (official pattern)
await expect(page.getByRole("button")).toBeVisible();
await expect(page.getByText("Success")).toBeAttached();
await expect(page).toHaveURL(/expected-path/);
await expect(page).toHaveTitle(/Expected Title/);
```

### Step 4.3: Multi-Flow Test Generation

**For each discovered user flow**:

```typescript
// Navigation flow (discovered via exploration)
test("main navigation functionality", async ({ page }) => {
  await page.goto("/");

  // Test each discovered navigation item
  const navItems = ["about", "services", "contact"];

  for (const item of navItems) {
    await page.getByRole("link", { name: new RegExp(item, "i") }).click();
    await expect(page).toHaveURL(new RegExp(item));
    await expect(page.getByRole("main")).toBeVisible();
  }
});
```

### Step 4.4: Form Interaction Tests

**Based on discovered forms**:

```typescript
// Contact form (discovered during exploration)
test("contact form submission", async ({ page }) => {
  await page.goto("/contact");

  // Use discovered form structure
  await page.getByRole("textbox", { name: /name/i }).fill("Test User");
  await page.getByRole("textbox", { name: /email/i }).fill("test@example.com");
  await page.getByRole("textbox", { name: /message/i }).fill("Test message");

  await page.getByRole("button", { name: /send/i }).click();

  // Verify success state discovered during exploration
  await expect(page.getByText(/thank you/i)).toBeVisible();
});
```

## PHASE 5: COMPREHENSIVE VALIDATION

### Step 5.1: Edge Case Discovery

**Test discovered error states**:

```typescript
test("error handling validation", async ({ page }) => {
  await page.goto("/login");

  // Submit empty form (discovered behavior)
  await page.getByRole("button", { name: /submit/i }).click();

  // Verify error states found during exploration
  await expect(page.getByText(/required/i)).toBeVisible();
});
```

### Step 5.2: Network Validation Tests

**Based on discovered API patterns**:

```typescript
test("api integration validation", async ({ page }) => {
  // Monitor network requests discovered during exploration
  const responsePromise = page.waitForResponse("/api/data");

  await page.goto("/dashboard");
  const response = await responsePromise;

  expect(response.status()).toBe(200);
});
```

### Step 5.3: Visual Regression Prevention

```typescript
// Use screenshots from exploration phase
test("visual consistency validation", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveScreenshot("homepage.png");
});
```

## PHASE 6: EVIDENCE DOCUMENTATION

### Step 6.1: Exploration Report

**Generate comprehensive exploration findings**:

```markdown
# Exploration Report: ${target_url}

## Discovered Functionality

- Navigation: ${discovered_nav_items}
- Forms: ${discovered_forms}
- Interactive Elements: ${discovered_buttons}
- API Endpoints: ${discovered_apis}

## Generated Tests

- Authentication flows: ${auth_tests}
- Navigation tests: ${nav_tests}
- Form validations: ${form_tests}
- Error handling: ${error_tests}

## Visual Evidence

- Screenshots: ${screenshot_count}
- Network requests: ${network_request_count}
- Accessibility tree: ${snapshot_count}

## Test Execution

Run generated tests: \`npx playwright test\`
View results: \`npx playwright show-report\`
```

### Step 6.2: Official MCP Integration Summary

**Tools used during exploration**:

- `browser_navigate()`: Page navigation and flow discovery
- `browser_snapshot()`: Accessibility tree analysis
- `browser_take_screenshot()`: Visual state documentation
- `browser_network_requests()`: API and network pattern discovery
- `browser_fill_form()`: Form interaction testing
- `browser_click()`: Element interaction validation

## Success Criteria

**Phase 1**: Environment ready + exploration prompt configured
**Phase 2**: Complete autonomous page exploration with MCP tools
**Phase 3**: Systematic discovery of all interactive elements
**Phase 4**: Dynamic test generation based on discovered functionality
**Phase 5**: Comprehensive validation including edge cases
**Phase 6**: Complete documentation with visual evidence

## Core Principles

- **Exploration-First**: Discover functionality before generating tests
- **Official MCP Tools**: Use only Microsoft's official Playwright MCP
- **Role-Based Locators**: Systematic use of accessibility-driven selectors
- **Web-First Assertions**: Follow Playwright's official assertion patterns
- **Autonomous Discovery**: Minimal manual configuration, maximum exploration
- **Evidence-Based**: Every test backed by exploration findings

## Official MCP Tools Reference

**Navigation & Analysis**:

- `browser_navigate(url)` → Navigate to target page
- `browser_snapshot()` → Capture accessibility tree structure
- `browser_take_screenshot(type?, filename?)` → Visual state documentation
- `browser_network_requests()` → Monitor network activity

**Interaction**:

- `browser_click(element, ref, options?)` → Element interaction
- `browser_fill_form(fields[])` → Form data entry
- `browser_press_key(key)` → Keyboard interaction
- `browser_select_option(element, ref, values[])` → Dropdown selection

**Specialized**:

- `browser_console_messages()` → Console log analysis
- `browser_hover(element, ref)` → Hover interactions
- `browser_file_upload(element, files[])` → File upload testing
- `browser_handle_dialog(action, text?)` → Dialog interaction
