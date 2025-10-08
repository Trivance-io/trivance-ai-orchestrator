# Branch Protection Rules for `main`

**Last updated:** 2025-10-08
**Configured by:** @Dario-Arcos

## Summary

The `main` branch is fully protected to ensure code quality and prevent accidental issues in production.

## Active Protections

| Rule                          | Status    | Description                                            |
| ----------------------------- | --------- | ------------------------------------------------------ |
| **Require Pull Requests**     | ✅ Active | Direct pushes to `main` are blocked                    |
| **Require 1 Approval**        | ✅ Active | PRs need at least 1 approval before merging            |
| **Code Owner Review**         | ✅ Active | @Dario-Arcos must approve all PRs (see CODEOWNERS)     |
| **Require Up-to-Date Branch** | ✅ Active | Branch must be rebased with latest `main` before merge |
| **Dismiss Stale Reviews**     | ✅ Active | New commits invalidate previous approvals              |
| **Conversation Resolution**   | ✅ Active | All review comments must be resolved                   |
| **Enforce for Admins**        | ✅ Active | Rules apply to ALL users (no bypass)                   |
| **Block Force Push**          | ✅ Active | Cannot force push to `main`                            |
| **Block Deletions**           | ✅ Active | Cannot delete `main` branch                            |

## Developer Workflow

### 1. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

### 2. Make Changes & Commit

```bash
# Make your changes
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature-name
```

### 3. Open Pull Request

```bash
# Via CLI
gh pr create --title "Your PR title" --body "Description"

# Or via GitHub UI
# https://github.com/Trivance-io/trivance-ai-orchestrator/compare
```

### 4. Wait for Code Owner Approval

GitHub will automatically request review from @Dario-Arcos (code owner).

**You cannot merge until:**

- ✅ @Dario-Arcos approves your PR
- ✅ All CI checks pass (if any)
- ✅ Your branch is up-to-date with `main`
- ✅ All review comments are resolved

### 5. Update Branch if Needed

If GitHub shows "Branch is out of date":

```bash
# Option A: Rebase (recommended)
git fetch origin
git rebase origin/main
git push --force-with-lease

# Option B: Use GitHub UI
# Click "Update branch" button in PR
```

### 6. Merge When Ready

Once all checks pass and approval is given:

- Click "Merge pull request" in GitHub UI
- Or use: `gh pr merge <pr-number> --rebase`

## Special Cases

### For @Dario-Arcos (Code Owner)

When you open a PR:

- ✅ Auto-approved (you're the code owner)
- ✅ Can merge immediately (if CI passes and branch is up-to-date)
- ❌ Still cannot push directly to `main` (must use PR)

### For Admins

Even admins (@fabiing10, @gracialab, @Dario-Arcos):

- ❌ Cannot bypass branch protection rules
- ❌ Cannot push directly to `main`
- ✅ Must follow the same PR workflow

## Troubleshooting

### Error: "Protected branch update failed"

**Cause:** Attempted direct push to `main`
**Solution:** Use feature branch + PR workflow

### Error: "Review required but not approved"

**Cause:** PR not yet approved by code owner
**Solution:** Wait for @Dario-Arcos review

### Error: "Branch is X commits behind main"

**Cause:** Other PRs merged while you were working
**Solution:** Rebase or click "Update branch"

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

### Error: "Conversation not resolved"

**Cause:** Review comments not marked as resolved
**Solution:** Resolve all comment threads in GitHub UI

## Code Ownership

See `.github/CODEOWNERS` for detailed ownership rules.

**Default owner:** @Dario-Arcos owns all files unless specified otherwise.

## Why These Rules?

1. **Quality:** Every change reviewed before production
2. **Safety:** Prevents accidental breaking changes
3. **Collaboration:** Forces code review and knowledge sharing
4. **Stability:** Up-to-date requirement prevents merge conflicts
5. **Accountability:** Clear approval trail for all changes

## Configuration Details

View full protection config:

```bash
gh api /repos/Trivance-io/trivance-ai-orchestrator/branches/main/protection | jq
```

Or visit: https://github.com/Trivance-io/trivance-ai-orchestrator/settings/branches

---

**Questions?** Contact @Dario-Arcos
