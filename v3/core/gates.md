# core/gates.md — SDD v3 Quality Gates

> **SSOT Domain:** Quality Control | **Inherits:** none  

---

## What is a Quality Gate?

A Quality Gate (QG) is a **hard checkpoint** in the development lifecycle. Work cannot proceed to the next phase unless the gate passes. Gates are binary: **PASS** or **BLOCK**.

There are no "partial passes". If any criterion fails, the gate is BLOCKED and work returns to the appropriate phase.

---

## Gate Registry

| Gate ID | Name | Phase Transition | Owner |
|---------|------|-----------------|-------|
| QG-1 | SPEC GATE | Phase 1 → Phase 3 | `product_agent` |
| QG-2 | ARCHITECTURE GATE | Phase 3 → Phase 4 | `architecture_agent` |
| QG-3 | BUILD GATE | Phase 5 → Phase 6 | CI / `backend_agent` |
| QG-4 | E2E GATE | Phase 6 → Phase 7 | `qa_agent` |
| QG-5 | RELEASE GATE | Phase 7 → Production | `traceability_agent` |

---

## QG-1: SPEC GATE

**Trigger:** Before architecture and UX work begins.

### PASS Criteria
- [ ] `spec.md` exists and is complete.
- [ ] Every user story has Given/When/Then acceptance criteria.
- [ ] NFRs are stated with measurable targets (e.g., "< 200 ms p95 response time").
- [ ] Out-of-scope is explicitly documented.
- [ ] No ambiguous language ("should", "maybe", "could") in requirements.
- [ ] Product owner reviewed and signed off.

### BLOCK Action
Return `spec.md` to the product owner with a list of blockers.  
Blockers must be filed in `jobs/inbox.md` under `[SPEC-BLOCKED]`.

---

## QG-2: ARCHITECTURE GATE

**Trigger:** Before ticket decomposition begins.

### PASS Criteria
- [ ] `architecture.md` documents all system components and their boundaries.
- [ ] `api-contract.md` covers all endpoints referenced in `spec.md`.
- [ ] All external dependencies are identified and risk-assessed.
- [ ] Database schema covers all entities in the spec.
- [ ] At least one ADR recorded for each significant design decision.
- [ ] **[v3.1]** Idempotency strategy documented for every mutation endpoint (PUT, PATCH, DELETE, and POST where applicable). Each entry in `api-contract.md` MUST state whether an `Idempotency-Key` is required and the TTL of the key store.
- [ ] **[v3.1]** Authorization strategy documented per resource type. Each resource in `architecture.md` MUST specify: who can access it, at which layer ownership is verified, and what the deny-by-default behavior is. BOLA mitigations must be explicitly stated (see `core/security-baseline.md §8`).
- [ ] **[v3.2]** API versioning strategy declared and documented. `api-contract.md` MUST specify: versioning approach (URL or header), current version(s) supported, and whether any endpoints are `v0`/experimental. See `core/engineering-standards.md §9`.
- [ ] **[v3.2]** Standard Error Contract confirmed applied. Architecture review MUST verify that the error format from `core/engineering-standards.md §10` is implemented at the controller/handler layer — not ad-hoc per endpoint.
- [ ] **[v3.2]** Observability strategy documented in `architecture.md`. MUST specify: logging framework, metrics export target, `request_id` propagation mechanism, and any distributed tracing solution. See `core/engineering-standards.md §11`.
- [ ] **[v3.2.2]** Inputs Scan Evidence present. If `inputs/` contains files beyond `README.md`, a scan evidence file MUST exist in `docs/changes/` confirming the agent scanned external references before any architecture decisions were made. Missing evidence when `inputs/` is non-empty = ARCHITECTURE GATE BLOCK. See `core/workflow.md PRE-JOB` and `02-agent-entrypoint.md STEP 0`.

### BLOCK Action
Return to Phase 3. Open a `[ARCH-BLOCKED]` item in `jobs/inbox.md`.

---

## QG-3: BUILD GATE

**Trigger:** Before PR review is requested.

### PASS Criteria
- [ ] CI pipeline completes with green status.
- [ ] Zero linting errors or warnings.
- [ ] SAST (static analysis security testing) passes with no high/critical findings.
- [ ] All unit tests pass.
- [ ] No secrets or credentials hardcoded (secret scanning clean).
- [ ] Code follows `core/engineering-standards.md`.
- [ ] **[v3.1]** Static analysis includes authorization rule checks: SAST ruleset MUST include rules for missing authorization calls (e.g., unprotected routes, missing ownership checks) where the language/framework supports it. Any route or handler without explicit auth middleware MUST be flagged as a CI warning unless the endpoint is explicitly marked `public: true` in `api-contract.md`.
- [ ] **[v3.1]** No endpoint exists in deployed code that is not declared in `api-contract.md`. Undeclared endpoints are treated as unapproved attack surface and constitute a BUILD BLOCK.
- [ ] **[v3.2]** Every HTTP handler assigns or forwards a `request_id` before producing any response. Endpoints that return responses without a `request_id` in the `X-Request-ID` response header constitute a BUILD BLOCK (see `core/engineering-standards.md §11.2`).
- [ ] **[v3.2]** All error responses from all endpoints conform to the Standard Error Contract schema (`core/engineering-standards.md §10.1`). Non-conforming error responses constitute a BUILD BLOCK. Unit tests MUST exist that verify the error format for each error scenario covered.
- [ ] **[v3.2]** Structured logging is in use: no `console.log`, `print()`, `error_log()`, or equivalent raw log calls in production code paths. All logging MUST go through the structured logger with the required fields (`core/engineering-standards.md §12.2`). Raw log calls in non-production paths (e.g., debug scripts) are permitted with a comment.

### BLOCK Action
Do NOT request PR review. Fix CI failures and re-push.  
Log failure in `implementation-log.md` under `[BUILD-BLOCKED]`.

---

## QG-4: E2E GATE

**Trigger:** Before merging to main/release branch.

### PASS Criteria
- [ ] All E2E tests pass on staging environment.
- [ ] Code coverage for new code ≥ 80%.
- [ ] All acceptance criteria in the linked tickets are verified by tests.
- [ ] `test-plan.md` updated with ticket IDs and test results.
- [ ] No regression in pre-existing tests.
- [ ] Accessibility checks pass (WCAG 2.1 AA minimum for UI work).
- [ ] **[v3.1]** BOLA test cases verified for every resource endpoint modified in this release. The following must pass: (1) access with valid owner → 200, (2) access with different authenticated user → 403, (3) access without authentication → 401. See `core/security-baseline.md §8.2` for the full required test matrix.
- [ ] **[v3.1]** Retry behavior validated for all mutation endpoints: tests must confirm that sending the same `Idempotency-Key` twice produces the same response and does not create duplicate resources or trigger duplicate side effects.
- [ ] **[v3.2]** Standard Error Contract verified by E2E tests for each key endpoint: tests MUST assert that `401`, `403`, `404`, `422`, and `500` responses match the Standard Error Contract schema (required fields present: `error.code`, `error.message`, `error.request_id`, `error.timestamp`). At minimum, one test per status category for each modified endpoint.
- [ ] **[v3.2]** `request_id` present and valid in all API responses verified by tests. Tests MUST assert that the `X-Request-ID` response header is a valid UUID v4 for all tested endpoints, including error responses.
- [ ] **[v3.2]** Log output reviewed for PII leakage for any endpoint that handles user-supplied data. At least a manual spot-check of staging logs MUST be documented in the PR before merge.
- [ ] **[v3.2]** Deprecation headers present on any endpoint marked deprecated in `api-contract.md` (verify `Deprecation: true` and `Sunset:` headers are returned).

### BLOCK Action
Reject merge. Return ticket to in-progress. Log failure in `test-plan.md`.

---

## QG-5: RELEASE GATE

**Trigger:** Before creating a release tag or deploying to production.

### PASS Criteria
- [ ] Traceability chain unbroken: Spec → Ticket ID → Branch → Commit → PR → Merge.
- [ ] All commits follow Conventional Commits format.
- [ ] `CHANGELOG.md` entry written and linked to tickets.
- [ ] No open `[BLOCKED]` items in `jobs/inbox.md` for this release.
- [ ] `implementation-log.md` has a deploy record entry.
- [ ] Rollback plan documented or automated rollback available.
- [ ] **[v3.2]** If any `BREAKING CHANGE` footer exists in any commit in this release range, the release tag MUST be a major version bump (vX+1.0.0). A minor/patch tag in the presence of a `BREAKING CHANGE` commit constitutes a RELEASE BLOCK.
- [ ] **[v3.2]** Any deprecated API version with a `Sunset` date within the next 14 days is flagged in the release notes with migration guidance referenced.

### BLOCK Action
Do NOT create release tag. Resolve traceability gaps. Open `[RELEASE-BLOCKED]` item.

---

## Gate Enforcement

Agents are responsible for self-enforcement. If an agent detects a gate failure, it MUST:
1. State the gate ID and failing criteria explicitly.
2. Add a `[GATE-BLOCKED: QG-X]` entry to `jobs/inbox.md`.
3. Stop execution and return control to the human or orchestrating agent.
4. Never proceed past a blocked gate under any circumstance.

---

