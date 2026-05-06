# GSU Language Profile Labs For JJ

Use these labs as command-contract references when setting up Python, Node, Go,
or Rust projects under jj. The VCS initialization is always:

```bash
jj git init --colocate
jj commit -m "chore: initialize project"
jj bookmark create main -r @-
```

After setup, map the project-specific commands in `AGENTS.md`:

```text
Setup: just setup
Format: just fmt [path]
Lint: just lint [path]
Typecheck/static/build: project-specific just targets
Tests: just test [target]
Smoke: just smoke
Diff/VCS inspection: jj diff, jj status
```

The reusable language snippets in `templates/` are starting points. They should
be adapted to the target repo and verified with `gfm`, `gte`, and `gdo`.
