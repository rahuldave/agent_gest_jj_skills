---
name: gsu
description: Gest Setup. Bootstrap or refresh a jj/Gest agent-operable repository surface.
---

# GSU: Gest Setup

Use when a repo needs first-time setup, command-contract normalization, hook
wiring, ignore rules, local tools, or installation of this skill family.

## Workflow

1. Inspect repository shape: jj/git state, `.gitignore`, `AGENTS.md`, `Justfile`,
   `.agents`, `.claude`, `.codex`, docs, tests, and package manifests.
2. Initialize jj only after confirming the repo root:

```bash
jj git init --colocate
```

3. Check tools: `jj`, `gest`, `just`, `gh`, and optionally `jst`.
4. Define the command contract in `AGENTS.md`.
5. Create/update `.claude` and `.codex` hook adapters.
6. Run the cheapest setup checks.
7. Record setup gaps as Gest follow-ups.

Do not add GitButler or git-worktree policy to jj repos. Use jj bookmarks and
jj workspaces.
