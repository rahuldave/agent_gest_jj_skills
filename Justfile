export npm_config_cache := ".local/npm-cache"

setup:
  npm install

lint:
  scripts/check_repo.sh

static: lint

test:
  scripts/run_jj_workflow_lab.sh
  scripts/run_tag_dependency_typescript_lab.sh
  scripts/run_language_profile_labs.sh
  scripts/run_cx_examples_lab.sh
  scripts/run_agentic_target_lab.sh
  scripts/run_agent_result_lab.sh

workflow-lab:
  scripts/run_jj_workflow_lab.sh

tag-dependency-dry-run:
  scripts/run_tag_dependency_agent_dry_run.sh

tag-dependency-live-lab:
  scripts/run_tag_dependency_typescript_lab.sh

language-profile-labs:
  scripts/run_language_profile_labs.sh

cx-examples-lab:
  scripts/run_cx_examples_lab.sh

agentic-target-lab:
  scripts/run_agentic_target_lab.sh

agent-result-lab:
  scripts/run_agent_result_lab.sh

integration-live:
  scripts/run_jj_github_integration_lab.sh

jj-stack:
  test -x node_modules/.bin/jst

diff-check:
  scripts/check_repo.sh --diff

verify: lint test tag-dependency-dry-run jj-stack diff-check
