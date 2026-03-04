# INBOX_MODEL_SIMPLIFICATION_V3_2_3.md — SDD v3.2.3 Patch Audit

> **Generated:** 2026-03-04  
> **Patch:** v3.2.2 → v3.2.3  
> **Type:** PATCH — Simplified job execution model  
> **Status:** ✅ Complete

---

## Summary

Replaced the external-runner (bash script) job execution model with a
**pure inbox-driven AI execution model**. No terminal commands required.

---

## Files Modified

| File | Change |
|------|--------|
| `templates/project/jobs/inbox.md` | Single visual marker; plain structure; agent-managed tables above marker |
| `templates/project/prompts/02-agent-entrypoint.md` | STEP 4: reads below marker; STEP 7: full AI-managed archive+clear protocol |
| `core/workflow.md` | New "Job Execution Flow" section; lifecycle diagram shows PRE-SESSION and POST-JOB; v3.2.3 |
| `tools/sdd-init.sh` | v3.2.3 bump; removed `scripts/` dir; removed sdd-run-job.sh copy |

---

## Before vs After

### Before (v3.2.2)
- HTML comment pair markers `<!-- BEGIN/END USER PROMPT -->`
- User had to run: `bash scripts/sdd-run-job.sh --slug <slug>`
- `scripts/` directory scaffolded in every project

### After (v3.2.3)
- Single visual marker line: `### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️`
- User pastes task in inbox, tells AI: `"Execute inbox job"`
- AI derives slug, archives prompt, clears inbox, updates tables — no terminal

---

## New Inbox Format

```markdown
────────────────────────────────────────────────────────
### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️

(PASTE YOUR TASK HERE)
```

Agent reads everything after the marker. After execution, deletes from marker downward and restores the placeholder.

---

## No Rules Removed

All gate criteria, SSOT rules, and engineering standards preserved. sdd-run-job.sh was user-deleted before this patch.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.2.3 | Pure inbox-driven execution; removed CLI runner; single visual marker |
| 2026-03-04 | 3.2.2 | inputs/ scaffold; sdd-run-job.sh (later deleted); inbox HTML markers |
| 2026-03-04 | 3.2.1 | Deterministic project root at ~/Desktop/projects |
