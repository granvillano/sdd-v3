# Framework Change Output Enforcement — SDD v3.6.0 MINOR Audit

> **Generated:** 2026-03-05 19:55
> **Patch:** v3.5.0 → v3.6.0 (MINOR)
> **Type:** MINOR — Added hard binary enforcement for README and CHANGELOG updates on framework modification jobs.
> **Status:** ✅ Complete

---

## Goal
Make `README.md` and `CHANGELOG.md` updates mandatory for any job that modifies the SDD v3 framework itself, enforcing this via the SSOT definition and runtime POST-JOB triggers. This acts as a binary PASS/STOP constraint.

## Scope of Changes

### 1. Extracted CHANGELOG
- Created `CHANGELOG.md` at the project root.
- Migrated all existing changelog history out of `README.md` into the new dedicated file, allowing `README.md` to remain leaner and redirect readers to `CHANGELOG.md`.

### 2. SSOT Rules Additions
- **Modified `core/workflow.md`:** 
  - Added new mandatory **Framework Change Protocol** specifying that changes to *any* framework core, definitions, templates, or tooling MUST output: an Audit Note, a Changelog entry, and a Readme update (if behavior is impacted). Defined strict semantic versioning bump rules.

### 3. Binary Enforcement Injection
- **Modified `templates/project/prompts/02-agent-entrypoint.md`:** (Template for future projects)
  - Expanded STEP 4 (POST-JOB) with an explicit Framework Change Protocol step: the agent MUST verify `CHANGELOG.md` and `README.md` were correctly updated.
  - Bound failure to provide this to a `[FRAMEWORK HARD STOP]` exit condition.
- **Modified `~/Desktop/projects/VTC-API-Node/prompts/02-agent-entrypoint.md`:** (Project sync)
  - Cloned the exact same runtime verification block to the existing VTC-API-Node local entrypoint so the constraint runs immediately for this project as well.

### 4. Version Alignments
- Framework version bumped from `3.5.0` to `3.6.0`.
- All `version` headers across the modified files updated to match.
- Audit note (this file) written to `audits/` via standard naming convention.

## Definition of Done Verification
- SSOT rule exists in `workflow.md` (✅)
- Enforcement is binary PASS/STOP in `02-agent-entrypoint.md` (✅)
- README and CHANGELOG (extracted) reflect this current change (✅)
- Audit tracked (✅)
- Version references bumped to `3.6.0` consistently (✅)

---
