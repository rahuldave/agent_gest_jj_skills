# JJ Workflow Guide

This guide is the jj counterpart to the git repo's
`gest_gitbutler_workflow_guide.md`. It keeps the same Gest workflow shape but
replaces GitButler with jj, LazyJJ aliases, `jj-stack`, and jj workspaces.

## Short Version

- Gest tracks intent, task hierarchy, phases, notes, and metadata.
- jj tracks code history and the working-copy commit.
- Bookmarks are review handles and GitHub branch refs.
- LazyJJ aliases provide GitButler-like local stack ergonomics inside jj.
- `jj-stack` is the preferred stacked PR backend when GitHub remote/auth exists.
- jj workspaces replace physical git worktrees for true parallel write work.
- Do not use raw git write commands or git worktrees in jj repos.

## Mental Model

In jj, the working copy is a commit named `@`. There is no staging area.

```bash
jj status
jj diff
jj describe -m "<message>"   # label @ and keep editing
jj commit -m "<message>"     # finalize @ and advance to fresh empty @
jj new                       # advance to fresh empty @
```

`@-` is the parent of `@`. `root()` is the virtual root commit.

Bookmarks are named pointers. They do not gate branching and they do not
advance automatically. Name them because you want a stable handle for review,
push, or future development.

```bash
jj bookmark set <name> -r @-
jj bookmark move <name> --to @-
jj bookmark list --all
jj git push --bookmark <name>
```

## Tool Roles

- `jj`: source of truth for local history, workspaces, bookmarks, and git push.
- LazyJJ aliases: optional local ergonomics for stack viewing, restacking,
  bookmark create/tug, stack push, and PR helpers.
- `jj-stack`: preferred automation for GitHub stacked PRs from jj bookmarks.
- `gh`: GitHub issue/PR inspection and review packets.
- Gest: durable work tracking.

Do not rely on LazyJJ's Claude aliases for reusable orchestration. Agent
workspace lifecycle belongs in Claude hooks and Codex skills/scripts.

## GitHub-Backed Initialization

For a new repo:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
```

At this point there is no special `main`, no `main@origin`, and no bookmark.
After the first meaningful edit:

```bash
printf '# Demo\n' > README.md
jj diff
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
jj bookmark list --all
```

After push, the bookmark list should show local `main`, `main@git`, and
`main@origin`.

## Branch Model Vs Execution Model

Keep two decisions separate:

- **Review model**: how work becomes reviewable.
- **Execution model**: where agents may write.

Review modes:

| Mode | Use When |
| --- | --- |
| `session-bookmark` | Small tactical session work. |
| `development-bookmark` | One coherent durable feature, bug, or workflow change. |
| `multi-commit-bookmark` | One bookmark points at a short related chain. |
| `stacked-session` | Multiple dependent session slices should stay reviewable. |
| `stacked-development` | Multiple dependent development slices should become stacked PRs. |
| `parallel-workspaces` | Independent slices run at the same time in jj workspaces. |

Execution modes:

| Mode | Meaning |
| --- | --- |
| `main-workspace` | One agent writes in the current jj workspace. |
| `jj-workspaces` | One jj workspace per parallel writable task. |

Metadata example:

```text
vcs.tool=jj
vcs.base_bookmark=main
vcs.review_mode=stacked-development
vcs.execution=main-workspace
vcs.parallel_allowed=false
vcs.bookmark=gest/demo-stack-child
vcs.integration=stacked-pr
```

## LazyJJ Stack Workflow

LazyJJ aliases replace the GitButler local stack ergonomics:

```bash
jj start                    # fetch + new commit from trunk
jj create <bookmark>        # create bookmark at @-
jj tug                      # move nearest bookmark to @-
jj stack                    # view current stack
jj top                      # move to stack top
jj sync                     # fetch + rebase stack onto trunk
jj ss                       # push stack to remote
jj prs                      # PR stack summary, when prerequisites exist
jj sprs                     # create/update stacked PRs, when prerequisites exist
jj uprs                     # update PR comments, when prerequisites exist
```

Use `jj-stack` for stacked PR submission when possible:

```bash
jst submit <top-bookmark> --dry-run
jst submit <top-bookmark>
```

Live PR commands require a GitHub remote and authenticated `gh`. The disposable
lab gates them.

## Reproduce The Workflow Lab

The lab is disposable and writes under `/tmp` by default:

```bash
scripts/run_jj_workflow_lab.sh
```

Override the path:

```bash
AGENT_GEST_JJ_LAB=/tmp/my-jj-lab scripts/run_jj_workflow_lab.sh
```

### Lab Setup

The lab initializes a colocated jj/git repo with a local bare remote so bookmark
push mechanics are exercised without creating a throwaway GitHub repository.
The GitHub-backed initialization sequence is still documented above and should
be used for real new GitHub repos.

For a full live integration tutorial, run the GitHub lab:

```bash
gh auth status -h github.com
gh auth refresh -h github.com -s delete_repo # if delete_repo is missing
scripts/run_jj_github_integration_lab.sh
```

That script creates four separate temporary GitHub repositories, one for each
example below. It uses authenticated `gh`, exercises real PR creation including
the LazyJJ plus `jj-stack` stack, writes command logs and a markdown tutorial
trace, and deletes every temp repository with `gh repo delete --yes` unless
`AGENT_GEST_JJ_KEEP_GITHUB_REPOS=1` is set for debugging.

For a prompt-first version suitable for handing to Codex, see
`docs/live_github_jj_workflow_tutorial.md`.

### Situation 1: Plain JJ Bookmark Review Flow

Use this when one coherent change should become one PR.

```bash
jj new main
printf 'plain bookmark change\n' > plain.txt
jj commit -m "test: add plain bookmark change"
jj bookmark set demo/plain-bookmark -r @-
jj git push --bookmark demo/plain-bookmark
```

Expected shape: one bookmark points to one completed review commit, and the
remote has that bookmark.

### Situation 2: Multi-Commit Session Bookmark Flow

Use this when one session contains several small related commits under one
review bookmark.

```bash
jj new main
printf 'session edit one\n' > session.txt
jj commit -m "test: add first session edit"
printf 'session edit two\n' >> session.txt
jj commit -m "test: add second session edit"
jj bookmark set demo/session-bookmark -r @-
jj git push --bookmark demo/session-bookmark
```

Expected shape: one bookmark points to the top of a short commit chain.

### Situation 3: GitButler Replacement Flow

Use this when dependent slices should be reviewed separately.

```bash
jj start
printf 'stack base\n' > stack.txt
jj commit -m "test: add stack base"
jj create demo/stack-base

printf 'stack child\n' >> stack.txt
jj commit -m "test: add stack child"
jj create demo/stack-child

jj stack
jj ss
```

The stack can then be submitted with `jj-stack` when GitHub prerequisites are
present:

```bash
jst submit demo/stack-child --dry-run
jst submit demo/stack-child
```

Expected shape: LazyJJ aliases create and push the bookmark stack; `jj-stack`
or gated LazyJJ PR aliases can create/update stacked PRs with the correct bases.

### Situation 4: Parallel JJ Workspaces

Use this when independent writable tasks can run concurrently.

```bash
jj workspace add ../lab-workspace-a --name demo-workspace-a -r main
jj workspace add ../lab-workspace-b --name demo-workspace-b -r main

(cd ../lab-workspace-a && printf 'workspace a\n' > workspace-a.txt && jj commit -m "test: add workspace a")
(cd ../lab-workspace-b && printf 'workspace b\n' > workspace-b.txt && jj commit -m "test: add workspace b")

jj log -r 'description("workspace a") | description("workspace b")'
jj workspace forget demo-workspace-a
jj workspace forget demo-workspace-b
rm -rf ../lab-workspace-a ../lab-workspace-b
```

Expected shape: both worker commits are visible from the main workspace because
the workspaces share a commit graph. There is no merge-back step.

If the workspace commits will be pushed as PR bookmarks, base the workspaces on
`main` or another described commit. Do not put an empty undescribed coordinator
commit between `main` and the pushed worker bookmarks.

## Common Mistakes

Mistake: assuming `main` exists in a new jj repo.

Fix: create it explicitly with `jj bookmark set main -r @-`.

Mistake: assuming bookmarks advance like git branches.

Fix: move or set the bookmark at each checkpoint.

Mistake: using raw `git commit` or `git push`.

Fix: use `jj commit` and `jj git push --bookmark`.

Mistake: using git worktrees for agent parallelism in a jj repo.

Fix: use jj workspaces.

Mistake: pushing a bookmark and stopping.

Fix: create/update the PR, run `gpa`, report review state, and ask before
merge.

## What To Ask Codex

```text
/gtw create a session bookmark and make these two small docs edits
```

```text
/gtw plan this feature as a stacked jj development flow because the API and UI
slices should be reviewed separately
```

```text
/gtw run this iteration with jj workspaces; the tasks touch disjoint files and
can run concurrently
```

```text
gcm: commit this verified checkpoint, set the bookmark, and push it if ready
```

```text
gpa: review PR #12, add missing Gest context, and recommend whether to merge
```
