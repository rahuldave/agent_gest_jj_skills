---
name: gtw
description: Gest Track Work. Route substantial jj-repo work into Gest, choose bookmark/workspace models, create or claim tasks, and dispatch the right g* stage skill.
---

# GTW: Gest Track Work

GTW is the default entry point before substantial file-writing work in a
Gest-managed jj repository.

Read `docs/gest_codex_workflow.md` when more detail is needed. Use
`docs/TUTORIAL.md` for hands-on bookmark, LazyJJ, jj-stack, and
workspace flows.

## Core Job

Before editing files, make the tracking decision visible:

1. Is this a tiny untracked answer, session work, or development work?
2. Does it need `gsp` before implementation?
3. Which durable outline task owns it?
4. Which tags and metadata apply?
5. Is review one bookmark, a multi-commit bookmark, or a bookmark stack?
6. Is execution the current jj workspace or one jj workspace per writable task?
7. Is GitHub issue or PR promotion appropriate?
8. Which stage skill runs next?
9. Is this a commit/bookmark/push checkpoint?
10. Which existing tags classify this work, and which new dynamic tags are
    justified?
11. Which semantic dependers should be checked with `ast-grep` if code changes?

Everything substantial should become a Gest task or issue with appropriate
dependencies. For multi-stage work, create a small treelet: one parent task for
the request and child leaves for separately verifiable stages such as `gsp`,
`gpl`, `gim`, `gfm`, `gte`, `gdo`, `grv`, `gpr`, and `gcm`.

## Inspect First

Serialize Gest commands. Local sync can make read-looking commands write to
SQLite.

```bash
gest search "<short phrase>" --all --json --limit 20
gest task list --all --json
gest iteration list --all --json
```

Inspect jj state:

```bash
jj status
jj diff
jj log -r 'trunk() | mutable() | @' --no-pager
jj bookmark list --all
jj git remote list
```

If a Gest command reports a readonly or locked database, retry serialized with
the required local approval. If jj needs to take the colocated git import/export
lock, rerun the jj command with the needed local approval.

## Gest Memory Lookup

Before planning or editing, search for prior decisions and unresolved
follow-ups:

```bash
gest search "<feature or symptom>" --all --json --limit 20
gest search "<module/script/doc name>" --all --json --limit 20
gest search "Follow-up <topic>" --all --json --limit 20
gest task show <id-or-prefix> --json
gest task note list <id-or-prefix> --json
gest iteration show <id-or-prefix> --json
```

Look for completion notes with `Done`, `Verification`, and `Follow-up`, prior
review findings, GitHub metadata, specs, and VCS metadata.

## Classification

Choose one:

- `session leaf only`: small tactical work.
- `session leaf under outline`: small work under an existing durable parent.
- `new outline plus session leaves`: new durable area but not GitHub-scale.
- `development iteration`: larger, multi-session, spec-worthy, GitHub-worthy,
  or phased work.

Promote session-shaped work to development when it needs a spec/design
decision, spans sessions, has durable acceptance criteria, creates reusable
workflow material, or should be visible on GitHub.

## JJ Review And Execution Policy

Keep these decisions separate:

- **Review model**: how the work becomes reviewable.
- **Execution model**: where agents are allowed to write.

Use review names keyed to the highest meaningful Gest task for the workstream:

```text
gest/<task-id-short>-two-word-summary
session/<task-id-short>-two-word-summary
```

Review modes:

- `session-bookmark`: one tactical bookmark.
- `development-bookmark`: one durable bookmark.
- `multi-commit-bookmark`: one bookmark pointing at a short related chain.
- `stacked-session`: dependent session slices reviewed as a bookmark stack.
- `stacked-development`: dependent development slices reviewed as stacked PRs.
- `parallel-workspaces`: independent writable slices executed in jj workspaces.

Execution modes:

- `main-workspace`: one agent writes in the current jj workspace.
- `jj-workspaces`: one jj workspace per independent writable task.

Use jj bookmarks as review handles. Bookmarks are not branches and do not
advance automatically. Move or create them explicitly with `jj bookmark set`,
`jj bookmark create`, or `jj bookmark move`, then push with `jj git push
--bookmark <name>`.

Use LazyJJ aliases for local stack ergonomics when available: `start`, `create`,
`tug`, `stack`, `top`, `gc`, `sync`, `ss`, `sprs`, `prs`, and `uprs`.
`jj-stack` is the preferred backend for creating/updating stacked PRs when a
GitHub remote and auth are available. Do not depend on the LazyJJ TUI.

Do not use git worktrees in jj repos. Do not use raw git write commands. Read
only git inspection is acceptable when it clarifies GitHub state.

## Metadata

Use metadata for source-of-truth facts:

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
vcs.write_scope=<paths-or-subsystems>
classification.tags.reviewed=true|false
classification.tags.new=<comma-separated-new-tags>
impact.ast_grep.required=true|false
impact.semantic_tags=<comma-separated-tags>
```

## Tag And Dependency Classifier

Use `docs/tag_dependency_workflow.md` whenever GTW creates, splits, or expands
tasks. Before `gest task create`, collect existing tags from tasks, artifacts,
and iterations, then classify the new task against that vocabulary. Prefer
existing semantic tags; add dynamic tags only when they describe a missing
concept. Record selected/new/rejected tags in task tags, metadata, or a note.

For code-facing work, identify changed semantic contracts and plan an
`ast-grep` dependency impact pass. If a selected tag reveals coupled surfaces
such as histogram and pill color mapping, expand the task or create linked
children before implementation.

## Creating Work

Create or reuse an active session/development iteration. Assign phases
deliberately; do not put every task in phase 1 by habit.

```bash
gest task create "<Leaf title>" \
  -d "<Concrete verifiable work>" \
  -i <iteration-id> \
  --phase <phase-number> \
  -l child-of:<parent-id> \
  --tag development \
  --tag leaf \
  --metadata workflow.kind=development \
  --metadata depth=2 \
  --metadata vcs.tool=jj \
  --metadata vcs.review_mode=development-bookmark \
  --metadata vcs.execution=main-workspace \
  --metadata vcs.parallel_allowed=false \
  --quiet

gest task claim --as codex <leaf-id> --quiet
```

Use `vcs.execution=jj-workspaces` only when each parallel writable task has a
distinct workspace path and disjoint write scope.

## Stage Routing

- `gbs`: explore rough ideas.
- `gsu`: bootstrap or refresh project setup, command contracts, ignores,
  tools, hooks, and installs.
- `gsp`: create/update a spec artifact.
- `gpl`: decompose a spec/outline into tasks, phases, dependencies, bookmarks,
  and workspace execution.
- `gis`: create/update durable Gest tasks.
- `gpr`: promote/sync durable work with GitHub issues.
- `gim`: implement one concrete task.
- `gor`: execute phased work, using jj workspaces when independent tasks can
  run concurrently.
- `gfm`: format/lint/typecheck/static checks and diff hygiene.
- `gte`: tests, smoke checks, regression checks, and integration checks.
- `gdo`: docs audit.
- `grv`: review after code changes.
- `gcm`: jj commit/bookmark/push checkpoint.
- `gpa`: PR acceptance review.

## Checkpoint Hygiene

At durable checkpoints, including Codex-created commits, completed development
parents, completed iterations, and substantial handoffs:

- regenerate overall and focused Gest graphs when the target repo has the graph
  tool
- run or record the `gpr` GitHub issue decision for development parents and
  iterations
- run `grv` after code changes before completing leaves
- verify push state for Codex-created bookmarks/commits
- if reviewable work has no pushed bookmark, create/move the bookmark and push
  it instead of treating local-only state as the default
- after pushing a non-mainline bookmark, create/update the PR, run `gpa`, and
  ask before merge unless the user already requested merge
- after merging a PR, run the repo's deploy/release contract when applicable,
  or report the exact reason deployment was skipped
- report graph paths, commit/change IDs, bookmark/push status, review status,
  and GitHub issue decision

## Completion

For non-trivial leaves, add a note before completion:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
gest task complete <id> --quiet
```

Use `Done` and `Verification` in every completion note. Add `Follow-up` only
for real residual issues. Do not complete long-lived parents unless the full
subtree is done.
