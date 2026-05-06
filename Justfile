export npm_config_cache := ".local/npm-cache"

setup:
  npm install

lint:
  scripts/check_repo.sh

static: lint

test:
  scripts/run_jj_workflow_lab.sh

tag-dependency-dry-run:
  scripts/run_tag_dependency_agent_dry_run.sh

integration-live:
  scripts/run_jj_github_integration_lab.sh

jj-stack:
  test -x node_modules/.bin/jst

diff-check:
  scripts/check_repo.sh --diff

verify: lint test tag-dependency-dry-run jj-stack diff-check
