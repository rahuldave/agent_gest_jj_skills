# JJ Tutorial

This tutorial creates four temporary GitHub repositories with fixed names, runs
four jj agent workflows, and tells you exactly what to check after each turn.

You will learn:

1. plain jj bookmark PR
2. multi-commit jj bookmark PR
3. jj-stack stacked PRs for dependent slices
4. parallel jj workspaces for independent parallel slices
5. tag classification and ast-grep dependency checks before code edits

Only step 3 uses jj-stack as the main PR submission tool. GitButler is not used
in this tutorial.

## What This Tutorial Will Do

The agent will create and later delete these GitHub repositories under your
GitHub account:

```text
agent-gest-jj-tutorial-plain
agent-gest-jj-tutorial-multi
agent-gest-jj-tutorial-stack
agent-gest-jj-tutorial-workspaces
```

Do not use those names for anything valuable. The prompts below tell the agent
to delete any existing repositories with those names before starting, then
delete them again during cleanup. Cleanup uses `gh repo delete --yes`.

Prerequisites:

- `gh auth status -h github.com` succeeds.
- Your GitHub auth has `repo` and `delete_repo` scopes.
- `git`, `gh`, `jj`, `gest`, `just`, and `jst` are installed.
- LazyJJ aliases such as `jj start`, `jj create`, `jj stack`, `jj ss`, and
  `jj prs` are installed for the stack step.
- You are comfortable letting the agent create and delete the four temporary
  repositories named above.

## Step 0: Setup And Cleanup Contract

What this step teaches:

The agent should use fixed repo names, clean up before and after the tutorial,
and tell you where it wrote logs.

Ask the agent:

```text
Run the jj tutorial setup.

Use my GitHub account from `gh api user -q .login`.
Use exactly these temporary private repo names:

- agent-gest-jj-tutorial-plain
- agent-gest-jj-tutorial-multi
- agent-gest-jj-tutorial-stack
- agent-gest-jj-tutorial-workspaces

Before starting, delete any existing GitHub repos with those names using
`gh repo delete <owner>/<name> --yes`, ignoring "not found" errors.

Create a local tutorial root at `/tmp/agent-gest-jj-tutorial`.
Create `/tmp/agent-gest-jj-tutorial/logs`.

For each following step, write a command log in that logs directory. After all
steps finish, delete the four GitHub repos unless I explicitly ask to keep them.
```

After the agent finishes, check:

```bash
test -d /tmp/agent-gest-jj-tutorial/logs
```

The agent should report your GitHub owner and the exact log directory.

## Step 1: Plain JJ Bookmark PR

What this step teaches:

Use one jj bookmark as one simple review handle. GitButler is not needed.

Repository:

```text
agent-gest-jj-tutorial-plain
```

Ask the agent:

```text
Run tutorial step 1: plain jj bookmark PR.

Create private GitHub repo `agent-gest-jj-tutorial-plain`.
Clone or initialize it under `/tmp/agent-gest-jj-tutorial/plain`.
Initialize it as a colocated jj repo.
Create `main` with README.md containing `plain tutorial base`.
Push only the `main` bookmark.

Create a new jj change from `main`.
Add `plain.txt` containing `plain bookmark change`.
Commit with message `test: add plain bookmark change`.
Set bookmark `tutorial/plain-bookmark` at the completed commit.
Push only bookmark `tutorial/plain-bookmark`.
Open a PR with:
- base: `main`
- head: `tutorial/plain-bookmark`
- title: `test: plain jj bookmark flow`

Write all commands and key outputs to
`/tmp/agent-gest-jj-tutorial/logs/01-plain-jj-bookmark.log`.
```

After the agent finishes, check:

```bash
gh pr view tutorial/plain-bookmark \
  --repo "$(gh api user -q .login)/agent-gest-jj-tutorial-plain" \
  --json state,baseRefName,headRefName,title
```

Expected:

```text
state: OPEN
baseRefName: main
headRefName: tutorial/plain-bookmark
title: test: plain jj bookmark flow
```

Commands it should have used:

- `jj git init --colocate`
- `jj new main`
- `jj commit`
- `jj bookmark set tutorial/plain-bookmark -r @-`
- `jj git push --bookmark tutorial/plain-bookmark`
- `gh pr create`

Commands it should not have used:

- `git commit`
- `git push`
- `but setup`
- `but commit`

## Step 2: Multi-Commit JJ Bookmark PR

What this step teaches:

Use one jj bookmark when one review branch needs more than one commit.

Repository:

```text
agent-gest-jj-tutorial-multi
```

Ask the agent:

```text
Run tutorial step 2: multi-commit jj bookmark PR.

Create private GitHub repo `agent-gest-jj-tutorial-multi`.
Clone or initialize it under `/tmp/agent-gest-jj-tutorial/multi`.
Initialize it as a colocated jj repo.
Create `main` with README.md containing `multi tutorial base`.
Push only the `main` bookmark.

Create a new jj change from `main`.
Add `session.txt` containing `session edit one`.
Commit with message `test: add first session edit`.
Append `session edit two` to `session.txt`.
Commit with message `test: add second session edit`.
Set bookmark `tutorial/multi-bookmark` at the second completed commit.
Push only bookmark `tutorial/multi-bookmark`.
Open a PR with:
- base: `main`
- head: `tutorial/multi-bookmark`
- title: `test: multi commit jj bookmark flow`

Write all commands and key outputs to
`/tmp/agent-gest-jj-tutorial/logs/02-multi-commit-jj-bookmark.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr view tutorial/multi-bookmark \
  --repo "$owner/agent-gest-jj-tutorial-multi" \
  --json state,baseRefName,headRefName,title,commits
```

Expected:

```text
state: OPEN
baseRefName: main
headRefName: tutorial/multi-bookmark
title: test: multi commit jj bookmark flow
commits: two commits on the PR branch
```

Commands it should not have used:

- `git commit`
- `git push`
- `but setup`
- `but commit`

## Step 3: jj-stack Stacked PRs

What this step teaches:

Use jj bookmarks and `jj-stack` when you have multiple dependent, meaty slices
that should be reviewed separately. This is the stacked PR step.

Repository:

```text
agent-gest-jj-tutorial-stack
```

Ask the agent:

```text
Run tutorial step 3: jj-stack stacked PRs.

Create private GitHub repo `agent-gest-jj-tutorial-stack`.
Clone or initialize it under `/tmp/agent-gest-jj-tutorial/stack`.
Initialize it as a colocated jj repo.
Create `main` with README.md containing `stack tutorial base`.
Push only the `main` bookmark.

Verify these LazyJJ aliases are available:
- `jj start`
- `jj create`
- `jj stack`
- `jj ss`
- `jj prs`

Run `jj start`.
Add `stack.txt` containing `stack base`.
Commit with message `test: add stack base`.
Create bookmark `tutorial/stack-base`.

Append `stack child` to `stack.txt`.
Commit with message `test: add stack child`.
Create bookmark `tutorial/stack-child`.

Run `jj stack`.
Run `jj ss` to push the bookmark stack.
Run `jst submit tutorial/stack-child` to create/update the stacked PRs.
Run `jj prs`.

Open or verify two PRs:
- `tutorial/stack-base` into `main`, title `test: add stack base`
- `tutorial/stack-child` into `tutorial/stack-base`, title `test: add stack child`

If `jst submit` cannot run because GitHub remote/auth prerequisites are
missing, stop and report the exact blocker. Do not silently replace this step
with GitButler.

Write all commands and key outputs to
`/tmp/agent-gest-jj-tutorial/logs/03-jj-stack.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr list \
  --repo "$owner/agent-gest-jj-tutorial-stack" \
  --state open \
  --json title,baseRefName,headRefName
```

Expected:

```text
PR: test: add stack base
baseRefName: main
headRefName: tutorial/stack-base

PR: test: add stack child
baseRefName: tutorial/stack-base
headRefName: tutorial/stack-child
```

Commands it should have used:

- `jj start`
- `jj create tutorial/stack-base`
- `jj create tutorial/stack-child`
- `jj stack`
- `jj ss`
- `jst submit tutorial/stack-child`
- `jj prs`

This step should not use GitButler or physical git worktrees.

## Step 4: Parallel JJ Workspaces

What this step teaches:

Use jj workspaces for independent parallel slices. Do not use GitButler
parallel lanes or git worktrees as the jj agent parallelism primitive.

Repository:

```text
agent-gest-jj-tutorial-workspaces
```

Ask the agent:

```text
Run tutorial step 4: parallel jj workspaces.

Create private GitHub repo `agent-gest-jj-tutorial-workspaces`.
Clone or initialize it under `/tmp/agent-gest-jj-tutorial/workspaces`.
Initialize it as a colocated jj repo.
Create `main` with README.md containing `workspace tutorial base`.
Push only the `main` bookmark.

Create two jj workspaces:
- `/tmp/agent-gest-jj-tutorial/workspace-a` named `tutorial-workspace-a`
- `/tmp/agent-gest-jj-tutorial/workspace-b` named `tutorial-workspace-b`

Base both workspaces on `main`.

In workspace A, add `workspace-a.txt` containing `workspace a isolated change`,
commit with message `test: add workspace a change`, set bookmark
`tutorial/workspace-a`, push that bookmark, and open a PR into `main` titled
`test: workspace a flow`.

In workspace B, add `workspace-b.txt` containing `workspace b isolated change`,
commit with message `test: add workspace b change`, set bookmark
`tutorial/workspace-b`, push that bookmark, and open a PR into `main` titled
`test: workspace b flow`.

Forget both jj workspaces after the PRs are open.

Write all commands and key outputs to
`/tmp/agent-gest-jj-tutorial/logs/04-parallel-jj-workspaces.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr list \
  --repo "$owner/agent-gest-jj-tutorial-workspaces" \
  --state open \
  --json title,baseRefName,headRefName
```

Expected:

```text
PR: test: workspace a flow
baseRefName: main
headRefName: tutorial/workspace-a

PR: test: workspace b flow
baseRefName: main
headRefName: tutorial/workspace-b
```

Commands it should have used:

- `jj workspace add /tmp/agent-gest-jj-tutorial/workspace-a --name tutorial-workspace-a -r main`
- `jj workspace add /tmp/agent-gest-jj-tutorial/workspace-b --name tutorial-workspace-b -r main`
- `jj commit` inside each workspace
- `jj bookmark set ... -r @-`
- `jj git push --bookmark ...`
- `gh pr create`
- `jj workspace forget ...`

Commands it should not have used:

- GitButler parallel lanes
- git worktrees

## Step 5: Tags And ast-grep Dependency Check

What this step teaches:

Before the agent edits code, it should classify the task with project tags and
run ast-grep against the semantic contract that is changing. If another surface
depends on that contract, the agent should expand the task or create a tagged
child task before implementation.

Local fixture:

```text
/tmp/agent-gest-jj-tutorial/tag-ast-grep
```

Ask the agent:

```text
Run tutorial step 5: tag classification and ast-grep dependency check.

Create `/tmp/agent-gest-jj-tutorial/tag-ast-grep/src`.

Create `src/colors.js` containing a function named
`countOrProbabilityColorScale`.
Create `src/histogram.js` that calls `countOrProbabilityColorScale`.
Create `src/pill.js` that calls `countOrProbabilityColorScale`.

Before editing anything, classify the requested change "change histogram colors
for low-count bins" with these tags:
- selected existing tag: `count-or-probability-coloring`
- selected existing tag: `histogram-colors`
- selected existing tag: `probability-pill-colors`
- rejected near miss: `reader-ui`

Then run:

`ast-grep run --lang javascript --pattern 'countOrProbabilityColorScale($$$)' --json=compact src`

The dependency impact should find both:
- `src/histogram.js`
- `src/pill.js`

Do not change the fixture in this step. Write the selected tags, rejected tag,
ast-grep command, and dependency-impact conclusion to
`/tmp/agent-gest-jj-tutorial/logs/05-tag-ast-grep.log`.
```

After the agent finishes, check:

```bash
rg "count-or-probability-coloring|histogram.js|pill.js|reader-ui" \
  /tmp/agent-gest-jj-tutorial/logs/05-tag-ast-grep.log
```

Expected:

```text
count-or-probability-coloring
histogram.js
pill.js
reader-ui
```

The agent should report that a histogram-color implementation must also account
for the probability-pill color surface, or create a child task tagged with the
same semantic dependency before completion.

## Step 6: Cleanup

Ask the agent:

```text
Run tutorial cleanup.

Delete these GitHub repositories if they exist:
- agent-gest-jj-tutorial-plain
- agent-gest-jj-tutorial-multi
- agent-gest-jj-tutorial-stack
- agent-gest-jj-tutorial-workspaces

Use `gh repo delete <owner>/<repo> --yes`.
Remove `/tmp/agent-gest-jj-tutorial/workspace-a` and
`/tmp/agent-gest-jj-tutorial/workspace-b` if they still exist.
Keep `/tmp/agent-gest-jj-tutorial/logs` unless I ask you to remove logs.
```

After cleanup, check one repo:

```bash
owner="$(gh api user -q .login)"
gh repo view "$owner/agent-gest-jj-tutorial-plain"
```

Expected:

```text
repository not found
```

## Automated Regression Labs

The scripts in this repo are regression checks, not the beginner tutorial:

```bash
just workflow-lab
just integration-live
```

They intentionally stress jj itself, LazyJJ aliases, `jj-stack`, jj workspace
hooks, and tag/ast-grep dependency checks. Read this tutorial first; use those
scripts when you want to verify the reusable skill repository.
