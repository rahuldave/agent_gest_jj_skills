#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-all}"

required_files=(
  "README.md"
  "AGENTS.template.md"
  "CLAUDE.md"
  "Justfile"
  "package.json"
  ".claude/settings.json"
  ".codex/hooks.json"
  "docs/gest_jj_workflow.md"
  "docs/jj_workflow_guide.md"
  "docs/g_commands_cheatsheet.md"
  "scripts/install.sh"
  "scripts/sync_g_skills.sh"
  "scripts/run_jj_workflow_lab.sh"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$repo_root/$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

for skill in gbs gcm gdo gfm gim gis gor gpa gpl gpr grv gsp gsu gte gtw; do
  if [ ! -f "$repo_root/.agents/skills/$skill/SKILL.md" ]; then
    echo "missing g skill: $skill" >&2
    exit 1
  fi
done

while IFS= read -r script; do
  bash -n "$script"
done < <(find "$repo_root/scripts" "$repo_root/.claude/hooks" "$repo_root/.codex/hooks" -type f -name '*.sh' | sort)

if command -v node >/dev/null 2>&1; then
  node -e '
    const fs = require("fs");
    for (const p of [".claude/settings.json", ".codex/hooks.json", "package.json"]) {
      JSON.parse(fs.readFileSync(p, "utf8"));
    }
  ' >/dev/null
fi

if [ "$mode" = "--diff" ]; then
  if command -v git >/dev/null 2>&1 && git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$repo_root" diff --check
  elif command -v jj >/dev/null 2>&1 && jj -R "$repo_root" root >/dev/null 2>&1; then
    jj -R "$repo_root" diff --git >/tmp/agent-gest-jj-diff.patch
    git apply --check /tmp/agent-gest-jj-diff.patch
  fi
fi

echo "repository checks passed"
