# Live JJ Tutorial Transcript

Date: 2026-05-07

Run ID: `20260507T141932Z`

Owner: `rahuldave`

This is a clean rerun of the four jj tutorial examples against live temporary
GitHub repositories. The transcript was captured while acting as both the user
and the agent. The temporary repositories were deleted at the end with
`gh repo delete --yes`.

## Step 1: Plain JJ Bookmark PR

$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: will change to "main" in Git 3.0. To configure the initial branch name
hint: to use in all of your new repositories, which will suppress this warning,
hint: call:
hint:
hint: 	git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint: 	git branch -m <name>
hint:
hint: Disable this message with "git config set advice.defaultBranchName false"
Initialized empty Git repository in /private/tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/plain/.git/

$ git config user.name tutorial-agent

$ git config user.email tutorial-agent@example.invalid

$ gh repo create rahuldave/agent-gest-jj-tutorial-plain --private --source=. --remote=origin --disable-issues --disable-wiki
https://github.com/rahuldave/agent-gest-jj-tutorial-plain

$ jj git init --colocate
Done importing changes from the underlying Git repo.
Initialized repo in "."
Hint: Running `git clean -xdf` will remove `.jj/`!

$ cat > README.md <<'EOF'
plain tutorial base
EOF

$ jj diff
Added regular file README.md:
        1: plain tutorial base

$ jj describe -m 'chore: initialize tutorial repo'
Working copy  (@) now at: xqsynuxw 7149780a chore: initialize tutorial repo
Parent commit (@-)      : zzzzzzzz 00000000 (empty) (no description set)

$ jj new
Working copy  (@) now at: slwrsmyy 84126ffd (empty) (no description set)
Parent commit (@-)      : xqsynuxw 7149780a chore: initialize tutorial repo

$ jj bookmark set main -r @-
Created 1 bookmarks pointing to xqsynuxw 7149780a main | chore: initialize tutorial repo

$ jj git push --bookmark main
Changes to push to origin:
  Add bookmark main to 7149780a4c7a

$ jj bookmark list --all
main: xqsynuxw 7149780a chore: initialize tutorial repo
  @git: xqsynuxw 7149780a chore: initialize tutorial repo
  @origin: xqsynuxw 7149780a chore: initialize tutorial repo

$ jj new main
Working copy  (@) now at: ynvnvsqt 607cf1c9 (empty) (no description set)
Parent commit (@-)      : xqsynuxw 7149780a main | chore: initialize tutorial repo

$ cat > plain.txt <<'EOF'
plain bookmark change
EOF

$ jj commit -m 'test: add plain bookmark change'
Working copy  (@) now at: qkmmyqlu b1fd79bb (empty) (no description set)
Parent commit (@-)      : ynvnvsqt 1c16baa8 test: add plain bookmark change

$ jj bookmark set tutorial/plain-bookmark -r @-
Created 1 bookmarks pointing to ynvnvsqt 1c16baa8 tutorial/plain-bookmark | test: add plain bookmark change

$ jj git push --bookmark tutorial/plain-bookmark
Changes to push to origin:
  Add bookmark tutorial/plain-bookmark to 1c16baa8be36
remote:
remote: Create a pull request for 'tutorial/plain-bookmark' on GitHub by visiting:
remote:      https://github.com/rahuldave/agent-gest-jj-tutorial-plain/pull/new/tutorial/plain-bookmark
remote:

$ gh pr create --repo rahuldave/agent-gest-jj-tutorial-plain --base main --head tutorial/plain-bookmark --title 'test: plain jj bookmark flow' --body 'Tutorial plain jj bookmark flow.'
https://github.com/rahuldave/agent-gest-jj-tutorial-plain/pull/1

$ gh pr view tutorial/plain-bookmark --repo rahuldave/agent-gest-jj-tutorial-plain --json state,baseRefName,headRefName,title
{"baseRefName":"main","headRefName":"tutorial/plain-bookmark","state":"OPEN","title":"test: plain jj bookmark flow"}

## Step 2: Multi-Commit JJ Bookmark PR

$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: will change to "main" in Git 3.0. To configure the initial branch name
hint: to use in all of your new repositories, which will suppress this warning,
hint: call:
hint:
hint: 	git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint: 	git branch -m <name>
hint:
hint: Disable this message with "git config set advice.defaultBranchName false"
Initialized empty Git repository in /private/tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/multi/.git/

$ git config user.name tutorial-agent

$ git config user.email tutorial-agent@example.invalid

$ gh repo create rahuldave/agent-gest-jj-tutorial-multi --private --source=. --remote=origin --disable-issues --disable-wiki
https://github.com/rahuldave/agent-gest-jj-tutorial-multi

$ jj git init --colocate
Done importing changes from the underlying Git repo.
Initialized repo in "."
Hint: Running `git clean -xdf` will remove `.jj/`!

$ cat > README.md <<'EOF'
multi tutorial base
EOF

$ jj diff
Added regular file README.md:
        1: multi tutorial base

$ jj describe -m 'chore: initialize tutorial repo'
Working copy  (@) now at: kvynwzkn e45f1953 chore: initialize tutorial repo
Parent commit (@-)      : zzzzzzzz 00000000 (empty) (no description set)

$ jj new
Working copy  (@) now at: qrtwprlm 2d96d027 (empty) (no description set)
Parent commit (@-)      : kvynwzkn e45f1953 chore: initialize tutorial repo

$ jj bookmark set main -r @-
Created 1 bookmarks pointing to kvynwzkn e45f1953 main | chore: initialize tutorial repo

$ jj git push --bookmark main
Changes to push to origin:
  Add bookmark main to e45f1953807a

$ jj bookmark list --all
main: kvynwzkn e45f1953 chore: initialize tutorial repo
  @git: kvynwzkn e45f1953 chore: initialize tutorial repo
  @origin: kvynwzkn e45f1953 chore: initialize tutorial repo

$ jj new main
Working copy  (@) now at: kknqowmy b3a53c55 (empty) (no description set)
Parent commit (@-)      : kvynwzkn e45f1953 main | chore: initialize tutorial repo

$ cat > session.txt <<'EOF'
session edit one
EOF

$ jj commit -m 'test: add first session edit'
Working copy  (@) now at: ssqwnlty 56914af5 (empty) (no description set)
Parent commit (@-)      : kknqowmy 86a51457 test: add first session edit

$ cat >> session.txt <<'EOF'
session edit two
EOF

$ jj commit -m 'test: add second session edit'
Working copy  (@) now at: qpklztlt d9de7a64 (empty) (no description set)
Parent commit (@-)      : ssqwnlty a3894543 test: add second session edit

$ jj bookmark set tutorial/multi-bookmark -r @-
Created 1 bookmarks pointing to ssqwnlty a3894543 tutorial/multi-bookmark | test: add second session edit

$ jj git push --bookmark tutorial/multi-bookmark
Changes to push to origin:
  Add bookmark tutorial/multi-bookmark to a3894543bc25
remote:
remote: Create a pull request for 'tutorial/multi-bookmark' on GitHub by visiting:
remote:      https://github.com/rahuldave/agent-gest-jj-tutorial-multi/pull/new/tutorial/multi-bookmark
remote:

$ gh pr create --repo rahuldave/agent-gest-jj-tutorial-multi --base main --head tutorial/multi-bookmark --title 'test: multi commit jj bookmark flow' --body 'Tutorial multi-commit jj bookmark flow.'
https://github.com/rahuldave/agent-gest-jj-tutorial-multi/pull/1

$ gh pr view tutorial/multi-bookmark --repo rahuldave/agent-gest-jj-tutorial-multi --json state,baseRefName,headRefName,title,commits
{"baseRefName":"main","commits":[{"authoredDate":"2026-05-07T14:20:40Z","authors":[{"email":"rahuldave@hey.com","id":"MDQ6VXNlcjY3NjIzOTY3","login":"rahuldavehey","name":"Rahul Dave"}],"committedDate":"2026-05-07T14:20:40Z","messageBody":"","messageHeadline":"test: add first session edit","oid":"86a5145742ab0b0d5bbbb756b646a68b9572b992"},{"authoredDate":"2026-05-07T14:20:40Z","authors":[{"email":"rahuldave@hey.com","id":"MDQ6VXNlcjY3NjIzOTY3","login":"rahuldavehey","name":"Rahul Dave"}],"committedDate":"2026-05-07T14:20:40Z","messageBody":"","messageHeadline":"test: add second session edit","oid":"a3894543bc25f133d19aa7fa50b3ceb787c97e67"}],"headRefName":"tutorial/multi-bookmark","state":"OPEN","title":"test: multi commit jj bookmark flow"}

## Step 3: jj-stack Stacked PRs

$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: will change to "main" in Git 3.0. To configure the initial branch name
hint: to use in all of your new repositories, which will suppress this warning,
hint: call:
hint:
hint: 	git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint: 	git branch -m <name>
hint:
hint: Disable this message with "git config set advice.defaultBranchName false"
Initialized empty Git repository in /private/tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/stack/.git/

$ git config user.name tutorial-agent

$ git config user.email tutorial-agent@example.invalid

$ gh repo create rahuldave/agent-gest-jj-tutorial-stack --private --source=. --remote=origin --disable-issues --disable-wiki
https://github.com/rahuldave/agent-gest-jj-tutorial-stack

$ jj git init --colocate
Done importing changes from the underlying Git repo.
Initialized repo in "."
Hint: Running `git clean -xdf` will remove `.jj/`!

$ cat > README.md <<'EOF'
stack tutorial base
EOF

$ jj diff
Added regular file README.md:
        1: stack tutorial base

$ jj describe -m 'chore: initialize tutorial repo'
Working copy  (@) now at: snllqrmn fba70ff1 chore: initialize tutorial repo
Parent commit (@-)      : zzzzzzzz 00000000 (empty) (no description set)

$ jj new
Working copy  (@) now at: zlkupqlo 1377e804 (empty) (no description set)
Parent commit (@-)      : snllqrmn fba70ff1 chore: initialize tutorial repo

$ jj bookmark set main -r @-
Created 1 bookmarks pointing to snllqrmn fba70ff1 main | chore: initialize tutorial repo

$ jj git push --bookmark main
Changes to push to origin:
  Add bookmark main to fba70ff1ff65

$ jj bookmark list --all
main: snllqrmn fba70ff1 chore: initialize tutorial repo
  @git: snllqrmn fba70ff1 chore: initialize tutorial repo
  @origin: snllqrmn fba70ff1 chore: initialize tutorial repo

$ jj config get aliases.start
["stack-start"]

$ jj config get aliases.create
["bookmark", "create", "--to", "@-"]

$ jj config get aliases.stack
["stack-view"]

$ jj config get aliases.ss
["stack-submit"]

$ jj config get aliases.prs
["pr-stack-summary"]

$ jj start
Nothing changed.
Working copy  (@) now at: vnqsnutn 3bb240ab (empty) (no description set)
Parent commit (@-)      : snllqrmn fba70ff1 main | chore: initialize tutorial repo

$ cat > stack.txt <<'EOF'
stack base
EOF

$ jj commit -m 'test: add stack base'
Working copy  (@) now at: vllnpzvo fbc75269 (empty) (no description set)
Parent commit (@-)      : vnqsnutn daa18426 test: add stack base

$ jj create tutorial/stack-base
Created 1 bookmarks pointing to vnqsnutn daa18426 tutorial/stack-base | test: add stack base

$ cat >> stack.txt <<'EOF'
stack child
EOF

$ jj commit -m 'test: add stack child'
Working copy  (@) now at: xkmmkrmm 7641292f (empty) (no description set)
Parent commit (@-)      : vllnpzvo d3325e09 test: add stack child

$ jj create tutorial/stack-child
Created 1 bookmarks pointing to vllnpzvo d3325e09 tutorial/stack-child | test: add stack child

$ jj stack --no-pager
@  xkmmkrmm rahuldave@hey.com 2026-05-07 10:20:50 7641292f
│  (empty) (no description set)
○  vllnpzvo rahuldave@hey.com 2026-05-07 10:20:50 tutorial/stack-child d3325e09
│  test: add stack child
○  vnqsnutn rahuldave@hey.com 2026-05-07 10:20:49 tutorial/stack-base daa18426
│  test: add stack base
◆  snllqrmn rahuldave@hey.com 2026-05-07 10:20:47 main fba70ff1
│  chore: initialize tutorial repo
~

$ jj ss
Warning: --allow-new is deprecated, track bookmarks manually or configure remotes.<name>.auto-track-bookmarks instead.
Changes to push to origin:
  Add bookmark tutorial/stack-base to daa18426d42e
  Add bookmark tutorial/stack-child to d3325e09dd57

$ /Users/rahul/Projects/agent_gest_jj_skills/node_modules/.bin/jst submit tutorial/stack-child
🚀 Submitting bookmark: tutorial/stack-child
Fetching from remote...
Building change graph from user bookmarks...
🔍 Analyzing submission requirements for: tutorial/stack-child
✅ Found stack with 2 segment(s)
📋 All changes have single bookmarks, proceeding automatically...
🔑 Getting GitHub authentication...
📋 Creating submission plan...
📍 GitHub repository: rahuldave/agent-gest-jj-tutorial-stack
📋 tutorial/stack-base: has remote, needs PR
📋 tutorial/stack-child: has remote, needs PR
Creating PR: tutorial/stack-base -> main
   Title: "test: add stack base"
✅ Created PR for tutorial/stack-base: https://github.com/rahuldave/agent-gest-jj-tutorial-stack/pull/1
   Title: test: add stack base
   Base: main <- Head: tutorial/stack-base
Creating PR: tutorial/stack-child -> tutorial/stack-base
   Title: "test: add stack child"
✅ Created PR for tutorial/stack-child: https://github.com/rahuldave/agent-gest-jj-tutorial-stack/pull/2
   Title: test: add stack child
   Base: tutorial/stack-base <- Head: tutorial/stack-child

🎉 Successfully submitted stack up to tutorial/stack-child!
   📝 Created PRs: tutorial/stack-base, tutorial/stack-child

$ jj prs
## PR Stack

- [tutorial/stack-child](https://github.com/rahuldave/agent-gest-jj-tutorial-stack/pull/2): test: add stack child
- [tutorial/stack-base](https://github.com/rahuldave/agent-gest-jj-tutorial-stack/pull/1): test: add stack base

$ gh pr list --repo rahuldave/agent-gest-jj-tutorial-stack --state open --json title,baseRefName,headRefName
[{"baseRefName":"tutorial/stack-base","headRefName":"tutorial/stack-child","title":"test: add stack child"},{"baseRefName":"main","headRefName":"tutorial/stack-base","title":"test: add stack base"}]

## Step 4: Parallel JJ Workspaces

$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: will change to "main" in Git 3.0. To configure the initial branch name
hint: to use in all of your new repositories, which will suppress this warning,
hint: call:
hint:
hint: 	git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint: 	git branch -m <name>
hint:
hint: Disable this message with "git config set advice.defaultBranchName false"
Initialized empty Git repository in /private/tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/workspaces/.git/

$ git config user.name tutorial-agent

$ git config user.email tutorial-agent@example.invalid

$ gh repo create rahuldave/agent-gest-jj-tutorial-workspaces --private --source=. --remote=origin --disable-issues --disable-wiki
https://github.com/rahuldave/agent-gest-jj-tutorial-workspaces

$ jj git init --colocate
Done importing changes from the underlying Git repo.
Initialized repo in "."
Hint: Running `git clean -xdf` will remove `.jj/`!

$ cat > README.md <<'EOF'
workspace tutorial base
EOF

$ jj diff
Added regular file README.md:
        1: workspace tutorial base

$ jj describe -m 'chore: initialize tutorial repo'
Working copy  (@) now at: rysvnpqm 73f83f58 chore: initialize tutorial repo
Parent commit (@-)      : zzzzzzzz 00000000 (empty) (no description set)

$ jj new
Working copy  (@) now at: uvlrxvtu 7235d531 (empty) (no description set)
Parent commit (@-)      : rysvnpqm 73f83f58 chore: initialize tutorial repo

$ jj bookmark set main -r @-
Created 1 bookmarks pointing to rysvnpqm 73f83f58 main | chore: initialize tutorial repo

$ jj git push --bookmark main
Changes to push to origin:
  Add bookmark main to 73f83f5832d5

$ jj bookmark list --all
main: rysvnpqm 73f83f58 chore: initialize tutorial repo
  @git: rysvnpqm 73f83f58 chore: initialize tutorial repo
  @origin: rysvnpqm 73f83f58 chore: initialize tutorial repo

$ jj workspace add /tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/workspace-a --name tutorial-workspace-a -r main
Created workspace in "../../../../../../tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/workspace-a"
Working copy  (@) now at: wovlknwx be5fa04a (empty) (no description set)
Parent commit (@-)      : rysvnpqm 73f83f58 main | chore: initialize tutorial repo
Added 1 files, modified 0 files, removed 0 files

$ jj workspace add /tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/workspace-b --name tutorial-workspace-b -r main
Created workspace in "../../../../../../tmp/agent-gest-clean-live-tutorial-runs/20260507T141932Z/jj/workspace-b"
Working copy  (@) now at: uwxuxonr 43e55644 (empty) (no description set)
Parent commit (@-)      : rysvnpqm 73f83f58 main | chore: initialize tutorial repo
Added 1 files, modified 0 files, removed 0 files

$ cat > workspace-a.txt <<'EOF'
workspace a isolated change
EOF

$ jj commit -m 'test: add workspace a change'
Working copy  (@) now at: pnuwrmvu 155bd791 (empty) (no description set)
Parent commit (@-)      : wovlknwx f2811cf7 test: add workspace a change

$ jj bookmark set tutorial/workspace-a -r @-
Created 1 bookmarks pointing to wovlknwx f2811cf7 tutorial/workspace-a | test: add workspace a change

$ jj git push --bookmark tutorial/workspace-a
Changes to push to origin:
  Add bookmark tutorial/workspace-a to f2811cf7588f
remote:
remote: Create a pull request for 'tutorial/workspace-a' on GitHub by visiting:
remote:      https://github.com/rahuldave/agent-gest-jj-tutorial-workspaces/pull/new/tutorial/workspace-a
remote:

$ gh pr create --repo rahuldave/agent-gest-jj-tutorial-workspaces --base main --head tutorial/workspace-a --title 'test: workspace a flow' --body 'Tutorial jj workspace A flow.'
https://github.com/rahuldave/agent-gest-jj-tutorial-workspaces/pull/1

$ cat > workspace-b.txt <<'EOF'
workspace b isolated change
EOF

$ jj commit -m 'test: add workspace b change'
Working copy  (@) now at: zrvoovyk e7688c2e (empty) (no description set)
Parent commit (@-)      : uwxuxonr 742ccdfe test: add workspace b change

$ jj bookmark set tutorial/workspace-b -r @-
Created 1 bookmarks pointing to uwxuxonr 742ccdfe tutorial/workspace-b | test: add workspace b change

$ jj git push --bookmark tutorial/workspace-b
Changes to push to origin:
  Add bookmark tutorial/workspace-b to 742ccdfee257
remote:
remote: Create a pull request for 'tutorial/workspace-b' on GitHub by visiting:
remote:      https://github.com/rahuldave/agent-gest-jj-tutorial-workspaces/pull/new/tutorial/workspace-b
remote:

$ gh pr create --repo rahuldave/agent-gest-jj-tutorial-workspaces --base main --head tutorial/workspace-b --title 'test: workspace b flow' --body 'Tutorial jj workspace B flow.'
https://github.com/rahuldave/agent-gest-jj-tutorial-workspaces/pull/2

$ gh pr list --repo rahuldave/agent-gest-jj-tutorial-workspaces --state open --json title,baseRefName,headRefName
[{"baseRefName":"main","headRefName":"tutorial/workspace-b","title":"test: workspace b flow"},{"baseRefName":"main","headRefName":"tutorial/workspace-a","title":"test: workspace a flow"}]

$ jj workspace forget tutorial-workspace-a

$ jj workspace forget tutorial-workspace-b

## Cleanup

Deleted temporary repositories with `gh repo delete --yes`:

- `rahuldave/agent-gest-jj-tutorial-plain`
- `rahuldave/agent-gest-jj-tutorial-multi`
- `rahuldave/agent-gest-jj-tutorial-stack`
- `rahuldave/agent-gest-jj-tutorial-workspaces`
