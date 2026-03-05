# CHAIN_RESTORATION_V3_3_3.md — SDD v3.3.3 Patch Audit

> **Generated:** 2026-03-04  
> **Patch:** v3.3.2 → v3.3.3 (PATCH)  
> **Type:** Execution chain restoration  
> **Status:** ✅ Complete

---

## Problem

In v3.3.2, `00-start-job.md` was removed from the scaffold and `00-run.md` was set to directly execute `02-agent-entrypoint.md`. This caused a logic regression: the inbox-reading logic, marker extraction, and archive/clear protocol that lived in `00-start-job.md` were no longer in any user-facing scaffold file.

`02-agent-entrypoint.md` defines the rules but does not itself read `jobs/inbox.md` — that intermediary step was lost.

---

## Fix Applied

### `templates/project/prompts/00-run.md`
- **Before:** `Execute prompts/02-agent-entrypoint.md`
- **After:** `Execute prompts/00-start-job.md`

### `templates/project/prompts/00-start-job.md`
- **Restored** with full logic:
  - Reads `jobs/inbox.md` below the marker
  - Stops if placeholder only
  - Loads `prompts/02-agent-entrypoint.md` as rules
  - Executes task
  - Archives to `jobs/archive/YYYY-MM-DD_HHMM_<slug>.md`
  - Clears inbox and restores placeholder
  - Updates Completed table and `implementation-log.md`

### `tools/sdd-init.sh`
- `00-start-job.md` copy re-added to scaffold

---

## Final Execution Chain

```
User: "Execute prompts/00-run.md"
  ↓
00-run.md       → Execute prompts/00-start-job.md
  ↓
00-start-job.md → reads inbox below marker
                  loads 02-agent-entrypoint.md
                  executes task
                  archives + clears inbox
  ↓
02-agent-entrypoint.md → all rules, gates, standards
```

---

## Scaffold in New Projects (v3.3.3)

```
prompts/
  00-run.md                ← user pastes this (one line)
  00-start-job.md          ← inbox logic + archive protocol
  02-agent-entrypoint.md   ← master rules (fill identity fields once)
```

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.3.3 | Restored 00-start-job.md; fixed 00-run.md delegation; re-added to scaffold |
| 2026-03-04 | 3.3.2 | Introduced 00-run.md launcher; removed .sdd/ from scaffold |
