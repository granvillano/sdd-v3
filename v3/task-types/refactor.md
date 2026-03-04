# Task Type: refactor

> **Task Type ID:** `refactor`  
> **Inherits:** `core/definition-of-done.md`  
> **Version:** 3.0.0

## Definition

A `refactor` task restructures existing code **without changing observable behavior**.

## Rules

- Observable behavior MUST be identical before and after.
- All pre-existing tests MUST pass without modification.
- Performance changes (positive or negative) MUST be measured and documented.

## Additional DoD Criteria

- [ ] All existing tests pass unchanged after the refactor.
- [ ] ADR written if the refactor changes architectural patterns.
- [ ] Benchmarks run if performance-sensitive code was touched.
- [ ] No functional changes smuggled into the refactor PR.

## Branch Pattern
```
refactor/<TICKET-ID>-<description>
```

## Commit Prefix
```
refactor(<scope>): <description> [<TICKET-ID>]
```
