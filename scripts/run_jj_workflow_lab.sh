#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lab="${AGENT_GEST_JJ_LAB:-/tmp/agent-gest-jj-workflow-lab}"
workspace_a="$lab-workspace-a"
workspace_b="$lab-workspace-b"

rm -rf "$lab" "$workspace_a" "$workspace_b"
mkdir -p "$lab"
cd "$lab"

jj git init --colocate >/dev/null

printf '# JJ Workflow Lab\n' > README.md
mkdir -p src
cat > src/app.txt <<'TXT'
base
TXT
jj commit -m "chore: initialize jj workflow lab" >/dev/null
jj bookmark create main -r @- >/dev/null

echo "Flow 1: plain jj bookmark review flow"
jj new main >/dev/null
printf 'plain bookmark change\n' > plain.txt
jj commit -m "test: add plain bookmark change" >/dev/null
jj bookmark create demo/plain-bookmark -r @- >/dev/null
jj log -r 'bookmarks(exact:"demo/plain-bookmark")' --no-pager >/dev/null

echo "Flow 2: multi-commit session bookmark flow"
jj new main >/dev/null
printf 'session edit one\n' > session.txt
jj commit -m "test: add first session edit" >/dev/null
printf 'session edit two\n' >> session.txt
jj commit -m "test: add second session edit" >/dev/null
jj bookmark create demo/session-bookmark -r @- >/dev/null
session_count="$(jj log -r 'main..bookmarks(exact:"demo/session-bookmark")' --no-graph --no-pager -T 'commit_id ++ "\n"' | wc -l | tr -d ' ')"
if [ "$session_count" -lt 2 ]; then
  echo "expected at least two commits in session bookmark flow" >&2
  exit 1
fi

echo "Flow 3: stacked bookmarks and jj-stack preparation"
jj new main >/dev/null
printf 'stack base\n' > stack.txt
jj commit -m "test: add stack base" >/dev/null
jj bookmark create demo/stack-base -r @- >/dev/null
printf 'stack child\n' >> stack.txt
jj commit -m "test: add stack child" >/dev/null
jj bookmark create demo/stack-child -r @- >/dev/null
jj log -r 'main..bookmarks(exact:"demo/stack-child")' --no-pager >/dev/null

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
jj new main >/dev/null
jj workspace add "$workspace_a" --name demo-workspace-a -r @ >/dev/null
jj workspace add "$workspace_b" --name demo-workspace-b -r @ >/dev/null

(cd "$workspace_a" && printf 'workspace a isolated change\n' > workspace-a.txt && jj commit -m "test: add workspace a change" >/dev/null)
(cd "$workspace_b" && printf 'workspace b isolated change\n' > workspace-b.txt && jj commit -m "test: add workspace b change" >/dev/null)

jj log -r 'description("workspace a") | description("workspace b")' --no-pager >/dev/null
jj workspace forget demo-workspace-a >/dev/null
jj workspace forget demo-workspace-b >/dev/null
rm -rf "$workspace_a" "$workspace_b"

jj workspace list --no-pager | grep -v 'demo-workspace-' >/dev/null
jj status --no-pager >/dev/null

echo "jj workflow lab passed: $lab"
