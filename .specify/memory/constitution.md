<!--
Sync Impact Report - Constitution v1.0.0
Version change: Template → v1.0.0 (Initial release with GitHub Spec-Kit architectural discipline)
Modified principles: All placeholders filled with AI-first workflow + GitHub discipline integration
Added sections: Quality Standards, Implementation Rules, complete governance framework
Removed sections: None (template structure preserved)
Templates requiring updates:
  ✅ plan-template.md (updated to v1.0.0)
  ✅ spec-template.md (no direct constitution references)
  ✅ tasks-template.md (no direct constitution references)
Follow-up TODOs: None
-->

# Trivance AI Orchestrator Constitution

<!-- Master configuration repository constitution for AI-first development workflow -->

## Core Principles

### I. AI-First Workflow (NON-NEGOTIABLE)

Everything must be executable by advanced AI with human oversight; Humans direct vision and strategy while AI executes implementation; All plans and outcomes must be AI-executable following clear patterns and established conventions; No manual processes that cannot be delegated to AI agents.

### II. Value/Complexity Ratio

Value delivered must be ≥ 2x implementation complexity; Measure ROI as benefit minus complexity (both scored 1-5); Always choose highest ROI approach, tie-break toward simplicity; Guided exploration requires 2-3 approaches with explicit ROI calculation before proceeding.

### III. Test-First Development (NON-NEGOTIABLE)

TDD mandatory: Tests written → User approved → Tests fail → Then implement; Red-Green-Refactor cycle strictly enforced; Contract tests before implementation always; Integration-First Testing: prefer real environments over mocks, use actual service instances; Integration tests for user stories; No implementation without failing tests first.

### IV. Complexity Budget (NON-NEGOTIABLE)

Size S ≤ 80 LOC, 1 file, 0 deps, ≤1% CPU/RAM; Size M ≤ 250 LOC, 3 files, 1 dep, ≤3% CPU/RAM; Size L ≤ 600 LOC, 5 files, 2 deps, ≤5% CPU/RAM; Anti-Abstraction enforcement: maximum 3 projects for initial implementation, use framework features directly, avoid unnecessary abstraction layers; Stop and ask if exceeding budget; Self-audit against metrics mandatory.

### V. Reuse First & Simplicity

Library-First Principle: Every feature MUST begin its existence as a standalone library; Reuse components before creating new abstractions; New abstraction requires ≥30% duplication justification or demonstrable future-cost reduction; Apply Einstein's principle: "Everything should be made as simple as possible, but not simpler"; List reused components explicitly.

## Quality Standards

Observability over Opacity: All interfaces must be observable, debuggable, and traceable; Language consistency enforced: Spanish for human documentation, English for code and AI documentation - never mix in same file; Security, performance, and reliability take priority over features; Production-ready output with quantified business impact required; Code quality reviewer used proactively for validation; Professional, minimalist communication style eliminating promotional content.

## Implementation Rules

CLI Interface Mandate: All interfaces must accept text input, produce text output, support JSON data exchange for observability; Guided exploration mandatory: propose 2-3 approaches with explicit benefit/complexity scoring before implementation; Self-audit confirming complexity metrics compliance before completion; TDD loop enforcement with red-green-refactor discipline; Framework and library choices must align with existing project conventions; Security best practices non-negotiable - no credential exposure.

## Governance

Constitutional Gates: Pre-implementation checkpoints mandatory for simplicity, anti-abstraction, and integration testing compliance; Constitution supersedes all other development practices; All PRs and code reviews must verify constitutional compliance; Complexity budget violations require explicit justification and simpler alternative analysis; Use specialist agents (code-quality-reviewer, systematic-debugger) proactively based on challenge type; Amendments require documentation of change rationale, stakeholder approval, and migration plan for affected workflows.

**Version**: 1.0.0 | **Ratified**: 2025-09-20 | **Last Amended**: 2025-09-20
