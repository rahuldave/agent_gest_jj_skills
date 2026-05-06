# Claude Code Bridge

Use `AGENTS.md` as the source of truth for workflow instructions.

This repository is jj-native. Claude hooks in `.claude/settings.json` should be
reviewed before use in a target repo. The important behavior is:

- use `jj` commands for VCS writes
- block raw git write commands in jj repositories
- map Claude worktree isolation to `jj workspace` creation/removal
- use `g*` skills for Gest planning, implementation, verification, docs, review,
  PR acceptance, and commits

When working on reusable workflow changes, use `/gtw` or the relevant `g*`
skill. Keep `.claude/skills` symlinks aligned with `.agents/skills`.
