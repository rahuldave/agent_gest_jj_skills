# GSU TypeScript Hello World Lab For JJ

This disposable setup lab proves that `gsu` concepts work in a jj repository.

```bash
lab=/tmp/gsu-jj-typescript-hello
rm -rf "$lab"
mkdir -p "$lab/src"
cd "$lab"

jj git init --colocate
printf '# GSU JJ TypeScript Hello\n' > README.md
cat > src/index.ts <<'TS'
export function greet(name = "world"): string {
  return `Hello, ${name}!`;
}

console.log(greet());
TS
jj commit -m "chore: initialize jj TypeScript lab"
jj bookmark create main -r @-
```

Install this skill repo, add a `Justfile`, then map setup/lint/typecheck/build
commands in `AGENTS.md`. Use `jj diff` and `jj status` for VCS inspection.

This is a setup pattern reference, not the main jj workflow lab. For branch,
stack, and workspace behavior, run `scripts/run_jj_workflow_lab.sh`.
