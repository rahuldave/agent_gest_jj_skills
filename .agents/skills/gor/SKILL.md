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
4. Claim tasks with:

```bash
gest iteration next <id> --claim --agent <agent-name> --json
```

Exit code 75 means no work is currently available.

## JJ Workspace Execution

For a parallel task:

```bash
jj workspace add ../gest-<task-id> --name <task-id> -r @
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
