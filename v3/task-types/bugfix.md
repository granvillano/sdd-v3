# Task Type: bugfix

> **Task Type ID:** `bugfix`  
> **Inherits:** `core/definition-of-done.md`  
> **Version:** 3.0.0

## Definition

A `bugfix` task corrects existing behavior to match the spec or a verified expected behavior.

## Additional DoD Criteria

- [ ] Root cause documented in the ticket comments.
- [ ] Regression test added — a test that fails before the fix and passes after.
- [ ] Verified that the bug is not reproducible after the fix in staging.
- [ ] If the bug was user-reported, the reporter's steps-to-reproduce are confirmed fixed.

## Branch Pattern
```
fix/<TICKET-ID>-<description>
```

## Commit Prefix
```
fix(<scope>): <description> [<TICKET-ID>]
```
