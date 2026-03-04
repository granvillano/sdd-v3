# core/00_INDEX.md — SDD v3 Core SSOT Index

> **SSOT Rule:** This file is the canonical entry point for all core framework rules.  
> All agents MUST load this file first. All profiles and task-types MUST reference this index.

---

## Purpose

This index enumerates every authoritative document in `core/`. Each document is the **single source of truth** for its domain. No other file in the framework may redefine or contradict these rules — only extend them via profiles or task-types.

---

## Core Document Registry

| # | File | Domain | Summary |
|---|------|--------|---------|
| 1 | [`workflow.md`](workflow.md) | Lifecycle | 7-phase development lifecycle with agents and expected outputs |
| 2 | [`gates.md`](gates.md) | Quality Control | Definition and enforcement rules for all Quality Gates |
| 3 | [`definition-of-done.md`](definition-of-done.md) | Acceptance Criteria | Universal DoD checklist — applies to every task type |
| 4 | [`engineering-standards.md`](engineering-standards.md) | Code Quality | SOLID, Clean Code, naming conventions, canonical references |
| 5 | [`security-baseline.md`](security-baseline.md) | Security | OWASP-aligned minimum security requirements |
| 6 | [`traceability-baseline.md`](traceability-baseline.md) | Traceability | Git branch/commit/PR contract and spec-to-deploy chain |
| 7 | [`docs-baseline.md`](docs-baseline.md) | Documentation | Mandatory documentation standards for all projects |

---

## Load Order for Agents

Agents MUST load core files in this order before loading their own profile or task-type overrides:

```
1. core/00_INDEX.md          ← You are here
2. core/workflow.md
3. core/gates.md
4. core/definition-of-done.md
5. core/engineering-standards.md
6. core/security-baseline.md
7. core/traceability-baseline.md
8. core/docs-baseline.md
9. profiles/<project-profile>.md   ← Stack-specific overrides
10. task-types/<task-type>.md       ← Task-specific constraints
11. agents/<agent-name>.md          ← Agent role definition
```

---

## Inheritance Rule

```
core/* (universal)
  └── profiles/<stack> (override/extend)
        └── task-types/<type> (constrain scope)
              └── agents/<role> (execute with context)
```

No document at a lower level may contradict a higher-level rule.  
If a conflict exists, the higher-level rule wins. Document the exception with an ADR.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.0.0 | Initial bootstrap of SDD v3 core |
