---
name: gcm
description: Gest Commit. Create a jj commit/bookmark/push checkpoint using conventional commit style and GitHub metadata when present.
---

# GCM: Gest Commit

Use when the user asks to commit, when the workflow reaches a durable
checkpoint, or before GitHub issue/PR sync.

## Inspect

```bash
jj status
jj diff
jj log -r 'trunk()..@ | @ | bookmarks()' --no-pager
jj bookmark list
jj git remote list
```

Draft a conventional commit:

```text
<type>(<scope>): <description>

[body]

[footer]
```

Never include Gest IDs in commit messages. Use GitHub footers only when Gest
metadata contains a real GitHub issue and the commit semantically closes or
references it.

## Commit

Use:

```bash
jj commit -m "<message>"
```

Use `jj describe -m "<message>"` only when the work should remain in the
current change.

## Bookmark And Push

For reviewable work:

```bash
jj bookmark create <bookmark> -r @-
# or
jj bookmark move <bookmark> --to @-
jj git push --bookmark <bookmark>
```

For stacked PRs:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

After pushing a non-mainline bookmark, create/update the PR, run `gpa`, report
the PR state, and ask before merging unless the user explicitly requested merge
in the current turn.
