#!/usr/bin/env bash
set -euo pipefail

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This repository is jj-native. Use jj for VCS writes, use bookmarks as review units, use jj workspaces for parallel write isolation, and do not use raw git write commands. Codex jj workspace orchestration is owned by the g* skills, especially gtw/gor/gim/gcm."}}
JSON
