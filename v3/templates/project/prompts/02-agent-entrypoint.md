# SDD v3 — Master Agent Entrypoint
# prompts/02-agent-entrypoint.md
# Version: 3.7.1
#
# PURPOSE: This file defines the full workflow, gate rules, and post-job
# protocol for every AI session on this project. It is loaded by 00-start-job.md.
# Humans do NOT need to paste this file — paste 00-start-job.md instead.

---

## Project Identity

Fill these in after bootstrapping:

| Field | Value |
|-------|-------|
| Project name | [PROJECT_NAME] |
| Profile | [PROFILE] (e.g., node-typescript-api) |
| SDD v3 root | [ABSOLUTE PATH TO SDD-V3/v3] |
| Project root | [ABSOLUTE PATH TO THIS PROJECT] |

---

## Execution Sequence (apply on every job)

### STEP 0 — PRE-JOB INPUTS SCAN

Before any planning or code generation:

1. Check `inputs/` for files beyond `README.md`.
2. **Brownfield** (files present):
   - Tree scan (max depth 4), summarize each file in 1–3 bullets.
   - Skip binaries > 10 MB: log name + size + "not parsed".
   - Declare: **PROJECT TYPE: Brownfield**
   - Record evidence in `docs/changes/YYYY-MM-DD_HHMM_<slug>.md`
3. **Greenfield** (empty / README.md only):
   - Declare: **PROJECT TYPE: Greenfield**
   - Log one line in `docs/changes/`: "Greenfield — inputs/ empty."
4. Gate: if `inputs/` non-empty AND no evidence in `docs/changes/` → **FAIL. Stop.**

---

### STEP 1 — CORE LOAD

Read and internalize (from SDD v3 root):
1. `core/00_INDEX.md`
2. `core/workflow.md`
3. `core/agent-routing.md`
4. `core/gates.md`
5. `core/definition-of-done.md`
6. `core/engineering-standards.md`
7. `core/security-baseline.md`
8. `core/traceability-baseline.md`
9. `core/docs-baseline.md`
10. `profiles/<profile>/profile.md`

---

### STEP 2 — GATE PRE-CHECK

| Phase | Required gate |
|-------|--------------|
| Phase 3+ | QG-1 SPEC GATE |
| Phase 5+ | QG-2 ARCHITECTURE GATE (includes inputs scan evidence) |
| PR review | QG-3 BUILD GATE |
| Merge | QG-4 E2E GATE |
| Release | QG-5 RELEASE GATE |

If any required gate is not passed → state the gate ID and STOP.

---

### STEP 3 — EXECUTE

State active context before starting:
- Agent role
- Profile
- Task type
- Active ticket (if any)
- Project type (Greenfield / Brownfield)

**ROUTING ENFORCEMENT (HARD STOP)**

Before writing any plan or code, you MUST classify the task according to `core/agent-routing.md`:
1. Classify the task from `jobs/inbox.md` into one of the matrix Categories.
2. Output EXACTLY:
   `[ROUTING] Task Category: <Category>`
   `[ROUTING] Assigned Role: <Your Agent Role>`
3. **HARD STOP**: If your `<Your Agent Role>` does NOT MATCH the matrix's "Required Agent Role" for that Category, you MUST stop execution immediately and print: `[ROUTING HARD STOP] Task requires <Required Agent Role>, but current agent is <Your Agent Role>. Stopping execution.`

Execute strictly per your agent constraints ONLY IF routing passes. No deviations from spec without explicit approval. No gate bypasses.

---

### STEP 4 — POST-JOB: ARCHIVE + CLEAR INBOX (MANDATORY)

After successful execution, in this exact order:

1. **Derive a slug**: 3–5 words, kebab-case from the task content.

2. **Create archive file** at `jobs/archive/YYYY-MM-DD_HHMM_<slug>.md`:
   ```
   # Job Archive — <slug>
   Archived: <ISO timestamp>

   <full task text from inbox>
   ```

3. **Clear inbox**: open `jobs/inbox.md`, delete everything after:
   ```
   ### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️
   ```
   Restore exactly on the next line:
   ```
   (PASTE YOUR TASK HERE)
   ```
   Do NOT modify anything above the marker.

4. **Update Completed table** in `jobs/inbox.md`:
   Append: `| <slug> | YYYY-MM-DD | [<filename>](jobs/archive/<filename>) |`

5. **Update `docs/implementation-log.md`** with a summary entry.

6. If API changed → update `docs/api-contract.md`.

7. If release → update `CHANGELOG.md`.

8. Confirm DoD checklist status (`core/definition-of-done.md`).

9. **If this task modifies the SDD framework itself** (any file under `core/`, `tools/`, `templates/`, `agents/`, `profiles/`, `task-types/`) →
   You MUST execute the **Framework Change Protocol** (`core/workflow.md`):
   - **Check 1:** Was `CHANGELOG.md` updated with an entry for this change?
   - **Check 2:** If the change affects runtime behavior, workflow, gates, or developer-facing usage, was `README.md` updated? (Explicit triggers: modifying `core/workflow.md`, `core/gates.md`, `core/engineering-standards.md`, `core/security-baseline.md`, `prompts/02-agent-entrypoint.md`, `tools/sdd-init.sh`, or `templates/project/*`).
   - **Enforcement:** If any required update is missing, output EXACTLY:
     `[FRAMEWORK HARD STOP] Missing mandatory README/CHANGELOG update for framework change. Stopping.`
     and HALT execution immediately.
   - **Audit Note:** Create an audit note at `[SDD_V3_ROOT]/audits/YYYY-MM-DD_HHMM_<slug>.md` using the exact required header format (see `core/docs-baseline.md §11`).


10. **AUTO-GIT (Framework vs Project)**
    Check `core/traceability-baseline.md` for Target Detection rules:
    - If `FrameworkChanged == true`, you MUST perform the Auto-Git Protocol:
      a) Auto-commit to framework repo with Conventional Commit (including audit filename).
      b) Push if remote exists.
      c) **HARD STOP**: If the mandatory audit, `CHANGELOG.md` entry, or framework commit is missing, you MUST halt and output:
         `[AUTO-GIT HARD STOP] Missing Framework Auto-Git components. Stopping.`


---

## Quality Gate Summaries

### QG-1 SPEC GATE — before architecture
- `spec.md` complete, all stories have Given/When/Then criteria
- NFRs measurable, out-of-scope documented, no ambiguous language

### QG-2 ARCHITECTURE GATE — before tickets
- `architecture.md` + `api-contract.md` complete
- Inputs scan evidence present if Brownfield
- Idempotency + auth strategy documented per endpoint
- Versioning strategy declared; error contract applied

### QG-3 BUILD GATE — before PR review
- CI green, zero lint errors, SAST clean, all unit tests pass
- No secrets hardcoded; every endpoint has `request_id`; error contract enforced
- Structured logging — no raw `console.log` / `print()` in production paths

### QG-4 E2E GATE — before merge
- All E2E tests pass on staging; coverage ≥ 80% new code
- BOLA test cases verified; Standard Error Contract verified for 401/403/422/500
- `X-Request-ID` present in all responses; PII log check completed

### QG-5 RELEASE GATE — before production
- Traceability chain intact: Spec → Ticket → Branch → Commit → PR → Merge
- `CHANGELOG.md` entry written; no open `[BLOCKED]` items; rollback plan documented
- `BREAKING CHANGE` commits → major semver tag (not minor/patch)

---

## Engineering Standards (summary)

- SOLID principles enforced; no business logic in controllers
- All error responses use Standard Error Contract (`{error: {code, message, request_id, timestamp}}`)
- All mutations atomic (transactions); `PUT`/`PATCH`/`DELETE` idempotent; `POST` uses `Idempotency-Key` on critical paths
- Structured JSON line logs; no PII in logs; `request_id` propagated on every request
- API versioned (URL `/v1/...` default); breaking changes = major bump only

---

## Security Rules (summary)

- Auth checked server-side on every protected action (never trust client)
- BOLA: ownership check at service layer for every resource accessed by ID
- No secrets in code; TLS 1.2+ everywhere; rate limiting on sensitive endpoints
- No passwords, tokens, PAN, CVV in logs — ever
