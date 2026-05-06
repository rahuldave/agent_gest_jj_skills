#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  workspace_path="$(printf '%s' "$input" | jq -r '.path // .worktree_path // .workspace_path // empty')"
  workspace_name="$(printf '%s' "$input" | jq -r '.name // .worktree_name // empty')"
else
  workspace_path="$(printf '%s' "$input" | sed -n 's/.*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  workspace_name="$(printf '%s' "$input" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

if [ -z "${workspace_name:-}" ] && [ -n "${workspace_path:-}" ]; then
  workspace_name="$(basename "$workspace_path")"
fi

if [ -n "${workspace_path:-}" ] && [ -d "$workspace_path" ] && command -v gest >/dev/null 2>&1; then
  (cd "$workspace_path" && gest project detach) >&2 2>/dev/null || true
fi

if [ -n "${workspace_name:-}" ]; then
  jj workspace forget "$workspace_name" >&2 2>/dev/null || true
fi

if [ -n "${workspace_path:-}" ]; then
  rm -rf "$workspace_path"
fi
