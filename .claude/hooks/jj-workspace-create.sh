#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  requested_name="$(printf '%s' "$input" | jq -r '.name // .worktree_name // .id // "agent-workspace"')"
  revision="$(printf '%s' "$input" | jq -r '.revision // "@"')"
else
  requested_name="$(printf '%s' "$input" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  revision="@"
fi

workspace_name="$(printf '%s' "${requested_name:-agent-workspace}" | tr -c 'A-Za-z0-9._-' '-')"
source_root="$(jj workspace root)"
source_name="$(basename "$source_root")"
base_dir="${AGENT_GEST_JJ_WORKSPACE_ROOT:-$(dirname "$source_root")/${source_name}-workspaces}"
workspace_path="$base_dir/$workspace_name"

mkdir -p "$base_dir"

if [ ! -d "$workspace_path" ]; then
  jj workspace add "$workspace_path" --name "$workspace_name" -r "$revision" >&2
fi

if command -v gest >/dev/null 2>&1; then
  project_id="$(gest project --json 2>/dev/null | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1 || true)"
  if [ -n "$project_id" ]; then
    (cd "$workspace_path" && gest project attach "$project_id") >&2 2>/dev/null || true
  fi
fi

printf '%s' "$workspace_path"
