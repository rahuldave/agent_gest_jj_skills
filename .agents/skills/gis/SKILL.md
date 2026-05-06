---
name: gis
description: Gest Issue. Create or update durable Gest outline tasks with jj-native metadata, user story, context, acceptance criteria, and child-of links.
---

# GIS: Gest Issue

Use to create or update durable internal Gest tasks. These are Gest issues, not
necessarily GitHub issues.

## Issue Shape

```markdown
## User Story
As a <role>, I want <capability> so that <benefit>.

## Context
Why this matters and any constraints.

## Acceptance Criteria
- [ ] <measurable outcome>

## Out of Scope
- <non-goal>
```

## Create

Use tags and metadata deliberately. Before creating a task, run the tag
classification pass in `docs/tag_dependency_workflow.md`: collect existing
project tags from tasks, artifacts, and iterations; classify the new task
against them; select existing tags where possible; add new dynamic tags only
when no existing tag fits; and record near misses when useful.

```bash
gest task create "<title>" \
  -d "<issue body>" \
  -l child-of:<parent-id> \
  --tag outline \
  --tag issue \
  --tag jj \
  --metadata workflow.kind=development \
  --metadata depth=1 \
  --metadata vcs.tool=jj \
  --metadata classification.tags.reviewed=true \
  --quiet
```

Use `subissue` for lower-level children. Subissues should always have a parent.

For tasks that will write files, include jj review/execution metadata:

```bash
--metadata vcs.tool=jj \
--metadata vcs.review_mode=development-bookmark \
--metadata vcs.execution=main-workspace \
--metadata vcs.parallel_allowed=false
```

Use `vcs.execution=jj-workspaces` and a distinct `vcs.workspace_path` per task
when parallel agents will write concurrently. Do not model git worktrees or
GitButler lanes in a jj repository.

## Bookmark Metadata

When a task is reviewable, record the intended bookmark:

```bash
gest task meta set <id> vcs.bookmark gest/<short-id>-summary
```

For stacks, record:

```text
vcs.review_mode=stacked-development
vcs.stack_root=<root-bookmark>
vcs.stack_parent=<parent-bookmark>
vcs.stack_index=<n>
```

Remember that bookmarks do not advance automatically; `gcm` owns the
commit/bookmark/push checkpoint.

## Dependency-Aware Issue Expansion

When the issue changes code behavior, identify semantic dependers before
finalizing scope. Use `ast-grep` patterns from `docs/tag_dependency_workflow.md`
to search imports, calls, components, selectors, and exported contracts. If a
related surface should change too, add it to acceptance criteria or create a
child task tagged with the same semantic tag.
