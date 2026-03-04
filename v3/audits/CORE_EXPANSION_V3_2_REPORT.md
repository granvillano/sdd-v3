# CORE_EXPANSION_V3_2_REPORT.md — SDD v3.2.0 Core Expansion Audit

> **Generated:** 2026-03-04  
> **Expansion Pass:** v3.1.0 → v3.2.0  
> **Status:** ✅ Complete  
> **Scope:** `core/` only — profiles, agents, templates untouched.

---

## Files Modified

| File | Lines Before | Lines After | Version | New Sections |
|------|------------|------------|---------|-------------|
| `core/engineering-standards.md` | 249 | 589 | 3.2.0 | §9, §10, §11, §12 |
| `core/security-baseline.md` | 208 | 262 | 3.2.0 | §10 |
| `core/gates.md` | 135 | 148 | 3.2.0 | QG-2 ×3, QG-3 ×3, QG-4 ×4, QG-5 ×2 |
| `core/docs-baseline.md` | 150 | 223 | 3.2.0 | §8, §9 |
| `core/traceability-baseline.md` | 179 | 237 | 3.2.0 | §3 extended, §4 PR template, §5 breaking change rule, §6 extended |

**Files NOT modified (confirmed):**
- `core/00_INDEX.md` — untouched
- `core/workflow.md` — untouched (observability does not require lifecycle change)
- `core/definition-of-done.md` — untouched
- All `profiles/`, `agents/`, `templates/`, `tools/`, `task-types/` — untouched

---

## New Sections Added — Detail

### `engineering-standards.md` — 4 new sections

#### §9 — API Versioning Contract
- **§9.1 Permitted Strategies:** URL versioning (default) vs. Header versioning (profile-declared only). No mixing without ADR. GraphQL uses schema deprecation.
- **§9.2 Universal Rules:** Explicit version required; v0 = experimental; max 2 simultaneous major versions.
- **§9.3 Breaking Change Policy:** Full table of 9 change types that always require a major bump (removing fields, rename, type change, semantic change, method change, etc.) and 5 safe minor/patch changes.
- **§9.4 Deprecation Policy:** 4-step lifecycle (mark, support window 90/180 days, migration guide, 410 Gone retirement). `Deprecation:` and `Sunset:` headers required.
- **§9.5 Backwards Compatibility Expectations:** Meaning of fields frozen, error contract cannot change without version bump, removed optional fields require deprecation first.
- **§9.6 Breaking Change Checklist:** 7-item PR checklist before merging any API change.

#### §10 — Standard Error Contract (SSOT)
- **§10.1 Required Schema:** 4 required fields (`error.code`, `error.message`, `error.request_id`, `error.timestamp`) + 3 optional fields (`details`, `field_errors`, `retryable`).
- **§10.2 HTTP Status Code Mapping:** Table covering 400, 401, 403, 404, 409, 422, 429, 500, 503 with canonical `error.code` values.
- **§10.3 Examples:** 4 complete JSON examples for 401, 403, 422, 500.
- **§10.4 Enforcement:** Wired to QG-3 (Build Gate) and QG-4 (E2E Gate).

#### §11 — Observability Baseline
- **§11.1 Three Pillars:** Logs (structured JSON), Metrics (5 minimum), Traces (request_id minimum).
- **§11.2 request_id Correlation:** Full propagation lifecycle — assign at ingress, attach to all logs, return in `X-Request-ID` header, propagate to downstream services.
- **§11.3 Minimum Metrics:** 5 mandatory metrics (`http_requests_total`, `http_request_duration_ms`, `http_errors_total`, `auth_failures_total`, `rate_limit_triggers_total`) with labels and histogram buckets.
- **§11.4 Distributed Tracing:** request_id as minimum; OpenTelemetry/W3C TraceContext for multi-service; span coverage requirements.

#### §12 — Structured Logging Contract
- **§12.1 Format:** JSON Lines, UTF-8, one event per line. No multi-line entries.
- **§12.2 Required Fields:** 6 mandatory fields (timestamp, level, message, request_id, component, operation).
- **§12.3 Optional Fields:** 7 recommended fields including actor_id, status_code, latency_ms, error_code.
- **§12.4 Examples:** 3 complete JSON log line examples.
- **§12.5 Log Levels:** 4 levels (DEBUG/INFO/WARN/ERROR) with precise usage rules.
- **§12.6 Forbidden Log Content:** 10-row table of data that must never appear in logs (passwords, tokens, PAN, CVV, API keys, SSN, etc.).
- **§12.7 Retention & Access:** 90-day minimum, append-only, PII rules apply.

---

### `security-baseline.md` — 1 new section

#### §10 — Sensitive Data Logging & Redaction
- **§10.1 Absolute Prohibitions:** 10-item table of data types that must never appear in any log at any level.
- **§10.2 Masking Rules:** 6-row masking table (email, phone, card, IP, name, national ID) with format patterns.
- **§10.3 Log-Safe Design Patterns:** Pre-masking before logging framework; no `toString()` on PII-containing objects; dedicated log serializers; exception handlers log type+message only.
- **§10.4 PII Logging Review Gate:** 4-item checklist applied at QG-4.

---

### `gates.md` — Hardening per gate

#### QG-2 — 3 new criteria `[v3.2]`
1. Versioning strategy declared in `api-contract.md` (strategy, version(s), experimental flags).
2. Standard Error Contract confirmed applied at controller/handler layer.
3. Observability strategy documented (logging framework, metrics export, request_id propagation, tracing solution).

#### QG-3 — 3 new criteria `[v3.2]`
1. Every HTTP handler assigns/forwards `request_id` before responding; missing `X-Request-ID` = BUILD BLOCK.
2. All error responses conform to Standard Error Contract schema; non-conforming = BUILD BLOCK.
3. Structured logging in use; raw `console.log`/`print()` in production code = BUILD BLOCK.

#### QG-4 — 4 new criteria `[v3.2]`
1. Standard Error Contract verified by E2E tests (401/403/404/422/500 — all 4 required fields present).
2. `X-Request-ID` UUID v4 verified in all API responses, including errors.
3. Staging log output reviewed for PII leakage (manual spot-check documented in PR).
4. Deprecation headers (`Deprecation:`, `Sunset:`) present on deprecated endpoints.

#### QG-5 — 2 new criteria `[v3.2]`
1. `BREAKING CHANGE:` commits → major version bump enforced. Minor/patch tag with breaking commit = RELEASE BLOCK.
2. Deprecated endpoints with Sunset within 14 days flagged in release notes with migration guidance.

---

### `docs-baseline.md` — 2 new sections

#### §8 — api-contract.md Requirements
- **§8.1 Required Per-Endpoint Fields:** 7 mandatory fields (API version, auth requirement, idempotency, error contract ref, observability/request_id, deprecation status, 404/403 strategy).
- **§8.2 Document-Level Metadata:** Mandatory table at top of every `api-contract.md` (API name, version, supported versions, strategy, error format, request_id, deprecation policy, auth mechanism, base URL).

#### §9 — Change Impact PR Sections
- Three mandatory subsections in every PR that modifies API behavior: Observability Impact, Error Contract Impact, Versioning Impact. PRs without these sections are blocked from review.

---

### `traceability-baseline.md` — Extended throughout

- **§1 Traceability chain:** Updated to reflect Change Impact sections in PRs and breaking change → major bump.
- **§3 Commit contract:** `BREAKING CHANGE:` footer clarified as MANDATORY for applicable changes; consequence stated.
- **§4 PR template:** Extended with Change Impact section (Observability, Error Contract, Versioning). PR without Change Impact sections is blocked from review.
- **§5 Release Tagging:** Explicit rule — BREAKING CHANGE commit = must be major tag. Required sections in release notes added (Breaking Changes, Observability Changes, API Deprecations).
- **§6 QG-5 Verification:** 3 new checks (#6 breaking change → major, #7 PR Change Impact sections, #8 imminent sunset callout).

---

## Version Confirmation

| File | Version |
|------|---------|
| `core/engineering-standards.md` | ✅ 3.2.0 |
| `core/security-baseline.md` | ✅ 3.2.0 |
| `core/gates.md` | ✅ 3.2.0 |
| `core/docs-baseline.md` | ✅ 3.2.0 |
| `core/traceability-baseline.md` | ✅ 3.2.0 |

---

## Rule Preservation Confirmation

> ✅ **No existing rule was removed, weakened, or qualified in any file.**

All changes are strictly append/extend. Every existing section in every file was preserved verbatim. Additions are clearly labeled `[v3.2]` in gates.md for auditability.

---

## Framework Structure Confirmation

> ✅ **No files created, renamed, moved or deleted outside the 5 modified core files.**

```
Modified (core only):
  core/engineering-standards.md   3.1.0 → 3.2.0
  core/security-baseline.md       3.1.0 → 3.2.0
  core/gates.md                   3.1.0 → 3.2.0
  core/docs-baseline.md           3.0.0 → 3.2.0
  core/traceability-baseline.md   3.0.0 → 3.2.0

Created:
  audits/CORE_EXPANSION_V3_2_REPORT.md  (this file)

Untouched:
  core/00_INDEX.md
  core/workflow.md
  core/definition-of-done.md
  profiles/*   (all 5 — untouched)
  agents/*     (all 9 — untouched)
  templates/*  (all 6 — untouched)
  task-types/* (all 9 — untouched)
  tools/*      (untouched)
```

---

## New Requirements Exigibles (Breaking for Existing Projects)

Projects that were bootstrapped under SDD v3.0.0 or v3.1.0 will need to address the following to pass v3.2.0 gates:

| # | Requirement | Gate | Effort Estimate |
|---|-------------|------|----------------|
| 1 | Declare API versioning strategy in `api-contract.md` | QG-2 | Low — documentation |
| 2 | Confirm Standard Error Contract applied to all error responses | QG-2/3 | Medium — may require refactor of error handlers |
| 3 | Document observability strategy in `architecture.md` | QG-2 | Low — documentation |
| 4 | Assign `request_id` in every HTTP handler | QG-3 | Medium — middleware addition |
| 5 | All error responses use Standard Error Contract schema | QG-3 | Medium — may require refactor |
| 6 | Replace raw log calls with structured logger | QG-3 | Medium — depends on current logging setup |
| 7 | E2E tests assert Standard Error Contract for 401/403/422/500 | QG-4 | Medium — new test cases |
| 8 | E2E tests assert `X-Request-ID` header presence | QG-4 | Low — assertion addition |
| 9 | Staging log PII spot-check documented in PR | QG-4 | Low — process addition |
| 10 | Deprecation headers on any deprecated endpoints | QG-4 | Low — middleware addition |
| 11 | BREAKING CHANGE commits → major version bump enforced | QG-5 | Low — process/CI check |
| 12 | PR template updated with Change Impact sections | QG-5 | Low — template update |
| 13 | PII masking confirmed before log pipeline | QG-4 | High — may require log serializer refactor |

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 1.0 | Initial v3.2.0 expansion audit |
