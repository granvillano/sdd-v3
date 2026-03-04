# Task Type: release

> **Task Type ID:** `release`  
> **Inherits:** `core/definition-of-done.md`, `core/traceability-baseline.md`  
> **Version:** 3.0.0

## Definition

A `release` task prepares and ships a versioned release to production.

## Additional DoD Criteria

- [ ] QG-5 RELEASE GATE fully passed (see `core/gates.md`).
- [ ] All tickets in this release are closed or explicitly deferred.
- [ ] `CHANGELOG.md` entry finalized with correct semver version.
- [ ] Release tag created and pushed: `git tag -a vX.Y.Z`.
- [ ] `implementation-log.md` deploy record added.
- [ ] Post-release monitoring active for 24 h minimum.
- [ ] Rollback procedure documented and accessible to on-call.

## Branch Pattern
```
release/v<MAJOR>.<MINOR>.<PATCH>
```

## Commit Prefix
```
chore(release): bump version to vX.Y.Z [<TICKET-ID>]
```
