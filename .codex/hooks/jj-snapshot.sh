#!/usr/bin/env bash
set -euo pipefail

if command -v jj >/dev/null 2>&1 && jj root >/dev/null 2>&1; then
  jj status --no-pager >/dev/null 2>&1 || true
fi

printf '{"continue":true}\n'
