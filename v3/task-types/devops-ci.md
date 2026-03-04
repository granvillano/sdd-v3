# Task Type: devops-ci

> **Task Type ID:** `devops-ci`  
> **Inherits:** `core/definition-of-done.md`  
> **Version:** 3.0.0

## Definition

A `devops-ci` task modifies CI/CD pipelines, infrastructure-as-code, deployment scripts or monitoring.

## Additional DoD Criteria

- [ ] Pipeline changes tested in a branch environment before merging.
- [ ] No production secrets added to pipeline YAML (use secret store references).
- [ ] Pipeline run time not increased by more than 20% without justification.
- [ ] All environment-specific configs reviewed (dev / staging / prod).
- [ ] Rollback mechanism tested.

## Branch Pattern
```
chore/<TICKET-ID>-<description>
```

## Commit Prefix
```
ci(<scope>): <description> [<TICKET-ID>]
```
