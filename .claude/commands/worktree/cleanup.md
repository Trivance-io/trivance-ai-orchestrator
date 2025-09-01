---
allowed-tools: Bash(git *), Bash(test *), Bash(mkdir *), Bash(date *), Bash(whoami), Bash(echo *), Bash([[ ]])
description: Safe removal of specific worktrees with ownership validation and discovery mode
---

# Worktree Cleanup

Safe removal of specific worktrees with ownership validation and discovery mode.

## Usage
```bash
/worktree:cleanup                                        # Discovery mode: lista worktrees disponibles
/worktree:cleanup <worktree1> [worktree2] [worktree3]   # Cleanup mode: eliminar específicos
```

## Examples
```bash
/worktree:cleanup                                        # Lista tus worktrees con comandos sugeridos
/worktree:cleanup worktree-feature-auth                 # Eliminar uno específico  
/worktree:cleanup worktree-hotfix worktree-refactor     # Eliminar múltiples
```

## Restrictions
- Only removes worktrees and branches created by you
- Never touches protected branches (main, develop, qa, staging, master)
- Requires clean state (no uncommitted changes)

## Execution

### Discovery Mode (no arguments)
If no arguments are provided, the command lists your available worktrees with suggested commands.

### Cleanup Mode (with arguments)
When executing with specific arguments, follow these steps:

### 1. Validation and preparation
- Validate each target using single-pass validation
- Create list of valid targets (skip invalid ones with warnings)
- If no valid targets: show "ℹ️ No hay worktrees válidos para eliminar" and terminate

### 2. Per-target validations (individual steps)
For each worktree target, execute validations in order:

**2a. Format validation:**
- Verify name using regex: `[[ "$target" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]`
- If fails: skip with message "Formato de nombre inválido"

**2b. Protected branch validation:**
- Verify it's not in array: `("main" "develop" "qa" "staging" "master")`
- If protected: skip with message "Rama protegida"

**2c. Current directory validation:**
- Execute validation defined in section 3
- If matches current directory: skip with specific error

**2d. Existence validation:**
- Verify it exists as worktree using `git worktree list --porcelain`
- If doesn't exist: skip with message "Worktree no encontrado"

**2e. Ownership validation:**
- Verify ownership using cross-platform logic from section 4
- If not user's: skip with message "No es tu worktree"

**2f. Clean state validation:**
- Verify no uncommitted changes: `git status --porcelain` in the worktree
- If not clean: skip with specific problem message

### 3. Current directory validation (CRITICAL SECURITY)
For each worktree target, verify the user is not trying to delete the worktree they are standing in:
- Get canonical path of current directory: `current_dir="$(realpath "$(pwd)" 2>/dev/null)"`
- Si falla obtener path actual: mostrar error "❌ Error: No se pudo resolver directorio actual" y terminar
- Get worktree target path using safe parsing: `git worktree list --porcelain | awk` with strict validation
- If target not found: continue (will be handled by another validation)
- Get canonical path of target: `target_path="$(realpath "$target_path" 2>/dev/null)"`
- Si falla obtener path del target: mostrar error "❌ Error: No se pudo resolver path del worktree target" y skip
- Compare canonical paths: if `"$current_dir" == "$target_path"` then:
  - Mostrar error: "❌ Error: No puedes eliminar el worktree donde estás actualmente"
  - Show current location and specific solution
  - Skip this target with warning

### 4. Cross-platform compatibility
To verify file ownership, use automatic OS detection:
- If `"$OSTYPE"` starts with "darwin": use command `stat -f %Su "$path"`
- If not (Linux/others): use command `stat -c %U "$path"`
- Compare result with `$(whoami)` to verify ownership
- If doesn't match: skip this target with ownership warning

### 5. User confirmation
- Show summary of valid targets
- Request confirmation: "Escribir 'ELIMINAR' para confirmar:"
- If confirmation != "ELIMINAR": cancel and terminate

### 6. Dual atomic cleanup
For each confirmed target:
- Remove worktree: `git worktree remove "$target"`
- Remove local branch: `git branch -D "$branch_name"`

### 7. Logging and final cleanup
- Log operation in JSONL format
- Execute `git remote prune origin`
- Show final results report

## Discovery Mode Implementation

When executed without arguments, follow these steps:
- Mostrar: "🔍 Tus worktrees disponibles para eliminar:"
- Get canonical path of current directory: `current_canonical="$(realpath "$(pwd)" 2>/dev/null)"`
- If fails to get current path: show error and terminate
- Execute `git worktree list --porcelain` and process each line:
  - For lines starting with "worktree": extract path as `worktree_path`
  - Get canonical path of worktree: `worktree_canonical="$(realpath "$worktree_path" 2>/dev/null)"`
  - If fails to get canonical path: skip this worktree
  - If `worktree_canonical` equals `current_canonical`: skip (it's current directory)
  - Verify basic ownership using cross-platform function
  - If owner is current user: show suggested command with format `"   /worktree:cleanup $worktree_name"`

## Logging Format Template

For each processed target, add line to JSONL file:

```json
{"timestamp":"$(date -Iseconds)","operation":"worktree_cleanup","target":"$target","user":"$(whoami)","my_email":"$(git config user.email)","worktree_removed":"$worktree_removed","local_removed":"$local_removed","local_only":true,"commit_sha":"$(git rev-parse HEAD)"}
```

## Implementation Principles
- **Single-pass validation**: One function, one pass, graceful degradation
- **Current-directory protection**: Does not allow deleting the worktree you are standing in
- **Cross-platform**: Auto-detection macOS/Linux
- **Discovery-first**: Helps user find worktrees
- **Backward compatibility**: Existing arguments work the same
- **Atomic operations**: Complete cleanup or skip with warning