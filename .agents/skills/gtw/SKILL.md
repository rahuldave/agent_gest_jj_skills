---
name: gtw
description: Gest Track Work. Route substantial jj-repo work into Gest, choose bookmark/workspace models, create or claim tasks, and dispatch the right g* stage skill.
---

# GTW: Gest Track Work

Use before any substantial file-writing work in a Gest-managed jj repository.

## Inspect First

Serialize Gest commands:

```bash
gest search "<topic>" --all --json --limit 20
gest task list --all --json
gest iteration list --all --json
```

Also inspect jj state:

```bash
jj status
jj log -r 'trunk() | mutable() | @' --no-pager
jj bookmark list
```

## Decisions

Before editing, decide:

1. Is this tiny, session-shaped, or development-shaped?
2. Does it need `gsp`?
3. Which durable parent task owns it?
4. Which tags and metadata apply?
5. Is review a single bookmark or stacked bookmarks?
6. Is execution `main-workspace` or `jj-workspaces`?
7. Is GitHub issue promotion appropriate?
8. Which stage skill runs next?
9. Is there a commit/bookmark/push checkpoint?

## Metadata

Use jj-native metadata:

```text
vcs.tool=jj
vcs.review_mode=session-bookmark|development-bookmark|stacked-session|stacked-development|parallel-workspaces
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark-name>
vcs.workspace_path=<absolute-path>
```

## Guardrails

Use `jj` for VCS writes. Do not use git worktrees or raw git write commands in
jj repositories. Read-only git inspection is acceptable when it clarifies
GitHub state.

Use `gor` when a phased iteration may need jj workspaces. Use `gcm` for
durable jj commit/bookmark/push checkpoints.
