# Gest Codex Workflow

This jj repository keeps the historical filename used by the git template repo,
but the authoritative jj workflow is now:

- `docs/gest_jj_workflow.md`
- `docs/jj_workflow_guide.md`
- `docs/g_commands_cheatsheet.md`

Codex-specific rule of thumb:

- hooks provide SessionStart context, raw git write guardrails, and cheap
  snapshots
- skills own jj workspace orchestration
- `gcm` owns jj commit/bookmark/push checkpoints
- `gpa` owns GitHub PR review packets

Do not use git worktrees in jj repos. Use `jj workspace add` and
`jj workspace forget`.
