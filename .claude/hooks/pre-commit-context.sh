#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
command_text="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

case "$command_text" in
  *"jj commit"*|*"jj describe"*|*"jst submit"*|*"jj git push"*)
    ;;
  *)
    exit 0
    ;;
esac

project_root="$(jj workspace root 2>/dev/null || git rev-parse --show-toplevel 2>/dev/null || pwd)"
doc="$project_root/docs/dev/commits.md"

if [ ! -f "$doc" ]; then
  exit 0
fi

context="$(cat "$doc")"
printf '{"hookSpecificOutput":{"additionalContext":"%s"}}' \
  "$(printf '%s' "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')"
