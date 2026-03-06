# core/docs-baseline.md — SDD v3 Documentation Baseline

> **SSOT Domain:** Documentation | **Inherits:** none  

---

## Purpose

This document defines the minimum documentation standards for every SDD v3 project.  
The Definition of Done (core/definition-of-done.md) requires these standards to be met.

---

## 1. Required Project Documents

Every project bootstrapped with SDD v3 MUST have these documents:

| Document | Location | Owner | Purpose |
|----------|----------|-------|---------|
| `README.md` | project root | Product/Dev | Project overview, setup, usage |
| `spec.md` | `docs/` | Product | Source-of-truth for requirements |
| `architecture.md` | `docs/` | Architecture | System design and component map |
| `api-contract.md` | `docs/` | Architecture | OpenAPI/JSON API specification |
| `implementation-log.md` | `docs/` | DevOps | Running log of deploys and changes |
| `docs/00_INDEX.md` | `docs/` | Team | Index of all project docs |
| `CHANGELOG.md` | project root | Release | Version history by ticket |
| `SECURITY.md` | project root | Security | Vulnerability reporting contact |

---

## 2. README.md Requirements

Every `README.md` MUST include:

```markdown
# [Project Name]

## Overview
[One-paragraph description]

## Prerequisites
[Runtime, OS, tools required]

## Installation
[Step-by-step install commands]

## Environment Variables
[Table of all required env vars with descriptions]

## Running Locally
[Command to start dev server]

## Testing
[Command to run tests]

## Architecture
[Link to docs/architecture.md]

## License
[License type]
```

---

## 3. implementation-log.md Requirements

Every deploy or significant change MUST be logged:

```markdown
## [YYYY-MM-DD] — v[X.Y.Z] — [Environment]

| Field | Value |
|-------|-------|
| Author | [Name/Agent] |
| Tickets | PROJ-42, PROJ-43 |
| Description | [Brief summary of changes] |
| Rollback | [How to rollback if needed] |
| Status | ✅ Success / ❌ Failed / ⚠️ Partial |
```

---

## 4. ADR (Architecture Decision Record) Format

Significant decisions MUST be recorded in `docs/adr/ADR-NNNN-title.md`:

```markdown
# ADR-NNNN: [Decision Title]

**Date:** YYYY-MM-DD  
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX  
**Deciders:** [Names/Agents]

## Context
[Problem being solved]

## Decision
[The decision made]

## Consequences
**Positive:** [Benefits]  
**Negative:** [Trade-offs]  
**Neutral:** [Other effects]
```

---

## 5. Code Documentation Standards

### All Languages
- Public APIs (methods, functions, classes) MUST have docstrings/JSDoc/PHPDoc.
- Parameters, return types and thrown errors MUST be documented.
- No auto-generated documentation without human review.

### Language-Specific
- **PHP:** PHPDoc with `@param`, `@return`, `@throws`.
- **TypeScript/JavaScript:** JSDoc with `@param`, `@returns`, `@throws`.
- **Python:** Google-style or NumPy-style docstrings.

---

## 6. Changelog Format

Follow **Keep a Changelog** format (https://keepachangelog.com/):

```markdown
## [Unreleased]

## [1.2.0] — 2026-03-04
### Added
- Feature X [PROJ-42]

### Fixed
- Bug Y [PROJ-99]

### Security
- Patched SQL injection [PROJ-110]
```

---

## 7. Documentation Review Gate

Documentation review is part of the E2E GATE (QG-4):
- All required documents exist and are up-to-date.
- No broken internal links.
- All environment variables and new dependencies documented.
- `implementation-log.md` has entry for current release.

---

## 8. api-contract.md Requirements

> **Rule:** The `api-contract.md` (or equivalent OpenAPI spec) is the authoritative source for all API behavior. The following fields are mandatory from v3.2.0 forward.

Every entry in `api-contract.md` for a public endpoint MUST declare:

### 8.1 Required Per-Endpoint Fields

| Field | Description |
|-------|-------------|
| **API Version** | The version this endpoint belongs to (e.g., `v1`, `v2`). Format: `version: v1` at the top of the document or per-endpoint. |
| **Auth requirement** | `public: true` (no auth) or the auth mechanism and required scope/role. |
| **Idempotency** | Whether `Idempotency-Key` is required and the key TTL. |
| **Error contract ref** | Statement that responses conform to `core/engineering-standards.md §10` Standard Error Contract, plus any endpoint-specific error codes. |
| **Observability / request_id** | Statement that `X-Request-ID` is propagated in all responses. |
| **Deprecation status** | `deprecated: false` (default) or `deprecated: true` with `sunset_date: YYYY-MM-DD`. |
| **404/403 strategy** | States which strategy is used: "404 for both not-found and forbidden" or "403 for forbidden, 404 for not-found". Must be consistent per API surface. |

### 8.2 Document-Level Required Sections

Every `api-contract.md` MUST include a top-level section:

```markdown
## API Contract — Metadata

| Field | Value |
|-------|-------|
| API Name | [Service/API name] |
| Current Version | v[X] |
| Supported Versions | v[X], v[X-1] (or "v[X] only") |
| Versioning Strategy | URL (/vX/...) or Header (API-Version: X) |
| Error Format | SDD v3 Standard Error Contract (engineering-standards.md §10) |
| request_id | Propagated via X-Request-ID header on all responses |
| Deprecation Policy | Minimum [90 / 180]-day notice before sunset |
| Auth Mechanism | [JWT Bearer / OAuth2 / API Key / Session] |
| Base URL (production) | https://[domain]/api/v[X] |
```

---

## 9. Change Impact Sections (PR Documentation)

Every PR that modifies API behavior, data models, or infrastructure MUST include a **Change Impact** section in the PR description with the following subsections (mark N/A if not applicable):

```markdown
## Change Impact

### Observability Impact
[Describe any changes to logs, metrics, traces, or request_id handling.
Example: "Added latency_ms to structured log on /orders endpoint."
Example: "No observability changes — N/A"]

### Error Contract Impact
[Describe any changes to error responses, new error codes, or format changes.
Example: "Added PAYMENT_DECLINED error code to POST /payments."
Example: "No error contract changes — N/A"]

### Versioning Impact
[Describe any API version changes, breaking changes, or deprecations.
Example: "Deprecating GET /v1/users/search — sunset date: 2026-09-01. Migration: use GET /v2/users?q=..."
Example: "No versioning changes — N/A"]
```

---

## 10. Inputs Scan Evidence (v3.2.2)

> **Rule:** When `inputs/` contains any files beyond `README.md`, an Inputs Scan Evidence document MUST exist in `docs/changes/` before any architecture or spec work begins.

### 10.1 Required Document

**Location:** `docs/changes/YYYY-MM-DD_HHMM_<job-slug>.md`  
**Created by:** Active agent during PRE-JOB INPUTS SCAN (see `core/workflow.md`).

```markdown
# Inputs Scan — <job-slug>

**Date:** <ISO timestamp>  
**Agent:** <agent-name>  
**Files found:** <count>  
**Project type:** [Greenfield | Brownfield]

## File Summary

| File | Size | Summary |
|------|------|---------|
| <filename> | <size> | <1-3 bullet description> |
| SKIPPED: <filename> | <size> | Binary/large — not parsed |

## Declaration

[Greenfield — inputs/ empty. No external reference scan required.]
[Brownfield — external reference materials detected. Scan complete. See summary above.]
```

### 10.2 When Required

| Condition | Requirement |
|-----------|-------------|
| `inputs/` empty (only README.md) | Log one-line Greenfield declaration. No full scan needed. |
| `inputs/` contains files | Full scan REQUIRED. Evidence doc REQUIRED before QG-2. |
| Evidence missing with non-empty `inputs/` | **QG-2 ARCHITECTURE GATE BLOCK** |

### 10.3 Retention

- All scan evidence files in `docs/changes/` are permanent project records.
- They are checked during QG-2 (Architecture Gate) and QG-5 (Release Gate traceability).
- They MUST NOT be deleted after creation.

---

## 11. Audit File Naming Convention (v3.3.4)

> **Rule:** Every file created in `audits/` MUST use the format `YYYY-MM-DD_HHMM_<slug>.md`.
> Files are listed newest-first. This is mandatory — no free-form names.

### 11.1 Format

```
audits/YYYY-MM-DD_HHMM_<slug>.md

Examples:
  2026-03-04_2026_chain-restoration.md
  2026-03-04_1614_inputs-inbox-enforcement.md
```

- `YYYY-MM-DD` — ISO date of the change
- `HHMM` — 24h local time, no colon
- `<slug>` — 2–5 kebab-case words describing the change

### 11.2 Rules

| Rule | Detail |
|------|--------|
| **Always timestamped** | Date and time are MANDATORY. Never create audit files without them. |
| **Newest first** | The file system sorts alphabetically = chronologically newest last. Document lists (README, changelogs) MUST show newest first. |
| **Permanent** | Audit files are NEVER deleted or renamed after creation. |
| **Created by AI** | The active agent creates the audit note at the end of every framework-modifying session. |

### 11.3 Content Header (required)

Every audit file MUST begin with:

```markdown
# <Title> — SDD v<X.Y.Z> Patch Audit

> **Generated:** YYYY-MM-DD HH:MM
> **Patch:** vX.Y.Z-prev → vX.Y.Z
> **Type:** [PATCH|MINOR|MAJOR] — <one-line description>
> **Status:** ✅ Complete
```

---

