# README_REALIGNMENT_2026-03-04.md — SDD v3.3.0 Audit

> **Generated:** 2026-03-04  
> **Bump:** 3.2.4 → 3.3.0 (MINOR)  
> **Status:** ✅ Complete

---

## Version Reasoning

**MINOR bump (3.2.4 → 3.3.0)**

The README realignment itself is documentation only, but it formalizes a set of changes that together constitute new user-facing framework capabilities introduced since 3.0.0:

- Inbox-driven execution model (new workflow — not backward-compatible with original Quick Start instructions)
- Prompt scaffolding (`prompts/` in every project)
- Inputs scan enforcement (Brownfield gate)
- Deterministic project root

None of these removed existing quality gate criteria or SSOT rules. All changes are additive or behavioral improvements. This satisfies the MINOR bump criterion: **new capabilities, backward-compatible core contracts**.

A MAJOR bump would require removal of existing gate criteria or breaking SSOT hierarchy — neither occurred.

---

## README Audit

| Field | Before (v3.0.0) | After (v3.3.0) |
|-------|-----------------|----------------|
| Version | 3.0.0 | 3.3.0 |
| Lines | 57 | ~190 |
| Directory structure | Flat, minimal | Annotated, accurate to real 44-file tree |
| Quick Start | `--project /path/to/...` (WRONG — removed in 3.2.1) | `--project MyName` with full explanation |
| Job execution | Not documented | Full inbox-driven flow with step-by-step |
| Brownfield | Not mentioned | `inputs/` dir, scan requirement, gate impact |
| Gate system | Not documented | Full QG-1…QG-5 summary table |
| Engineering standards | Not documented | API versioning, error contract, observability, logging |
| Prompt files | Not documented | `00-start-job.md` and `02-agent-entrypoint.md` explained |
| Changelog | Not present | Full 3.0.0 → 3.3.0 changelog with 8 entries |
| Audit trail | One-line reference | Full table of 8 audit files |

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.3.0 | README full realignment to reflect real framework state v3.3.0 |
