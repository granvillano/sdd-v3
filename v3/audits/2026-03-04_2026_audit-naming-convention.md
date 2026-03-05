# Audit File Naming Convention — SDD v3.3.4 Patch Audit

> **Generated:** 2026-03-04 20:26
> **Patch:** v3.3.3 → v3.3.4 (PATCH)
> **Type:** PATCH — Enforced chronological audit file naming convention
> **Status:** ✅ Complete

---

## Problem

The `audits/` directory was unordered. Files had no date or time in their names, making it impossible to determine creation order from the filesystem. Listing was arbitrary and the newest entry was not identifiable without reading content.

## Fix Applied

### 1. Existing files renamed (10 files)

Format applied: `YYYY-MM-DD_HHMM_<slug>.md`

| Old name | New name |
|----------|----------|
| `BOOTSTRAP_REPORT.md` | `2026-03-04_1000_bootstrap-report.md` |
| `CORE_HARDENING_REPORT.md` | `2026-03-04_1030_core-hardening.md` |
| `CORE_EXPANSION_V3_2_REPORT.md` | `2026-03-04_1100_core-expansion-v3-2.md` |
| `CLI_ROOT_ENFORCEMENT_PATCH.md` | `2026-03-04_1130_cli-root-enforcement.md` |
| `INPUTS_INBOX_ENFORCEMENT_V3_2_2.md` | `2026-03-04_1614_inputs-inbox-enforcement.md` |
| `INBOX_MODEL_SIMPLIFICATION_V3_2_3.md` | `2026-03-04_1733_inbox-model-simplification.md` |
| `PROMPTS_SCAFFOLDING_V3_2_4.md` | `2026-03-04_1757_prompts-scaffolding.md` |
| `README_REALIGNMENT_2026-03-04.md` | `2026-03-04_1801_readme-realignment.md` |
| `PROMPT_DEDUPLICATION_V3_3_1.md` | `2026-03-04_1941_prompt-deduplication.md` |
| `CHAIN_RESTORATION_V3_3_3.md` | `2026-03-04_2017_chain-restoration.md` |

### 2. `core/docs-baseline.md` — §11 added

Mandatory naming rule, format spec, content header template, retention and ordering rules.

### 3. `templates/project/prompts/02-agent-entrypoint.md` — STEP 4 item 9 added

Whenever a job modifies any framework file, the AI MUST create an audit note in `audits/` following the naming convention.

### 4. `README.md` — Audit Trail table updated

All filenames updated to new format. Naming convention note added. Newest-first ordering.

---

## Naming Convention (permanent)

```
audits/YYYY-MM-DD_HHMM_<slug>.md
```

- Date + time: mandatory
- Slug: 2–5 kebab-case words
- Ordered: directory lists newest last (alphabetical), document lists newest first
- Permanent: never rename or delete after creation

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.3.4 | Enforced YYYY-MM-DD_HHMM_slug.md naming; renamed 10 existing audit files; §11 in docs-baseline.md; STEP 4 item 9 in 02-agent-entrypoint.md |
| 2026-03-04 | 3.3.3 | Execution chain restored |
