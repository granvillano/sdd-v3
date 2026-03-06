# Auto-Git Protocol Enforcement — SDD v3.7.0 MINOR Audit

> **Generated:** 2026-03-05 19:56
> **Patch:** v3.6.0 → v3.7.0 (MINOR)
> **Type:** MINOR — Added target detection and auto-git hard enforcement.
> **Status:** ✅ Complete

---

## Goal
Implement strict "Target Detection + Auto-Git Protocol" to ensure future agent runs automatically detect when they are modifying the framework repo and autonomously generate the required Conventional Commits and audits without manual instruction.

## Scope of Changes

### 1. Framework SSOT Rules
- **Modified `core/traceability-baseline.md`:** 
  - Added new section `8. Target Detection + Auto-Git Protocol`.
  - Defined rigid Boolean triggers (`FrameworkChanged` and `ProjectChanged`).
  - Required that if `FrameworkChanged == true`, the AI autonomously handles updating the README/CHANGELOG, writing the Audit note, creating a Conventional Commit into the exact `SDD-V3/v3/` repo, and pushing.

### 2. Runtime Enforcement
- **Modified `templates/project/prompts/02-agent-entrypoint.md`:** 
  - Added step 10 to the `STEP 4 — POST-JOB` section: `AUTO-GIT (Framework vs Project)`.
  - Added `[AUTO-GIT HARD STOP]` if the AI concludes a job affecting framework files without executing the automated Git persistence protocol.

### 3. Version & Documentation Alignment
- Framework version bumped to `3.7.0` in `README.md`, `CHANGELOG.md`, `traceability-baseline.md`, and the `02-agent-entrypoint.md` template file.
- `README` audit trail augmented with this record.

## Definition of Done Verification
- SSOT rules present in `traceability-baseline.md` (✅)
- Template entrypoint includes STEP 4 auto-git checklist + hard stop rule (✅)
- README/CHANGELOG/version consistent (✅)
- Audit (`audits/2026-03-05_1956_auto-git-protocol.md`) created (✅)
- Framework commit created and pushed per the new rules (✅)
