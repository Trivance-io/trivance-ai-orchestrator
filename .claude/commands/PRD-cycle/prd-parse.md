---
allowed-tools: Bash(date -u +"%Y-%m-%dT%H:%M:%SZ"), Read, Write, LS
---

# PRD Parse

Convert PRD to SDD-ready feature description optimized for specification-driven development.

## Usage

```
/PRD-cycle:prd-parse <feature_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:

- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### Validation Steps

1. **Verify <feature_name> was provided as a parameter:**
   - If not, tell user: "❌ <feature_name> was not provided as parameter. Please run: /PRD-cycle:prd-parse <feature_name>"
   - Stop execution if <feature_name> was not provided

2. **Verify PRD exists:**
   - Check if `.claude/prds/$ARGUMENTS/prd.md` exists
   - If not found, tell user: "❌ PRD not found: $ARGUMENTS. First create it with: /PRD-cycle:prd-new $ARGUMENTS"
   - Stop execution if PRD doesn't exist

3. **Validate PRD frontmatter:**
   - Verify PRD has valid frontmatter with: name, description, status, created
   - If frontmatter is invalid or missing, tell user: "❌ Invalid PRD frontmatter. Please check: .claude/prds/$ARGUMENTS/prd.md"
   - Show what's missing or invalid

4. **Check for existing SDD-input:**
   - Check if `.claude/prds/$ARGUMENTS/sdd-input.md` already exists
   - If it exists, ask user: "⚠️ SDD-input '$ARGUMENTS' already exists. Overwrite? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "View existing SDD-input at: .claude/prds/$ARGUMENTS/sdd-input.md"

5. **Verify directory permissions:**
   - Ensure `.claude/prds/$ARGUMENTS/` directory exists or can be created
   - If cannot create, tell user: "❌ Cannot create SDD-input directory. Please check permissions."

## Instructions

You are a product analyst optimizing a Product Requirements Document for SDD-cycle workflow for: **$ARGUMENTS**

### 1. Read the PRD

- Load the PRD from `.claude/prds/$ARGUMENTS/prd.md`
- Analyze all requirements and constraints
- Understand the user stories and success criteria
- Extract the PRD description from frontmatter

### 2. SDD-Optimization Analysis

- Pre-resolve common ambiguities that trigger clarify.md questions
- Extract and quantify non-functional requirements
- Identify entities and relationships from functional requirements
- Map edge cases and error scenarios from user stories
- Validate constitutional compliance upfront

### 3. File Format with Template

Create the SDD-input file at: `.claude/prds/$ARGUMENTS/sdd-input.md` using the template structure:

- Load `.specify/templates/sdd-input-template.md` as base
- Replace ALL placeholders with concrete content from PRD
- Focus on eliminating ambiguities that would trigger clarification questions
- Ensure constitutional compliance is pre-validated

### 4. Transformation Guidelines

**From PRD to SDD-Input:**

- **Executive Summary** → Core Feature Summary (natural language for SDD)
- **User Stories** → Primary User Flow (detailed scenarios)
- **Functional Requirements** → SDD-Ready Requirements (testable format)
- **Success Criteria** → Measurable Success Targets (quantified)
- **Dependencies** → Integration Approach (explicit failure modes)
- **Constraints** → Technical Constraints (constitutional compliance)

**Pre-Resolve Clarify Categories:**

- **Domain & Data Model**: Extract entities, attributes, relationships from requirements
- **Non-Functional Quality**: Quantify vague terms (fast→<200ms, scalable→10k users)
- **Integration Dependencies**: Make external services and failure modes explicit
- **Edge Cases & Failure Handling**: Extract error scenarios from user stories
- **Constraints & Tradeoffs**: Document technology choices and rejected alternatives

### 5. Output Location

Create the directory structure if it doesn't exist:

- `.claude/prds/$ARGUMENTS/` (directory)
- `.claude/prds/$ARGUMENTS/sdd-input.md` (SDD-optimized description)
- `.claude/prds/$ARGUMENTS/transformation-log.md` (audit trail)

### 6. Quality Validation

Before saving the SDD-input, verify:

- [ ] All clarify.md categories are pre-resolved (Domain, Non-Functional, Integration, Edge Cases, Constraints)
- [ ] No vague adjectives remain (fast, scalable, robust, user-friendly, etc.)
- [ ] Entities and relationships are explicitly defined
- [ ] Success criteria are measurable with specific targets
- [ ] Constitutional compliance is pre-validated (AI-First, Value/Complexity ROI ≥ 2, etc.)

### 7. Post-Creation

After successfully creating the SDD-input:

1. Confirm: "✅ SDD-Ready Feature Description created: .claude/prds/$ARGUMENTS/sdd-input.md"
2. Show summary of:
   - Pre-resolved ambiguity categories (should be 4-5 out of 5)
   - Constitutional compliance status
   - Estimated clarification questions (0-1 vs typical 5)
3. Suggest next step: "Ready to sync to GitHub? Run: /git-github:prd-sync $ARGUMENTS"

## Error Recovery

If any step fails:

- Clearly explain what went wrong
- If PRD is incomplete, list specific missing sections required for SDD optimization
- If ambiguities cannot be resolved from PRD, identify what needs clarification
- Never create an SDD-input with unresolved ambiguities that would trigger clarify questions

Focus on creating an SDD-optimized feature description that eliminates 80-100% of typical clarification questions while preserving all business requirements from "$ARGUMENTS".

## IMPORTANT:

- Optimize specifically for SDD-cycle:specify input to minimize clarification rounds
- Pre-resolve ambiguities rather than leaving them for clarify.md
- Ensure output is immediately consumable by `/SDD-cycle:specify "$(cat .claude/prds/$ARGUMENTS/sdd-input.md)"`
- Maintain constitutional compliance throughout transformation
