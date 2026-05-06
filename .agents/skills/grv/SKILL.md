---
name: grv
description: Gest Review. Review the current jj changeset for correctness, safety, regressions, VCS policy, and missing tests.
---

# GRV: Gest Review

Use for code-review stance after every code change before completing the task.

## Workflow

Inspect:

```bash
jj status
jj diff
jj diff --summary
```

If reviewing a specific commit/change, diff that revision:

```bash
jj diff -r <rev>
jj show <rev>
```

Search Gest for prior regressions and review findings:

```bash
gest search "<module/feature> regression" --all --json --limit 20
gest search "<module/feature> review" --all --json --limit 20
gest search "Follow-up <module/feature>" --all --json --limit 20
```

## Review Checklist

Findings first, ordered by severity, with file/line references:

- correctness, regressions, safety, error handling
- missing tests for changed callable code or scripts
- docs drift for changed workflow behavior
- setup/installer impact
- raw git write commands in jj repos
- git worktrees instead of jj workspaces
- bookmark flows that assume bookmarks advance automatically
- stack flows that lack LazyJJ/jj-stack/PR review guidance
- Codex plans that assume a WorktreeCreate/Remove hook exists
- Claude WorktreeCreate/Remove wrappers that are not tested with payloads
- structural ordering and test convention violations when project docs define
  them; in jj-profile repos these may be blocking findings

If no issues are found, say so clearly and mention residual risk or test gaps.

Missing focused tests for changed callable code, hooks, scripts, or public APIs
are review findings, not just nice-to-have follow-ups.
