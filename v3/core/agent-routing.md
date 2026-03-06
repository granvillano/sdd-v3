# core/agent-routing.md — Agent Routing Matrix

> **SSOT Domain:** Agent Routing | **Inherits:** workflow.md  

---

## Purpose

This document defines the deterministic mapping between task intents and the AI agent roles authorized to execute them.

**Enforcement Rule:** Every job executed under SDD v3 MUST be classified against this matrix BEFORE execution begins. If a task does not map to the agent attempting to execute it, the process MUST experience a **HARD STOP**. No "best effort" execution is permitted.

---

## Agent Decision Matrix

| Category | Trigger Signals / Keywords | Required Agent Role | Expected Outputs | Constraints |
|----------|----------------------------|---------------------|------------------|-------------|
| **architecture** | "design", "evaluate", "plan", "architecture", "system", "ADR", "spec" | `architecture_agent` | `architecture.md`, ADRs, `spec.md`, API contracts | No code generation. Output is strictly Markdown/Mermaid. |
| **backend** | "API", "endpoint", "service", "controller", "business logic", "refactor" | `backend_agent` | `src/**/*.ts`, `tests/**/*.ts`, implementation logs | Must implement `api-contract.md` accurately. Must write unit tests. |
| **db** | "schema", "table", "data model", "ORM", "Prisma", "TypeORM" | `backend_agent` | Schema definitions, model classes | Must ensure relationships obey business logic constraints. |
| **migration** | "migration script", "schema update", "legacy data map", "alter table" | `backend_agent` | Migration DDL/scripts | Must include "down" migration logic for rollbacks. |
| **qa** | "write tests", "E2E", "coverage", "integration test", "automation", "lint" | `qa_agent` | Test harnesses, test scripts, bug reports | Independent validation; must not modify business logic to pass tests. |
| **security** | "auth", "JWT", "BOLA", "encryption", "vulnerability", "audit", "CVE" | `backend_agent` | Security patches, auth middleware, audit logs | Must strictly follow `core/security-baseline.md`. Prioritize over features. |
| **devops** | "CI/CD", "GitHub Actions", "Docker", "deployment", "infrastructure", "pipeline" | `devops_agent` | Dockerfiles, YAML workflows, Terraform | Must not weaken CI checks (lint/SAST must remain enabled). |
| **docs-only** | "readme", "docs", "swagger", "openapi", "changelog", "explain" | `docs_agent` | `.md` files, API docs | ZERO application code changes permitted. Markdown outputs only. |
| **release** | "bump version", "tag", "deploy to prod", "release notes" | `traceability_agent` | Version bumps, Git tags, Release summaries | Must verify QG-5 is passed before executing. |

---

## Classification Protocol (Runtime)

During `STEP 3 — EXECUTE` in `02-agent-entrypoint.md`, the active agent must:

1. Analyze the core intent of the task in `jobs/inbox.md`.
2. Map it to one of the **Categories** above based on the trigger signals.
3. Verify that its own internal system prompt (`Role`) matches the **Required Agent Role**.
4. Declare the classification explicitly:
   ```
   [ROUTING] Task Category: <Category>
   [ROUTING] Assigned Role: <Role>
   ```
5. If the roles do NOT match, output exactly:
   ```
   [ROUTING HARD STOP] Task requires <Required Agent Role>, but current agent is <Current Role>. Stopping execution.
   ```
   Then HALT processing immediately.
