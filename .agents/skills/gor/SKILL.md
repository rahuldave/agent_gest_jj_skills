---
name: gor
description: Gest Orchestrate. Execute a phased Gest iteration, using jj workspaces for independent parallel write tasks.
---

# GOR: Gest Orchestrate

Use for phased iterations in jj repositories.

## Workflow

1. Read iteration state:

```bash
gest iteration show <id> --json
gest iteration status <id> --json
gest iteration graph <id>
gest project --json
```

2. Group tasks by phase and dependency.
3. Choose execution:
   - single task: run `gim` locally
   - dependent tasks: run sequentially
   - independent writable tasks: create one jj workspace per task
   - read-only review, test-design, and reconnaissance tasks: may use
     sub-agents without separate jj workspaces when they do not write files or
     mutate Gest
4. Before dispatching a phase, confirm every task has had the tag
   classification pass from `docs/tag_dependency_workflow.md`. For code-facing
   tasks, make sure workers know which `ast-grep` dependency checks and
   semantic tags apply.
5. Claim tasks with:

```bash
gest iteration next <id> --claim --agent <agent-name> --json
```

Exit code 75 means no work is currently available.

## Sub-Agent Roles

Distinguish sub-agent roles before dispatch:

- **write agents** implement code/docs and need isolated execution when running
  concurrently.
- **review agents** inspect diffs, tests, docs, VCS safety, or PR state and
  return findings first.
- **test-design agents** propose the smallest meaningful failing or
  characterization tests before implementation.
- **reconnaissance agents** map code, prior Gest memory, or dependency impact
  without editing.

Gest mutations, task completion, commit/bookmark/push decisions, and PR
decisions should remain centralized unless a role is explicitly assigned those
responsibilities. Writable sub-agents must have disjoint write scopes. In jj
repos, concurrent writable work uses one jj workspace per writable task; do not
use git worktrees.

## JJ Workspace Execution

For a parallel task:

```bash
jj workspace add ../gest-<task-id> --name <task-id> -r main
(cd ../gest-<task-id> && gest project attach <project-id>)
```

Dispatch the worker with cwd/workdir set to that workspace. The worker should
record `vcs.workspace_path` and should not create another workspace layer.

Cleanup:

```bash
(cd ../gest-<task-id> && gest project detach)
jj workspace forget <task-id>
rm -rf ../gest-<task-id>
```

JJ workspaces share the commit graph. Do not merge or cherry-pick worker
results back; verify the resulting graph and phase state instead.
