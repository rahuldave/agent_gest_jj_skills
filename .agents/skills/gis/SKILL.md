---
name: gis
description: Gest Issue. Create or update durable Gest issue tasks with jj-native metadata.
---

# GIS: Gest Issue

Use native Gest `child-of` links for hierarchy. Tags are filters, not hierarchy.

Issue body shape:

```markdown
## User Story
As a <role>, I want <capability> so that <benefit>.

## Context

## Acceptance Criteria
- [ ] <measurable outcome>

## Out of Scope
```

For jj writable work, include:

```bash
--metadata vcs.tool=jj \
--metadata vcs.review_mode=development-bookmark \
--metadata vcs.execution=main-workspace \
--metadata vcs.parallel_allowed=false
```

Use `vcs.execution=jj-workspaces` only when each parallel writable task has a
distinct `vcs.workspace_path`.
