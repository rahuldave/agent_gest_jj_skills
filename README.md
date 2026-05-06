# Agent Gest JJ Skills

Reusable agent skills, hooks, scripts, and documentation for Gest-tracked
projects that use Jujutsu (`jj`) for version control.

This repository is the jj counterpart to `agent_gest_git_skills`. It keeps the
Gest workflow concepts but changes the VCS contract:

- use jj bookmarks as review/PR units
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
- `scripts/sync_g_skills.sh`: sync g skills and hook adapters into a target repo.
- `scripts/check_repo.sh`: repository shape and hook syntax checks.
- `scripts/run_jj_workflow_lab.sh`: disposable four-situation jj workflow lab.
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
AGENTS.template.md -> AGENTS.md, only if AGENTS.md does not already exist
```

After installation:

1. Review `AGENTS.md` and replace placeholders.
2. Initialize the target repo with jj if needed:

   ```bash
   jj git init --colocate
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
- LazyJJ for personal local stack ergonomics

LazyJJ's stack aliases are useful for humans, but this repo does not depend on
LazyJJ's Claude aliases. Agent orchestration belongs in skills and hooks.

`jj-stack` is the preferred stacked PR backend because it leaves local jj
history management to jj and focuses on turning bookmarked stacks into GitHub
PRs. It is included as a development dependency for local verification.

## Verify This Repo

```bash
just setup
just verify
```

`just verify` checks repository shape, shell syntax, hook JSON, and the four
disposable jj workflow lab situations. The `jj-stack` PR submission part runs
as a documented dry-run command and is only executed when the lab has the
required GitHub-style remote/auth prerequisites.

## Publishing

This repo is expected to be a jj repo with a colocated git store so it can be
pushed to GitHub when ready:

```bash
jj git init --colocate
jj commit -m "chore: initialize jj gest agent skills"
jj bookmark create main -r @-
jj git remote add origin git@github.com:rahuldave/agent_gest_jj_skills.git
jj git push --bookmark main
```

Create/update pull requests with `jj-stack` or direct `gh` commands after a
bookmark is pushed. Do not merge without explicit approval.
