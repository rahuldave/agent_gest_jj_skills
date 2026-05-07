# G Commands Cheat Sheet For JJ Repos

If you are new, start with `docs/TUTORIAL.md`. This cheat sheet is a compact
reference, not the beginner tutorial.

Use `gtw` for most substantial project work. The user may invoke it as `/gtw`,
`$gtw`, or `gtw:`.

## Core Commands

| Skill | Purpose |
|---|---|
| `gtw` | Route substantial work into Gest, choose jj review/execution model, and dispatch stages. |
| `gbs` | Brainstorm rough ideas and decide whether to spec, plan, or create tasks. |
| `gsp` | Draft/update a Gest spec artifact. |
| `gpl` | Turn a spec or outline task into phased tasks, dependencies, bookmarks, and workspaces. |
| `gis` | Create/update durable Gest issue tasks with jj metadata. |
| `gim` | Implement one concrete task in the assigned jj workspace. |
| `gor` | Execute phased iterations, using jj workspaces for independent parallel work. |
| `gfm` | Format, lint, typecheck, static checks, and diff hygiene. |
| `gte` | Tests, smoke checks, regression checks, and integration checks. |
| `gdo` | Documentation audit and updates. |
| `grv` | Review current changes for bugs, regressions, VCS safety, and missing tests. |
| `gcm` | Create a jj commit/bookmark/push checkpoint. |
| `gpr` | Promote/sync durable work with GitHub issues. |
| `gpa` | Review a GitHub PR before approval or merge. |

Tag/dependency rule of thumb: when creating any task, classify it against the
existing Gest tag vocabulary. When changing code contracts, run an `ast-grep`
dependency impact pass and verify dependent surfaces/tests. See
`docs/tag_dependency_workflow.md`.

## JJ Basics

The working copy is a commit named `@`.

```bash
jj status
jj diff
jj describe -m "<message>"   # label @ and keep editing
jj commit -m "<message>"     # finalize @ and advance to a fresh empty @
jj new                       # advance to a fresh empty @ without a final message
```

Bookmarks are review handles. They do not advance automatically.

```bash
jj bookmark set <bookmark> -r @-
jj bookmark move <bookmark> --to @-
jj bookmark list --all
jj git push --bookmark <bookmark>
```

For new GitHub-backed repos:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
# edit files
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
```

## Review And Execution Modes

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

Use metadata such as:

```text
vcs.tool=jj
vcs.review_mode=development-bookmark
vcs.execution=main-workspace
vcs.bookmark=gest/abc123-two-word-summary
vcs.workspace_path=/absolute/path
```

## LazyJJ And JJ-Stack

LazyJJ aliases are optional local ergonomics for stack work:

```bash
jj start
jj create <bookmark>
jj tug
jj stack
jj top
jj sync
jj ss
jj prs
jj sprs
jj uprs
```

Use `jj-stack` as the preferred stacked PR backend when a GitHub remote and auth
are available:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

Live PR creation is gated. Do not imply `jst submit` or `jj sprs` ran unless
the repo had the needed GitHub remote/auth.

## Common Flows

Small session:

```text
gtw -> claim/create leaf -> gim -> gfm -> gte -> grv
```

Development slice:

```text
gtw -> gsp/gpl if needed -> gim -> gfm -> gte -> gdo -> grv -> gcm
```

Stacked work:

```text
gtw -> gpl creates stacked leaves -> implement bottom-up -> jj create/tug/stack -> jst submit -> gpa
```

Parallel work:

```text
gor -> jj workspace add per independent task -> gim in each workspace -> workspace forget -> verify graph
```

## Practice Situations

The beginner tutorial in `docs/TUTORIAL.md` includes deterministic prompts and
checks for:

- plain jj bookmark review flow
- multi-commit session bookmark flow
- stacked jj PR flow through LazyJJ aliases and `jj-stack`
- parallel jj workspace flow
- tag classification and ast-grep dependency-impact workflow

Run:

```bash
scripts/run_jj_workflow_lab.sh
```

`just verify` runs this lab by default. GitHub PR creation remains gated by
remote/auth prerequisites.
