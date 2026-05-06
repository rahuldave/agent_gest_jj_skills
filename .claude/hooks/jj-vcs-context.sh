#!/usr/bin/env bash
set -euo pipefail

read -r -d '' CONTEXT <<'CONTEXT_EOF' || true
## JJ VCS Context

This repository uses Jujutsu (`jj`) with a colocated git store. Use `jj` for
VCS writes. Do not use raw git write commands. In this repo:

- a branch-like review unit is a jj bookmark
- parallel agent isolation uses `jj workspace`
- Claude worktree isolation is mapped by hooks to jj workspace lifecycle
- LazyJJ is optional human ergonomics, not the reusable agent orchestration layer
- `jj-stack` is the preferred stacked PR backend
CONTEXT_EOF

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' \
  "$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')"
