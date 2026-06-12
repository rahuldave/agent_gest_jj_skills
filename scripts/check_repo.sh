#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-all}"

required_files=(
  "README.md"
  "AGENTS.template.md"
  "CLAUDE.md"
  "Justfile"
  "skill-package.json"
  "package.json"
  ".claude/settings.json"
  ".codex/hooks.json"
  "docs/README.md"
  "docs/TUTORIAL.md"
  "docs/live_jj_tutorial_transcript_2026-05-07.md"
  "docs/gest_jj_workflow.md"
  "docs/gest_codex_workflow.md"
  "docs/tag_dependency_workflow.md"
  "docs/g_commands_cheatsheet.md"
  "docs/just_command_contract.md"
  "scripts/install.sh"
  "scripts/sync_g_skills.sh"
  "scripts/run_jj_workflow_lab.sh"
  "scripts/run_jj_github_integration_lab.sh"
  "scripts/run_tag_dependency_agent_dry_run.sh"
  "scripts/run_tag_dependency_typescript_lab.sh"
  "scripts/run_language_profile_labs.sh"
  "scripts/run_cx_examples_lab.sh"
  ".agents/skills/gest_jj_installer/SKILL.md"
  ".agents/skills/gest_jj_installer/scripts/install_gest_jj_package.sh"
  "templates/README.md"
  "tools/gest_mermaid_graph.py"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$repo_root/$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

for skill in gbs gcm gdo gfm gest_jj_installer gim gis gor gpa gpl gpr grv gsp gsu gte gtw; do
  if [ ! -f "$repo_root/.agents/skills/$skill/SKILL.md" ]; then
    echo "missing g skill: $skill" >&2
    exit 1
  fi
done

while IFS= read -r script; do
  bash -n "$script"
done < <(find "$repo_root/scripts" "$repo_root/.agents/skills" "$repo_root/.claude/hooks" "$repo_root/.codex/hooks" -type f -name '*.sh' | sort)

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
  "Only step 3 uses jj-stack"
  "plain jj bookmark PR"
  "multi-commit jj bookmark PR"
  "jj-stack stacked PRs"
  "parallel jj workspaces"
  "Tags And ast-grep Dependency Check"
  "Pull Request Command Map"
  "Successfully submitted stack"
  "gh repo delete --yes"
  "Accept And Merge The Tutorial PRs"
  "PR acceptance checkpoint"
  "gh pr diff <number> --patch"
  "gh pr checks <number>"
  "gh pr merge <number> --merge --delete-branch"
  "state MERGED"
  "existing-tags.txt"
  "new dynamic tags: none"
  "vocabulary source"
  "After the agent finishes, check:"
  "classification.tags.reviewed"
  "impact.ast_grep.required"
  "count-or-probability-coloring"
  "probability-pill-colors"
  "tag-dependency-dry-run"
  "tag-dependency-live-lab"
  "ast-grep run"
  "Live TypeScript Tag And ast-grep Dependency Lab"
  "tag dependency expansion"
  "ast-grep dependency expansion"
  "run_tag_dependency_typescript_lab.sh"
  "jj workspace add"
  "run_language_profile_labs.sh"
  "language-profile-labs"
  "live local end-to-end"
  "cx Incremental Builds"
  "cx-examples-lab"
  "skill-package-maker"
  "skill-package.json"
  "uv --version"
  "rsync --version"
  "command -v uv"
  "command -v rsync"
  "run_cx_examples_lab.sh"
  "Artifact Pipeline"
  "Incremental C Build"
  "Python With UV"
  "TypeScript With NPM"
  "Rust With Cargo"
)

for needle in "${required_text[@]}"; do
  if ! grep -R "$needle" "$repo_root/AGENTS.template.md" "$repo_root/README.md" "$repo_root/docs" "$repo_root/.agents/skills" "$repo_root/scripts" >/dev/null; then
    echo "missing required jj workflow text: $needle" >&2
    exit 1
  fi
done

for stale_tutorial_text in "Latest Live Run" "live_jj_tutorial_transcript"; do
  if grep -q "$stale_tutorial_text" "$repo_root/docs/TUTORIAL.md"; then
    echo "stale run-specific text remains in docs/TUTORIAL.md: $stale_tutorial_text" >&2
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
