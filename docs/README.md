# Documentation Map

Start with one document:

- `TUTORIAL.md`: deterministic, step-by-step GitHub tutorial for a new user.

Use the rest only when you need reference material:

- `g_commands_cheatsheet.md`: quick guide to the `g*` skills.
- `gest_jj_workflow.md`: advanced jj workflow playbook for agents.
- `gest_codex_workflow.md`: shared Gest/Codex workflow reference.
- `tag_dependency_workflow.md`: tag classification and ast-grep dependency checks.
- `just_command_contract.md`: stable Justfile command contract guidance,
  including optional dynamic `agent-*` context targets, `AGENT_TASK v1`
  handoff packets, and `AGENT_RESULT v1` subagent reports.
- `cx_incremental_pipelines.md`: `cx` guidance for incremental builds and
  file-artifact pipelines, including one pipeline example and one C build
  example.
- `gsu_typescript_hello_world.md`: tiny setup example.
- `gsu_language_profile_labs.md`: live local end-to-end setup labs for the
  Python, TypeScript, Go, and Rust setup/profile templates under jj. These are
  command contract profiles, not language reasoning skills.
- `live_jj_tutorial_transcript_2026-05-07.md`: historical live GitHub
  transcript for the four jj tutorial examples.

The beginner tutorial is the source of truth for the supported review shapes:

1. plain jj bookmark PR
2. multi-commit jj bookmark PR
3. jj-stack stacked PRs for dependent slices
4. parallel jj workspaces for independent slices

It also includes a deterministic tag classification and ast-grep dependency
check. Only step 3 uses jj-stack as the main PR submission tool. GitButler is
not part of the jj workflow.
