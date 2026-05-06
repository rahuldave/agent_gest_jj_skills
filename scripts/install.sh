#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: scripts/install.sh /path/to/target/repo

Install the jj Gest agent skills, hooks, docs, templates, and graph tool into a
target repository. Existing AGENTS.md is preserved.
USAGE
}

if [ "$#" -ne 1 ]; then
  usage
  exit 64
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$1"

if [ ! -d "$target" ]; then
  echo "Target does not exist: $target" >&2
  exit 66
fi

mkdir -p "$target/.agents/skills" "$target/docs" "$target/tools" "$target/templates"

rsync -a --delete "$repo_root/.agents/skills/" "$target/.agents/skills/"
rsync -a --delete "$repo_root/.claude/" "$target/.claude/"
rsync -a --delete "$repo_root/.codex/" "$target/.codex/"
rsync -a "$repo_root/docs/" "$target/docs/"
rsync -a --delete "$repo_root/templates/" "$target/templates/"
rsync -a "$repo_root/tools/gest_mermaid_graph.py" "$target/tools/gest_mermaid_graph.py"
chmod +x "$target/tools/gest_mermaid_graph.py"

if [ ! -f "$target/AGENTS.md" ]; then
  cp "$repo_root/AGENTS.template.md" "$target/AGENTS.md"
else
  echo "Kept existing AGENTS.md; merge AGENTS.template.md manually if needed." >&2
fi

echo "Installed jj Gest agent skills into $target"
echo "Review AGENTS.md, .claude/settings.json, and .codex/hooks.json before use."
