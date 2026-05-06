#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lab="${AGENT_GEST_JJ_LAB:-/tmp/agent-gest-jj-workflow-lab}"
remote="${AGENT_GEST_JJ_LAB_REMOTE:-$lab-remote.git}"
workspace_a="$lab-workspace-a"
workspace_b="$lab-workspace-b"

rm -rf "$lab" "$remote" "$workspace_a" "$workspace_b"
mkdir -p "$lab"
git init --bare "$remote" >/dev/null
cd "$lab"

jj git init --colocate >/dev/null
jj git remote add origin "$remote" >/dev/null

printf '# JJ Workflow Lab\n' > README.md
mkdir -p src
cat > src/app.txt <<'TXT'
base
TXT
jj describe -m "chore: initialize jj workflow lab" >/dev/null
jj new >/dev/null
jj bookmark set main -r @- >/dev/null
jj git push --bookmark main >/dev/null

if ! jj bookmark list --all | grep -A2 '^main:' | grep -q '@origin'; then
  echo "expected main to have @origin tracking after initial bookmark push" >&2
  exit 1
fi

echo "Flow 1: plain jj bookmark review flow"
jj new main >/dev/null
printf 'plain bookmark change\n' > plain.txt
jj commit -m "test: add plain bookmark change" >/dev/null
jj bookmark set demo/plain-bookmark -r @- >/dev/null
jj git push --bookmark demo/plain-bookmark >/dev/null

if ! jj bookmark list --all | grep -A2 '^demo/plain-bookmark:' | grep -q '@origin'; then
  echo "expected demo/plain-bookmark to have @origin tracking after push" >&2
  exit 1
fi

echo "Flow 2: multi-commit session bookmark flow"
jj new main >/dev/null
printf 'session edit one\n' > session.txt
jj commit -m "test: add first session edit" >/dev/null
printf 'session edit two\n' >> session.txt
jj commit -m "test: add second session edit" >/dev/null
jj bookmark set demo/session-bookmark -r @- >/dev/null
jj git push --bookmark demo/session-bookmark >/dev/null

session_count="$(jj log -r 'main..bookmarks(exact:"demo/session-bookmark")' --no-graph --no-pager -T 'commit_id ++ "\n"' | wc -l | tr -d ' ')"
if [ "$session_count" -lt 2 ]; then
  echo "expected at least two commits in session bookmark flow" >&2
  exit 1
fi

echo "Flow 3: LazyJJ stack workflow and jj-stack preparation"
for alias_name in start create stack ss; do
  if ! jj "$alias_name" --help >/dev/null 2>&1 && [ "$alias_name" != "ss" ]; then
    echo "expected LazyJJ alias '$alias_name' to be available" >&2
    exit 1
  fi
done

jj start >/dev/null
printf 'stack base\n' > stack.txt
jj commit -m "test: add stack base" >/dev/null
jj create demo/stack-base >/dev/null
printf 'stack child\n' >> stack.txt
jj commit -m "test: add stack child" >/dev/null
jj create demo/stack-child >/dev/null
jj stack --no-pager >/dev/null
jj ss >/dev/null

if ! jj bookmark list --all | grep -A2 '^demo/stack-child:' | grep -q '@origin'; then
  echo "expected demo/stack-child to have @origin tracking after LazyJJ stack push" >&2
  exit 1
fi

if command -v tac >/dev/null 2>&1; then
  # This verifies the installed LazyJJ PR summary alias is at least callable.
  # It may print "no PR" for local/remoteless GitHub state, which is fine here.
  jj prs >/dev/null || echo "LazyJJ jj prs unavailable without GitHub PR context; continuing."
else
  echo "Skipped jj prs probe because tac is unavailable."
fi

if [ "${RUN_JJ_STACK_DRY_RUN:-0}" = "1" ]; then
  if [ -x "$repo_root/node_modules/.bin/jst" ]; then
    "$repo_root/node_modules/.bin/jst" submit demo/stack-child --dry-run
  elif command -v jst >/dev/null 2>&1; then
    jst submit demo/stack-child --dry-run
  else
    echo "RUN_JJ_STACK_DRY_RUN=1 but jst is unavailable" >&2
    exit 1
  fi
else
  echo "Skipped jst submit dry-run; set RUN_JJ_STACK_DRY_RUN=1 in a repo with GitHub remote/auth."
fi

echo "Flow 4: parallel jj workspaces"
jj workspace add "$workspace_a" --name demo-workspace-a -r main >/dev/null
jj workspace add "$workspace_b" --name demo-workspace-b -r main >/dev/null

(cd "$workspace_a" && printf 'workspace a isolated change\n' > workspace-a.txt && jj commit -m "test: add workspace a change" >/dev/null)
(cd "$workspace_b" && printf 'workspace b isolated change\n' > workspace-b.txt && jj commit -m "test: add workspace b change" >/dev/null)

jj log -r 'description("workspace a") | description("workspace b")' --no-pager >/dev/null
jj workspace forget demo-workspace-a >/dev/null
jj workspace forget demo-workspace-b >/dev/null
rm -rf "$workspace_a" "$workspace_b"

if jj workspace list --no-pager | grep -q 'demo-workspace-'; then
  echo "expected demo workspaces to be forgotten" >&2
  exit 1
fi

jj status --no-pager >/dev/null
echo "jj workflow lab passed: $lab"
