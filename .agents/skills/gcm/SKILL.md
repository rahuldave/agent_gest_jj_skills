---
name: gcm
description: Gest Commit. Create a jj commit/bookmark/push checkpoint using conventional commit style and GitHub metadata when present.
---

# GCM: Gest Commit

Use when the user asks to commit, when a verified development checkpoint should
be committed, before GitHub issue/PR sync, or when the final dirty-workspace
gate finds Codex-owned changes at a commit-required checkpoint.

Committing is VCS hygiene, not a Gest task by itself. Do not create a Gest task
whose only purpose is making a normal commit.

## Inspect

```bash
jj status
jj diff
jj log -r 'trunk()..@ | @ | bookmarks()' --no-pager
jj bookmark list --all
jj git remote list
```

Read related Gest notes and metadata. Look for `github.issue`, `github.url`,
`vcs.bookmark`, `vcs.review_mode`, and stack metadata.

## JJ Commit Model

There is no staging area in jj. The working copy is a commit named `@`.

Use `jj describe` when you want to label the current working-copy commit and
continue editing it:

```bash
jj describe -m "<message>"
```

Use `jj commit` when the current change is complete and you want to advance to
a fresh empty `@`:

```bash
jj commit -m "<message>"
```

`jj new` also advances to a new empty `@`, but it does not create the final
conventional message by itself. Use it for workflow boundaries only when that
is the intended shape.

## Message

Draft a conventional commit:

```text
<type>(<scope>): <description>

[body]

[footer]
```

Never include Gest IDs in commit messages. Include GitHub footers only when
Gest metadata contains a real GitHub issue and the commit semantically closes
or references it.

Derive useful bodies from completed Gest notes: `Done`, `Verification`, and
real `Follow-up` items.

## Bookmark And Push

Bookmarks are review handles and do not advance automatically. After a commit,
create or move the intended bookmark explicitly:

```bash
jj bookmark set <bookmark> -r @-
# or, for an existing bookmark:
jj bookmark move <bookmark> --to @-
```

Push only the intended bookmark:

```bash
jj git push --bookmark <bookmark>
jj bookmark list --all
```

For a new GitHub-backed repo, the first mainline publication normally looks
like:

```bash
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
```

After the first push, `jj bookmark list --all` should show local `main`,
`main@git`, and `main@origin`.

For local LazyJJ stack ergonomics, use commands such as:

```bash
jj start
jj create <bookmark>
jj tug
jj stack
jj ss
```

For stacked PRs, prefer `jj-stack` when GitHub remote/auth prerequisites are
available:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

`jj sprs` may also create/update PR stacks when the installed LazyJJ aliases,
`gh`, and a GitHub remote are configured. Treat live PR creation as a gated
operation.

## After Commit

Run checkpoint hygiene:

```bash
jj status
jj bookmark list --all
```

If a non-mainline bookmark was pushed, create/update the PR, run `gpa`, report
the PR state, and ask before merging unless the user explicitly requested merge
in the current turn.
