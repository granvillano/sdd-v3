# Task Type: docs-only

> **Task Type ID:** `docs-only`  
> **Inherits:** `core/definition-of-done.md`, `core/docs-baseline.md`  
> **Version:** 3.0.0

## Definition

A `docs-only` task makes changes exclusively to documentation files. No source code is modified.

## Rules

- If the PR contains any source code change, it is NOT a `docs-only` task — reassign type.

## Additional DoD Criteria

- [ ] All internal links verified (no broken references).
- [ ] Technical accuracy reviewed by the relevant domain expert.
- [ ] Diagrams updated if architecture or flows changed.
- [ ] Spelling and grammar checked.

## Branch Pattern
```
docs/<TICKET-ID>-<description>
```

## Commit Prefix
```
docs(<scope>): <description> [<TICKET-ID>]
```
