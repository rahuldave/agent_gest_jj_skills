# Agent Instructions

This repository uses Gest to track substantial implementation work and
Jujutsu (`jj`) for version control. Use the project-local skill family under
`.agents/skills/`, especially `gtw`, for coding, debugging, implementation,
refactoring, documentation, verification, and project planning.

The user may invoke the router as `$gtw`, `gtw:`, or `/gtw`.
Use `gsu` for repository bootstrap, setup refresh, tool selection, ignore
rules, installs, command-contract mapping, and Justfile creation.

If a request is substantial enough for Gest tracking but no `g*` command was
explicitly invoked, still use the appropriate Gest workflow. If an agent chooses
not to use Gest for a coding/debugging/refactoring/documentation/verification
request, it must say why in the final response.

## Project Context

- Project name: `<replace-me>`
- Main source directory: `<replace-me>`
- Primary docs/specs: `<replace-me>`
- Detailed workflow playbook: `docs/gest_jj_workflow.md`
- Hands-on jj workflow guide: `docs/jj_workflow_guide.md`

Replace this section with project-specific invariants, runtime commands, and
verification commands.

## JJ Workflow

This is a colocated jj/git repository. Use `jj` for write operations. Do not use
raw git write commands such as `git commit`, `git switch`, `git checkout`,
`git branch`, `git worktree`, `git merge`, `git rebase`, `git reset`,
`git clean`, or `git push`.

Allowed raw git usage is read-only inspection when it clarifies GitHub state,
such as `git status`, `git log`, `git diff`, `git remote -v`, and
`git ls-remote`. Prefer `jj status`, `jj log`, `jj diff`, `jj bookmark`, and
`jj git ...` commands.

### Working-Copy Commit

In jj, the working copy is a commit named `@`. There is no staging area.
Commands such as `jj status`, `jj log`, and `jj diff` snapshot the filesystem
into `@` before they run.

Use:

```bash
jj describe -m "<message>"
```

to label the current working-copy commit while continuing to edit it.

Use:

```bash
jj commit -m "<message>"
```

to finalize the current working-copy commit and advance to a fresh empty `@`.
`jj new` also advances to a fresh `@`; use it for workflow boundaries when a
description is already set or not yet needed.

`@-` is the parent of the current working-copy commit. `root()` is the virtual
root commit.

### GitHub-Backed Init

For a new GitHub-backed jj repo, use this baseline:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
```

At this point there is no special `main` bookmark and no `main@origin`.
After the first meaningful change:

```bash
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
jj bookmark list --all
```

After the push, local `main`, `main@git`, and `main@origin` should exist.

### Bookmarks

Use jj bookmarks as branch-like review handles for GitHub PRs. Bookmarks are
not branches, they are named pointers, and they do not advance automatically.

Typical commands:

```bash
jj bookmark set <name> -r @-
jj bookmark create <name> -r @-
jj bookmark move <name> --to @-
jj bookmark list --all
jj git push --bookmark <name>
```

Use LazyJJ aliases for local stack ergonomics when available:

```bash
jj start
jj create <bookmark>
jj tug
jj stack
jj top
jj sync
jj ss
```

For stacked PRs, prefer `jj-stack` when GitHub remote/auth prerequisites are
available:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

LazyJJ PR aliases such as `jj sprs`, `jj prs`, and `jj uprs` may also be useful
when configured. They are convenience wrappers, not the required orchestration
layer.

### Workspaces

Use jj workspaces as the parallel write primitive. Do not mix git worktrees
with jj workspaces.

```bash
jj workspace add <path> --name <name> -r @
jj workspace forget <name>
```

JJ workspaces share the same commit graph and op log. Commits made in one
workspace are visible in every other workspace; no merge-back is required.

## Gest Workflow

Before creating new tasks, search and inspect existing work:

```bash
gest search "<project keyword>" --all --json
gest task list --all --json
gest iteration list --all --json
```

Use native Gest `child-of` / `parent-of` links for hierarchy. Tags are filters,
not hierarchy. Claim one leaf task at a time, verify before completion, and keep
long-lived outline parents open until the whole subtree is done.

For any Gest-tracked work that writes files, choose a jj review model and
execution model before editing. Review bookmark names should be keyed to the
highest meaningful Gest task for the workstream:

```text
gest/<task-id-short>-two-word-summary
session/<task-id-short>-two-word-summary
```

Review modes:

- `session-bookmark`: one tactical bookmark.
- `development-bookmark`: one durable bookmark.
- `multi-commit-bookmark`: one bookmark pointing at a related commit chain.
- `stacked-session`: dependent session slices reviewed as a bookmark stack.
- `stacked-development`: dependent development slices reviewed as stacked PRs.
- `parallel-workspaces`: independent writable slices executed in jj workspaces.

Execution modes:

- `main-workspace`: one agent writes in the current jj workspace.
- `jj-workspaces`: one jj workspace per independent writable task.

Record VCS metadata when work is substantial:

```text
vcs.tool=jj
vcs.base_bookmark=main
vcs.review_mode=session-bookmark|development-bookmark|multi-commit-bookmark|stacked-session|stacked-development|parallel-workspaces
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark-name>
vcs.stack_root=<bookmark-name>
vcs.stack_parent=<bookmark-name>
vcs.stack_index=<n>
vcs.workspace_path=<absolute-path>
```

For non-trivial completed leaf tasks, add a Gest task note before completion:

```bash
gest task note add <task-id-or-prefix> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
gest task complete <task-id-or-prefix> --quiet
```

Use task metadata for machine-queryable facts, not prose work logs.

## Commit Cadence

Committing is VCS hygiene, not a Gest task by itself. Do not create a Gest task
whose only purpose is making a normal commit.

Session work should not commit every small leaf by default. Commit when the user
asks, when a coherent checkpoint helps, or when a long-lived parent/subtree
reaches a stable point.

Session classification alone is not a reason to skip `gcm`. A verified slice is
a commit-required checkpoint when it changes deployment/runtime configuration,
persistence, migrations, schemas, public APIs, user-visible UI, reusable
workflow material, publishable docs/templates, or a non-trivial multi-file
changeset.

Development work should commit at verified durable checkpoints such as a
completed depth-1 workstream, coherent depth-2 implementation subtree, handoff,
risky bug/migration fix, or GitHub issue/PR sync.

For reviewable work, create/move the bookmark explicitly after the commit:

```bash
jj commit -m "<conventional message>"
jj bookmark set <bookmark> -r @-
jj git push --bookmark <bookmark>
```

After pushing a non-mainline bookmark, create/update the PR, run `gpa`, report
the PR review findings/state to the user, and ask whether to merge. Do not merge
unless the user explicitly asked for that merge in the current turn or gives
approval after the `gpa` packet.

## Claude And Codex Hooks

Claude Code:

- `.claude/settings.json` wires jj SessionStart reminders, source/commit
  context hooks, raw git write guardrails, and WorktreeCreate/WorktreeRemove.
- Claude's `isolation: "worktree"` is mapped to `jj workspace add` and
  `jj workspace forget`.

Codex:

- `.codex/hooks.json` wires SessionStart, raw git write guardrails, and cheap
  snapshots.
- Codex does not currently expose a documented WorktreeCreate/WorktreeRemove
  equivalent, so `gtw`/`gor`/`gim` own jj workspace creation and cleanup.

## Project Command Contract

Prefer a `Justfile` as the stable executable interface when present. Replace
these placeholders with the project-specific mappings and arguments:

```bash
<setup command>
<format command or just fmt [path]>
<lint command or just lint [path]>
<typecheck command or just typecheck>
<static/compile command or just static>
<build command or just build>
<focused test command or just test [target]>
<full test command or just test>
<smoke command or just smoke>
<run app command or just dev [port]>
<browser setup command or just browser-setup>
<browser spot check command or just browser [url-or-flow]>
<integration flow or just integration [flow]>
<docs command or just docs>
<diff hygiene command>
```

For Just, target parameters are passed positionally: `just lint src/foo.ts`,
`just test tests/foo.test.ts`, or `just dev 3000`.

When changing Just recipes, consult:

- Just dependencies: https://just.systems/man/en/dependencies.html
- Just skill reference: https://raw.githubusercontent.com/casey/just/refs/heads/master/skills/just/SKILL.md

Use native recipe dependencies when one recipe composes other recipes, such as
`verify: lint typecheck static test smoke diff-check`.

Use `gfm` for formatting, linting, typechecking, compile/static checks, and
diff hygiene. Use `gte` for unit tests, API regression tests, smoke checks, and
integration tests. Use `gdo` to check and update user-facing docs,
developer-facing docs, and in-code docs.

Recommended test layout:

- `tests/`: inner-function and focused callable-code unit tests.
- `regression_tests/`: bug and API regression tests.
- `integration_tests/`: end-to-end and browser-agent-driven checks.

For frontend, browser UI, or interaction changes, use the mapped browser
spot-check command to inspect the running app visually and exercise the relevant
interaction flow. Browser integration tests are durable rerunnable checks.
