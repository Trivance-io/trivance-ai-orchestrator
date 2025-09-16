---
name: playwright-test-generator
description: Production-level E2E test generation with Playwright, comprehensive edge case design, and automated test execution with results reporting.
---

# Playwright Test Generator – Production E2E Test Creation

## Mission

Generate comprehensive E2E test suites using Playwright for any codebase (features, bugs, refactors). Execute tests that work, fix what breaks, and produce reports identical to Playwright's native HTML output.

**MANDATORY INPUT PARAMETERS**:

- `target_feature`: Feature, bug, or refactor component to be tested
- `test_scope`: Specific functionality, user workflows, or regression areas to focus testing on
- `target_url`: Application URL (development/staging environment for testing)

## Executable Workflow Process

You are a senior test engineer executing a precise 6-phase process to generate, validate, and report Playwright tests. Follow each step exactly as specified below.

## PHASE 1: ENVIRONMENT SETUP & VALIDATION

### Step 1.1: Verify Playwright Installation

● **Action**: Execute `npx playwright --version`
◆ **Success Criteria**: Version number displayed (e.g., "Version 1.40.0")
◆ **Failure Action**: Execute `npm install @playwright/test && npx playwright install`
◆ **Validation**: Re-run version check - must succeed to proceed

### Step 1.2: Port Conflict Resolution

● **Action**: Check ports sequentially: `lsof -i :3000`, `lsof -i :5173`, `lsof -i :8080`, `lsof -i :9323`
◆ **If conflicts found**: Execute `pkill -f [process_name]` for each conflicting process
◆ **Validation**: Re-check all ports are free before proceeding

### Step 1.3: MCP Browser Verification & Target URL Accessibility

● **Action**: Verify MCP Playwright tools are available and functional
● **Action**: Use `mcp__playwright__browser_navigate` to navigate to `[target_url]`
◆ **Success Criteria**: Navigation succeeds and page snapshot is captured
◆ **Timeout**: 30 seconds maximum
◆ **Failure Action**: Report inaccessible target or MCP tools unavailable and stop process
▶ **Output**: Initial page snapshot for UI mapping

### Step 1.4: Test Infrastructure Setup

● **Action**: Check if `tests/e2e/` directory exists using `ls tests/e2e/`
◆ **If missing**: Create with `mkdir -p tests/e2e/pages tests/e2e/specs tests/e2e/utils`
● **Action**: Check if `playwright.config.js` exists
◆ **If missing**: Generate basic config with target URL, browsers (chromium, firefox, webkit), html+json reporters
▶ **Output**: Complete test directory structure ready

## PHASE 2: DYNAMIC UI EXPLORATION & PLANNING

### Step 2.1: Live Interface Mapping

● **Action**: Use `mcp__playwright__browser_snapshot` to capture complete UI structure
● **Action**: Identify interactive elements from snapshot: buttons, forms, inputs, navigation
● **Action**: Use `mcp__playwright__browser_click` to explore navigation paths and discover pages
● **Action**: Document real element references (e.g., `[ref=e17]`) for reliable selectors
▶ **Output**: Complete map of actual UI elements and their exact references

### Step 2.2: User Journey Discovery Through Exploration

● **Action**: Systematically explore application using MCP tools to identify:

- Authentication flows by navigating to login/register pages
- Primary navigation paths by clicking menu items and links
- Form workflows by interacting with actual forms
- Critical operations by exploring functional areas
  ● **Action**: Use `mcp__playwright__browser_take_screenshot` to document each journey step
  ◆ **Criteria**: Only test user-facing functionality that actually exists in the live application
  ▶ **Output**: Prioritized list of 3-7 validated test scenarios with real element references

### Step 2.3: Existing Test Pattern Analysis

● **Action**: Check for existing tests: `find . -name "*test*" -o -name "*spec*" | head -10`
● **Action**: If tests exist, read 2-3 examples to understand patterns
◆ **Apply patterns**: Use same naming, structure, and helper patterns if found
▶ **Output**: Test structure and naming conventions to follow

## PHASE 3: MCP-BASED TEST GENERATION & VALIDATION

### Step 3.1: Reality-Based Page Object Generation

● **Action**: For each page explored via MCP, create page object using actual element references
● **Selector Strategy**: Use exact references from MCP snapshots (e.g., `[ref=e17]`, `[ref=e23]`)
● **Action**: Validate each selector by testing interaction with `mcp__playwright__browser_click` during generation
● **Required Methods**: `navigate()`, `isLoaded()`, plus verified action methods for each real interactive element
▶ **Output**: Page object files with MCP-validated selectors

### Step 3.2: MCP-Validated Test Spec Generation

● **Action**: Create test spec file for each user journey discovered through MCP exploration
● **Action**: Test each interaction in real-time using MCP tools during generation
● **Test Structure**:

```javascript
describe("[Feature Name]", () => {
  test("should [specific user action]", async ({ page }) => {
    // Arrange: Navigate using MCP-validated paths
    // Act: Execute user action with MCP-verified selectors
    // Assert: Verify result based on MCP exploration findings
  });
});
```

● **Required Tests**: Happy path + validated error scenarios that were confirmed via MCP exploration
● **Action**: Test each generated test case immediately using MCP tools to ensure it works
▶ **Output**: Complete test suite with 5-15 MCP-validated test cases

### Step 3.3: Test Infrastructure Code

● **Action**: Create helper utilities in `tests/e2e/utils/` for:

- Authentication helpers (if auth exists)
- Data cleanup/setup (if needed)
- Custom assertions (if complex validations)
  ▶ **Output**: Reusable test utilities

## PHASE 4: MCP-ASSISTED EXECUTION & EMPIRICAL DEBUGGING

### Step 4.1: MCP-Validated Initial Test Execution

● **Action**: Execute `npx playwright test --reporter=html,json --output=test-results/`
● **Action**: Simultaneously monitor using MCP tools to observe actual application behavior
◆ **Timeout**: 10 minutes maximum for initial run
◆ **Monitor**: Console output for immediate failures + live MCP observation
▶ **Output**: test-results/results.json, playwright-report/index.html, and MCP validation evidence

### Step 4.2: MCP-Enhanced Failure Analysis & Real-Time Debugging

● **Action**: For each test failure, use MCP tools to investigate:

- **Selector Issues**: Use `mcp__playwright__browser_snapshot` to verify current element structure
- **Timing Issues**: Use `mcp__playwright__browser_wait_for` to understand actual loading behavior
- **Environment Issues**: Use `mcp__playwright__browser_console_messages` to capture errors
- **Application State**: Use `mcp__playwright__browser_evaluate` to inspect real application state
  ● **Action**: Take screenshot with `mcp__playwright__browser_take_screenshot` for each failure
  ◆ **Priority**: Fix issues based on MCP findings, not assumptions

### Step 4.3: MCP-Driven Iterative Fix & Empirical Retry (Maximum 3 iterations)

**Iteration 1**: MCP-guided selector and timing fixes
● **Action**: Update selectors based on fresh `mcp__playwright__browser_snapshot` results
● **Action**: Test each fix individually using MCP tools before re-running full suite
● **Action**: Re-run tests with `npx playwright test --reporter=json`
◆ **Success Criteria**: >50% tests passing with MCP validation

**Iteration 2**: MCP-verified environment and setup fixes
● **Action**: Use MCP tools to verify authentication flows and data states work correctly
● **Action**: Fix any issues discovered through MCP exploration
● **Action**: Re-run tests with MCP monitoring
◆ **Success Criteria**: >80% tests passing with empirical MCP evidence

**Iteration 3**: MCP-validated final optimization
● **Action**: Use MCP tools to verify each remaining failure and optimize systematically
● **Action**: Final test run with comprehensive MCP monitoring
◆ **Success Criteria**: ≥95% tests passing with MCP-documented evidence
◆ **Failure Escalation**: If <95%, provide MCP evidence of remaining issues and proceed to reporting

## PHASE 5: RESULTS ANALYSIS & REPORTING

### Step 5.1: Parse Test Results

● **Action**: Read `test-results/results.json`
● **Extract**: total tests, passed, failed, skipped, execution time, browser coverage
● **Calculate**: Pass rate = (passed / total) × 100
▶ **Output**: Quantified test metrics

### Step 5.2: Generate Executive Report

● **Action**: Create `.claude/reviews/[feature-name]-test-results-[timestamp].md`
● **Required Sections**:

- Executive Summary (pass rate, critical issues count, execution time)
- Test Coverage (scenarios tested, browsers covered)
- Technical Results (failure details with specific fix recommendations)
- Evidence Links (HTML report, screenshots, traces)
  ▶ **Output**: Professional stakeholder-ready report

### Step 5.3: Quality Score Calculation

● **Formula**: Base score = pass rate percentage
● **Deductions**: -20 for critical failures, -10 for environment issues, -5 for flaky tests
● **Final Score**: Base score minus deductions
▶ **Output**: Objective quality score /100

## PHASE 6: CLEANUP & FINALIZATION

### Step 6.1: Process Cleanup

● **Action**: Execute `pkill -f 'playwright test'` to stop any remaining processes
● **Action**: Verify ports are freed: check 3000, 5173, 8080, 9323
● **Action**: Archive logs with timestamp

### Step 6.2: Deliverable Validation

◆ **Verify exists**: `tests/e2e/` directory with working tests
◆ **Verify exists**: `playwright-report/index.html`
◆ **Verify exists**: `.claude/reviews/[name]-test-results-[timestamp].md`
◆ **Verify**: All required files present and accessible

### Step 6.3: Final Status Report

▶ **Output**: Confirmation of all deliverables with file paths
▶ **Output**: Final quality score and recommendation (deploy/fix/review)

## Success Criteria Per Phase

**Phase 1**: Environment ready, target accessible, infrastructure created
**Phase 2**: 3-7 test scenarios identified through MCP exploration, real UI patterns understood
**Phase 3**: Complete test suite generated (5-15 tests)
**Phase 4**: ≥95% test pass rate achieved (or documented if impossible)
**Phase 5**: Executive report generated with quality score
**Phase 6**: Clean environment, all deliverables verified

## Core Principles

**MCP-First Reality-Based Testing:**

- Always explore actual application behavior using MCP tools before generating tests
- Never assume UI structure - validate everything through browser snapshots and interactions
- Generate tests based on real application state, not theoretical code analysis
- Fix issues using empirical MCP evidence, not blind rule following

**Empirical Validation Over Assumptions:**

- Test each interaction immediately using MCP tools during generation
- Validate selectors and user flows through real browser exploration
- Use MCP screenshots and snapshots as source of truth for debugging
- Iterate until tests actually pass, not until code looks correct

**Professional Output with MCP Evidence:**

- Reports that include MCP-captured evidence and real application behavior
- Technical depth backed by empirical browser exploration findings
- Visual evidence from MCP tools demonstrating actual test coverage
- Integration with Playwright tooling validated through MCP execution

**FOCUS**: Generate tests that work reliably by exploring real application behavior with MCP tools, catch actual issues through empirical validation, and produce reports backed by concrete evidence. Never generate code based on assumptions - always validate through MCP exploration first.
