---
name: gsu
description: Gest Setup. Bootstrap or refresh a jj/Gest agent-operable repository surface: tools, command contract, Justfile targets, hooks, ignores, installs, and setup follow-ups.
---

# GSU: Gest Setup

Use when a jj/Gest repository needs first-time setup, command-contract
normalization, hook wiring, ignore rules, local tools, or installation of this
skill family.

`gsu` deals in project concepts. It should not bake one language, package
manager, or test runner into the reusable skills. It helps choose tools, record
those choices in `AGENTS.md`, and create/update an executable command
interface, preferably a `Justfile`.

## Core Concepts

Identify which concepts apply:

- environment bootstrap
- GitHub-backed jj initialization
- ignore rules
- dependency installation
- local tool installation
- run app or service
- format
- lint
- typecheck
- static or compile check
- build
- unit tests
- regression tests
- integration tests
- smoke checks
- browser/UI verification
- incremental build or artifact pipeline
- database/migration checks
- API docs
- user docs
- internal/developer docs
- release or CI checks

## JJ Initialization

For a new GitHub-backed jj repo, use the explicit sequence the user prefers:

```bash
git init
gh repo create --source=. --public
jj git init --colocate
```

After the first meaningful edit:

```bash
jj describe -m "chore: initialize project"
jj new
jj bookmark set main -r @-
jj git push --bookmark main
jj bookmark list --all
```

Do not assume `main` or `main@origin` exists before it is created and pushed.
Bookmarks are pointers, not active branches, and they do not advance
automatically.

Ask before creating public/private GitHub repos, installing tools, or running
commands that modify user-level state.

## Workflow

1. Inspect repository shape: jj/git state, `.gitignore`, `AGENTS.md`,
   `.agents/skills`, `.claude`, `.codex`, `Justfile`, `.envrc`, package
   manifests, lockfiles, CI configs, docs, tests, source directories, and app
   entrypoints.
2. Initialize git/GitHub/jj only after confirming the desired repo root.
3. Check required workflow tools: `jj`, `git`, `gest`, `just`, and `uv`.
   Missing tools should be reported clearly without blocking skill
   installation. Treat `rsync` as optional cleaner installer behavior.
   Check optional tools: `gh`, `jst`, LazyJJ aliases (`jj lazyjj`),
   `ast-grep`, `direnv`, `cx`, `node`, `npm`, and
   browser tools when the project needs them. Check `cx` only when the project
   has or wants explicit file-producing incremental build/pipeline stages.
4. Infer likely project profiles:
   - Python: `pyproject.toml`, `uv.lock`, FastAPI, Django, Flask, pytest, ruff,
     ty, pyright, mypy.
   - TypeScript/JavaScript: `package.json`, lockfiles, Vite, Next, ESLint,
     Biome, TypeScript, Vitest, Jest, Playwright.
   - Rust: `Cargo.toml`, Cargo workspaces, clippy, rustfmt, rustdoc.
   - Go: `go.mod`, `go.sum`, Go toolchain commands.
   - C/C++ or native build: `Makefile`, `CMakeLists.txt`,
     `compile_commands.json`, `src/*.c`, `src/*.cc`, `include/`, object files,
     custom compile/link recipes.
5. Ask the smallest necessary question when multiple plausible tools exist or
   the choice affects committed files.
6. Create/update ignore rules for generated files, local environments, caches,
   logs, build artifacts, project-local tools, and secrets.
7. Create/update `.env.example`, `.envrc`, and local PATH/cache setup when
   needed.
8. Install/sync dependencies through the chosen package manager when approved.
9. Define the command contract in `AGENTS.md`, including focused arguments.
10. Create/update `Justfile` targets when the project uses `just`.
11. Install or refresh `.agents/skills`, `.claude`, `.codex`, docs, templates,
    and graph tools from this repository when requested.
12. Run setup verification: tool discovery, `just --list`, cheap static checks,
    and representative focused command arguments.
13. Record remaining setup gaps as Gest follow-ups.

## Skill Repository Packaging

When the target repository is itself a skill repository, look for
`skill-package.json`, `skills/*/SKILL.md`, `.agents/skills/*/SKILL.md`, and
`scripts/install.sh`. If the `skill-package-installer` skill is installed or
available in the current source checkout, use it before declaring setup
complete.

Preferred checks:

```bash
uv run python .agents/skills/skill-package-installer/scripts/lint_skill_bundle.py .
uv run python .agents/skills/skill-package-installer/scripts/render_package_plan.py .
```

If the skill is not installed in the target repo but the standalone checkout is
available, use:

```bash
uv run python /Users/rahul/Projects/agent_skill_package_installer/skills/skill-package-installer/scripts/lint_skill_bundle.py .
```

Require skill repos to declare their installer and executable prerequisites in
`skill-package.json`. Installer scripts must report every required workflow
executable without blocking the skill copy and mention optional executables that
unlock extra flows. For this jj skill repo, required workflow executables are
`git`, `jj`, `gest`, `just`, and `uv`; optional executables include `rsync`,
`gh`, `jst`, `ast-grep`, `direnv`, `cx`, `node`, and `npm`. Runtime commands
should re-check tools they actually need.

When setup creates follow-up tasks, classify them against existing project tags
using `docs/tag_dependency_workflow.md`. If setup changes shared tooling,
hooks, generated code, or command contracts, use `ast-grep` or targeted
structured searches to find dependent scripts/docs before declaring setup done.

## Templates

This repository includes composable snippets under `templates/`. Use them as
starting points, not blind overwrites:

- `templates/gitignore/base.gitignore`
- `templates/gitignore/python-uv.gitignore`
- `templates/gitignore/typescript-npm.gitignore`
- `templates/gitignore/browser-agent.gitignore`
- `templates/env/envrc.local-bin`
- `templates/env/*.envrc`
- `templates/env/env.example`
- `templates/just/*.just`
- `templates/rust/rust-toolchain.toml`

Every setup should include base ignore concepts. Layer profile snippets only
when the project needs them.

## Command Contract

Prefer `just` targets when present. `AGENTS.md` should map concepts to commands
and argument forms. See `docs/just_command_contract.md`.

Common mapping:

```text
Setup: just setup
Format: just fmt [path]
Lint: just lint [path]
Typecheck: just typecheck
Static/compile: just static
Build: just build
Focused tests: just test [target]
Regression tests: just regression [target]
Integration tests: just integration [target]
Smoke checks: just smoke
Run app: just dev [port]
Browser spot check: just browser [url-or-flow]
Docs check: just docs
Diff hygiene: jj diff / git diff --check equivalent
```

For Just, parameters are positional:

```just
lint path=".":
  <lint-command> {{path}}

test target="tests":
  <test-command> {{target}}
```

Agents run:

```bash
just lint src/foo.ts
just test tests/foo.test.ts
```

Use native Just dependencies for aggregate recipes:

```just
verify: lint typecheck static test smoke diff-check
```

## Tool Installation Policy

Check before installing:

```bash
jj --version
jj lazyjj
git --version
gh --version
gest --version
just --version
uv --version
rsync --version
jst --help
direnv version
cx --help
```

Use project-local dependency state and version pins where possible:

- Python/uv: `.venv/`, `uv.lock`, optional `.local/uv-cache`.
- Node/npm: `node_modules/`, `package-lock.json`, optional
  `.local/npm-cache`.
- Go: `go.mod`, `go.sum`, absolute `.local/go-build` and `.local/go-mod`
  caches when needed.
- Rust: `rust-toolchain.toml` when a pinned toolchain is desired, `target/`
  ignored.

Do not silently rely on ambient global tools when the project contract says a
local toolchain is required.

## cx Incremental Build And Pipeline Setup

`cx` is for incremental builds and file-artifact pipelines in linewise Just
recipes. It is not a test runner. Use it only when a command reads explicit
files and writes durable output files.

Good setup candidates:

- ML/AI or data pipelines with intermediate artifacts, such as raw data to
  features to model to report.
- Generated artifact workflows where schemas, prompts, scripts, or configs
  produce generated files.
- Document, book, image, audio, or data conversion pipelines.
- Hand-written C/C++ compile/link recipes with object files and binaries as
  explicit outputs.

Do not add `cx` for tests, lint, format, typecheck, browser checks, ordinary
`cargo build`, `go build`, `tsc`, or commands without durable file outputs.
Those stay ordinary project command-contract targets.

When adding `cx`:

- keep Just recipe dependencies for recipe ordering;
- wrap only individual file-producing command lines with
  `cx --in ... --out ... -- COMMAND ...`;
- include scripts, schemas, prompts, config, and parameter files in `--in`
  when they affect outputs;
- add `cx lint` or `just cx-lint` to the static/check contract when useful;
- ignore `.cx/state.json`, `.cx/graph.json`, and `.cx/tmp/`, but leave
  `.cx/config.toml` committable unless the project decides otherwise;
- verify the pipeline/build by running once, running again to observe
  `up-to-date`, then changing one input and confirming the expected downstream
  artifacts rerun.

For reusable examples, read `docs/cx_incremental_pipelines.md` and run
`just cx-examples-lab` in this skill repository.

## Browser Setup

When a project has browser UI, ask whether browser-agent checks should be part
of the command contract. Keep two concepts separate:

- Browser spot checks: exploratory visual/interaction checks during
  implementation.
- Browser integration tests: durable rerunnable checks under the project's
  chosen integration test location.

## Ignore Rules

Common setup-owned ignores include:

- `.venv/`, `.local/`, `.ruff_cache/`, `.pytest_cache/`
- `node_modules/`, `dist/`, `coverage/`
- `target/`
- browser-agent local state and screenshots
- `.env`
- logs and temporary files

Do not ignore data, generated code, model artifacts, or lockfiles without
understanding the project policy.

## Deliverable

Report:

- detected project profile and chosen tools
- required/recommended executable status
- files created or updated
- command contract mappings
- verification commands and results
- open follow-ups
