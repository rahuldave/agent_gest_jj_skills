#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: scripts/sync_g_skills.sh /path/to/target/repo" >&2
  exit 64
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$1"

if [ ! -d "$target" ]; then
  echo "Target does not exist: $target" >&2
  exit 66
fi

mkdir -p "$target/.agents/skills" "$target/.claude" "$target/.codex"

find "$target/.agents/skills" -maxdepth 1 -type d -name 'g*' -mindepth 1 -exec rm -rf {} +
rsync -a "$repo_root/.agents/skills/" "$target/.agents/skills/"
rsync -a --delete "$repo_root/.claude/" "$target/.claude/"
rsync -a --delete "$repo_root/.codex/" "$target/.codex/"

echo "Synced g* skills and jj hook adapters into $target"
