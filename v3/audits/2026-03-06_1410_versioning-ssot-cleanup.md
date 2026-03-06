# Versioning SSOT Hardening — SDD v3.7.1 PATCH Audit

> **Generated:** 2026-03-06 14:10
> **Patch:** v3.7.0 → v3.7.1 (PATCH)
> **Type:** PATCH — Documentation cleanup and SSOT centralization.
> **Status:** ✅ Complete

---

## Goal
Clean the SDD v3 framework versioning system so that the framework has a single global version source and no fragmented local versions. This mitigates hallucinated version parsing by agents reading individual core files.

## Scope of Changes

### 1. Removing Redundant Version Headers
- Swept all `v3/core/*.md` files.
- Stripped embedded `> **Version:** X.Y.Z` metadata blocks from:
  - `agent-routing.md`
  - `definition-of-done.md`
  - `docs-baseline.md`
  - `engineering-standards.md`
  - `gates.md`
  - `security-baseline.md`
  - `tooling-baseline.md`
  - `traceability-baseline.md`
  - `workflow.md`

### 2. Removing Redundant Local Changelogs
- Swept all `v3/core/*.md` files.
- Stripped embedded `## Changelog` tables from all core documents. This history is now exclusively tracked in the global `CHANGELOG.md` file.

### 3. Versioning SSOT Rule Enforced
- **Modified `core/traceability-baseline.md`**: added the rule `9. Version SSOT Constraint` to explicitly declare that "Framework version is defined ONLY in README.md and CHANGELOG.md".

### 4. Runtime & Global Version Alignment
- Kept the static version header exclusively on the runtime `templates/project/prompts/02-agent-entrypoint.md` and bumped it to `3.7.1`.
- Bumped `README.md` to `3.7.1`.
- Written `3.7.1` tracking block into `CHANGELOG.md`.
- Added this audit to the `README.md` audit index.

## Definition of Done Verification
- All core files cleaned of version headers (✅)
- All core files cleaned of internal changelogs (✅)
- SSOT rule appended to traceability baseline (✅)
- README and CHANGELOG incremented correctly (✅)
- Audit log written (✅)
- Committed to SSOT (✅)
