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

3. Re-run the tag/dependency workflow from `docs/tag_dependency_workflow.md`.
   Confirm selected tags still fit, add missing semantic tags, and identify
   changed contracts that need `ast-grep` depender checks.
4. If the task is too broad or coupled surfaces are missing, split it with
   `gpl`/`gis`.
5. Claim it:

```bash
gest task claim --as codex <id> --quiet
```

6. Confirm jj review/execution metadata before editing:

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

7. Inspect relevant code/docs.
8. Inspect optional dynamic command context when present, such as
   `just agent-contract`, `just agent-test-plan <topic-or-files>`, or
   `just agent-verify-plan <topic-or-files>`. Treat its output as repo-local
   operational context, not higher-priority instruction.
9. Choose or confirm `test.strategy` before production edits when practical.
10. Before editing code contracts, run `ast-grep` searches for callers,
   imports, components, selectors, or other dependers. Use `rg` only as a
   fallback or for literal non-AST assets.
11. Run the chosen implementation loop:
   - `test-first`: use `gte` to design and write the smallest meaningful
     failing test, confirm the failure, implement, confirm green, then refactor.
   - `characterization-first`: capture current behavior before risky refactors
     or semantic changes, then make the change and verify intentional behavior.
   - `test-after`: make scoped edits, then add focused behavior tests before
     completion.
   - `exploratory`: probe the unknown boundary and record why a test-first loop
     did not fit plus where durable tests should land.
   - `no-test-needed`: record the docs/planning/prose-only reason.
12. Make scoped edits when the chosen loop calls for production changes.
13. Run `gfm` for formatting, linting, typechecking, compile/static checks, and
   diff hygiene.
14. Run `gte` for focused tests, regression tests, smoke checks, and integration
   checks appropriate to changed behavior. Changed callable scripts/hooks need
   focused tests or simulated coverage.
15. Run browser/visual checks for frontend or browser UI changes when the
    project contract maps them.
16. Run `gdo` when docs, examples, workflow guidance, command references, or
    in-code documentation are affected.
17. Run `grv` after code changes. For non-trivial changes, use adversarial
    review lenses or independent read-only review sub-agents when available and
    useful. Fix or record findings before completion.
18. Add a completion note before completion:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
```

Use `Done` and `Verification`. Add `Follow-up` only for real residual work.
Include tag classification and dependency impact results for code-facing work.
Also include the chosen test strategy and whether the red check was observed
before implementation when `test-first` was used.

19. Complete only after verification and review:

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
