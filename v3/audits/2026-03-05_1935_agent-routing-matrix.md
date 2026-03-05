# Agent Routing Matrix Integration — SDD v3.4.0 Patch Audit

> **Generated:** 2026-03-05 19:35
> **Patch:** v3.3.5 → v3.4.0 (MINOR)
> **Type:** MINOR — Runtime routing enforcement introduced
> **Status:** ✅ Complete

---

## Goal
Implement a deterministic Agent Decision Matrix to ensure jobs are explicitly categorized and routed to the correct agent roles, enforcing a HARD STOP if the current agent role does not match the required intent. This applies to both the framework template and existing projects.

## Scope of Changes

### 1. Framework Base Changes
- **Created** `core/agent-routing.md`: Sets SSOT mapping of 9 specific task categories to explicit agent roles (e.g. `architecture_agent`, `backend_agent`, `devops_agent`). Includes trigger keywords, expected outputs, constraints, and the classification protocol.
- **Modified** `core/00_INDEX.md`: Integrated `agent-routing.md` into the Core Document Registry (index 2) so it is internalized immediately in STEP 1.

### 2. Runtime Enforcement (Template)
- **Modified** `templates/project/prompts/02-agent-entrypoint.md`: 
  - Added `core/agent-routing.md` to the STEP 1 CORE LOAD chain.
  - Injected an explicit binary PASS/STOP condition in STEP 3 EXECUTE: the agent must declare the Task Category and Assigned Role, halting execution if they don't match the matrix. Version header bumped to 3.4.0.

### 3. Project Sync (VTC-API-Node)
- **Modified** `~/Desktop/projects/VTC-API-Node/prompts/02-agent-entrypoint.md` (Local project instance):
  - Applied the exact same STEP 1 and STEP 3 routing constraints directly to the live project, meaning the next job run here will enforce routing determinism.

## Version Reasoning
The SDD v3 framework has been bumped to **3.4.0 (MINOR)**. This constitutes a change in *runtime execution behaviour* (introducing a hard stop that didn't exist before) rather than just a patch.

## Definition of Done Verification
- `core/agent-routing.md` exists and is referenced by `core/00_INDEX.md` (✅)
- `templates/project/prompts/02-agent-entrypoint.md` enforces PASS/STOP routing (✅)
- Local project `prompts/02-agent-entrypoint.md` enforces PASS/STOP routing (✅)
- Framework version bumped MINOR + changelog updated + audit recorded (✅)
- Mismatch results in a STOP, not a best-effort warning (✅)

---
