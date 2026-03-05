# INPUTS_INBOX_ENFORCEMENT_V3_2_2.md — SDD v3.2.2 Patch Audit

> **Generated:** 2026-03-04  
> **Patch:** v3.2.1 → v3.2.2  
> **Type:** PATCH — Inputs scan enforcement + inbox auto-clear  
> **Status:** ✅ Complete

---

## Files Modified or Created

| File | Action | Lines | Change |
|------|--------|-------|--------|
| `tools/sdd-init.sh` | Modified | 275→418 | v3.2.2 bump; `inputs/`, `docs/changes/`, `jobs/archive/`, `scripts/` dirs; `inputs/README.md`; sdd-run-job.sh copy; `sdd.config.yml` inputs block |
| `tools/sdd-run-job.sh` | **Created** | 213 | Auto-clear inbox script |
| `templates/project/jobs/inbox.md` | Modified | 47→69 | USER PROMPT block with HTML comment markers; archive column |
| `templates/project/prompts/02-agent-entrypoint.md` | Modified | 123→177 | STEP 0 PRE-JOB INPUTS SCAN (mandatory) |
| `core/workflow.md` | Modified | 160→210 | PRE-JOB Inputs Scan phase; v3.2.2 |
| `core/gates.md` | Modified | 148→150 | QG-2: inputs scan evidence criterion; v3.2.2 |
| `core/docs-baseline.md` | Modified | 223→270 | §10 Inputs Scan Evidence; v3.2.2 |
| `audits/INPUTS_INBOX_ENFORCEMENT_V3_2_2.md` | **Created** | — | This file |

**Untouched:** `profiles/`, `agents/`, `task-types/`, other `core/` files, `templates/project/prompts/00-quick-run.md`

---

## New Capabilities in Detail

### 1. `inputs/` Scaffold

Every new project now includes:
```
inputs/
inputs/README.md   ← explains read-only rule, human-managed, scan requirement
```
`inputs/README.md` documents: read-only for AI, human-managed, Brownfield detection, evidence requirement.  
`sdd.config.yml` now declares: `inputs.path` and `inputs.scan_required_if_non_empty: true`.

### 2. PRE-JOB INPUTS SCAN (STEP 0)

Added as the **first step** in `02-agent-entrypoint.md` — runs before core load, before any planning:

| State | Trigger | Action |
|-------|---------|--------|
| `inputs/` empty | README.md only | Log Greenfield declaration (1 line) |
| `inputs/` non-empty | Any additional file | Full tree scan (max depth 4), 1-3 bullet summary per file, skip binaries >10 MB |

Evidence written to: `docs/changes/YYYY-MM-DD_HHMM_<slug>.md`  
Traceability gate: non-empty `inputs/` + no evidence → **FAIL, do not proceed**.

### 3. Redesigned `jobs/inbox.md`

```
<!-- BEGIN USER PROMPT -->
## User Prompt
(PASTE YOUR TASK HERE)
<!-- END USER PROMPT -->
```

- Agent reads **only** between the markers.
- If block contains only the placeholder → agent stops and asks for a task.
- After job: agent archives + resets.
- Completed table now includes `Archive File` column.

### 4. `sdd-run-job.sh` — Auto-Clear Script

Shell script that a human (or agent) runs after job completion:
1. Extracts content between `<!-- BEGIN USER PROMPT -->` / `<!-- END USER PROMPT -->`.
2. Saves to `jobs/archive/YYYY-MM-DD_HHMM_<slug>.md`.
3. Resets block to `(PASTE YOUR TASK HERE)` using safe awk transform.
4. Appends row to Completed table.
5. Idempotency guard: refuses to overwrite existing archive file.

The script is automatically copied to each new project's `scripts/` directory by `sdd-init.sh`.

### 5. Gates & Docs

| File | Addition |
|------|---------|
| `core/gates.md` QG-2 | `[v3.2.2]` — inputs scan evidence REQUIRED if `inputs/` non-empty. Missing = ARCHITECTURE GATE BLOCK. |
| `core/docs-baseline.md §10` | Required format for scan evidence doc, 3-state table (empty/files/missing), retention rule (permanent, never delete). |
| `core/workflow.md` | PRE-JOB Inputs Scan promoted to named phase before Phase 1 in lifecycle. |

---

## Framework Version Status

| File | Version |
|------|---------|
| `tools/sdd-init.sh` | ✅ 3.2.2 |
| `tools/sdd-run-job.sh` | ✅ 3.2.2 (new) |
| `core/workflow.md` | ✅ 3.2.2 |
| `core/gates.md` | ✅ 3.2.2 |
| `core/docs-baseline.md` | ✅ 3.2.2 |

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.2.2 | inputs/ scaffold, PRE-JOB scan enforcement, inbox USER PROMPT block, sdd-run-job.sh auto-clear, QG-2 inputs scan gate |
| 2026-03-04 | 3.2.1 | Deterministic project root at ~/Desktop/projects; project-name-only CLI validation |
| 2026-03-04 | 3.2.0 | API versioning, error format, observability, structured logging |
