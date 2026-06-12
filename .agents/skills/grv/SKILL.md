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

Review the task's tag classification and dependency impact notes from
`references/tag_dependency_workflow.md`. If code contracts changed, inspect the
`ast-grep` patterns that were run and the dependers they found.

For non-trivial changes, act as an adversarial review aggregator. Default to
independent read-only review sub-agents when sub-agents are available,
authorized, and the lenses can be checked independently; skip sub-agents only
when they are unavailable, unsafe, or overkill for a tiny change. Apply distinct
review lenses:

- correctness and regression risk
- test adequacy and missing edge cases
- jj bookmark/workspace safety
- docs, setup, and command-contract drift
- security, privacy, or data safety when relevant
- browser/UI behavior when relevant
- language/runtime idioms when the project profile is known

If sub-agents are not used, run the lenses explicitly yourself. Writable
sub-agents still require separate jj workspaces. Gest mutations, task
completion, commits/bookmarks/pushes, and PR decisions should remain
centralized unless deliberately assigned.

Test review should ask:

- Would the new or changed test fail against the old code?
- Does it assert behavior rather than implementation trivia?
- Are semantic dependers and edge cases covered?
- Does the test scope match the workflow kind, blast radius, and
  `test.strategy`?

## Review Checklist

Findings first, ordered by severity, with file/line references. Treat
`Findings: None` as a precise statement about blocking or actionable code-review
findings, not as the whole review.

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
- missing tag classification for newly created or expanded tasks
- missing `ast-grep` dependency impact checks for changed code contracts
- dependent surfaces found by tags or ast-grep that were not updated, tested,
  or turned into follow-up tasks
- reusable workflow changes that collapse GitButler and jj semantics, describe
  jj bookmarks as auto-advancing branches, allow raw git writes in jj repos, or
  use git worktrees instead of jj workspaces
- `cx` workflow changes that use `cx` for tests, lint, format, typecheck,
  ordinary package-manager builds, or commands without durable file outputs;
  miss real `--in` inputs or `--out` outputs; rely on missing producer/consumer
  Just ordering; or ignore `.cx` in a way that hides future config

After findings, add reviewer judgment when it would help the user: call out
non-blocking opinions about clarity, maintainability, UX, naming, fit with local
patterns, jj workflow shape, or tradeoffs. Label these separately from findings
so taste-level feedback does not look like a merge blocker.

If no issues are found, say so clearly, then still mention residual risk, test
gaps, and any useful non-blocking observations.

Missing focused tests for changed callable code, hooks, scripts, or public APIs
are review findings, not just nice-to-have follow-ups.
