---
name: gpa
description: Gest PR Accept. Review a GitHub PR created from a jj bookmark or bookmark stack.
---

# GPA: Gest PR Accept

Use after a jj bookmark or bookmark stack has become a GitHub pull request.
`gpa` reviews a PR as an integration object: GitHub state, bookmark state,
checks, review history, diff, and Gest context.

`gpa` is mandatory after Codex pushes a non-mainline bookmark and creates or
updates a PR. Report the acceptance packet and ask before approving, requesting
changes, or merging unless the user explicitly asked for that action in the
current turn.

After a PR is merged, inspect the repository instructions and command contract
for required deployment or release work. Run the applicable deploy/release step
or report the concrete blocker; a merge alone is not a completed handoff when
the project expects deployment.

## Inputs

Accept a PR number, URL, bookmark/head name, or current bookmark PR. If no PR is
provided, discover it:

```bash
gh pr status
gh pr view --json number,url,title,headRefName,baseRefName,state
```

When using LazyJJ aliases, `jj prv`/`jj pro` may help inspect/open the current
PR if a GitHub remote is configured.

## Gather PR State

```bash
gh pr view <pr> --json \
  number,url,state,isDraft,title,body,author,headRefName,baseRefName,mergeable,reviewDecision,labels,commits,files,statusCheckRollup,latestReviews

gh pr diff <pr> --patch
gh pr checks <pr>
jj status
jj log -r 'trunk()..@ | bookmarks()' --no-pager
jj bookmark list --all
```

For stacks, also inspect whichever local stack command is available:

```bash
jj stack --no-pager
jj prmd 2>/dev/null || true
jst submit <top-bookmark> --dry-run
```

Do not claim live `jj-stack` or LazyJJ PR creation ran unless the repo has a
GitHub remote and authenticated `gh`.

## Gather Gest Context

```bash
gest search "<pr title or bookmark>" --all --json --limit 20
gest search "<pr url>" --all --json --limit 20
gest task list --all --json
gest iteration list --all --json
gest task show <task-id> --json
gest task note list <task-id> --json
gest iteration status <iteration-id> --json
```

Look for parent tasks, leaves, artifacts/specs, completion notes, GitHub issue
metadata, `github.pr`, `github.pr_url`, `vcs.bookmark`, `vcs.stack_*`, and
graph paths.
Also look for tag classification and dependency impact notes from
`references/tag_dependency_workflow.md`, especially selected semantic tags and
`ast-grep` dependers.

## Review

Findings first. Check:

- correctness, regressions, safety, error handling
- missing or insufficient tests
- docs drift
- installer/setup impact
- CI/check failures
- PR body mismatch with actual diff
- missing sanitized Gest context in the PR body
- missing completion notes
- unsafe merge method for the bookmark or stack model
- unpushed local bookmarks or dirty jj workspace state
- raw git write instructions in a jj repo
- git worktree usage instead of jj workspaces
- stack flows that lack bottom-up or `jj-stack`/LazyJJ PR guidance
- missing tag classification or missing `ast-grep` dependency impact coverage
  for code-facing PRs

For non-trivial PRs, use adversarial review lenses. Default to independent
read-only review sub-agents when sub-agents are available, authorized, and the
lenses can be checked independently; skip sub-agents only when they are
unavailable, unsafe, or overkill for a tiny PR. Otherwise run the lenses
explicitly yourself:

- code behavior and regression risk
- test adequacy, including whether new tests would fail on the old code
- jj bookmark/workspace, stack, push, and merge safety
- PR body and sanitized Gest context accuracy
- docs, setup, command-contract, release, and deployment drift
- security, privacy, data, browser/UI, or language/runtime risk when relevant

Writable sub-agents still require separate jj workspaces. Gest mutations,
approvals, merges, and post-merge bookkeeping should remain centralized unless
deliberately assigned.

For reusable workflow PRs, preserve adapter boundaries: bookmarks are not
branches, bookmarks do not auto-advance, jj workspaces are not git worktrees,
raw git writes remain forbidden, and GitButler stack guidance should not be
copied into jj mechanics.

For `cx` workflow PRs, verify that `cx` is framed as incremental build/pipeline
infrastructure, not testing. Review `cx` lines for complete `--in`/`--out`
declarations, durable file outputs, producer/consumer Just ordering, and
`.cx` runtime-state ignore rules that do not hide future config.

Treat `Findings: None` as a precise statement about blocking or actionable
code-review findings, not as the whole PR review. If no findings exist, say so
clearly and list residual risk.

After findings, add reviewer judgment when it would help the user: call out
non-blocking opinions about clarity, maintainability, UX, naming, fit with local
patterns, bookmark/PR shape, or tradeoffs. Label these separately from findings
so taste-level feedback does not look like a merge blocker.

## Acceptance Packet

Report:

```markdown
## Codex PR Review

Findings:
- None / <findings ordered by severity>

Reviewer Notes:
- <non-blocking opinions, maintainability/UX/readability judgment, or None>

PR State:
- PR: <url>
- Bookmark/head/base:
- Mergeability:
- Checks:
- Review decision:

Gest Context:
- Parent task:
- Leaf tasks:
- Iteration:
- Artifacts/specs:
- Completion notes:
- Verification:
- Follow-ups:
- GitHub metadata:
- Graphs:

Adversarial Review:
- Code behavior:
- Test adequacy:
- Workflow/VCS safety:
- Docs/setup/contract drift:
- Residual risk:

Recommendation:
- approve/request changes/hold
- merge method:
- post-merge steps:
```

## Gest Context Appendix

Every PR for Gest-tracked work should include a concise sanitized appendix
unless the repo is public and context is too internal:

```markdown
## Gest Context

- Parent: <title>
- Leaves: <titles>
- Iteration: <title>
- Artifacts/specs: <public-safe list>
- Verification: <commands/checks>
- Follow-ups: <none or list>
```

Use `gh pr edit <pr> --body-file <file>` only after reviewing the current body.

## Safe Actions

Ask before approving, requesting changes, or merging unless explicitly
authorized in the current turn:

```bash
gh pr review <pr> --approve --body-file <file>
gh pr review <pr> --request-changes --body-file <file>
gh pr review <pr> --comment --body-file <file>
gh pr merge <pr> --merge --delete-branch
gh pr merge <pr> --squash --delete-branch
gh pr merge <pr> --rebase --delete-branch
```

After merging, record PR metadata on the relevant Gest task(s), regenerate
checkpoint graphs when applicable, and verify local jj/bookmark state.
