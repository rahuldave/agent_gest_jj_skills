# Live GitHub JJ Workflow Tutorial

This tutorial shows the four jj/GitHub workflows that replace the older
GitButler-centered examples. It is based on a successful live run of
`scripts/run_jj_github_integration_lab.sh`, which created four private
temporary GitHub repositories, exercised the workflows, captured logs, and then
deleted the repositories with `gh repo delete --yes`.

Use this document in two ways:

- As user prompts to give Codex when you want it to set up and run these flows.
- As a command/tutorial source for porting the same scenario structure back to
  the git skills repo.

## Setup Prompt

Give Codex a setup prompt like this before asking for individual flows:

```text
Use the jj Gest workflow. Verify that gh is authenticated for github.com and
has repo plus delete_repo scopes. If delete_repo is missing, ask me to run or
approve `gh auth refresh -h github.com -s delete_repo`. Then create a uniquely
named temporary private GitHub repo for each workflow example, initialize it
with git + gh + colocated jj, run the example, capture command output for a
tutorial trace, and delete the temp repo with `gh repo delete --yes` during
cleanup. Do not use raw git commit, branch, switch, checkout, or push after
`jj git init --colocate`; use jj writes and explicit bookmarks.
```

The live harness implements that prompt:

```bash
gh auth status -h github.com
gh auth refresh -h github.com -s delete_repo # only if needed
just integration-live
```

The harness refuses to create repositories until `gh auth status` shows
`delete_repo`, because reliable cleanup is part of the test.

## Common Initialization

Prompt:

```text
Create a new temporary GitHub-backed jj repository using the documented
initialization sequence. Show me the state before main exists, then make the
first described commit, create the main bookmark explicitly, push only that
bookmark, and verify main has @git and @origin tracking.
```

Commands:

```bash
git init
gh repo create <owner>/<temp-repo> --private --source=. --remote=origin
jj git init --colocate

printf '# Demo\n' > README.md
mkdir -p src
printf 'base\n' > src/app.txt
jj diff
jj describe -m "chore: initialize demo"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
jj bookmark list --all
```

Expected shape:

```text
main: <change> <commit> chore: initialize demo
  @git: <change> <commit> chore: initialize demo
  @origin: <change> <commit> chore: initialize demo
```

Remember: `main` is a bookmark, not a branch. It does not exist until you set
it, and it does not advance automatically.

## Flow 1: Plain Bookmark PR

Prompt:

```text
In a fresh temporary GitHub-backed jj repo, demonstrate the plain bookmark PR
flow. Start from main, make one described jj commit, set a review bookmark at
@-, push that bookmark, open a GitHub PR, verify the PR head/base, then delete
the temporary repo.
```

Commands:

```bash
jj new main
printf 'plain bookmark change\n' > plain.txt
jj commit -m "test: add plain bookmark change"
jj bookmark set demo/plain-bookmark -r @-
jj git push --bookmark demo/plain-bookmark
gh pr create --repo <owner>/<repo> \
  --base main \
  --head demo/plain-bookmark \
  --title "test: plain bookmark flow" \
  --body "Live jj plain bookmark flow."
gh pr view demo/plain-bookmark --repo <owner>/<repo> \
  --json number,url,state,mergeable,headRefName,baseRefName
```

The live run proved:

```json
{
  "baseRefName": "main",
  "headRefName": "demo/plain-bookmark",
  "state": "OPEN"
}
```

Use this for one coherent change that should become one PR.

## Flow 2: Multi-Commit Bookmark PR

Prompt:

```text
In a fresh temporary GitHub-backed jj repo, demonstrate a multi-commit session
bookmark. Start from main, make two described jj commits in a short chain, set
one review bookmark at the top commit, push that bookmark, open one PR, and
verify the PR contains both commits.
```

Commands:

```bash
jj new main
printf 'session edit one\n' > session.txt
jj commit -m "test: add first session edit"
printf 'session edit two\n' >> session.txt
jj commit -m "test: add second session edit"
jj bookmark set demo/session-bookmark -r @-
jj git push --bookmark demo/session-bookmark

jj log -r 'main..bookmarks(exact:"demo/session-bookmark")' \
  --no-graph --no-pager

gh pr create --repo <owner>/<repo> \
  --base main \
  --head demo/session-bookmark \
  --title "test: multi-commit bookmark flow" \
  --body "Live jj multi-commit bookmark flow."
gh pr view demo/session-bookmark --repo <owner>/<repo> \
  --json number,url,state,headRefName,baseRefName,commits
```

The live run proved that one bookmark can point at the top of a short chain and
GitHub shows both commits in one PR.

Use this when the review unit is one PR, but the local history should preserve
multiple meaningful commits.

## Flow 3: LazyJJ And JJ-Stack PR Stack

Prompt:

```text
In a fresh temporary GitHub-backed jj repo, demonstrate the GitButler
replacement stack flow using LazyJJ aliases and jj-stack. Verify the LazyJJ
aliases exist, create a base and child bookmark stack, push the stack with
`jj ss`, submit it with `jst submit <top-bookmark>`, show `jj prs`, and verify
GitHub has two open PRs with the child PR based on the base bookmark.
```

Commands:

```bash
jj config get aliases.start
jj config get aliases.create
jj config get aliases.stack
jj config get aliases.ss
jj config get aliases.prs

jj start
printf 'stack base\n' > stack.txt
jj commit -m "test: add stack base"
jj create demo/stack-base

printf 'stack child\n' >> stack.txt
jj commit -m "test: add stack child"
jj create demo/stack-child

jj stack --no-pager
jj ss
jst submit demo/stack-child
jj prs
gh pr list --repo <owner>/<repo> --state open \
  --json number,url,title,headRefName,baseRefName
```

The live run proved that `jj-stack` created:

```text
demo/stack-base  -> main
demo/stack-child -> demo/stack-base
```

and `jj prs` showed:

```text
## PR Stack

- demo/stack-child: test: add stack child
- demo/stack-base: test: add stack base
```

Use this for dependent slices that should be reviewed as stacked PRs. Local
stack manipulation stays in jj/LazyJJ; PR creation and base management belongs
to `jj-stack`.

## Flow 4: Parallel JJ Workspaces

Prompt:

```text
In a fresh temporary GitHub-backed jj repo, demonstrate parallel jj workspaces.
Create two workspaces based on main, make one described commit in each
workspace, set and push one bookmark per workspace, open one PR per bookmark,
verify both PRs target main, then forget the workspaces and delete the temp
repo.
```

Commands:

```bash
jj workspace add /tmp/demo-workspace-a --name live-workspace-a -r main
jj workspace add /tmp/demo-workspace-b --name live-workspace-b -r main

(
  cd /tmp/demo-workspace-a
  printf 'workspace a isolated change\n' > workspace-a.txt
  jj commit -m "test: add workspace a change"
  jj bookmark set demo/workspace-a -r @-
  jj git push --bookmark demo/workspace-a
  gh pr create --repo <owner>/<repo> \
    --base main \
    --head demo/workspace-a \
    --title "test: workspace a flow" \
    --body "Live jj workspace A flow."
)

(
  cd /tmp/demo-workspace-b
  printf 'workspace b isolated change\n' > workspace-b.txt
  jj commit -m "test: add workspace b change"
  jj bookmark set demo/workspace-b -r @-
  jj git push --bookmark demo/workspace-b
  gh pr create --repo <owner>/<repo> \
    --base main \
    --head demo/workspace-b \
    --title "test: workspace b flow" \
    --body "Live jj workspace B flow."
)

gh pr list --repo <owner>/<repo> --state open \
  --json number,url,title,headRefName,baseRefName
jj workspace forget live-workspace-a
jj workspace forget live-workspace-b
```

The live run proved that both workspace PRs target `main` independently:

```text
demo/workspace-a -> main
demo/workspace-b -> main
```

Base PR-ready workspaces on `main` or another described commit. Do not insert an
empty undescribed coordinator commit between `main` and worker bookmarks; jj
will reject pushing that undescribed ancestor.

## Cleanup Prompt

Prompt:

```text
After each live GitHub workflow example, verify the expected PR state, capture
the command log, and delete the temporary GitHub repository with
`gh repo delete <owner>/<repo> --yes`. Then verify the repo no longer exists.
```

Commands:

```bash
gh repo delete <owner>/<repo> --yes
gh repo view <owner>/<repo> --json name
```

The second command should fail after cleanup. If you need to debug a failed
run, set `AGENT_GEST_JJ_KEEP_GITHUB_REPOS=1`, inspect the repo, then delete it
manually.
