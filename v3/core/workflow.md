# core/workflow.md — SDD v3 Development Lifecycle

> **SSOT Domain:** Lifecycle | **Inherits:** none (root document)  

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
Phase 4.0: ADR Generation & Architecture Decisions
    ↓
Phase 4: Task Decomposition (Tickets)
    ↓
Phase 4.1: Architecture Guardrails & ADR Review
    ↓ [ARCH GUARDRAIL GATE]
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
| **Goal** | Define system structure, data models, integration contracts, and extract formal architecture decisions |
| **Owner Agent** | `architecture_agent` |
| **Inputs** | `spec.md`, `ux-spec.md`, inputs scan evidence (if Brownfield) |
| **Outputs** | `architecture.md`, `api-contract.md` (OpenAPI/JSON) |
| **Gate** | **ARCHITECTURE GATE** — No undefined dependencies; all endpoints specified; inputs scan evidence present if Brownfield |

### Activities
1. Design database schema and entity relationships.
2. Define system components and their boundaries.
3. Write full API contract (request/response, auth, error codes).
4. Record architecture decisions as ADR candidates.
5. Generate a section in `architecture.md` titled:

   `## Architecture Decisions Extractable as ADR`

   This section must list all architecture decisions that must be converted into ADR records during **Phase 4.0**.

6. Extract decisions from the architecture description including (at minimum):

   - Runtime environment
   - Framework selection
   - Database engine
   - Authentication strategy
   - Logging strategy
   - API error contract
   - Request tracing strategy
   - Idempotency strategy
   - Authorization model
   - Concurrency / locking strategy
   - External integrations

7. The extracted decisions must be listed as structured items so they can be automatically converted to ADR files during **Phase 4.0**.

8. **[v3.2.2]** Verify inputs scan evidence exists in `docs/changes/` if `inputs/` is non-empty.

---
## Phase 4.0 — ADR Generation & Architecture Decisions

| Field | Value |
|------|------|
| **Goal** | Identify and formally record architecture decisions before task decomposition |
| **Owner Agent** | `architecture_agent` |
| **Inputs** | `architecture.md`, `api-contract.md`, `spec.md` |
| **Outputs** | ADR files in `docs/adr/` |
| **Gate** | **ADR GATE** — All critical architecture decisions recorded as ADRs |

### Activities

1. Analyze `architecture.md` and `api-contract.md` to detect architecture decisions.
2. Identify decisions requiring formal documentation, including:
   - Runtime environment
   - Framework selection
   - Authentication strategy
   - Database technology
   - API error contract
   - Logging and tracing strategy
   - Idempotency and request safety
   - External integrations
3. For each decision identified:
   - Generate an ADR file in `docs/adr/`.
4. Ensure ADR filenames strictly follow this convention:
   - `docs/adr/ADR-0001-<slug>.md`
5. Rules for ADR Generation:
   1. Sequential numbering starting from ADR-0001.
   2. If ADR files already exist, detect the highest number and continue sequentially.
   3. One ADR must be created per major architecture decision.
   4. ADRs must be generated automatically by architecture_agent.
6. Each ADR must follow the mandatory standard template exactly.

### ADR Template (Mandatory)

```markdown
# ADR-XXXX — <Title>

Status: Accepted  
Date: <ISO timestamp>

## Context
Explain the architectural problem or design constraint.

## Decision
Describe the chosen solution.

## Consequences
Explain trade-offs, implications and future impact.
```
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

## Phase 4.1 — Architecture Guardrails & ADR Review

| Field | Value |
|------|------|
| **Goal** | Ensure implementation tickets respect existing architecture decisions before development begins |
| **Owner Agent** | `architecture_agent` |
| **Inputs** | `tickets.md`, `architecture.md`, `api-contract.md`, `docs/adr/*` |
| **Outputs** | ADR validation note or proposal in `docs/changes/YYYY-MM-DD_HHMM_<slug>.md`, new ADRs if needed |
| **Gate** | **ARCH GUARDRAIL GATE (ADR Compliance Gate)** — All tickets verified against ADR decisions. All architectural choices must have an ADR. |

### Activities

1. Read all ADR records located in `docs/adr/`.
2. Verify each ticket in `tickets.md` respects existing architecture decisions.
3. Confirm the following architectural constraints are respected:
   - Framework choice (e.g., Fastify)
   - Authentication model (e.g., JWT RS256 + refresh tokens)
   - Database technology
   - Error contract structure
   - Request tracing (`X-Request-ID`)
   - Idempotency strategy for critical operations

### ADR Compliance Rule (Mandatory)

During Phase 4.1, the `architecture_agent` MUST validate ADR compliance:
1. Detect whether a ticket introduces any new architectural component, framework, infrastructure dependency, or cross-cutting concern not previously documented in ADR files.
2. If such a decision is detected:
   - The workflow MUST pause.
   - The `architecture_agent` MUST generate a new ADR file in: `docs/adr/ADR-XXXX-<slug>.md`
   - The ADR must follow the mandatory template defined in Phase 4.0.
3. Only after the ADR has been created and documented may the workflow proceed.
4. **Silent architecture changes are strictly forbidden.**
5. If a ticket directly contradicts an existing ADR decision:
   - The agent must NOT modify the system architecture automatically.
   - Instead, it must create a proposal document in:
     `docs/changes/YYYY-MM-DD_HHMM_architecture-change-proposal.md`
     explaining the conflict.

### Post-Validation Check
6. Record validation evidence in:
   `docs/changes/YYYY-MM-DD_HHMM_architecture-guardrail-check.md`

### Validation Evidence Format

```markdown
# Architecture Guardrail Check

Date: <ISO timestamp>

## ADRs Reviewed
- ADR-001 <title>
- ADR-002 <title>

## Ticket Validation
- TICK-001 — OK
- TICK-002 — OK
- TICK-003 — OK

## Conflicts
None





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

### Ticket Implementation Rule (Mandatory)
Each ticket must be implemented in isolation. After completing a ticket:
- create a dedicated commit
- use Conventional Commits format
- include the ticket ID in the commit message
- do not begin the next ticket until the current one is completed

**Examples:**
- `feat(auth): implement login endpoint [TICK-008]`
- `fix(db): handle mysql reconnect logic [TICK-004]`
- `chore(config): add env validation loader [TICK-001]`

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

## Framework Change Protocol (Mandatory)

This protocol is a **HARD REQUIREMENT** for any job modifying the SDD v3 framework itself.

| Field | Value |
|-------|-------|
| **Trigger** | Any modification to files under: `core/**`, `tools/**`, `templates/**`, `agents/**`, `profiles/**`, `task-types/**` |
| **When to run** | POST-JOB |

### Mandatory Outputs
1. **Audit Note:** `audits/YYYY-MM-DD_HHMM_<slug>.md`.
2. **Changelog:** `CHANGELOG.md` updated with an entry for the new version.
3. **Readme:** `README.md` updated **IF** the change affects runtime behavior, workflow, gates, or developer-facing usage.

### SemVer Bump Rules
- **PATCH:** Documentation, tooling, or internal corrections without behavior change.
- **MINOR:** Behavior/workflow changes (e.g., routing enforcement, new gate requirements).
- **MAJOR:** Breaking change in contract or execution chain.

No agent or human may skip this protocol.

---

