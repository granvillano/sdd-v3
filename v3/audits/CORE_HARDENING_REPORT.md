# CORE_HARDENING_REPORT.md — SDD v3 Core Hardening Audit

> **Generated:** 2026-03-04  
> **Hardening Pass:** v3.0.0 → v3.1.0  
> **Status:** ✅ Complete  
> **Scope:** `core/` only — no profiles, agents, or templates modified.

---

## Files Modified

| File | Version Before | Version After | New Sections Added |
|------|--------------|--------------|-------------------|
| `core/engineering-standards.md` | 3.0.0 | 3.1.0 | §6, §7, §8 |
| `core/security-baseline.md` | 3.0.0 | 3.1.0 | §8, §9 |
| `core/gates.md` | 3.0.0 | 3.1.0 | QG-2 ×2, QG-3 ×2, QG-4 ×2 |

**No other files were created, modified, or deleted.**

---

## New Sections — Detail

### `core/engineering-standards.md`

#### § 6 — API Semantics & Idempotency
- **§6.1 HTTP Method Semantics:** Formal table defining idempotency and safety contract for GET, PUT, PATCH, DELETE, POST. GET is strictly read-only; POST requires `Idempotency-Key` on critical paths.
- **§6.2 Idempotency-Key Strategy:** Implementation contract — server must store key + result in durable store, return cached result on retry, reject 409 on payload mismatch.
- **§6.3 Safe Retry Patterns:** Exponential back-off with jitter, bounded retry budgets, server must guarantee idempotency for keyed retries.
- **§6.4 Deterministic Mutation Requirement:** All mutations must produce reproducible final state; non-deterministic values generated server-side only.
- **§6.5 Prohibitions:** Auto-fail table for: mutation in GET, side-effects in reads, non-idempotent PUT, POST without Idempotency-Key on critical paths, silent mutation on retry.

#### § 7 — Mutation Determinism & Consistency
- **§7.1 Transaction Requirement:** Multi-entity mutations must run in a database transaction; partial commits are never acceptable.
- **§7.2 Rollback Requirement:** Compensating transactions or explicit rollback strategy for all multi-step ops; external side effects (email, charge) must execute last.
- **§7.3 Eventual Consistency Policy:** Must be declared in spec as NFR, documented in architecture, and tested with convergence scenarios.

#### § 8 — API Anti-Patterns (Auto-Fail)
- Formal table of 7 auto-fail anti-patterns with consequence level (Architecture BLOCK / Build BLOCK / Security BLOCK).
- Required consistent error format schema (JSON) for all error responses.

---

### `core/security-baseline.md`

#### § 8 — Broken Object Level Authorization (BOLA) Protection
- References OWASP API Security Top 10 (2023) API1:2023.
- **§8.1 Checklist:** 7-item mandatory checklist — every resource by ID must verify ownership at the service layer; client IDs never trusted; deny-by-default required; horizontal and vertical privilege escalation must be impossible.
- **§8.2 Required Test Cases:** 5-row test matrix (valid owner ✅, different user ❌ 403, no auth ❌ 401, non-existent ID ❌ 404, wrong role ❌ 403). All must be in test suite.
- **§8.3 Implementation Pattern:** Pseudocode showing correct (service-layer ownership check) vs. forbidden (no check) patterns.
- **§8.4 BOLA Review Gate:** Explicitly wired to QG-2, QG-3, and QG-4 touchpoints.

#### § 9 — Anti-Replay & Idempotency Protection
- **§9.1 Idempotency-Key Validation:** Minimum 24-hour TTL, persistent storage required, 409 on payload mismatch.
- **§9.2 Replay Attack Detection:** Timestamp validation window (5 min default), JWT `iat`/`exp` enforcement, token blacklisting on logout.
- **§9.3 Rate Limiting for Sensitive Endpoints:** 5-row table by endpoint category with specific limits; 429 + `Retry-After` required.
- **§9.4 Audit Logging for Mutation Attempts:** Append-only audit log requirement with mandatory fields; repeated attempts must generate alerts, not just logs.

---

### `core/gates.md`

#### QG-2 ARCHITECTURE GATE — 2 new criteria
| Label | Requirement |
|-------|------------|
| `[NEW v3.1]` | Idempotency strategy documented for every mutation endpoint in `api-contract.md` (Idempotency-Key requirement + TTL). |
| `[NEW v3.1]` | Authorization strategy documented per resource type in `architecture.md` (ownership layer, deny-by-default, BOLA mitigation). |

#### QG-3 BUILD GATE — 2 new criteria
| Label | Requirement |
|-------|------------|
| `[NEW v3.1]` | SAST ruleset includes authorization checks; unprotected routes flagged unless marked `public: true` in `api-contract.md`. |
| `[NEW v3.1]` | No endpoint exists in deployed code that is not declared in `api-contract.md` — undeclared endpoints = BUILD BLOCK. |

#### QG-4 E2E GATE — 2 new criteria
| Label | Requirement |
|-------|------------|
| `[NEW v3.1]` | BOLA test cases verified: valid owner → 200, different user → 403, no auth → 401. Full matrix from `security-baseline.md §8.2`. |
| `[NEW v3.1]` | Retry behavior validated: identical payload retry, timeout simulation retry, concurrent duplicate request — no duplicate resources created. |

---

## Rule Preservation Confirmation

> ✅ **No existing rule was removed, weakened, or qualified.**

All 3 files were audited line-by-line. The hardening pass operated strictly in append/extend mode:

| Check | Result |
|-------|--------|
| Existing SOLID rules preserved | ✅ |
| Existing Clean Code rules preserved | ✅ |
| Existing architecture layer rules preserved | ✅ |
| Existing testing coverage thresholds preserved (≥ 80%) | ✅ |
| Existing auth & authorization rules preserved | ✅ |
| Existing input validation rules preserved | ✅ |
| Existing secrets management rules preserved | ✅ |
| Existing OWASP Top 10 checklist preserved | ✅ |
| Existing CI/CD security rules preserved | ✅ |
| Existing QG-1 criteria preserved | ✅ |
| Existing QG-2 criteria preserved (only added to) | ✅ |
| Existing QG-3 criteria preserved (only added to) | ✅ |
| Existing QG-4 criteria preserved (only added to) | ✅ |
| Existing QG-5 criteria preserved | ✅ |
| Gate enforcement protocol preserved | ✅ |

---

## Framework Structure Confirmation

> ✅ **No files were created, renamed, moved or deleted outside the 3 modified files.**

```
Modified: core/engineering-standards.md   (3.0.0 → 3.1.0)
Modified: core/security-baseline.md       (3.0.0 → 3.1.0)
Modified: core/gates.md                   (3.0.0 → 3.1.0)
Created:  audits/CORE_HARDENING_REPORT.md (this file)
─────────────────────────────────────────────────────────
Profiles:   UNTOUCHED
Agents:     UNTOUCHED
Templates:  UNTOUCHED
Task-types: UNTOUCHED
Tools:      UNTOUCHED
```

---

## Cross-Reference Matrix

The new additions form a coherent chain across all 3 files:

```
engineering-standards.md §6 (Idempotency rules)
    ↓ referenced by
security-baseline.md §9.1 (validates compliance)
    ↓ enforced at
gates.md QG-2 (documented in api-contract.md)
gates.md QG-3 (SAST checks enforcement)
gates.md QG-4 (retry behavior tested)

security-baseline.md §8 (BOLA protection)
    ↓ enforced at
gates.md QG-2 (auth strategy documented per resource)
gates.md QG-3 (unprotected routes flagged)
gates.md QG-4 (BOLA test cases verified)
```

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 1.0 | Initial hardening audit — v3.0.0 → v3.1.0 |
