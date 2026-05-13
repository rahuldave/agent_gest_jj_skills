# Gest-Codex JJ Workflow

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

JJ workspaces share a commit graph and operation log. A worker in a jj workspace
does not produce a branch that must be merged back. Its commits are already
visible to every workspace. Cleanup removes checkout and workspace metadata,
not the commits.

## JJ Mental Model

In jj, the working copy is a commit named `@`. There is no staging area.

- `jj describe -m "<message>"` labels the current working-copy commit and keeps
  editing on it.
- `jj commit -m "<message>"` labels/finalizes the current working-copy commit
  and advances to a fresh empty `@`.
- `jj new` advances to a fresh empty `@`; use it when the current commit is
  already described or when a temporary boundary is intended.
- `@-` is the parent of `@`.
- `root()` is the virtual root commit.

Bookmarks are named pointers, not branches, and they do not advance
automatically. Create or move them explicitly before pushing:

```bash
jj bookmark set <bookmark> -r @-
jj git push --bookmark <bookmark>
```

Remote bookmark positions appear as `<bookmark>@<remote>`, such as
`main@origin`.

## GitHub-Backed Initialization

For a fresh repo that should immediately exist on GitHub:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
```

There is no special `main` bookmark yet. After the first meaningful edit:

```bash
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
jj bookmark list --all
```

After the push, the bookmark list should include local `main`, `main@git`, and
`main@origin`.

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

Before creating or splitting tasks, classify the task against the current
project tag vocabulary from tasks, artifacts, and iterations. Prefer existing
semantic tags and add dynamic tags only when a real missing concept appears.
Record selected/new/rejected tags in task tags, metadata, or a note. See
`docs/tag_dependency_workflow.md`.

For code-facing work, use `ast-grep` to inspect semantic dependers of changed
contracts. If a tag or dependency search reveals coupled surfaces, expand the
task or create linked children before implementation. This is how a histogram
color change should discover probability pills or legends that encode the same
count/probability color semantics.

## GTW

`gtw` is the router. Before writing files, it decides:

1. Is this tiny, session-shaped, or development-shaped?
2. Does it need `gsp` before implementation?
3. Which durable parent task owns it?
4. Which tags and metadata apply?
5. Is review a single bookmark, multi-commit bookmark, or bookmark stack?
6. Is execution local or one jj workspace per independent task?
7. Is GitHub issue/PR promotion appropriate?
8. Which stage skill owns the next step?
9. Is this a commit/bookmark/push checkpoint?

## Planning

Use `gsp` for unclear or substantial behavior. Use `gpl` to split the spec into
tasks and phases. Tasks in the same phase must be independent enough to run in
separate jj workspaces if parallelized.

Use `gis` to create durable outline issues. Use `gim` for one concrete task.
Use `gor` for phased iterations.

## Review And Stack Model

Supported review modes:

- `session-bookmark`: one tactical bookmark.
- `development-bookmark`: one durable bookmark.
- `multi-commit-bookmark`: one bookmark pointing at a short related chain.
- `stacked-session`: dependent session slices reviewed separately.
- `stacked-development`: dependent development slices reviewed as stacked PRs.
- `parallel-workspaces`: independent writable slices executed in jj workspaces.

LazyJJ aliases provide local stack ergonomics when installed:

```bash
jj start
jj create <bookmark>
jj tug
jj stack
jj top
jj sync
jj ss
jj prs
jj sprs
jj uprs
```

`jj-stack` is the preferred stacked PR backend when GitHub remote/auth
prerequisites are available:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

Use `gpa` after a bookmark or bookmark stack becomes a PR.

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

Parallel independent work:

```bash
jj workspace add ../gest-<task-id> --name <task-id> -r main
(cd ../gest-<task-id> && gest project attach <project-id>)
# worker runs in that workspace
(cd ../gest-<task-id> && gest project detach)
jj workspace forget <task-id>
rm -rf ../gest-<task-id>
```

Do not use git worktrees in jj repos. Do not use raw git write commands.
For PR-ready parallel work, base workspaces on `main` or another described base
commit so pushed bookmarks do not include an empty undescribed ancestor.

## Claude Hooks

Claude can use hook lifecycle events to map worktree isolation to jj:

- `SessionStart`: inject workflow and jj context.
- `PreToolUse(Bash)`: block raw git writes and inject commit conventions.
- `PreToolUse(Write|Edit)`: inject source style/testing docs.
- `WorktreeCreate`: run `jj workspace add`.
- `WorktreeRemove`: run `jj workspace forget` and remove the checkout.
- `Stop`: run a cheap `jj status` snapshot.

The WorktreeCreate/Remove wrappers should be validated against simulated and
live payloads because Claude's payload schema may evolve.

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

For reviewable non-local work, create or move the bookmark and push it unless
the user explicitly requested local-only work or the push is blocked. Local
bookmark state is not a completed checkpoint by itself.

After pushing a non-mainline bookmark, create/update the PR, run `gpa`, report
the PR review findings/state, and ask before merge unless the user explicitly
asked for merge in the current turn.

After a PR is merged, inspect the repository's project instructions and command
contract for deploy/release expectations. If the repo defines a deploy command
for that kind of change, run it or record the exact blocker before handoff.

## Verification

Use `gfm` for formatting/static checks, `gte` for tests and smoke/integration
checks, `gdo` for docs, and `grv` for a review pass after every code change.

Use `scripts/run_jj_workflow_lab.sh` to exercise the four supported workflow
situations in a disposable repo:

1. Plain jj bookmark review flow.
2. Multi-commit session bookmark flow.
3. GitButler replacement flow through jj + LazyJJ aliases + gated jj-stack/PR
   preparation.
4. Parallel jj workspaces.

Treat live GitHub PR creation as gated by explicit remote/auth prerequisites.
