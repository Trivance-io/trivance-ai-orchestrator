---
description: Create or update the feature specification from a natural language feature description.
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

The user input can be either:

- **Natural language**: `/SDD-cycle:specify "Create user authentication system"`
- **GitHub Issue**: `/SDD-cycle:specify --from-issue 456`

Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that input, do this:

1. **Parse input type and extract content:**
   - If `$ARGUMENTS` starts with `--from-issue`:
     - Extract issue number: `ISSUE_NUM=$(echo "$ARGUMENTS" | sed 's/--from-issue *//')`
     - Run: `gh issue view $ISSUE_NUM --json body,title --jq '.title + "\n\n" + .body'`
     - Use the GitHub Issue content as feature description
   - Otherwise: Use `$ARGUMENTS` directly as natural language feature description

2. Run the script `.specify/scripts/bash/create-new-feature.sh --json "$FEATURE_DESCRIPTION"` from repo root and parse its JSON output for BRANCH_NAME and SPEC_FILE. All file paths must be absolute.
   **IMPORTANT** You must only ever run this script once. The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for.
3. Load `.specify/templates/spec-template.md` to understand required sections.
4. Write the specification to SPEC_FILE using the template structure, replacing placeholders with concrete details derived from the feature description while preserving section order and headings.

   **IMPORTANT**: If input came from `--from-issue`, update the **Input** field to include parent issue reference:
   - Replace: `**Input**: User description: "$ARGUMENTS"`
   - With: `**Input**: GitHub Issue #$ISSUE_NUM: "$FEATURE_DESCRIPTION"`

   This enables the tasks workflow to create GitHub sub-issues under the parent issue.

5. Open IDE automatically to enhance developer experience:
   - Detect available IDE by executing commands in order:
     - `which code > /dev/null 2>&1` para VS Code
     - `which cursor > /dev/null 2>&1` para Cursor
   - If IDE is found, execute `(cd "." && [IDE_COMMAND] . --new-window)` where [IDE_COMMAND] is `code` or `cursor`
   - Si IDE se abre exitosamente, mostrar: "✅ IDE abierto en nueva ventana para especificación"
   - Si no se encuentra IDE disponible, mostrar: "⚠️ No se encontró IDE compatible. Abre manualmente: [IDE] ."
   - If fails to open IDE, show warning: "⚠️ No se pudo abrir IDE automáticamente" but continue

6. Report completion with branch name, spec file path, IDE status, and readiness for the next phase:

   ```
   ✅ Feature specification created:
   - Branch: [BRANCH_NAME]
   - Spec file: [SPEC_FILE]
   - IDE: Opened automatically / Manual opening required

   ⚠️  NEXT STEPS:
   PASO 1 - En la nueva ventana del IDE (si se abrió automáticamente):
     Abrir Terminal integrado (Cmd+` o View → Terminal)

   PASO 2 - Continuar con el workflow SDD:
     /SDD-cycle:plan

   ✅ Ready for planning phase of SDD-cycle workflow.
   ```

Note: The script creates and checks out the new branch and initializes the spec file before writing.
