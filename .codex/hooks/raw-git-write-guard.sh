#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
command_text="$(printf '%s' "$input" | sed -n 's/.*"tool_input"[^{]*{[^}]*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p; s/.*"cmd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p; s/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

if printf '%s' "$command_text" | grep -Eq '(^|[;&|][[:space:]]*)git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(commit|add|restore|reset|checkout|switch|branch|worktree|merge|rebase|cherry-pick|revert|pull|push|clean|rm|mv|tag)([[:space:]]|$)'; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Raw git write command blocked in a jj repository. Use jj equivalents such as jj commit, jj bookmark, jj workspace, jj rebase, or jj git push."}}
JSON
fi
