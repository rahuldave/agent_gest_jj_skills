# Documentation Map

Start with one document:

- `TUTORIAL.md`: deterministic, step-by-step GitHub tutorial for a new user.

Use the rest only when you need reference material:

- `g_commands_cheatsheet.md`: quick guide to the `g*` skills.
- `gest_jj_workflow.md`: advanced jj workflow playbook for agents.
- `gest_codex_workflow.md`: shared Gest/Codex workflow reference.
- `tag_dependency_workflow.md`: tag classification and ast-grep dependency checks.
- `just_command_contract.md`: stable Justfile command contract guidance.
- `gsu_typescript_hello_world.md`: tiny setup example.
- `gsu_language_profile_labs.md`: setup examples for Python, TypeScript, Go, and Rust.

The beginner tutorial is the source of truth for the supported review shapes:

1. plain jj bookmark PR
2. multi-commit jj bookmark PR
3. jj-stack stacked PRs for dependent slices
4. parallel jj workspaces for independent slices

It also includes a deterministic tag classification and ast-grep dependency
check. Only step 3 uses jj-stack as the main PR submission tool. GitButler is
not part of the jj workflow.
