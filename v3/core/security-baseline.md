# core/security-baseline.md — SDD v3 Security Baseline

> **SSOT Domain:** Security | **Inherits:** none  
> **Reference:** OWASP Top 10 (2021 edition), OWASP API Security Top 10 (2023 edition)

---

## Purpose

This document defines the minimum security requirements for all SDD v3 projects.  
All items are mandatory. The BUILD GATE (QG-3) will not pass if any critical item fails.

---

## 1. Authentication & Authorization

- [ ] Authentication implemented via proven mechanism (JWT, OAuth2, session token — documented in spec).
- [ ] Tokens/sessions expire and are rotatable.
- [ ] Passwords hashed using bcrypt, Argon2id or equivalent (min. work factor 12 for bcrypt).
- [ ] Authorization checked server-side on every protected action — never trust the client.
- [ ] Principle of least privilege: users/services have minimum permissions needed.
- [ ] Multi-factor authentication available for admin accounts.

---

## 2. Input Validation & Sanitization

- [ ] All user inputs validated (type, length, format, range) on the server side.
- [ ] All user inputs sanitized before rendering in HTML (prevent XSS).
- [ ] All SQL/NoSQL queries use parameterized statements or ORM — no string concatenation for queries.
- [ ] File uploads restricted by type, size and stored outside the web root.
- [ ] API rate limiting implemented on all public endpoints.

---

## 3. Secrets & Configuration

- [ ] No secrets, API keys, credentials or tokens in source code or version control.
- [ ] Secrets managed via environment variables, secret managers (Vault, AWS SSM, etc.).
- [ ] `.env` files and secret files listed in `.gitignore`.
- [ ] Different credentials for development, staging and production environments.
- [ ] Secret rotation plan documented.

---

## 4. Data Protection

- [ ] Data in transit encrypted via TLS 1.2+ (TLS 1.3 preferred).
- [ ] Sensitive data at rest encrypted (PII, payment data, health data).
- [ ] Minimal data collection — only collect what is needed (data minimization).
- [ ] GDPR/privacy regulation compliance verified if personal data is handled.
- [ ] Database backups encrypted and access-controlled.

---

## 5. OWASP Top 10 Checklist (2021)

| ID | Category | Mitigation |
|----|----------|-----------|
| A01 | Broken Access Control | Role checks on every endpoint; deny-by-default |
| A02 | Cryptographic Failures | TLS everywhere; strong hashing; no MD5/SHA1 for passwords |
| A03 | Injection | Parameterized queries; input validation |
| A04 | Insecure Design | Threat model documented; security requirements in spec |
| A05 | Security Misconfiguration | Hardened defaults; remove unused features/services |
| A06 | Vulnerable Components | Dependency scanning in CI; `npm audit`, `composer audit`, `pip-audit` |
| A07 | Identification/Auth Failures | MFA; brute-force protection; secure session management |
| A08 | Software/Data Integrity Failures | Signed artifacts; CI integrity checks; no untrusted CDNs |
| A09 | Logging/Monitoring Failures | Structured logs; audit trail for auth events; alerting |
| A10 | Server-Side Request Forgery | Allowlist outbound URLs; block internal IP ranges |

---

## 6. Security in CI/CD

- [ ] SAST tool configured (e.g., Semgrep, SonarCloud, Snyk) and runs on every PR.
- [ ] Dependency vulnerability scan in CI pipeline.
- [ ] Container image scanning if Docker is used.
- [ ] Secrets scanning enforced (e.g., GitGuardian, detect-secrets).
- [ ] Production deployments require explicit approval step.

---

## 7. Security Incident Response

- [ ] Contact point for security vulnerabilities documented in `SECURITY.md`.
- [ ] Incident response runbook exists or is referenced.
- [ ] Logs have sufficient detail to reconstruct security incidents (who, what, when, from where).

---

## 8. Broken Object Level Authorization (BOLA) Protection

> **Reference:** OWASP API Security Top 10 (2023) — API1:2023 Broken Object Level Authorization  
> **Risk Level:** Critical — BOLA is the #1 cause of API data breaches.

BOLA occurs when an API endpoint uses client-supplied identifiers (IDs) to access resources without verifying that the authenticated user is authorized to access that specific object.

### 8.1 Mandatory Checklist

- [ ] Every endpoint that accesses a resource by ID MUST verify that the authenticated user owns or is authorized to access that specific resource.
- [ ] Authorization checks MUST be performed at the **service/use-case layer** — never only at the controller or routing layer.
- [ ] Client-supplied identifiers (e.g., `?user_id=X` or `/orders/42`) MUST NEVER be trusted without server-side ownership verification.
- [ ] Deny-by-default strategy is REQUIRED: access is denied unless explicitly granted.
- [ ] The authorization check MUST use the authenticated identity from the token/session — NOT from the request body or URL parameters.
- [ ] Horizontal privilege escalation MUST be impossible: User A cannot access User B's resources via ID manipulation.
- [ ] Vertical privilege escalation MUST be impossible: a non-admin cannot access admin-only resources by guessing IDs.

### 8.2 Required Test Cases

Every protected resource endpoint MUST have the following test cases in the test suite:

| Test Case | Expected Result |
|-----------|----------------|
| Access with valid owner credentials | ✅ 200 — resource returned |
| Access with a different authenticated user (not owner) | ❌ 403 Forbidden |
| Access without any authentication | ❌ 401 Unauthorized |
| Access with a non-existent ID | ❌ 404 Not Found (do not leak existence) |
| Access with a valid token but insufficient role | ❌ 403 Forbidden |

> ⚠️ Returning `404` for "resource exists but access denied" is acceptable to avoid enumeration attacks — but MUST be consistent. Document the chosen strategy in `api-contract.md`.

### 8.3 Implementation Pattern (Required)

```
// Correct pattern (pseudocode)
function getOrder(requesterId, orderId):
    order = orderRepository.findById(orderId)
    if order is null:
        throw NotFoundException()
    if order.ownerId != requesterId AND requester.role != ADMIN:
        throw ForbiddenException()   // ← ownership check at service layer
    return order

// Anti-pattern (FORBIDDEN)
function getOrder(orderId):
    return orderRepository.findById(orderId)   // ← no ownership check
```

### 8.4 BOLA Review Gate

BOLA verification is mandatory during:
- Architecture review (QG-2): Authorization strategy documented per resource type.
- Code review (QG-3): Service-layer ownership checks verified in diff.
- E2E gate (QG-4): All BOLA test cases pass (see §8.2).

---

## 9. Anti-Replay & Idempotency Protection

> **Rule:** Critical mutation endpoints must be protected against replay attacks and accidental duplicate execution.

### 9.1 Idempotency-Key Validation

- [ ] All `POST` endpoints that create resources or trigger financial/critical mutations MUST require an `Idempotency-Key` header.
- [ ] The server MUST store and validate idempotency keys with a minimum TTL of **24 hours**.
- [ ] Duplicate requests with the same key and same payload MUST return the original response — no duplicate resource is created.
- [ ] Duplicate requests with the same key but different payload MUST be rejected with `409 Conflict`.
- [ ] Idempotency key storage MUST survive server restarts (use persistent store, not in-memory cache alone).
- [ ] See `core/engineering-standards.md §6.2` for the full Idempotency-Key strategy.

### 9.2 Replay Attack Detection

- [ ] Time-sensitive operations (payments, OTP validation, session tokens) MUST include a timestamp and reject requests older than a defined window (default: 5 minutes).
- [ ] Signed requests (HMAC, JWT) MUST validate the `iat` (issued at) and `exp` (expiration) claims.
- [ ] Replay of auth tokens after logout MUST be rejected via token blacklisting or short expiry + refresh token rotation.

### 9.3 Rate Limiting for Sensitive Endpoints

All of the following endpoint categories MUST have dedicated, stricter rate limits than general endpoints:

| Endpoint Category | Rate Limit Strategy |
|------------------|-------------------|
| Login / authentication | Max 5 attempts per 15 min per IP |
| Password reset | Max 3 attempts per hour per email |
| Payment / financial mutations | Max 10 per minute per user |
| OTP / 2FA validation | Max 5 attempts, then lockout |
| Resource-creating POST with Idempotency-Key | Log duplicates; alert on high duplicate rate |

Rate limit responses MUST return:
- HTTP `429 Too Many Requests`
- `Retry-After` header with seconds until next allowed attempt.

### 9.4 Audit Logging for Mutation Attempts

- [ ] All mutations to sensitive resources (payments, user roles, credentials, personal data) MUST be logged with: user ID, timestamp, IP address, resource ID, action performed, result.
- [ ] Repeated mutation attempts that trigger rate limits MUST generate an alert (not just a log entry).
- [ ] Audit logs MUST be append-only — no deletion or modification allowed.
- [ ] Audit logs MUST be stored separately from application logs and access-controlled.

---

## 10. Sensitive Data Logging & Redaction

> **Rule:** Logging systems are a primary exfiltration vector for sensitive data. All services MUST apply mandatory redaction before any data reaches the log pipeline.

### 10.1 Absolute Prohibitions (Log Content)

The following data MUST NEVER appear in any log, at any log level, in any environment:

| Forbidden Data | Category |
|---------------|----------|
| Passwords (plaintext or hashed) | Credentials |
| Auth tokens, JWT values, refresh tokens | Session data |
| Full credit/debit card numbers (PAN) | PCI-DSS |
| CVV / CVC / card security codes | PCI-DSS |
| Private API keys or signing keys | Secrets |
| Full Social Security / National ID numbers | PII |
| Bank account / IBAN numbers (full) | Financial PII |
| Biometric data | Sensitive PII |
| Database connection strings with credentials | Infrastructure |
| Private key file contents | Cryptographic material |

### 10.2 Mandatory Masking Rules

Data that may be logged in masked form:

| Data Type | Masking Pattern | Example |
|-----------|----------------|---------|
| Email address | Mask local part | `j***@example.com` |
| Phone number | Last 4 digits only | `***-***-1234` |
| Card number (PAN) | Last 4 digits only | `**** **** **** 4242` |
| IP address (GDPR regions) | Mask last octet | `192.168.1.***` |
| Full names | First initial + last name | `J. Smith` |
| National ID / SSN | Never log, even masked | — |

Masking MUST happen **before** the data reaches the logging framework — not after. Do not rely on log scrubbing as the primary protection.

### 10.3 Log-Safe Design Patterns

- Design logging calls to receive **pre-formatted, pre-masked strings**, not raw domain objects.
- Do not implement `toString()` or `__str__()` on domain objects that contain PII — it creates invisible log leakage risk.
- Use dedicated log DTO/serializer classes that explicitly select fields to log.
- In exception handlers, log the **exception type and message** only — not the full request body.
- Structured logging fields containing user data must be reviewed for PII at every PR.

### 10.4 PII Logging Review Gate

- [ ] No log statement references a field known to contain PII without masking or explicit justification.
- [ ] No domain object with PII properties is passed directly to a logger.
- [ ] Exception handlers do not log raw request bodies.
- [ ] Log samples are reviewed at QG-4 (E2E Gate) for any new endpoint or data model.

---

## Profile-Specific Additions

Each profile (`profiles/`) may add stack-specific security rules.  
See for example:
- `profiles/php-wordpress-api/` — WordPress nonce, capability checks, `wpdb` safe queries.
- `profiles/node-typescript-api/` — Helmet.js, CORS policy, Express rate limiter.
- `profiles/python-fastapi-api/` — Pydantic validation, FastAPI security dependencies.

---

