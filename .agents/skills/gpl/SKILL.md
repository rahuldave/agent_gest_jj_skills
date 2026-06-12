---
name: gpl
description: Gest Plan. Decompose a spec or outline task into jj-native Gest tasks, phases, dependencies, bookmarks, and workspace execution.
---

# GPL: Gest Plan

Use to convert a spec, outline task, GitHub issue, or user-described scope into
executable Gest structure.

## Inputs

Accept a Gest artifact ID, task ID, GitHub issue URL/number, or described
scope. Read entities with `gest ... show --json` when possible.

## Gest Memory

```bash
gest search "<scope/topic>" --all --json --limit 20
gest search "Follow-up <scope/topic>" --all --json --limit 20
gest task show <id-or-prefix> --json
gest task note list <id-or-prefix> --json
gest iteration show <id-or-prefix> --json
```

Reuse existing durable parents when they fit.

## Decisions

1. Is this a session plan or development plan?
2. What outline parent owns it?
3. What depth should new tasks have?
4. Which tasks are independent?
5. Which phases and `blocked-by` links are needed?
6. Which jj review mode applies?
7. Which execution mode applies?
8. Should GitHub issue/PR metadata be attached?
9. Which verification/review/checkpoint leaves are required?
10. Which existing or new semantic tags classify every task?
11. Which changed contracts require `ast-grep` dependency impact checks?

## Output Structure

Create tasks with native `child-of` links:

- depth 1: durable issue/parent
- depth 2: concrete implementation or verification leaf
- depth 3: tiny subtasks only when useful

Create or update an iteration with explicit phases. Tasks in the same phase
must be safe to run concurrently and must have disjoint write scopes if
parallelized.

For non-trivial write slices, use jj-native metadata:

```text
vcs.tool=jj
vcs.review_mode=session-bookmark|development-bookmark|multi-commit-bookmark|stacked-session|stacked-development|parallel-workspaces
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark-name>
vcs.stack_root=<bookmark-name>
vcs.stack_parent=<bookmark-name>
vcs.stack_index=<n>
vcs.workspace_path=<absolute-path>
```

Use stacked review modes for dependent slices that should remain separately
reviewable. Use `parallel-workspaces` only when independent tasks will run at
the same time in separate jj workspaces.

## JJ Planning Rules

- Bookmarks are review handles and do not advance automatically.
- `main` and `main@origin` may not exist in a fresh repo until explicitly set
  and pushed.
- LazyJJ aliases may support local stack ergonomics: `start`, `create`, `tug`,
  `stack`, `sync`, and `ss`.
- Use `jj-stack` or gated LazyJJ PR aliases for stacked PR creation/update when
  GitHub remote/auth prerequisites exist.
- Do not plan raw git write operations or git worktrees in jj repos.

Report task IDs, phase grouping, dependencies, metadata, and whether `gor` can
parallelize the work.

## Tag And Dependency Planning

Apply `references/tag_dependency_workflow.md` while decomposing work. For every
planned task, classify tags against the current project vocabulary and add
`classification.tags.reviewed=true` metadata. For code-facing phases, list the
semantic contracts and `ast-grep` patterns that implementers must check. If
tag/classifier results reveal coupled surfaces, make them explicit tasks or
acceptance criteria instead of hoping implementers notice them later.
