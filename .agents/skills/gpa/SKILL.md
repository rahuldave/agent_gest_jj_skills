---
name: gpa
description: Gest PR Accept. Review a GitHub PR created from a jj bookmark or bookmark stack.
---

# GPA: Gest PR Accept

Use after a jj bookmark has become a GitHub pull request.

## Gather PR State

```bash
gh pr view <pr> --json number,url,state,isDraft,title,body,author,headRefName,baseRefName,mergeable,reviewDecision,labels,commits,files,statusCheckRollup,latestReviews
gh pr diff <pr> --patch
gh pr checks <pr>
jj status
jj log -r 'trunk()..@ | bookmarks()' --no-pager
jj bookmark list
```

Gather related Gest context with `gest search`, task notes, and iteration
status. Look for `github.pr`, `github.pr_url`, `vcs.bookmark`, and stack
metadata.

## Review

Findings first. Check correctness, tests, docs, CI, PR body accuracy, missing
Gest context, unsafe merge method, unpushed bookmarks, and jj policy violations.

## Acceptance Packet

Report:

- PR URL and state
- bookmark/head/base relationship
- checks and review decision
- Gest parent/leaves/iteration/specs
- verification and follow-ups
- recommendation: approve, request changes, hold, or merge after approval

Ask before approving/requesting changes/merging unless the user explicitly
asked for that action in the current turn.
