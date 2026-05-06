# JJ Workflow Guide

This guide teaches the supported jj workflow by hand. It mirrors the git repo's
GitButler/worktree guide, but replaces git worktrees with jj workspaces and
GitButler stacks with jj bookmarks plus `jj-stack`.

## Mental Model

In jj, the working copy is a commit. There is no staging area. Use `jj commit`
to finalize the current working-copy commit and advance to a fresh empty `@`.
Use `jj describe` when you want to name the current change without advancing.

Review units are bookmarks. A simple PR uses one bookmark. A stacked PR flow
uses several bookmarks on a linear stack of commits.

Parallel agent execution uses jj workspaces. Workspaces share the commit graph,
so there is no git-style merge-back step.

## Tool Roles

- `jj`: source of truth for local history, workspaces, bookmarks, and git push.
- LazyJJ: optional local aliases for stack viewing, restack, bookmark create/tug,
  and stack submit/sync.
- `jj-stack`: preferred automation for creating/updating GitHub stacked PRs from
  jj bookmarks.
- `gh`: GitHub issue/PR inspection and review packets.
- Gest: durable work tracking.

Do not rely on LazyJJ's Claude aliases for reusable orchestration. Agent
workspace lifecycle belongs in Claude hooks and Codex skills/scripts.

## Install And Verify

```bash
just setup
just verify
```

The verification lab is disposable and writes under `/tmp` by default. Override
with:

```bash
AGENT_GEST_JJ_LAB=/tmp/my-jj-lab scripts/run_jj_workflow_lab.sh
```

## Four Test Situations

### Situation 1: Plain JJ Bookmark Review Flow

Use this when one coherent change should become one PR.

```bash
jj new main
printf 'plain bookmark change\n' > plain.txt
jj commit -m "test: add plain bookmark change"
jj bookmark create demo/plain-bookmark -r @-
jj git push --bookmark demo/plain-bookmark
```

Expected shape: one bookmark points to one completed review commit.

### Situation 2: Multi-Commit Session Bookmark Flow

Use this when one session contains several small related commits under one
review bookmark.

```bash
jj new main
printf 'session edit one\n' > session.txt
jj commit -m "test: add first session edit"
printf 'session edit two\n' >> session.txt
jj commit -m "test: add second session edit"
jj bookmark create demo/session-bookmark -r @-
```

Expected shape: one bookmark points to the top of a short commit chain.

### Situation 3: Stacked Bookmarks With JJ-Stack

Use this when dependent slices should be reviewed separately.

```bash
jj new main
printf 'stack base\n' > stack.txt
jj commit -m "test: add stack base"
jj bookmark create demo/stack-base -r @-

printf 'stack child\n' >> stack.txt
jj commit -m "test: add stack child"
jj bookmark create demo/stack-child -r @-
```

Preview the stacked PR operation:

```bash
jst submit demo/stack-child --dry-run
```

Submit when the remote/auth state is ready:

```bash
jst submit demo/stack-child
```

Expected shape: `jj-stack` infers the bookmark stack, pushes missing bookmarks,
and creates or updates GitHub PRs with the correct bases.

### Situation 4: Parallel JJ Workspaces

Use this when independent writable tasks can run concurrently.

```bash
jj new main
jj workspace add ../lab-workspace-a --name demo-workspace-a -r @
jj workspace add ../lab-workspace-b --name demo-workspace-b -r @

(cd ../lab-workspace-a && printf 'workspace a\n' > workspace-a.txt && jj commit -m "test: add workspace a")
(cd ../lab-workspace-b && printf 'workspace b\n' > workspace-b.txt && jj commit -m "test: add workspace b")

jj log -r 'description("workspace a") | description("workspace b")'
jj workspace forget demo-workspace-a
jj workspace forget demo-workspace-b
rm -rf ../lab-workspace-a ../lab-workspace-b
```

Expected shape: both worker commits are visible from the main workspace because
the workspaces share a commit graph. There is no merge-back step.

## Gest Metadata Examples

Single bookmark:

```text
vcs.tool=jj
vcs.review_mode=development-bookmark
vcs.execution=main-workspace
vcs.bookmark=gest/abc123-reader-notes
```

Stacked bookmarks:

```text
vcs.tool=jj
vcs.review_mode=stacked-development
vcs.execution=main-workspace
vcs.stack_root=gest/abc123-api-base
vcs.stack_parent=gest/abc123-api-base
vcs.stack_index=2
```

Parallel workspaces:

```text
vcs.tool=jj
vcs.review_mode=parallel-workspaces
vcs.execution=jj-workspaces
vcs.parallel_allowed=true
vcs.workspace_path=/absolute/path/to/workspace
```
