# Task Type: migration

> **Task Type ID:** `migration`  
> **Inherits:** `core/definition-of-done.md`  
> **Version:** 3.0.0

## Definition

A `migration` task moves, transforms or restructures data, infrastructure or dependencies.

## Rules

- Rollback plan MUST exist before running any migration in production.
- Migrations are NEVER run without a tested dry-run first.
- Data integrity verification MUST be performed post-migration.

## Additional DoD Criteria

- [ ] Migration script tested on a copy of production data.
- [ ] Rollback script written and tested.
- [ ] Data integrity checks (row counts, checksums) documented before and after.
- [ ] Downtime window estimated and communicated if applicable.
- [ ] Migration idempotent (safe to run twice without side effects).
- [ ] Post-migration monitoring alert set.

## Branch Pattern
```
chore/<TICKET-ID>-migrate-<description>
```

## Commit Prefix
```
chore(<scope>): migrate <description> [<TICKET-ID>]
```
