# PROMPTS_SCAFFOLDING_V3_2_4.md — SDD v3.2.4 Patch Audit

> **Generated:** 2026-03-04  
> **Patch:** v3.2.3 → v3.2.4  
> **Type:** PATCH — Added `prompts/` scaffolding to project bootstrap  
> **Status:** ✅ Complete

---

## Summary

Every new project now includes a `prompts/` directory with two ready-to-use files:
- `prompts/00-start-job.md` — short prompt the human pastes into Antigravity to trigger a job
- `prompts/02-agent-entrypoint.md` — master prompt with full workflow, gates, and archive/clear rules

---

## Files Modified or Created

| File | Action | Change |
|------|--------|--------|
| `templates/project/prompts/00-start-job.md` | **Created** | New short job trigger prompt |
| `templates/project/prompts/02-agent-entrypoint.md` | **Replaced** | Now project-facing master rules (self-contained, no external file deps) |
| `tools/sdd-init.sh` | Modified | v3.2.4; `prompts/` added to mkdir; both files copied; next-steps updated |

---

## New Workflow for Project Humans

1. Fill in `prompts/02-agent-entrypoint.md` project identity fields (once per project).
2. Paste task in `jobs/inbox.md` below the marker.
3. Paste `prompts/00-start-job.md` into Antigravity.
4. AI handles execution, archive, and inbox reset automatically.

No terminal. No scripts. No repeated file copying.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.2.4 | prompts/00-start-job.md and prompts/02-agent-entrypoint.md added to project bootstrap |
| 2026-03-04 | 3.2.3 | Pure inbox-driven execution; removed CLI runner; single visual marker |
| 2026-03-04 | 3.2.2 | inputs/ scaffold; inbox USER PROMPT block; PRE-JOB scan enforcement |
