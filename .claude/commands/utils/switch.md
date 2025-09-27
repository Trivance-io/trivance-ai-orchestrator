---
allowed-tools: Bash(git *), Bash(gh), Bash(command)
description: Cambia de rama temporal a rama objetivo validando PR mergeado
---

# Switch Branch

Cambia de rama temporal a rama objetivo, valida que PR asociado esté mergeado y elimina la rama temporal local usando natural language instructions.

## Uso

```bash
/utils:switch <target_branch>  # Argumento obligatorio
```

## Ejemplos

```bash
/utils:switch main        # Salir de temporal → ir a main
/utils:switch develop     # Salir de temporal → ir a develop
/utils:switch feature/123 # Salir de temporal → ir a feature branch
```

## User Input

$ARGUMENTS

## Instructions

### 1. Parse Arguments and Validate Input

**Parse the arguments** from `$ARGUMENTS`:

- **Target branch**: Extract the branch name (required argument)
- If no argument provided, show error: "❌ Error: Target branch requerido. Uso: /utils:switch <target_branch>"
- Display: "Switching from temporal branch to: <target_branch>"

### 2. Validate Working Directory

**Check for uncommitted changes** using simple bash command:

- Execute: `git status --porcelain`
- If command returns any output (uncommitted changes exist):
  - Show error: "❌ Error: Hay cambios sin commitear. El switch está bloqueado."
  - Show guidance: "Debes resolver los cambios primero:"
  - Show options: " • git add . && git commit -m 'mensaje' (para guardar cambios)"
  - Show options: " • git stash (para guardar temporalmente)"
  - Show options: " • git checkout -- . (para descartar cambios)"
  - **STOP process completely**
- If no output, show: "✓ Working directory clean, proceeding..."

### 3. Capture Current Temporal Branch

**Get current branch name** using atomic bash command:

- Execute: `git branch --show-current`
- Store the branch name as temporal_branch for later cleanup
- Display: "Leaving temporal branch: <temporal_branch>"

### 4. Check Associated PR Status (if exists)

**Check for GitHub CLI availability**:

- Execute: `command -v gh >/dev/null 2>&1` - if fails, continue to step 5
- Execute: `command -v jq >/dev/null 2>&1` - if fails, continue to step 5

**Check for associated PR**:

- Execute: `gh pr list --head "<temporal_branch>" --state all --json number,state,title 2>/dev/null`
- If output is empty or "[]", continue to step 5
- If output contains JSON data, parse using separate commands:
  - Execute: `gh pr list --head "<temporal_branch>" --state all --json number,state,title 2>/dev/null | jq -r '.[0].number'` to get PR number
  - Execute: `gh pr list --head "<temporal_branch>" --state all --json number,state,title 2>/dev/null | jq -r '.[0].state'` to get PR state
  - Execute: `gh pr list --head "<temporal_branch>" --state all --json number,state,title 2>/dev/null | jq -r '.[0].title'` to get PR title
  - If state is not "MERGED":
    - Show error: "❌ Error: PR asociado a esta rama no está mergeado. El switch está bloqueado."
    - Show details: "PR encontrado: #<pr_number> - <pr_title>"
    - Show status: "Estado actual: <pr_state>"
    - Show requirement: "El PR debe ser mergeado primero en GitHub antes de hacer switch."
    - **STOP process completely**
  - If state is "MERGED":
    - Show: "✓ PR mergeado verificado, continuando switch..."

### 5. Switch to Target Branch

**Perform branch switch** using atomic bash command:

- Execute: `git checkout "<target_branch>"`
- If command fails, show error: "❌ Error: No se pudo cambiar a '<target_branch>'" and stop
- If successful, show: "Switched to: <target_branch>"

### 6. Update from Remote

**Update target branch** using atomic bash command:

- Execute: `git pull`
- If command fails, show warning: "⚠️ No se pudo actualizar desde remoto" but continue
- If successful, show: "Updated from remote"

### 7. Delete Temporal Branch

**Clean up temporal branch** using atomic bash command:

- Execute: `git branch -D "<temporal_branch>"` (using name captured in step 3)
- If successful, show: "🗑️ Deleted temporal branch: <temporal_branch>"
- If fails, show: "⚠️ Could not delete temporal branch: <temporal_branch>"

### 8. Report Final Status

**Verify final state**:

- Execute: `git branch --show-current` to confirm current branch
- Display final status:
  ```
  ✅ Switch completed:
  - Current branch: <current_branch>
  - Temporal branch deleted: <temporal_branch>
  ```

## Error Handling

- **If working directory has changes**: Block switch completely, show resolution options
- **If target branch doesn't exist**: Git will show error, command stops
- **If PR not merged**: Block switch completely, require merge first
- **If remote update fails**: Show warning but continue with cleanup
- **If branch deletion fails**: Show warning but don't block completion

## Important Notes

- Trust git CLI operations (no pre-auth checks)
- Use atomic bash commands only, avoid complex piping
- Each step is independent and verifiable
- No user confirmation prompts during execution
- Sequential execution, stop on critical failures
- Optimized for temporal → target → cleanup workflow
- For CHANGELOG updates use: `/workflow:changelog --pr <number>`

## Implementation Approach

This command uses **natural language instructions** processed by Claude Code's native capabilities rather than complex bash scripting. Claude will:

1. **Parse arguments** intelligently from `$ARGUMENTS`
2. **Execute atomic bash commands** using the Bash tool
3. **Handle GitHub operations** using simple gh commands
4. **Process JSON output** using separate jq commands
5. **Manage flow control** through natural language logic

This approach is more robust than complex bash scripting because:

- No variable persistence issues between commands
- No complex pipe chaining with failure points
- Leverages Claude's natural language processing
- More maintainable and debuggable
- Handles edge cases intelligently
- Each command is atomic and verifiable
