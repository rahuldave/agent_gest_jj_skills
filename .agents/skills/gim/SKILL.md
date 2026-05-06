---
name: gim
description: Gest Implement. Implement one concrete Gest task end to end inside the assigned jj workspace.
---

# GIM: Gest Implement

Use for one concrete implementable Gest task.

## Workflow

1. Read the task:

```bash
gest task show <id> --json
gest task note list <id> --json
```

2. Search Gest memory for the task area:

```bash
gest search "<feature/module/symptom>" --all --json --limit 20
gest search "Follow-up <feature/module>" --all --json --limit 20
```

Carry forward real `Follow-up` items and verification constraints.

3. If the task is too broad, split it with `gpl`/`gis`.
4. Claim it:

```bash
gest task claim --as codex <id> --quiet
```

5. Confirm jj review/execution metadata before editing:

```text
vcs.tool=jj
vcs.review_mode=...
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark>
vcs.workspace_path=<absolute-path>
```

If the task was assigned to a jj workspace, work in that workspace and do not
create another workspace layer. If `vcs.execution=jj-workspaces`, each parallel
worker must have a distinct `vcs.workspace_path`.

6. Inspect relevant code/docs.
7. Make scoped edits.
8. Run `gfm` for formatting, linting, typechecking, compile/static checks, and
   diff hygiene.
9. Run `gte` for focused tests, regression tests, smoke checks, and integration
   checks appropriate to changed behavior. Changed callable scripts/hooks need
   focused tests or simulated coverage.
10. Run browser/visual checks for frontend or browser UI changes when the
    project contract maps them.
11. Run `gdo` when docs, examples, workflow guidance, command references, or
    in-code documentation are affected.
12. Run `grv` after code changes. Fix or record findings before completion.
13. Add a completion note before completion:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
```

Use `Done` and `Verification`. Add `Follow-up` only for real residual work.

14. Complete only after verification and review:

```bash
gest task complete <id> --quiet
```

## JJ Guardrails

Use `jj` for VCS writes. Do not use raw git write commands or git worktrees in
jj repos.

Helpful inspection:

```bash
jj status
jj diff
jj log -r 'trunk() | mutable() | @' --no-pager
jj bookmark list --all
```

Use `jj describe -m "<message>"` to label a working-copy commit while
continuing work. Use `jj commit -m "<message>"` to finalize a complete change
and advance to a fresh `@`. Use `gcm` for durable commit/bookmark/push
checkpoints.

## Checks

Use the project command contract in `AGENTS.md`; prefer `just` targets when
mapped. Typical concepts include:

```bash
just fmt [path]
just lint [path]
just typecheck
just static
just test [target]
just regression [target]
just integration [target]
just smoke
just verify
```

If the project has no command contract, route to `gsu` before assuming
language-specific tools.
