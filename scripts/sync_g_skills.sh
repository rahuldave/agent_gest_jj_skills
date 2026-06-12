#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/sync_g_skills.sh [--dry-run] [--hooks] <target-repo>

Sync reusable g* skills from this repository into a target repository. Non-g
skills in the target are left alone. Skill-local references, scripts, and assets
travel inside each synced skill. Pass --hooks to also sync .claude and .codex
hook adapters.
USAGE
}

rsync_args=(-a --delete)
dry_run=0
sync_hooks=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      rsync_args+=(--dry-run)
      shift
      ;;
    --hooks)
      sync_hooks=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      usage >&2
      exit 64
      ;;
    *)
      break
      ;;
  esac
done

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 64
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_arg="$1"

if [ ! -d "$target_arg" ]; then
  echo "Target does not exist: $target_arg" >&2
  exit 66
fi
target="$(cd "$target_arg" && pwd)"

ensure_dir() {
  dir="$1"
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$dir"
  elif [ ! -d "$dir" ]; then
    echo "Would create $dir"
    return 1
  fi
}

ensure_dir "$target/.agents/skills" || true

for source_dir in "$repo_root"/.agents/skills/g*; do
  [ -d "$source_dir" ] || continue
  skill_name="$(basename "$source_dir")"
  if ensure_dir "$target/.agents/skills/$skill_name"; then
    rsync "${rsync_args[@]}" "$source_dir/" "$target/.agents/skills/$skill_name/"
  fi
done

if [ "$sync_hooks" -eq 1 ]; then
  ensure_dir "$target/.claude" || true
  ensure_dir "$target/.codex" || true
  if [ "$dry_run" -eq 0 ] || [ -d "$target/.claude" ]; then
    rsync "${rsync_args[@]}" "$repo_root/.claude/" "$target/.claude/"
  fi
  if [ "$dry_run" -eq 0 ] || [ -d "$target/.codex" ]; then
    rsync "${rsync_args[@]}" "$repo_root/.codex/" "$target/.codex/"
  fi
fi

echo "Synced reusable jj g* skills to $target/.agents/skills"
if [ "$sync_hooks" -eq 0 ]; then
  echo "Hook adapters were not synced; rerun with --hooks to refresh .claude/.codex."
fi
