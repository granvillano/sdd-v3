# core/workflow.md — SDD v3 Development Lifecycle

> **SSOT Domain:** Lifecycle | **Inherits:** none (root document)  
> **Version:** 3.5.0

---

## Overview

SDD v3 defines a **7-phase lifecycle**. Each phase has a designated owner agent, explicit inputs/outputs, and at least one Quality Gate. No phase may begin without the previous phase's gate having passed.

```
[PRE-SESSION] User pastes task in jobs/inbox.md below the marker
              User tells AI: "Execute inbox job"
    ↓
[PRE-JOB] Inputs Scan (MANDATORY — AI runs before Phase 1)
    ↓
Phase 1: Spec & Product Definition
    ↓ [SPEC GATE]
Phase 2: UX / UI Design
    ↓
Phase 3: Architecture & API Contracts
    ↓ [ARCHITECTURE GATE]
Phase 4: Task Decomposition (Tickets)
    ↓
Phase 5: Development
    ↓ [BUILD GATE]
Phase 6: QA & Testing
    ↓ [E2E GATE]
Phase 7: Release & Deploy
    ↓ [RELEASE GATE]
    ↓
[POST-JOB] AI archives prompt → resets inbox → updates implementation-log
```

---

## Job Execution Flow (v3.2.3)

SDD v3 uses a **pure inbox-driven model**. No external CLI runners or automation scripts are required.

### How to run a job

1. **Human:** Paste the task description in `jobs/inbox.md` below the marker:
   ```
   ### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️
   ```
2. **Human → AI:** Send the message: `"Execute inbox job"`
3. **AI:** Reads the inbox, runs the full entrypoint sequence (STEP 0–7), then:
   - Archives the prompt to `jobs/archive/YYYY-MM-DD_HHMM_<slug>.md`
   - Resets the inbox to `(PASTE YOUR TASK HERE)`
   - Updates the Completed table and `implementation-log.md`

**No terminal commands. No bash scripts. The AI manages the full job lifecycle.**

---

## PRE-JOB: Inputs Scan (v3.2.3)

| Field | Value |
|-------|-------|
| **When** | Before Phase 1, and before every agent session |
| **Owner** | Active agent (whichever agent is initializing) |
| **Trigger** | Presence of any file in `inputs/` beyond `README.md` |
| **Outputs** | `docs/changes/YYYY-MM-DD_HHMM_<slug>.md` (scan evidence) |
| **Gate impact** | Missing evidence with non-empty `inputs/` → QG-2 ARCHITECTURE GATE blocked |

### Activities

1. Check `inputs/` for files beyond `README.md`.
2. If non-empty (Brownfield): scan tree (max depth 4), summarize each file in 1–3 bullets. Skip binaries >10 MB with a log note.
3. Declare project type: **Greenfield** (empty) or **Brownfield** (files present).
4. Record evidence in `docs/changes/YYYY-MM-DD_HHMM_<slug>.md`.
5. If Brownfield and no evidence → **FAIL** before proceeding.

### Scan Evidence Format

```markdown
# Inputs Scan — <job-slug>
Date: <ISO timestamp>
Files found: <count>

## File Summary
- <filename> (<size>) — <1-3 bullet summary>
- SKIPPED: <filename> (<size>) — binary/large file, not parsed

## Project Type Declaration
[Greenfield | Brownfield]
```

---

## Phase 1 — Spec & Product Definition

| Field | Value |
|-------|-------|
| **Goal** | Transform a raw idea into verified, unambiguous requirements |
| **Owner Agent** | `product_agent` |
| **Inputs** | Business idea, user stories, market objectives; scan evidence from PRE-JOB step |
| **Outputs** | `spec.md`, `PROJECT_BRIEF.md` |
| **Gate** | **SPEC GATE** — `spec-completeness-checklist` passes with 0 blockers |

### Activities
1. Define the problem and target users.
2. Write high-level user stories in Given/When/Then format.
3. Define MVP scope and explicitly list out-of-scope items.
4. Record functional and non-functional requirements.

### Spec Gate Criteria
- All user stories have acceptance criteria.
- No ambiguous language ("maybe", "could", "sometimes").
- NFRs (performance, security, availability) are stated with measurable targets.
- Out-of-scope explicitly documented.

---

## Phase 2 — UX / UI Design

| Field | Value |
|-------|-------|
| **Goal** | Define user flows, interface states, and visual design before coding |
| **Owner Agent** | `ux_agent` |
| **Inputs** | `spec.md` |
| **Outputs** | `ux-spec.md`, `figma-handoff.md` |
| **Gate** | UX reviewed by product owner against spec alignment |

### Activities
1. Map complete user flows from all entry points.
2. Define all interface states: Loading, Empty, Error, Success.
3. Produce Figma designs; extract tokens and component inventory.
4. Document responsive breakpoints and accessibility requirements.

---

## Phase 3 — Architecture & API Contracts

| Field | Value |
|-------|-------|
| **Goal** | Define system structure, data models, and integration contracts |
| **Owner Agent** | `architecture_agent` |
| **Inputs** | `spec.md`, `ux-spec.md`, inputs scan evidence (if Brownfield) |
| **Outputs** | `architecture.md`, `api-contract.md` (OpenAPI/JSON) |
| **Gate** | **ARCHITECTURE GATE** — No undefined dependencies; all endpoints specified; inputs scan evidence present if Brownfield |

### Activities
1. Design database schema and entity relationships.
2. Define system components and their boundaries.
3. Write full API contract (request/response, auth, error codes).
4. Record architecture decisions as ADRs.
5. **[v3.2.2]** Verify inputs scan evidence exists in `docs/changes/` if `inputs/` is non-empty.

---

## Phase 4 — Task Decomposition

| Field | Value |
|-------|-------|
| **Goal** | Break spec into independent, actionable tickets |
| **Owner Agent** | `product_agent`, `architecture_agent` |
| **Inputs** | `spec.md`, `api-contract.md`, `ux-spec.md` |
| **Outputs** | `tickets.md` (with acceptance criteria per ticket) |
| **Gate** | All tickets map to a spec requirement; no orphan tickets |

### Activities
1. Split work into frontend and backend slices.
2. Write acceptance criteria per ticket (Given/When/Then).
3. Assign task-type label (see `task-types/`).
4. Verify no mutual blocking dependencies.

---

## Phase 5 — Development

| Field | Value |
|-------|-------|
| **Goal** | Implement code guided strictly by tickets and spec |
| **Owner Agent** | `backend_agent`, `frontend_agent` |
| **Inputs** | `tickets.md`, `api-contract.md`, `figma-handoff.md` |
| **Outputs** | Feature branches, PRs |
| **Gate** | **BUILD GATE** — CI green (lint, SAST, unit tests) before PR review |

### Activities
1. Frontend: isolated components → state integration → API integration.
2. Backend: models → services → controllers → routes → auth.
3. Follow `core/engineering-standards.md` and profile conventions.
4. Commit using Conventional Commits format (see `traceability-baseline.md`).

---

## Phase 6 — QA & Testing

| Field | Value |
|-------|-------|
| **Goal** | Validate 100% spec coverage via automated and manual tests |
| **Owner Agent** | `qa_agent` |
| **Inputs** | PRs, `spec.md`, `ux-spec.md` |
| **Outputs** | Test reports, `test-plan.md` updated |
| **Gate** | **E2E GATE** — All E2E tests pass; coverage ≥ 80% for new code |

### Activities
1. Run unit, integration and E2E test suites.
2. Perform linting, accessibility and performance checks.
3. Verify UI against `figma-handoff.md` (pixel-accurate).
4. Update `test-plan.md` with ticket IDs covered.

---

## Phase 7 — Release & Deploy

| Field | Value |
|-------|-------|
| **Goal** | Ship code to production safely with full traceability |
| **Owner Agent** | `devops_agent`, `docs_agent`, `traceability_agent` |
| **Inputs** | Merged code, environment variables, `CHANGELOG.md` |
| **Outputs** | Git tag, live deployment, updated docs |
| **Gate** | **RELEASE GATE** — Traceability chain verified, CHANGELOG updated, no dangling PRs |

### Activities
1. Generate changelog entry (link spec → tickets → commits).
2. Create release tag following semver.
3. Execute CI/CD pipeline.
4. Update `implementation-log.md` with deploy record.

## Framework Consistency Inspection (Mandatory)

This step is a **HARD REQUIREMENT** for any job modifying the SDD v3 framework itself.

| Field | Value |
|-------|-------|
| **Trigger** | Any modification to files in: `core/`, `prompts/`, `templates/`, `profiles/`, `tools/` |
| **When to run** | Immediately before closing the job |
| **Minimum target set** | `README.md`, `CHANGELOG.md`, `core/00_INDEX.md`, `core/workflow.md`, `core/definition-of-done.md`, `core/engineering-standards.md`, `core/traceability-baseline.md`, `profiles/*` |

### Rules & Outcomes
1. **Audit:** The agent MUST read the minimum target set to ensure the new change does not contradict existing SSOT, miss an index registration, or leave documentation out of sync.
2. **Auto-fix:** If inconsistencies are found, the agent MUST auto-fix them within the same job session.
3. **Semver:** If the framework change introduces new runtime behavior, new SSOT files, or altered prompts, the agent MUST bump the framework version correctly (MINOR for new non-breaking features, PATCH for fixes) and update all version headers consistently.

No agent or human may skip this check.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-05 | 3.5.0 | Added mandatory Framework Consistency Inspection section to lifecycle |
| 2026-03-04 | 3.2.3 | Replaced external runner model with pure inbox-driven AI execution; added Job Execution Flow section; no CLI scripts required |
| 2026-03-04 | 3.2.2 | Added PRE-JOB Inputs Scan phase; Phase 3 activities updated with inputs scan gate check |
| 2026-03-04 | 3.0.0 | Initial bootstrap of SDD v3 core |
