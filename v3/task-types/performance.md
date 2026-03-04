# Task Type: performance

> **Task Type ID:** `performance`  
> **Inherits:** `core/definition-of-done.md`  
> **Version:** 3.0.0

## Definition

A `performance` task improves speed, memory, or resource efficiency of the system.

## Rules

- Baseline metrics MUST be measured BEFORE any change.
- Target metrics MUST be specified in the ticket.
- Behavior MUST not change — identical functional outcomes required.

## Additional DoD Criteria

- [ ] Benchmark results documented: before and after metrics.
- [ ] Performance target from ticket met (e.g., "< 100 ms p99").
- [ ] No regression in other performance metrics.
- [ ] Profiler output or APM screenshot attached to PR.

## Branch Pattern
```
perf/<TICKET-ID>-<description>
```

## Commit Prefix
```
perf(<scope>): <description> [<TICKET-ID>]
```
