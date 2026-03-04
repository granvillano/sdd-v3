# core/engineering-standards.md — SDD v3 Engineering Standards

> **SSOT Domain:** Code Quality | **Inherits:** none  
> **Version:** 3.2.0

---

## Purpose

This document defines the universal engineering standards that all code produced under SDD v3 must follow. Profiles may add language-specific rules; they may **not** relax these baseline standards.

---

## 1. SOLID Principles

All object-oriented code MUST follow SOLID:

| Principle | Name | Rule |
|-----------|------|------|
| **S** | Single Responsibility | A class/module does one thing only. Split if it has multiple reasons to change. |
| **O** | Open/Closed | Open for extension, closed for modification. Use interfaces and abstractions. |
| **L** | Liskov Substitution | Subtypes must be substitutable for their base types without breaking behavior. |
| **I** | Interface Segregation | Prefer many small, specific interfaces over one large general one. |
| **D** | Dependency Inversion | Depend on abstractions, not concretions. Inject dependencies. |

### SOLID Red Flags (auto-fail in code review)
- Classes > 300 lines → likely violates SRP.
- Switch/match on type enums spread across codebase → violates OCP.
- `instanceof` checks in business logic → violates LSP or DIP.
- God objects with > 10 public methods → violates ISP.
- `new Dependency()` inside business logic classes → violates DIP.

---

## 2. Clean Code Standards

### Naming
- Use **intention-revealing names**. `getUserByEmail()` not `getU()`.
- Avoid abbreviations except universally understood ones (`id`, `url`, `api`).
- Boolean variables/methods: prefix with `is`, `has`, `can`, `should`.
- Collections are always plural: `users`, not `userList`.
- Constants: `SCREAMING_SNAKE_CASE`.

### Functions / Methods
- Maximum **20 lines** per function (guideline, not hard limit).
- Maximum **3 parameters** per function — use a DTO/value object if more needed.
- No side effects unless the function name makes the side effect obvious.
- Functions either do something (command) or return something (query) — not both (CQS).

### Comments
- Code should be self-explanatory. Comments explain **WHY**, not **WHAT**.
- Banned: `// TODO` without a ticket ID, `// HACK`, `// FIXME` without an issue link.
- Required: PHPDoc / JSDoc / docstrings on all public API methods.

### Error Handling
- Never swallow exceptions silently.
- Return typed errors rather than `null` where the language supports it.
- Distinguish between recoverable (user errors) and unrecoverable (programmer errors).

---

## 3. Architecture Standards

### Layered Architecture
All projects follow a strict layer hierarchy:
```
Controller / Handler (HTTP boundary)
    ↓
Use Case / Service (business logic)
    ↓
Repository / Gateway (data access)
    ↓
External Systems (DB, API, filesystem)
```
- Upper layers may call lower layers. Lower layers MUST NOT know about upper layers.
- Business logic MUST NOT appear in controllers.
- Database queries MUST NOT appear outside repositories.

### Dependency Injection
- All dependencies injected via constructor (preferred) or method injection.
- No service locators or global registries without explicit justification (ADR required).

---

## 4. Testing Standards

| Level | Minimum Coverage | Scope |
|-------|-----------------|-------|
| Unit | 80% per new file | Isolated, no I/O |
| Integration | Key paths | Real dependencies (DB, API) |
| E2E | Happy path + 2 edge cases | Full user flow |

- Tests are co-located with code or in a mirrored `tests/` structure.
- Test names follow: `methodUnderTest_scenario_expectedBehavior`.
- No `sleep()` or time-based waits in tests — use mocks or fixed clock.

---

## 5. Canonical References

| Topic | Reference |
|-------|-----------|
| Clean Code | *Clean Code* by Robert C. Martin (2008) |
| SOLID | *Agile Software Development* by Robert C. Martin (2002) |
| Design Patterns | *Design Patterns: Elements of Reusable OO Software* — GoF (1994) |
| Security | OWASP Top 10 (current edition) — https://owasp.org/Top10/ |
| Conventional Commits | https://www.conventionalcommits.org/en/v1.0.0/ |
| Semantic Versioning | https://semver.org/ |
| REST API Design | https://restfulapi.net/ |
| Accessibility | WCAG 2.1 — https://www.w3.org/TR/WCAG21/ |
| PHP Standards | PSR-1, PSR-2, PSR-4, PSR-12 — https://www.php-fig.org/psr/ |
| Node/TS Standards | Airbnb JS Style Guide — https://github.com/airbnb/javascript |
| Python Standards | PEP 8 — https://peps.python.org/pep-0008/ |
| Idempotency | IETF RFC 8030 / Stripe Idempotency Pattern |
| API Versioning | REST API Versioning — https://restfulapi.net/versioning/ |
| Structured Logging | OpenTelemetry — https://opentelemetry.io/docs/ |

---

## 6. API Semantics & Idempotency

> **Rule:** Every HTTP method has a defined semantic contract. Violations are auto-fail in architecture review.

### 6.1 HTTP Method Semantics

| Method | Idempotent? | Safe? | Contract |
|--------|------------|-------|----------|
| GET | ✅ Yes | ✅ Yes | MUST never modify state. Calling N times = same result as calling once. |
| PUT | ✅ Yes | ❌ No | MUST replace the full resource. Same payload = same final state, no matter how many times sent. |
| PATCH | ✅ Required | ❌ No | MUST be designed to be idempotent. Applying the same patch twice MUST produce no additional change. |
| DELETE | ✅ Yes | ❌ No | MUST be idempotent. Deleting an already-deleted resource returns 200/204, never 500. |
| POST | ❌ Not by default | ❌ No | Non-idempotent by design. MUST require `Idempotency-Key` header for any resource-creating or payment-triggering operation. |

### 6.2 Idempotency-Key Strategy

All `POST` endpoints that create resources or trigger financial/critical mutations MUST:

1. **Accept** an `Idempotency-Key` request header (UUID v4 or client-generated unique token).
2. **Store** the key with the result (response body + status code) in a durable short-lived store (e.g., Redis, DB table).
3. **Return** the stored result on duplicate requests within the TTL window (default: 24 h).
4. **Respond** with `409 Conflict` if the same key is used with a different payload.
5. **Document** the key requirement in `api-contract.md` for every applicable endpoint.

```
POST /payments
Headers:
  Idempotency-Key: a7f3c2e1-0b4d-4e2a-9f1c-000000000001
  Authorization: Bearer <token>
  Content-Type: application/json
```

### 6.3 Safe Retry Patterns

- Clients MUST be safe to retry failed requests when they receive `5xx` or network timeout.
- The server MUST guarantee idempotent behavior for retried requests that include an `Idempotency-Key`.
- Retry logic MUST use **exponential back-off** with jitter (no tight retry loops).
- Retry budgets MUST be bounded (max 3 automatic retries for client libraries).

### 6.4 Deterministic Mutation Requirement

- Every mutation endpoint MUST produce a **deterministic, reproducible final state** given the same input.
- Non-deterministic side effects (e.g., random IDs, timestamps) MUST be generated server-side and NOT derived from client input.
- No mutation may depend on hidden server state that is not reflected in the API contract.

### 6.5 Prohibitions (auto-fail in code review)

| Anti-Pattern | Rule |
|-------------|------|
| Mutation in GET | FORBIDDEN. GET requests MUST be 100% side-effect free. |
| Side-effects in read-only ops | FORBIDDEN. Reads must never trigger writes, emails, charges, or any observable state change. |
| Non-idempotent PUT | FORBIDDEN. PUT must always replace; never append or partially update. |
| POST without Idempotency-Key on critical paths | FORBIDDEN on payment, resource creation, or mutation endpoints. |
| Silent mutation on retry | FORBIDDEN. Duplicate mutations must be detected and the previous result returned. |

---

## 7. Mutation Determinism & Consistency

> **Rule:** Multi-step mutations must be atomic. No partial state may ever be persisted.

### 7.1 Transaction Requirement

- Any operation that mutates more than one entity or table MUST execute within a database transaction.
- If the transaction cannot be completed, it MUST be rolled back entirely.
- Partial commits are **never acceptable**.

```
// Correct (pseudocode)
beginTransaction()
  updateOrder(orderId, status='paid')
  deductInventory(productId, qty)
  createAuditLog(userId, action)
commitTransaction()
// If any step fails → rollback all
```

### 7.2 Rollback Requirement

- Every multi-step operation (DB + external API) MUST have a compensating transaction or rollback strategy.
- Rollback strategy MUST be documented in `architecture.md` for any workflow involving external services.
- If rollback is impossible (e.g., email already sent), the operation MUST be structured to send the email **last**, after all reversible steps succeed.

### 7.3 Eventual Consistency Policy

- If a system component relies on eventual consistency (e.g., async queues, event sourcing), this MUST be:
  - Explicitly stated in `spec.md` as a Non-Functional Requirement.
  - Documented in `architecture.md` with the consistency model used.
  - Tested with scenarios that validate eventual convergence (not just happy-path consistency).
- Silently assuming eventual consistency where strong consistency is needed is a **critical architecture defect**.

---

## 8. API Anti-Patterns (Auto-Fail)

The following patterns constitute hard failures in architecture and code review. No exceptions without an approved ADR.

| Anti-Pattern | Description | Consequence |
|-------------|-------------|------------|
| **Hidden state transitions** | An action triggers a state machine transition that is not documented in the API contract or spec. | Architecture BLOCK |
| **Silent mutation retry** | A retry of a mutation creates duplicate resources without detection. | Architecture BLOCK |
| **Inconsistent error format** | Different endpoints return errors in different JSON shapes. All errors must follow the Standard Error Contract (§10). | Build BLOCK |
| **Business logic in controllers** | Route handlers contain domain logic instead of delegating to services. | Code review BLOCK |
| **God endpoint** | One endpoint does too many things depending on hidden parameters. Split into separate endpoints. | Architecture BLOCK |
| **Magic state from client** | Server trusts client-provided state (e.g., `is_admin: true` in body) instead of deriving it server-side. | Security BLOCK |
| **Undocumented side effects** | An endpoint produces side effects (emails, charges, state changes) not described in `api-contract.md`. | Architecture BLOCK |
| **Unversioned breaking change** | A breaking change deployed without a version bump and without deprecation notice. | Release BLOCK |

---

## 9. API Versioning Contract

> **SSOT Rule:** Every public API MUST declare and maintain a version. Breaking changes require a major version bump. This section defines the universal versioning contract; profiles may narrow (not relax) the strategy.

### 9.1 Permitted Versioning Strategies

| Strategy | Format | When to use |
|----------|--------|-------------|
| **URL versioning** (default, recommended) | `/v1/users`, `/v2/orders` | All public REST APIs |
| **Header versioning** | `Accept-Version: v2` or `API-Version: 2` | Only if explicitly adopted by profile and documented in `api-contract.md` |

- **URL versioning is the default** for all SDD v3 projects unless a profile explicitly declares header versioning.
- Both strategies MUST NOT be mixed within the same API surface without an ADR.
- GraphQL APIs use schema versioning and deprecation directives instead of URL versioning.

### 9.2 Universal Versioning Rules

- Version is **always explicit** — no implicit "latest" endpoints in production APIs without an alias declaration.
- Version string is a stable, published contract — once `v1` is live, its behavior is frozen (within backwards-compatible limits).
- `v0` prefix is permissible for pre-release/experimental APIs and carries no stability guarantee. `v0` endpoints MUST be marked experimental in `api-contract.md`.
- **Two simultaneous major versions maximum** are supported at any time (current + previous).

### 9.3 Breaking Change Policy

A change is a **breaking change** if any existing client would need to modify code to continue functioning. The following ALWAYS require a major version bump:

| Breaking Change Type | Examples |
|--------------------|---------|
| Remove a field from response | Remove `user.phone` from GET /users/:id |
| Rename a field | `first_name` → `given_name` |
| Change field type | `amount: number` → `amount: string` |
| Change semantics of existing field | `status: "active"` now means something different |
| Remove an endpoint | DELETE /v1/legacy-reports |
| Change HTTP method of endpoint | POST → PUT |
| Change error format or stable error codes | Rename `VALIDATION_FAILED` → `INVALID_INPUT` |
| Add a required request field | New required body param on existing endpoint |
| Remove query parameter support | Drop `?include=` from endpoint that supported it |

The following are **NOT** breaking changes (safe in minor/patch):
- Adding new optional response fields.
- Adding new optional request parameters with sensible defaults.
- Adding new endpoints.
- Adding new error codes (clients must handle unknown codes gracefully).

### 9.4 Deprecation Policy

When a version or endpoint is deprecated, the following lifecycle MUST be followed:

```
Step 1 — Mark deprecated:
  - Add Deprecation: true header to all responses from the deprecated endpoint.
  - Add deprecation notice in api-contract.md with sunset date.
  - Add deprecation notice in CHANGELOG.md.

Step 2 — Support window:
  - Minimum 90-day support window for internal APIs.
  - Minimum 180-day support window for external/public APIs.
  - Communicate sunset date via API response header: Sunset: <HTTP-date>

Step 3 — Migration guide:
  - Document migration path in api-contract.md.
  - Provide code examples for consumers migrating to the new version.

Step 4 — Retirement:
  - Return 410 Gone after sunset date (never 404).
  - Log all 410 responses for monitoring.
```

### 9.5 Backwards Compatibility Expectations

All changes within a major version MUST be backwards-compatible:

- **Do NOT change the meaning** of existing response fields. A field called `amount` that previously was cents must not silently switch to dollars.
- **Do NOT change the error contract** (error codes, error format) without a version bump. See §10 for the Standard Error Contract.
- **Do NOT remove optional fields** from responses within a major version — mark them deprecated first.
- **Do NOT add required fields** to existing request bodies within a major version.
- New fields added to responses MUST be ignored gracefully by compliant clients (clients must not fail on unknown fields).

### 9.6 Breaking Change Checklist

Before merging any change to a published API endpoint, the PR author MUST complete:

- [ ] Is this a breaking change? (refer to §9.3 table)
- [ ] If YES: is a new major version created for this endpoint?
- [ ] If YES: is the old version deprecated with a sunset date?
- [ ] If YES: is the `CHANGELOG.md` updated with `BREAKING CHANGE` note?
- [ ] If YES: does the commit include `BREAKING CHANGE:` in the footer (triggers major semver bump)?
- [ ] Is `api-contract.md` updated to reflect the new version?
- [ ] Is the deprecation header added to old endpoint responses?

---

## 10. Standard Error Contract (SSOT)

> **SSOT Rule:** All error responses across ALL endpoints and ALL services MUST use this format. No deviations without an ADR referencing this section. This contract is stack-agnostic.

### 10.1 Required Error Response Schema

```json
{
  "error": {
    "code": "MACHINE_READABLE_CODE",
    "message": "Human-readable description safe for client display",
    "request_id": "uuid-v4-for-tracing",
    "timestamp": "2026-03-04T16:00:00Z"
  }
}
```

**Required fields (always present):**

| Field | Type | Description |
|-------|------|-------------|
| `error.code` | `string` | Stable, machine-readable error code in `SCREAMING_SNAKE_CASE`. Never changes across versions. |
| `error.message` | `string` | Human-readable message safe to display to end users. Must NOT contain stack traces, internal paths, or secrets. |
| `error.request_id` | `string` (UUID v4) | Matches the `X-Request-ID` response header. Used for log correlation. |
| `error.timestamp` | `string` (ISO 8601) | UTC timestamp of when the error occurred. Format: `YYYY-MM-DDTHH:mm:ssZ`. |

**Optional fields (included when relevant):**

| Field | Type | Description |
|-------|------|-------------|
| `error.details` | `object` or `array` | Additional structured context (e.g., rate limit info, retry guidance). |
| `error.field_errors` | `object` (map) | Field-level validation errors. Key = field path, value = error message. |
| `error.retryable` | `boolean` | `true` if the client may safely retry this request. `false` if retrying will not help. |

### 10.2 HTTP Status Code → Error Code Mapping

All APIs MUST use HTTP status codes consistently per this table:

| HTTP Status | Semantic | Example `error.code` values |
|-------------|----------|----------------------------|
| `400` | Bad Request — malformed syntax | `MALFORMED_REQUEST`, `INVALID_JSON` |
| `401` | Unauthorized — authentication required | `AUTHENTICATION_REQUIRED`, `TOKEN_EXPIRED`, `TOKEN_INVALID` |
| `403` | Forbidden — authenticated but not allowed | `FORBIDDEN`, `INSUFFICIENT_PERMISSIONS`, `RESOURCE_FORBIDDEN` |
| `404` | Not Found | `RESOURCE_NOT_FOUND`, `ENDPOINT_NOT_FOUND` |
| `409` | Conflict — state conflict | `DUPLICATE_RESOURCE`, `IDEMPOTENCY_CONFLICT`, `STATE_CONFLICT` |
| `422` | Unprocessable — valid syntax but invalid semantics | `VALIDATION_FAILED`, `BUSINESS_RULE_VIOLATED` |
| `429` | Too Many Requests | `RATE_LIMIT_EXCEEDED`, `QUOTA_EXCEEDED` |
| `500` | Internal Server Error | `INTERNAL_ERROR` (never expose details to client) |
| `503` | Service Unavailable | `SERVICE_UNAVAILABLE`, `MAINTENANCE_MODE` |

**Rules:**
- `404` vs `403` strategy: for resources that exist but are forbidden to the requester, either `404` (to avoid leaking existence) or `403` may be used. The chosen strategy MUST be consistent and documented in `api-contract.md`.
- `500` responses MUST NEVER include stack traces, SQL errors, or internal paths in the response body. Full error details go to internal logs only.
- `503` responses SHOULD include a `Retry-After` header.

### 10.3 Error Response Examples

**401 — Authentication Required:**
```json
{
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Your session has expired. Please sign in again.",
    "request_id": "a3f1c2e1-0b4d-4e2a-9f1c-000000000042",
    "timestamp": "2026-03-04T16:00:00Z",
    "retryable": false
  }
}
```

**403 — Forbidden:**
```json
{
  "error": {
    "code": "RESOURCE_FORBIDDEN",
    "message": "You do not have permission to access this resource.",
    "request_id": "b8e2d3f4-1c5e-5f3b-a02d-111111111111",
    "timestamp": "2026-03-04T16:00:01Z",
    "retryable": false
  }
}
```

**422 — Validation Failed:**
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The request contains invalid fields.",
    "request_id": "c9f4e5a6-2d6f-6a4c-b13e-222222222222",
    "timestamp": "2026-03-04T16:00:02Z",
    "retryable": false,
    "field_errors": {
      "email": "Must be a valid email address.",
      "amount": "Must be a positive integer."
    }
  }
}
```

**500 — Internal Error:**
```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred. Please try again later.",
    "request_id": "d0a5f6b7-3e7a-7b5d-c24f-333333333333",
    "timestamp": "2026-03-04T16:00:03Z",
    "retryable": true
  }
}
```

### 10.4 Error Contract Enforcement

- The Standard Error Contract is enforced at **Build Gate (QG-3)** and **E2E Gate (QG-4)**. See `core/gates.md`.
- Deviations require an ADR referencing this section.
- Client error messages MUST be reviewed for PII leakage (see `core/security-baseline.md §10`).

---

## 11. Observability Baseline

> **SSOT Rule:** Every service component MUST be observable. Observability is not optional. It is a mandatory engineering capability, not a monitoring add-on.

### 11.1 The Three Pillars

| Pillar | Purpose | Minimum Requirement |
|--------|---------|-------------------|
| **Logs** | Record discrete events for debugging and audit | Structured JSON logs on every request |
| **Metrics** | Measure system behavior over time | 5 minimum metrics per service (see §11.3) |
| **Traces** | Follow a request through distributed components | `request_id` propagated through all components |

### 11.2 Request Correlation — `request_id`

The `request_id` is the **central correlation key** that connects logs, metrics, and traces across the entire system.

**Rules:**
- Every inbound HTTP request MUST receive a `request_id` at the ingress point (gateway or first handler).
- If the client provides an `X-Request-ID` header, use it (validate it is a valid UUID); otherwise generate a new UUID v4.
- The `request_id` MUST be:
  - Attached to **every log** line associated with this request.
  - Returned in the **`X-Request-ID` response header**.
  - Included in the **error response body** (`error.request_id`).
  - Propagated to **all downstream services** called during the request via the `X-Request-ID` header.
- `request_id` MUST appear even in error responses, especially 500s.

```
Incoming request
    ↓
Assign request_id (or accept from X-Request-ID header)
    ↓
Attach to request context / thread-local / async context
    ↓
Pass to all: logs, downstream calls, error responses, metrics labels
    ↓
Return X-Request-ID: <uuid> in response headers
```

### 11.3 Minimum Metrics (Per Service)

Every service MUST expose at minimum the following metrics:

| Metric | Type | Labels |
|--------|------|--------|
| `http_requests_total` | Counter | `method`, `route`, `status_code` |
| `http_request_duration_ms` | Histogram | `method`, `route` — buckets at 50ms, 100ms, 200ms, 500ms, 1000ms, 5000ms |
| `http_errors_total` | Counter | `route`, `error_code` |
| `auth_failures_total` | Counter | `reason` (e.g., `token_expired`, `invalid_credentials`) |
| `rate_limit_triggers_total` | Counter | `route`, `limit_type` |

**Optional but strongly recommended:**
- `db_query_duration_ms` histogram by query type.
- `external_api_call_duration_ms` by service name.
- `queue_depth` for async workers.

Metrics MUST be exported in a standard format compatible with the project's monitoring stack (Prometheus/OpenMetrics preferred).

### 11.4 Distributed Tracing

- `request_id` serves as the minimum trace correlation ID for all projects.
- For projects with multiple services, a full distributed tracing solution (OpenTelemetry, Jaeger, Zipkin) MUST be evaluated and a decision recorded in `architecture.md`.
- Minimum span coverage: one span per primary operation (DB query, external API call, queue publish).
- Trace context propagation follows W3C TraceContext standard (`traceparent` header) when full tracing is implemented.

---

## 12. Structured Logging Contract

> **SSOT Rule:** All logs produced by SDD v3 services MUST be structured. Free-form text logs are forbidden in production services. This section defines the universal log format.

### 12.1 Log Format

**Format:** JSON Lines (one JSON object per line, newline-delimited).  
**Encoding:** UTF-8.  
**No multi-line log entries** — stack traces must be serialized as escaped strings within the JSON object.

### 12.2 Required Fields (Every Log Entry)

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | `string` (ISO 8601 UTC) | When the event occurred. Format: `2026-03-04T16:00:00.000Z` |
| `level` | `string` | Log level: `DEBUG`, `INFO`, `WARN`, `ERROR` |
| `message` | `string` | Human-readable description of the event. Must NOT contain PII or secrets. |
| `request_id` | `string` (UUID) | Correlation ID. Required for all request-scoped logs. |
| `component` | `string` | Service or module name (e.g., `auth-service`, `payment-controller`) |
| `operation` | `string` | The operation being performed (e.g., `createOrder`, `validateToken`) |

### 12.3 Optional but Recommended Fields

| Field | Type | Description |
|-------|------|-------------|
| `actor_id` | `string` | Authenticated user ID (never include username/email in logs without masking) |
| `status_code` | `integer` | HTTP status code of the response |
| `latency_ms` | `integer` | Request or operation duration in milliseconds |
| `error_code` | `string` | Machine-readable error code (matches Standard Error Contract §10) |
| `stack_trace` | `string` | Serialized stack trace (ERROR level only, never sent to client) |
| `environment` | `string` | `development`, `staging`, `production` |

### 12.4 Example Log Entries

```json
{"timestamp":"2026-03-04T16:00:00.123Z","level":"INFO","message":"Request received","request_id":"a3f1c2e1-0b4d-4e2a-9f1c-000000000042","component":"orders-api","operation":"createOrder","actor_id":"usr_1234","latency_ms":null}
{"timestamp":"2026-03-04T16:00:00.450Z","level":"INFO","message":"Order created successfully","request_id":"a3f1c2e1-0b4d-4e2a-9f1c-000000000042","component":"orders-api","operation":"createOrder","actor_id":"usr_1234","status_code":201,"latency_ms":327}
{"timestamp":"2026-03-04T16:00:01.010Z","level":"ERROR","message":"Payment gateway timeout","request_id":"b8e2d3f4-1c5e-5f3b-a02d-111111111111","component":"payment-service","operation":"chargeCard","error_code":"GATEWAY_TIMEOUT","latency_ms":5001,"stack_trace":"Error: Gateway timeout\n  at PaymentGateway.charge (payment.js:42)"}
```

### 12.5 Log Levels — Definitions

| Level | When to use |
|-------|-------------|
| `DEBUG` | Detailed diagnostic info. MUST be disabled in production by default. |
| `INFO` | Normal operational events (request received, resource created, job started). |
| `WARN` | Unexpected but recoverable situations (deprecated endpoint used, retry triggered, rate limit approaching). |
| `ERROR` | Failures requiring attention (unhandled exception, external service failure, data integrity issue). |

### 12.6 What MUST NOT Appear in Logs

| Forbidden Data | Reason |
|---------------|--------|
| Passwords (in any form) | Credential exposure |
| Auth tokens / JWT values | Session hijacking risk |
| Full credit/debit card numbers (PAN) | PCI-DSS violation |
| CVV / CVC codes | PCI-DSS violation |
| API keys or private keys | Secret exposure |
| Full Social Security / National ID numbers | PII / legal risk |
| Unmasked email addresses in sensitive contexts | GDPR risk |
| Stack traces in client-facing responses | Internal path/logic exposure |
| Database connection strings | Infrastructure exposure |

**Masking rule:** If a field must appear for debugging (e.g., email for user identification), mask it: `j***@example.com`. Never log the unmasked value.

### 12.7 Log Retention & Access

- Production logs MUST be retained for a minimum of **90 days**.
- Logs containing PII MUST be subject to the same data protection rules as the data they describe (see `core/security-baseline.md §4`).
- Log access MUST be restricted to authorized operations personnel.
- Logs MUST NOT be writable by the application itself (append-only pipeline).

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.2.0 | Added §9 API Versioning Contract, §10 Standard Error Contract, §11 Observability Baseline, §12 Structured Logging Contract |
| 2026-03-04 | 3.1.0 | Added §6 API Semantics & Idempotency, §7 Mutation Determinism & Consistency, §8 API Anti-Patterns |
| 2026-03-04 | 3.0.0 | Initial bootstrap of SDD v3 core |
