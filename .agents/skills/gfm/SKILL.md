---
name: gfm
description: Gest Format. Run formatting, linting, typechecking, compile/static checks, and mechanical diff hygiene; fix mechanical issues. Use gte for tests and gdo for documentation.
---

# GFM: Gest Format

Use to mechanically clean and statically check a changeset. `gfm` does not own
runtime tests or documentation checks; route those to `gte` and `gdo`.

## Workflow

1. Identify the project root and changed files.
2. Read the command contract in `AGENTS.md`, especially `just` mappings and
   focused-argument guidance.
3. Run formatting, linting, typechecking, compile/static checks, and diff
   hygiene appropriate to the project.
4. Fix mechanical issues.
5. Re-run failing checks.
6. Report every command run and whether it passed.

Prefer project-specific `just` targets. Common concepts:

```bash
just fmt [path]
just lint [path]
just typecheck
just static
just build
just diff-check
```

For jj repos, inspect changes with:

```bash
jj status
jj diff
jj diff --summary
```

Use raw git only for read-only inspection or for a command-contract diff check
that intentionally validates the colocated git patch. Do not use raw git write
commands or git worktrees.

If no command contract exists, inspect manifests and route to `gsu` to establish
one before guessing language-specific tools.
