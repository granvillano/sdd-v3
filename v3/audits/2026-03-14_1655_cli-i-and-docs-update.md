# Clear Inbox & Docs Update — SDD v3.14.0 MINOR Audit

> **Generated:** 2026-03-14 16:55
> **Patch:** v3.13.0 → v3.14.0 (MINOR)
> **Type:** MINOR — Added `cli-i` command and synchronized scripts documentation.
> **Status:** ✅ Complete

---

## Goal
Improve project maintenance by adding a safe way to clear the `jobs/inbox.md` prompt area and ensuring all operational scripts are correctly documented in the `scripts/README.md`.

## Scope of Changes

### 1. New Inbox Tool
- **Added `v3/templates/project/scripts/cli-i.sh`**:
    - Safely resets the area below the marker `### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️`.
    - Restores the placeholder `(PASTE YOUR TASK HERE)`.
    - Includes safety checks for file and marker existence.

### 2. Documentation Synchronization
- **Regenerated `v3/templates/project/scripts/README.md`**:
    - Now accurately documents all 6 current SDD scripts:
        1. `run-ticket.sh`
        2. `close-ticket.sh`
        3. `cli-i.sh` (New)
        4. `generate-new-agent-context.sh`
        5. `sync-project.sh`
        6. `generate-changelog.sh`

### 3. Scaffolding Update
- **Modified `v3/tools/sdd-init.sh`**:
    - Incremented internal SDD version to `v3.14.0`.
    - Added `cli-i.sh` to the project bootstrap process and set execution permissions.

### 4. Current Project Integration
- **Applied to `VTC-API-Node`**:
    - Installed `scripts/cli-i.sh`.
    - Updates `scripts/README.md` to the new documentation standard.

## Definition of Done Verification
- `cli-i.sh` template created (✅)
- `scripts/README.md` template synchronized (✅)
- `sdd-init.sh` scaffolds the new tool (✅)
- Applied to current project and verified (✅)
- Framework commit created (✅)
