#!/usr/bin/env bash
set -euo pipefail

read -r -d '' CONTEXT <<'CONTEXT_EOF' || true
## Gest Workflow Reminder

Use the project-local `g*` skills for substantial work:

- `gtw`: route project work into Gest
- `gsp`: create/update specs
- `gpl`: plan tasks and iterations
- `gis`: create durable tasks
- `gim`: implement one concrete task
- `gor`: execute phased work, using jj workspaces when useful
- `gfm`: format/lint/static checks
- `gte`: tests and smoke/integration checks
- `gdo`: docs audit
- `grv`: review current changes
- `gcm`: jj commit/bookmark/push checkpoint
- `gpr`: GitHub issue promotion decision
- `gpa`: GitHub PR acceptance review

Keep Gest commands serialized. Use task notes with Done and Verification before
completing non-trivial leaves.
CONTEXT_EOF

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' \
  "$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')"
