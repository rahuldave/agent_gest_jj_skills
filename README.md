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

Shared Gest concepts now stay orthogonal to the jj adapter: session versus
development mode, test strategy (`test-first`, `characterization-first`,
`test-after`, `exploratory`, or `no-test-needed`), review depth, language
profile context, and optional dynamic `just agent-*` targets are chosen
separately from jj bookmark/workspace mechanics.

## What Is Included

- `.agents/skills/g*`: reusable Gest agent skills adapted for jj workflows.
- `.agents/skills/gest_jj_installer`: package-specific installer skill for
  hooks, docs, templates, tools, and AGENTS guidance after `npx skills add`.
- `.claude/`: Claude Code settings, skill links, and jj hook adapters.
- `.codex/`: Codex hook config and guardrail scripts.
- `AGENTS.template.md`: starter agent instructions for target repositories.
- `docs/README.md`: documentation map.
- `docs/TUTORIAL.md`: the deterministic beginner tutorial. Start here.
- `docs/*.md`: reference docs and setup examples for users who need details.
- `scripts/install.sh`: source-checkout installer for target repos.
- `skill-package.json`: package manifest used by `skill-package-maker` to
  validate skills, installer scripts, and executable prerequisites.
- `scripts/sync_g_skills.sh`: sync g skills, docs, templates, and optionally
  hook adapters into a target repo.
- `scripts/check_repo.sh`: repository shape and hook syntax checks.
- `scripts/run_jj_workflow_lab.sh`: disposable four-situation jj workflow lab.
- `scripts/run_jj_github_integration_lab.sh`: live GitHub integration lab that
  runs the four examples in four separate temporary repos, captures a jj
  tutorial trace, and deletes the repos with `gh repo delete --yes`.
- `scripts/run_tag_dependency_agent_dry_run.sh`: local agent dry run for tag
  classification plus `ast-grep` dependency expansion.
- `scripts/run_tag_dependency_typescript_lab.sh`: live local TypeScript lab for
  Gest tag-based dependency expansion plus `ast-grep` call-site expansion under
  a colocated jj/git repo.
- `scripts/run_language_profile_labs.sh`: live local end-to-end setup labs for
  the Python/UV, TypeScript/NPM, Go, and Rust/Cargo profiles under jj.
- `scripts/run_cx_examples_lab.sh`: live local examples for `cx` incremental
  builds and file-artifact pipelines.
- `scripts/run_agentic_target_lab.sh`: local lab for generic `AGENT_TASK v1`
  agentic Just targets, subagent handoff classification, recursive delegation,
  malformed-packet failures, and concrete target non-detection.
- `scripts/validate_agent_task.sh`: small validator for `AGENT_TASK v1` packets
  emitted by agentic Just targets.
- `tools/gest_mermaid_graph.py`: optional Gest graph exporter.
- `templates/`: reusable setup snippets for language/profile setup.

## Install Into A Repo

For a fresh machine or a fresh project, use three steps from inside the target
repository.

First, install the skills:

```bash
npx skills add rahuldave/agent_gest_jj_skills -a codex --skill '*' -y
```

Second, ask the agent to use `gest_jj_installer` to install the jj Gest hooks,
docs, templates, tools, and AGENTS guidance in the current repo. `npx skills
add` installs skill folders only; it does not run hooks or copy root-level
package extras. `gest_jj_installer` carries a bundled helper that fetches this
repository and runs the source-checkout installer with clear prerequisite
messages and overwrite approval.

Third, use `gsu` for normal repository setup and command-contract refresh work.

Source checkout alternative:

From this repository:

```bash
scripts/install.sh /path/to/target/repo
```

The installer reports missing workflow executables and still copies the skill
bundle: `git`, `jj`, `gest`, `just`, and `uv`. It also reports optional
executables that unlock additional workflows or cleaner installs: `rsync`,
`gh`, `jst`, `ast-grep`, `direnv`, `cx`, `node`, and `npm`. If `rsync` is
missing, the installer uses a `cp` fallback.

The installer copies:

```text
.agents/skills/g* and .agents/skills/gest_jj_installer
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

- `git`
- `jj`
- `gest`
- `just`
- `uv`

Recommended:

- `rsync` for cleaner installer sync behavior
- `gh` for GitHub issue/PR checks
- `jj-stack` for stacked PR creation from jj bookmarks
- LazyJJ aliases for personal local stack ergonomics
- `ast-grep` for dependency-impact checks when code-facing tasks change shared
  contracts

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
behavior, the four disposable jj workflow lab situations, the tag/dependency
agent dry run, the live TypeScript tag/ast-grep lab, the four language profile
labs, jj-stack installation, and diff hygiene. The workflow lab uses a local
bare remote by default to prove bookmark push mechanics without creating a
GitHub repo. Live `jj-stack` PR submission remains gated by GitHub remote/auth
prerequisites.

`just cx-examples-lab` runs two `cx` examples: one staged artifact pipeline and
one explicit C incremental build. Use `cx` only for file-producing build or
pipeline stages inside linewise Just recipes, not for tests or ordinary
package-manager builds.

Projects may expose agentic Just targets that emit `AGENT_TASK v1` packets.
Those packets are subagent handoffs: validate the block, then delegate the work
to a subagent. Apply the same rule recursively to nested agentic Just calls,
agentic dependencies, hook-triggered packets, and agentic verification targets.
The reusable `just agentic-target-lab` proves that contract.

When `gsu` is working on a skill repository and `skill-package-maker` is
installed, it should run that skill's uv/Python linter against
`skill-package.json` and installer-skill prerequisite checks before handoff. In
an `npx skills` package, hooks and templates should be installed by the
package's explicit installer skill after `npx skills add`, not as a hidden
install side effect.

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

For a deterministic walkthrough of the same four flows, read
`docs/TUTORIAL.md`. It is the only beginner tutorial. It uses jj bookmarks for
simple PRs, `jj-stack` for stacked dependent PRs, and jj workspaces for
independent parallel slices. GitButler is not part of the jj tutorial.

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
bookmark is pushed. For reviewable non-local work, create/move and push the
bookmark instead of stopping in a local-only state. Do not merge without
explicit approval. After merging, run any deploy/release command defined by the
target repository's instructions, or report the exact blocker.
