# Task Type: feature

> **Task Type ID:** `feature`  
> **Inherits:** `core/definition-of-done.md` (all DoD items apply)  
> **Version:** 3.0.0

## Definition

A `feature` task implements new functionality that is explicitly described in `spec.md`.  
No functionality may be added that is not in the spec.

## Additional DoD Criteria (extends core)

- [ ] Feature flag considered for progressive rollout (if applicable).
- [ ] Loading, empty, error and success states implemented for all UI flows.
- [ ] API contract updated if new endpoints were added.
- [ ] Acceptance criteria from the ticket validated by QA against the spec.

## Branch Pattern
```
feat/<TICKET-ID>-<description>
```

## Commit Prefix
```
feat(<scope>): <description> [<TICKET-ID>]
```

## Gate Requirements
- QG-1 SPEC GATE must be passed before any feature development begins.
- QG-3 BUILD GATE: CI green before PR review.
- QG-4 E2E GATE: Feature E2E test written and green before merge.
