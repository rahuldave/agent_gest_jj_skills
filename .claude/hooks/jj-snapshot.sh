#!/usr/bin/env bash
set -euo pipefail

project_root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$project_root"

if command -v jj >/dev/null 2>&1 && jj root >/dev/null 2>&1; then
  jj status --no-pager >/dev/null 2>&1 || true
fi
