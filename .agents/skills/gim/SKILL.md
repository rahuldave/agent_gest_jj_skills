---
name: gim
description: Gest Implement. Implement one concrete Gest task end to end inside the assigned jj workspace.
---

# GIM: Gest Implement

Use for one concrete task.

## Workflow

1. Read task and notes:

```bash
gest task show <id> --json
gest task note list <id> --json
```

2. Claim the task:

```bash
gest task claim --as codex <id> --quiet
```

3. Confirm `vcs.tool=jj`, review mode, execution mode, bookmark, and
   workspace path metadata.
4. Inspect relevant code/docs.
5. Edit within the assigned jj workspace.
6. Run `gfm`, `gte`, `gdo` as appropriate.
7. Run `grv` after code changes.
8. Add a completion note:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ..."
gest task complete <id> --quiet
```

Do not create an extra workspace layer unless explicitly assigned. Do not use
raw git write commands.
