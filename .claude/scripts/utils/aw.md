---
description: Ensure what you implement Always Works™ with comprehensive testing
---

# How to ensure Always Works™ implementation

Please ensure your implementation Always Works™ for: $ARGUMENTS.

Follow this systematic approach:

## Core Philosophy

- "Should work" ≠ "does work" - Pattern matching isn't enough
- "Simple enough" ≠ "over-engineered" - Complexity requires justification
- I'm not paid to write code, I'm paid to solve problems
- Untested code is just a guess, not a solution
- Over-engineered code solves tomorrow's imaginary problems, not today's real ones

# The 30-Second Reality Check - Must answer YES to ALL:

## Functionality Reality:
- Did I run/build the code?
- Did I trigger the exact feature I changed?
- Did I see the expected result with my own observation (including GUI)?
- Did I check for error messages?
- Would I bet $100 this works?

## Simplicity Reality:
- Does this solve ONLY the stated problem?
- Can I remove any abstraction without breaking functionality?
- Am I adding code for "future needs" that don't exist today?
- Would I bet $100 this is as simple as it can be?

# Phrases to Avoid:

## Functionality Phrases:
- "This should work now"
- "I've fixed the issue" (especially 2nd+ time)
- "Try it now" (without trying it myself)
- "The logic is correct so..."

## Over-engineering Phrases:
- "This is more flexible for future needs"
- "I added this pattern in case we need..."
- "This abstraction will help when..."
- "It's more enterprise-ready this way"

# Specific Requirements:

## Testing Requirements:
- UI Changes: Actually click the button/link/form
- API Changes: Make the actual API call
- Data Changes: Query the database
- Logic Changes: Run the specific scenario
- Config Changes: Restart and verify it loads

## Simplicity Requirements:
- UI Changes: One component per concern, remove unused props/methods
- API Changes: Single responsibility endpoints, no speculative parameters
- Data Changes: Minimal schema changes, question each new field/table
- Logic Changes: Straightforward flow, remove nested abstractions
- Config Changes: Essential configs only, no "just in case" settings

# The Complexity Budget Reality Check:

**Before implementing, answer these:**
- Size S (≤80 LOC): Can I solve this in one focused function/component?
- Size M (≤250 LOC): Can I avoid creating new abstractions/interfaces?
- Size L (≤600 LOC): Is every new class/file absolutely necessary?

**During implementation:**
- Am I creating patterns the codebase doesn't already have?
- Would a new developer understand this in 5 minutes?
- Can I delete any abstraction without breaking core functionality?

**The Simplicity Test:**
"If I have to explain why this abstraction is necessary, it probably isn't."

# The Embarrassment Test:

"If the user records trying this and it fails, will I feel embarrassed to see his face?"

# Time Reality:

## Testing Reality:
- Time saved skipping tests: 30 seconds
- Time wasted when it doesn't work: 30 minutes
- User trust lost: Immeasurable

## Complexity Reality:
- Time saved with simple solution: 2 hours
- Time wasted maintaining over-engineered code: 2 weeks
- Developer sanity lost: Immeasurable

A user describing a bug for the third time isn't thinking "this AI is trying hard" - they're thinking "why am I wasting time with this incompetent tool?"

A developer reading over-engineered code isn't thinking "this is flexible" - they're thinking "who wrote this maze and why?"


