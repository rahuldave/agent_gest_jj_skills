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
  "docs/gest_codex_workflow.md"
  "docs/jj_workflow_guide.md"
  "docs/g_commands_cheatsheet.md"
  "docs/just_command_contract.md"
  "scripts/install.sh"
  "scripts/sync_g_skills.sh"
  "scripts/run_jj_workflow_lab.sh"
  "templates/README.md"
  "tools/gest_mermaid_graph.py"
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

required_text=(
  "jj bookmark set main -r @-"
  "jj git push --bookmark"
  "jj start"
  "jj create"
  "jst submit"
  "jj workspace add"
)

for needle in "${required_text[@]}"; do
  if ! grep -R "$needle" "$repo_root/AGENTS.template.md" "$repo_root/docs" "$repo_root/.agents/skills" >/dev/null; then
    echo "missing required jj workflow text: $needle" >&2
    exit 1
  fi
done

claude_deny="$(printf '{"command":"git commit -m nope"}' | "$repo_root/.claude/hooks/raw-git-write-guard.sh" || true)"
if ! printf '%s' "$claude_deny" | grep -q 'permissionDecision'; then
  echo "Claude raw git guard did not deny git commit" >&2
  exit 1
fi

claude_allow="$(printf '{"command":"jj git push --bookmark demo"}' | "$repo_root/.claude/hooks/raw-git-write-guard.sh" || true)"
if [ -n "$claude_allow" ]; then
  echo "Claude raw git guard denied jj git push" >&2
  exit 1
fi

codex_deny="$(printf '{"tool_input":{"command":"git commit -m nope"}}' | "$repo_root/.codex/hooks/raw-git-write-guard.sh" || true)"
if ! printf '%s' "$codex_deny" | grep -q 'permissionDecision'; then
  echo "Codex raw git guard did not deny git commit" >&2
  exit 1
fi

codex_allow="$(printf '{"tool_input":{"command":"jj git push --bookmark demo"}}' | "$repo_root/.codex/hooks/raw-git-write-guard.sh" || true)"
if [ -n "$codex_allow" ]; then
  echo "Codex raw git guard denied jj git push" >&2
  exit 1
fi

hook_workspace_root="${TMPDIR:-/tmp}/agent-gest-jj-hook-workspaces"
rm -rf "$hook_workspace_root"
if ! printf '{"name":"check-repo-workspace","revision":"@"}' | AGENT_GEST_JJ_WORKSPACE_ROOT="$hook_workspace_root" "$repo_root/.claude/hooks/jj-workspace-create.sh" >/tmp/agent-gest-jj-workspace-path 2>/dev/null; then
  echo "Claude jj workspace create hook failed" >&2
  exit 1
fi
created_workspace="$(cat /tmp/agent-gest-jj-workspace-path)"
if [ -n "$created_workspace" ] && [ -d "$created_workspace" ]; then
  printf '{"name":"check-repo-workspace","path":"%s"}' "$created_workspace" | "$repo_root/.claude/hooks/jj-workspace-remove.sh" >/dev/null 2>&1 || true
fi
rm -rf "$hook_workspace_root"

if [ "$mode" = "--diff" ]; then
  if command -v git >/dev/null 2>&1 && git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$repo_root" diff --check
  elif command -v jj >/dev/null 2>&1 && jj -R "$repo_root" root >/dev/null 2>&1; then
    jj -R "$repo_root" diff --git >/tmp/agent-gest-jj-diff.patch
    git apply --check /tmp/agent-gest-jj-diff.patch
  fi
fi

echo "repository checks passed"
