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

Use jj bookmarks as the branch-like review units for GitHub PRs. Use jj
workspaces as the parallel write primitive. Do not mix git worktrees with jj
workspaces in this repository.

Typical commands:

```bash
jj status
jj diff
jj log
jj commit -m "<message>"
jj describe -m "<message>"
jj new <revision>
jj bookmark create <name> -r @-
jj bookmark move <name> --to @-
jj git push --bookmark <name>
jj workspace add <path> --name <name> -r @
jj workspace forget <name>
```

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
highest meaningful Gest task for the workstream, for example:

```text
gest/<task-id-short>-two-word-summary
session/<task-id-short>-two-word-summary
```

Use one bookmark for one coherent workstream. Use stacked bookmarks for multiple
meaty dependent slices that should be separately reviewable. Use jj workspaces
for multiple independent write tasks running at the same time.

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

Development work should commit at verified durable checkpoints. In jj, a commit
checkpoint usually means:

```bash
jj status
jj diff
jj commit -m "<conventional message>"
```

If the work should become reviewable on GitHub, create or move a bookmark to the
completed commit:

```bash
jj bookmark create <bookmark> -r @-
# or
jj bookmark move <bookmark> --to @-
```

Then push with jj:

```bash
jj git push --bookmark <bookmark>
```

For stacked PRs, prefer `jj-stack`:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

After pushing a non-mainline bookmark, create/update the PR, run `gpa`, report
the PR review findings/state to the user, and ask whether to merge. Do not
merge unless the user explicitly asked for that merge in the current turn or
gives approval after the `gpa` packet.

## Claude And Codex Hooks

Claude Code:

- `.claude/settings.json` wires jj SessionStart reminders, source/commit
  context hooks, raw git write guardrails, and WorktreeCreate/WorktreeRemove.
- Claude's `isolation: "worktree"` is mapped to `jj workspace add` and
  `jj workspace forget`.

Codex:

- `.codex/hooks.json` wires SessionStart and raw git write guardrails.
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
jj diff
```

Use `gfm` for formatting, linting, typechecking, compile/static checks, and
diff hygiene. Use `gte` for unit tests, API regression tests, smoke checks, and
integration tests. Use `gdo` to check and update user-facing docs,
developer-facing docs, and in-code docs.
