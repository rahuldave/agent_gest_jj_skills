# Gest JJ Workflow

This document defines how agents should use Gest, jj, GitHub, Claude hooks, and
Codex hooks in repositories that install this skill family.

## Core Model

Keep three concepts separate:

- **Gest hierarchy**: durable product/workflow memory using tasks, artifacts,
  iterations, notes, and metadata.
- **Review model**: how work becomes reviewable, usually a jj bookmark or a
  stack of bookmarks.
- **Execution model**: where agents are allowed to write, usually the current
  jj workspace or one jj workspace per independent task.

The important jj shift is that workspaces share the same commit graph. A worker
in a jj workspace does not produce a branch that must be merged back. Its
commits are immediately part of the shared repo history. Cleanup removes the
workspace checkout and metadata.

## JJ Basics

The working copy is a commit named `@`. Use `jj describe -m "<message>"` to
label the current working-copy commit while continuing to edit. Use
`jj commit -m "<message>"` to finalize the current working-copy commit and
advance to a fresh empty `@`. `jj new` advances to a fresh `@` without a final
message.

Bookmarks are named pointers, not branches. They do not advance automatically.
Use `jj bookmark set <name> -r @-` or `jj bookmark move <name> --to @-` before
pushing with `jj git push --bookmark <name>`.

For a fresh GitHub-backed repo:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
# edit files
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
```

## Metadata

Use metadata for machine-queryable workflow facts:

```text
workflow.kind=session|development
depth=<0-3>
github.issue=<number>
github.url=<url>
github.pr=<number>
github.pr_url=<url>
vcs.tool=jj
vcs.base_bookmark=main
vcs.base_change=<change-id>
vcs.review_mode=session-bookmark|development-bookmark|multi-commit-bookmark|stacked-session|stacked-development|parallel-workspaces
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark-name>
vcs.stack_root=<bookmark-name>
vcs.stack_parent=<bookmark-name>
vcs.stack_index=<n>
vcs.workspace_path=<absolute-path>
vcs.integration=bookmark-pr|stacked-pr|local-only
vcs.owner_session=<thread-or-agent-label>
vcs.write_scope=<paths-or-subsystems>
classification.tags.reviewed=true|false
classification.tags.new=<comma-separated-new-tags>
impact.ast_grep.required=true|false
impact.semantic_tags=<comma-separated-tags>
```

## Tag And Dependency Impact

Every new Gest task should run a tag classification pass against existing task,
artifact, and iteration tags. Existing semantic tags are preferred; new dynamic
tags are allowed when they capture a real missing concept. For code-facing
changes, use `ast-grep` to find callers, imports, components, and other
dependers of changed contracts. Use `docs/tag_dependency_workflow.md` for the
full checklist and completion-note shape.

## GTW

`gtw` is the router. Before writing files, it decides:

1. Is this tiny, session-shaped, or development-shaped?
2. Does it need `gsp` before implementation?
3. Which durable parent task owns the work?
4. Which tags and metadata apply?
5. Is the review model a single bookmark, multi-commit bookmark, or bookmark stack?
6. Is execution local or one jj workspace per independent task?
7. Is GitHub issue promotion appropriate?
8. Which stage skill owns the next step?
9. Is this already a commit/bookmark/push checkpoint?

## Planning

Use `gsp` for unclear or substantial behavior. Use `gpl` to split the spec into
tasks and phases. Tasks in the same phase must be independent enough to run in
separate jj workspaces.

Use `gis` to create durable outline issues. Use `gim` for one concrete task.
Use `gor` for phased iterations.

## JJ Execution

Single coherent work:

```bash
jj status
jj diff
# edit, verify, review
jj commit -m "<conventional message>"
jj bookmark set <bookmark> -r @-
jj git push --bookmark <bookmark>
```

LazyJJ stack work:

```bash
jj start
jj create <bookmark>
jj stack
jj ss
```

Stacked PR preparation:

```bash
jst submit <top-bookmark> --dry-run
```

Parallel independent work:

```bash
jj workspace add ../gest-<task-id> --name <task-id> -r @
(cd ../gest-<task-id> && gest project attach <project-id>)
# worker runs in that workspace
(cd ../gest-<task-id> && gest project detach)
jj workspace forget <task-id>
rm -rf ../gest-<task-id>
```

Do not use git worktrees in jj repos. Do not use raw git write commands.

## Claude Hooks

Claude can use hook lifecycle events to map worktree isolation to jj:

- `SessionStart`: inject workflow and jj context.
- `PreToolUse(Bash)`: block raw git writes and inject commit conventions.
- `PreToolUse(Write|Edit)`: inject source style/testing docs.
- `WorktreeCreate`: run `jj workspace add`.
- `WorktreeRemove`: run `jj workspace forget` and remove the checkout.
- `Stop`: run a cheap `jj status` snapshot.

The WorktreeCreate/Remove wrappers are the first Claude-specific behavior to
validate in a target repo, because Claude's worktree payload schema may evolve.

## Codex Hooks

Codex hooks are useful for context and guardrails, but Codex does not currently
document a WorktreeCreate/WorktreeRemove hook equivalent. Therefore:

- `gtw` and `gor` own jj workspace planning and creation.
- `gim` assumes it is running in its assigned workspace.
- `gcm` owns jj commit/bookmark/push decisions.
- Codex hooks block raw git write commands and can run cheap snapshots.

## Commit, Push, And PR

Use `gcm` at durable checkpoints. A jj checkpoint normally includes:

```bash
jj status
jj diff
jj commit -m "<message>"
jj bookmark set <bookmark> -r @-
jj git push --bookmark <bookmark>
```

For stacked PRs, use LazyJJ for local stack ergonomics and prefer `jj-stack` for
GitHub PR creation/update when prerequisites exist:

```bash
jj stack
jj ss
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

Run `gpa` after pushing a non-mainline bookmark and creating/updating a PR.
Merge only with explicit user approval.

## Verification

Use `gfm` for formatting/static checks, `gte` for tests and smoke/integration
checks, `gdo` for docs, and `grv` for a review pass after every code change.

Use `scripts/run_jj_workflow_lab.sh` to exercise the four supported situations:
plain bookmark review, multi-commit session bookmark, LazyJJ/jj-stack stack
workflow, and parallel jj workspaces.
