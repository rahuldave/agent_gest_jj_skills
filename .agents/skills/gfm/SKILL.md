---
name: gfm
description: Gest Format. Run formatting, linting, typechecking, static checks, and jj diff hygiene.
---

# GFM: Gest Format

Read `AGENTS.md` for the project command contract. Prefer `just` targets.

Common commands:

```bash
just fmt [path]
just lint [path]
just typecheck
just static
just build
just diff-check
jj diff
```

Fix mechanical issues and rerun failing checks. Do not use raw git write
commands in jj repositories.
