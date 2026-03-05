# PROMPT_DEDUPLICATION_V3_3_1.md — SDD v3.3.1 Patch Audit

> **Generated:** 2026-03-04  
> **Patch:** v3.3.0 → v3.3.1 (PATCH)  
> **Type:** Scaffold deduplication — removed identical copy of entrypoint prompt from `.sdd/`  
> **Status:** ✅ Complete

---

## Root Cause: Why 4 Files Existed

| # | File | Source | How it got there |
|---|------|--------|-----------------|
| 1 | `.sdd/00-quick-run.md` | `templates/project/prompts/00-quick-run.md` | Copied by `sdd-init.sh` since v3.0.0. Legacy prompt from the pre-inbox era. |
| 2 | `.sdd/02-agent-entrypoint.md` | `templates/project/prompts/02-agent-entrypoint.md` | **Accidentally copied here** in the v3.2.4 patch (sdd-init.sh copied the file to both `.sdd/` and `prompts/`). This was a duplication error — `.sdd/` had inherited this copy behavior from the v3.0.0 scaffolding before `prompts/` existed. |
| 3 | `prompts/00-start-job.md` | `templates/project/prompts/00-start-job.md` | Added in v3.2.4 as the canonical user-facing job trigger. |
| 4 | `prompts/02-agent-entrypoint.md` | `templates/project/prompts/02-agent-entrypoint.md` | Added in v3.2.4 as the canonical master rules file. |

**Files 2 and 4 were byte-for-byte identical.** Different paths, same source, no divergence.

---

## Role of Each File (Authoritative Decision)

### `.sdd/00-quick-run.md` — LEGACY, INTERNAL FALLBACK
- **Purpose:** v3.0.0-era onboarding prompt. Requires human to fill bracketed placeholders and describe task inline. Does not know about `jobs/inbox.md`.
- **Who edits:** No one (treat as read-only).
- **Who uses it:** Only users on pre-3.2.3 workflow, or users needing a one-off ad-hoc session without the inbox.
- **Authoritative:** No. Superseded by `prompts/00-start-job.md`.
- **Kept:** Yes — backward compat. `.sdd/` is now the internal/legacy dir. `00-quick-run.md` has been given a `⚠️ LEGACY` header.

### `.sdd/02-agent-entrypoint.md` — REMOVED (was an accidental duplicate)
- **Purpose:** Was an identical copy of `prompts/02-agent-entrypoint.md`. Served no distinct purpose.
- **Action:** **Removed from scaffold.** `sdd-init.sh` no longer copies it here.

### `prompts/00-start-job.md` — CANONICAL JOB TRIGGER ✅
- **Purpose:** The short prompt the human pastes into Antigravity to trigger any job. Reads `jobs/inbox.md`, loads `prompts/02-agent-entrypoint.md`, executes, archives, clears.
- **Who edits:** No one (static trigger — same for all jobs on the project).
- **Who uses it:** Human — pasted into Antigravity verbatim.
- **Authoritative:** **Yes.** This is the canonical start prompt.

### `prompts/02-agent-entrypoint.md` — CANONICAL MASTER RULES ✅
- **Purpose:** Project-specific master rules: project identity fields, full STEP 0–4 execution sequence, gate summaries, engineering + security rules.
- **Who edits:** Human — fills in the 4 identity fields once after bootstrapping.
- **Who uses it:** AI — loaded automatically by `00-start-job.md`.
- **Authoritative:** **Yes.** This is the canonical entrypoint/rules file.

---

## Content Comparison

| Pair | Relationship | Verdict |
|------|-------------|---------|
| `.sdd/00-quick-run.md` vs `prompts/00-start-job.md` | **Materially different.** `00-quick-run.md` is bracket-fill, no inbox awareness. `00-start-job.md` reads inbox, auto-archives. | Different by design — different eras, different models. |
| `.ssd/02-agent-entrypoint.md` vs `prompts/02-agent-entrypoint.md` | **Byte-for-byte identical** — same source file in `templates/`. | Redundant. `.sdd/` copy removed. |

---

## References Audit

| Reference location | Points to | Status |
|------------------|-----------|--------|
| `inputs/README.md` (in sdd-init.sh template inline) | `.sdd/02-agent-entrypoint.md` | **Fixed** → now points to `prompts/02-agent-entrypoint.md` |
| `README.md` How to Use section | `prompts/00-start-job.md` and `prompts/02-agent-entrypoint.md` | ✅ Correct |
| `sdd-init.sh` next-steps echo | `prompts/00-start-job.md` and `prompts/02-agent-entrypoint.md` | ✅ Correct |
| `core/workflow.md` | `prompts/02-agent-entrypoint.md` via Job Execution Flow | ✅ Correct |
| No file references `.sdd/02-agent-entrypoint.md` in the canonical flow | — | ✅ Confirmed |

---

## Patch Applied

**`tools/sdd-init.sh`** (v3.3.0 → v3.3.1):
- Removed: `cp "…/02-agent-entrypoint.md"  "$PROJECT_PATH/.sdd/02-agent-entrypoint.md"`
- Added: comments clarifying `.sdd/` = internal/legacy, `prompts/` = canonical user-facing

**`templates/project/prompts/00-quick-run.md`**:
- Added: `⚠️ LEGACY PROMPT` header, explanation, canonical workflow pointer

**`tools/sdd-init.sh` inline `inputs/README.md`**:
- Fixed stale `.sdd/02-agent-entrypoint.md` reference → `prompts/02-agent-entrypoint.md`

---

## Canonical Workflow Declaration

```
1. Human pastes task in jobs/inbox.md below the marker
2. Human pastes prompts/00-start-job.md into Antigravity
3. AI loads prompts/02-agent-entrypoint.md as rules
4. AI executes → archives → clears inbox → updates logs
```

**One start prompt. One rules file. One inbox.** No confusion.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.3.1 | Removed duplicate `.sdd/02-agent-entrypoint.md` from scaffold; `.sdd/` designated internal/legacy; `00-quick-run.md` marked LEGACY; stale reference in inputs/README.md fixed |
| 2026-03-04 | 3.3.0 | README full realignment |
