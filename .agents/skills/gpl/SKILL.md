---
name: gpl
description: Gest Plan. Decompose a spec or outline task into jj-native Gest tasks, phases, dependencies, bookmarks, and workspace execution.
---

# GPL: Gest Plan

Read the spec/task, inspect related Gest memory, then create or update tasks and
iterations.

Decide:

1. session or development plan
2. outline parent
3. task depth and dependencies
4. phases
5. review mode: single bookmark or stacked bookmarks
6. execution mode: main workspace or jj workspaces
7. GitHub issue/PR metadata needs

For writable tasks, set metadata:

```text
vcs.tool=jj
vcs.review_mode=session-bookmark|development-bookmark|stacked-session|stacked-development|parallel-workspaces
vcs.execution=main-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.bookmark=<bookmark-name>
vcs.workspace_path=<absolute-path>
```

Tasks in the same phase must be safe to run concurrently in different jj
workspaces.
