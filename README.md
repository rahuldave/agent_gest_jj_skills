# Agent Gest JJ Skills

Reusable agent skills, hooks, scripts, and documentation for Gest-tracked
projects that use Jujutsu (`jj`) for version control.

This repository is the jj counterpart to `agent_gest_git_skills`. It keeps the
Gest workflow concepts but changes the VCS contract:

- use jj bookmarks as review/PR units
- use LazyJJ aliases for GitButler-like local stack ergonomics inside jj
- use `jj-stack` as the preferred stacked PR backend
- use jj workspaces as the parallel write primitive
- avoid raw git write commands in colocated jj/git repositories
- use Claude hooks to translate Claude worktree isolation into jj workspaces
- use Codex skills/scripts to own jj workspace orchestration

## What Is Included

- `.agents/skills/g*`: reusable Gest agent skills adapted for jj workflows.
- `.claude/`: Claude Code settings, skill links, and jj hook adapters.
- `.codex/`: Codex hook config and guardrail scripts.
- `AGENTS.template.md`: starter agent instructions for target repositories.
- `docs/gest_jj_workflow.md`: the full jj/Gest/Codex/Claude workflow playbook.
- `docs/jj_workflow_guide.md`: user-facing guide and four disposable jj labs.
- `docs/g_commands_cheatsheet.md`: quick guide to `gtw` and the stage skills.
- `docs/just_command_contract.md`: reusable Justfile command-contract guidance.
- `scripts/install.sh`: copy-based installer for target repos.
- `scripts/sync_g_skills.sh`: sync g skills, docs, templates, and optionally
  hook adapters into a target repo.
- `scripts/check_repo.sh`: repository shape and hook syntax checks.
- `scripts/run_jj_workflow_lab.sh`: disposable four-situation jj workflow lab.
- `scripts/run_jj_github_integration_lab.sh`: live GitHub integration lab that
  runs the four examples in four separate temporary repos, captures a jj
  tutorial trace, and deletes the repos with `gh repo delete --yes`.
- `tools/gest_mermaid_graph.py`: optional Gest graph exporter.
- `templates/`: reusable setup snippets for language/profile setup.

## Install Into A Repo

From this repository:

```bash
scripts/install.sh /path/to/target/repo
```

The installer copies:

```text
.agents/skills/g*
.claude/
.codex/
docs/*.md
tools/gest_mermaid_graph.py
templates/
AGENTS.template.md -> AGENTS.md, only if AGENTS.md does not already exist
```

After installation:

1. Review `AGENTS.md` and replace placeholders.
2. Initialize the target repo with jj if needed. For a new GitHub-backed repo:

   ```bash
   git init
   gh repo create --source=. --public
   jj git init --colocate
   ```

   After the first meaningful change, create and push `main` explicitly:

   ```bash
   jj describe -m "chore: initialize project"
   jj new
   jj bookmark set main -r @-
   jj git push --bookmark main
   ```

3. Enable Codex hooks in the trusted project or user config:

   ```toml
   [features]
   codex_hooks = true
   ```

4. Review `.claude/settings.json` before trusting Claude hooks in the target
   repo.

## Tooling Defaults

Required:

- `jj`
- `gest`
- `just`

Recommended:

- `gh` for GitHub issue/PR checks
- `jj-stack` for stacked PR creation from jj bookmarks
- LazyJJ aliases for personal local stack ergonomics

LazyJJ stack aliases (`jj start`, `jj create`, `jj tug`, `jj stack`, `jj ss`,
`jj prs`, `jj sprs`, `jj uprs`) replace the GitButler local stack workflow.
This repo does not depend on LazyJJ's Claude aliases. Agent orchestration
belongs in skills and hooks.

`jj-stack` is the preferred stacked PR backend because it leaves local jj
history management to jj and focuses on turning bookmarked stacks into GitHub
PRs. It is included as a development dependency for local verification.

## Verify This Repo

```bash
just setup
just verify
```

`just verify` checks repository shape, shell syntax, hook JSON, hook guardrail
behavior, and the four disposable jj workflow lab situations. The lab uses a
local bare remote by default to prove bookmark push mechanics without creating
a GitHub repo. Live `jj-stack` PR submission remains gated by GitHub remote/auth
prerequisites.

For a real GitHub integration pass, run:

```bash
gh auth status -h github.com
gh auth refresh -h github.com -s delete_repo # if delete_repo is missing
just integration-live
```

The live lab preflights authenticated `gh`, requires the `delete_repo` scope,
creates four private temporary GitHub repositories, runs one parity example per
repo, captures command logs plus a markdown jj tutorial trace under `/tmp`, and
then destroys the repositories with `gh repo delete --yes`. Use
`AGENT_GEST_JJ_KEEP_GITHUB_REPOS=1` only when debugging a failed run.

## Publishing

This repo is expected to be a jj repo with a colocated git store so it can be
pushed to GitHub when ready:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
jj describe -m "chore: initialize jj gest agent skills"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
```

Create/update pull requests with `jj-stack` or direct `gh` commands after a
bookmark is pushed. Do not merge without explicit approval.
