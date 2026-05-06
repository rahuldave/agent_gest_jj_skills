# Just Command Contract

Use a `Justfile` as the stable command interface for agents. Targets should map
workflow concepts, not one agent's favorite tool invocation.

Common shape:

```just
setup:
  <install or sync dependencies>

fmt path=".":
  <format command> {{path}}

lint path=".":
  <lint command> {{path}}

typecheck:
  <typecheck command>

static:
  <compile/static check>

test target="tests":
  <test command> {{target}}

smoke:
  <smoke command>

diff-check:
  jj diff --git >/tmp/project.patch
  git apply --check /tmp/project.patch

verify: lint typecheck static test smoke diff-check
```

For this reusable repo:

```bash
just setup
just lint
just test
just jj-stack
just diff-check
just verify
```

Just is a command runner, not a file-freshness build system. Prefer native
dependencies such as `verify: lint test diff-check` over recursively invoking
`just` inside a recipe.
