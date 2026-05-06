---
name: grv
description: Gest Review. Review the current jj changeset for correctness, safety, regressions, VCS policy, and missing tests.
---

# GRV: Gest Review

Inspect:

```bash
jj diff
jj status
jj log -r 'trunk()..@ | @' --no-pager
```

Review findings first, ordered by severity, with file/line references. Focus on
bugs, regressions, safety, error handling, and missing tests.

For workflow changes, flag:

- raw git write commands in jj repos
- use of git worktrees instead of jj workspaces
- Codex plans that assume a WorktreeCreate/Remove hook exists
- stacked PR flows that lack bookmark/push/PR review guidance
- missing focused tests for changed callable scripts/hooks

If no issues are found, say so clearly and mention residual risk.
