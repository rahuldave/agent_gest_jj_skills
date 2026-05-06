# G Commands Cheat Sheet For JJ Repos

Use `gtw` for most substantial project work. The user may invoke it as
`/gtw`, `$gtw`, or `gtw:`.

## Core Commands

| Skill | Purpose |
|---|---|
| `gtw` | Route substantial work into Gest, choose review/execution model, and dispatch stages. |
| `gbs` | Brainstorm rough ideas and decide whether to spec, plan, or create tasks. |
| `gsp` | Draft/update a Gest spec artifact. |
| `gpl` | Turn a spec or outline task into phased tasks and iterations. |
| `gis` | Create/update durable Gest issue tasks. |
| `gim` | Implement one concrete task in the assigned jj workspace. |
| `gor` | Execute phased iterations, using jj workspaces for independent parallel work. |
| `gfm` | Format, lint, typecheck, static checks, and diff hygiene. |
| `gte` | Tests, smoke checks, regression checks, and integration checks. |
| `gdo` | Documentation audit and updates. |
| `grv` | Review current changes for bugs, regressions, safety, and missing tests. |
| `gcm` | Create a jj commit/bookmark/push checkpoint. |
| `gpr` | Promote/sync durable work with GitHub issues. |
| `gpa` | Review a GitHub PR before approval or merge. |

## JJ Review And Execution Modes

Review modes:

- `session-bookmark`: one tactical bookmark for small session work.
- `development-bookmark`: one durable bookmark for a coherent feature/bug.
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

## Four Practice Situations

The full guide in `docs/jj_workflow_guide.md` includes a disposable lab for:

- plain jj bookmark review flow
- multi-commit session bookmark flow
- stacked bookmarks and `jj-stack` PR preparation
- parallel jj workspaces replacing git worktrees

Run:

```bash
scripts/run_jj_workflow_lab.sh
```

Use `RUN_JJ_STACK_DRY_RUN=1` only when the disposable repo has a GitHub-style
remote/auth setup that lets `jj-stack` inspect the stack safely.
