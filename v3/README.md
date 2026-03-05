# SDD v3 — Spec-Driven Development Framework

> **Version:** 3.3.4 | **Date:** 2026-03-04 | **Status:** Active  
> **Previous:** 3.0.0 → 3.1.0 → 3.2.x → 3.3.x

---

## What is SDD v3?

SDD (Spec-Driven Development) v3 is an AI-agent orchestration framework for building production software under a specification-first, gate-driven methodology. Every decision must be specced. Every line of code must trace back to a requirement. Every deploy must have an unbroken audit trail.

SDD v3 is a **clean rewrite** — it does not import or extend SDD v2.

---

## Core Principles

| Principle | Description |
|-----------|-------------|
| **Spec-First** | Nothing is built without a validated spec. |
| **Gate-Driven** | Work cannot proceed without passing quality gates (QG-1 → QG-5). |
| **Traceable** | Spec → Ticket → Branch → Commit → PR → Deploy. Unbroken chain required. |
| **Profile-Scoped** | Standards adapt to the project's technology stack via profiles. |
| **SSOT** | Core is the single source of truth. Profiles and agents extend — never contradict — core. |
| **Inbox-Driven** | AI execution is triggered by pasting a task in `jobs/inbox.md`. No external runners. |

---

## Framework Directory Structure

```
v3/
├── core/                        ← Universal SSOT rules (all projects inherit)
│   ├── 00_INDEX.md              ← Master index of all core domains
│   ├── workflow.md              ← 7-phase lifecycle + PRE-JOB inputs scan
│   ├── gates.md                 ← QG-1 … QG-5 with full pass/block criteria
│   ├── definition-of-done.md   ← Universal DoD checklist
│   ├── engineering-standards.md ← SOLID, API versioning, error contract,
│   │                              observability baseline, structured logging
│   ├── security-baseline.md     ← Auth, BOLA, idempotency, PII log redaction
│   ├── traceability-baseline.md ← Git contract, commit format, release tagging
│   └── docs-baseline.md        ← Required project docs, api-contract format,
│                                  inputs scan evidence requirements
│
├── profiles/                    ← Per-stack overrides (must never contradict core)
│   ├── php-wordpress-api/
│   ├── node-typescript-api/
│   ├── python-fastapi-api/
│   ├── react-webapp/
│   └── react-native-app/
│
├── task-types/                  ← Per-task-type constraints
│   ├── feature.md
│   ├── bugfix.md
│   ├── refactor.md
│   ├── security-fix.md
│   ├── performance.md
│   ├── migration.md
│   ├── devops-ci.md
│   ├── docs-only.md
│   └── release.md
│
├── agents/                      ← AI agent definitions
│   ├── product_agent.md
│   ├── architecture_agent.md
│   ├── backend_agent.md
│   ├── frontend_agent.md
│   ├── qa_agent.md
│   ├── devops_agent.md
│   ├── docs_agent.md
│   ├── ux_agent.md
│   └── traceability_agent.md
│
├── templates/project/           ← Scaffold copied into every new project
│   ├── prompts/
│   │   ├── 00-run.md              ← Minimal launcher: paste in AI to start any job
│   │   ├── 02-agent-entrypoint.md ← Master rules prompt (fill identity fields once)
│   │   ├── 00-start-job.md        ← Legacy / not scaffolded into new projects
│   │   └── 00-quick-run.md        ← Legacy / not scaffolded into new projects
│   ├── jobs/
│   │   └── inbox.md               ← Job inbox with marker-based write zone
│   ├── docs/
│   │   ├── 00_INDEX.md
│   │   └── implementation-log.md
│   └── PROJECT_BRIEF.template.md
│
├── tools/
│   └── sdd-init.sh              ← Project initializer CLI (v3.3.2)
│
├── handbook/                    ← Human-readable guides
├── audits/                      ← Audit reports (auto-generated, permanent)
└── README.md                    ← This file
```

---

## Project Bootstrap

Every project is created with `sdd-init.sh`. Projects are **always** placed inside `~/Desktop/projects/`.

```bash
bash /path/to/SDD-V3/v3/tools/sdd-init.sh \
  --project MyProjectName \
  --profile node-typescript-api
```

`--project` accepts a **name only** — not a path. The full path is resolved automatically:
`~/Desktop/projects/MyProjectName`

If the directory already exists the script exits safely (idempotency guard).

### What gets scaffolded

```
MyProjectName/
├── prompts/
│   ├── 00-run.md                ← Paste into Antigravity to run any job
│   └── 02-agent-entrypoint.md  ← Master rules prompt (fill in identity fields once)
├── jobs/
│   ├── inbox.md                 ← Paste tasks here
│   └── archive/                 ← Archived job prompts (AI-managed)
├── inputs/
│   └── README.md                ← Drop external reference files here (Brownfield)
├── docs/
│   ├── 00_INDEX.md
│   ├── implementation-log.md
│   ├── spec.md, architecture.md, api-contract.md, tickets.md, test-plan.md
│   ├── adr/
│   └── changes/                 ← Inputs scan evidence files
├── sdd.config.yml               ← Project config (loaded by AI on every session)
├── PROJECT_BRIEF.md
├── CHANGELOG.md
└── SECURITY.md
```

---

## How to Use With AI (Inbox-Driven Model)

SDD v3 uses a **pure inbox-driven execution model**. No terminal commands required after bootstrap.

### One-time setup (per project)

1. Run `sdd-init.sh` to bootstrap the project.
2. Open `prompts/02-agent-entrypoint.md` and fill in the 4 identity fields:
   - Project name
   - Profile
   - SDD v3 root path
   - Project root path

### Running a job

```
Step 1: Write your task in jobs/inbox.md below the marker:

         ### ⬇️ A PARTIR DE AQUÍ PEGA EL PROMPT ⬇️

Step 2: Paste this into Antigravity:

         Execute prompts/00-run.md
```

→ AI reads `prompts/00-run.md`  
→ AI reads and applies `prompts/02-agent-entrypoint.md` (rules, gates, archive protocol)  
→ AI reads the task from `jobs/inbox.md`  
→ AI executes → archives to `jobs/archive/` → resets inbox  

No scripts. No terminal. No file copying per session.

---

## Brownfield Projects (inputs/ Directory)

If you are working on an **existing codebase**, drop reference files into `inputs/` before the first job:

- Existing code dumps, API docs, legacy schemas, client requirements
- Files are **read-only for AI** — never modified by agents
- Non-empty `inputs/` triggers mandatory **PRE-JOB INPUTS SCAN** (STEP 0 in agent entrypoint)
- AI declares Greenfield or Brownfield and records scan evidence in `docs/changes/`
- Missing evidence with non-empty `inputs/` = **QG-2 ARCHITECTURE GATE BLOCK**

---

## Quality Gate System

| Gate | Name | Trigger | Key checks |
|------|------|---------|------------|
| **QG-1** | SPEC GATE | Before architecture | `spec.md` complete, Given/When/Then criteria, no ambiguous language |
| **QG-2** | ARCHITECTURE GATE | Before tickets | `architecture.md` + `api-contract.md` done; versioning declared; inputs scan evidence present |
| **QG-3** | BUILD GATE | Before PR review | CI green; `request_id` on all endpoints; error contract enforced; no raw logs |
| **QG-4** | E2E GATE | Before merge | E2E tests pass; BOLA verified; Standard Error Contract tested; PII log check |
| **QG-5** | RELEASE GATE | Before production | Traceability chain unbroken; BREAKING CHANGE → major semver; CHANGELOG updated |

Gates are **binary**: PASS or BLOCK. No partial passes. See `core/gates.md` for full criteria.

---

## Engineering Standards Summary

Defined in full in `core/engineering-standards.md`. Key mandates:

- **API Versioning** — URL versioning (`/v1/...`) by default; max 2 major versions simultaneously; breaking changes require major bump.
- **Standard Error Contract** — All error responses must match: `{error: {code, message, request_id, timestamp}}`.
- **Observability** — `request_id` propagated through all logs, response headers, and downstream calls. 5 minimum metrics.
- **Structured Logging** — JSON Lines; 6 required fields; no passwords, tokens, PAN, CVV or PII in logs.
- **BOLA Protection** — Ownership verified at service layer for every resource accessed by ID.
- **Idempotency** — `PUT`/`PATCH`/`DELETE` idempotent; `POST` uses `Idempotency-Key` on critical paths.

---

## Versioning Philosophy

SDD v3 uses **Semantic Versioning 2.0.0**:

| Change type | Bump |
|-------------|------|
| Bug fix or documentation correction | PATCH |
| New capability, backward-compatible | MINOR |
| Breaking change to existing contract | MAJOR |

`BREAKING CHANGE:` in a commit footer triggers a mandatory major tag — enforced at QG-5.

The framework itself follows these same conventions.

---

## Framework Changelog

| Version | Date | Summary |
|---------|------|---------|
| **3.0.0** | 2026-03-04 | Initial bootstrap. 8 core SSOT files, 5 profiles, 9 task-types, 9 agents, project templates, `sdd-init.sh` |
| **3.1.0** | 2026-03-04 | Core hardening: idempotency contract and BOLA protection in `engineering-standards.md` and `security-baseline.md`; QG-2/QG-4 gate criteria hardened |
| **3.2.0** | 2026-03-04 | Core expansion: API Versioning Contract (§9), Standard Error Contract (§10), Observability Baseline (§11), Structured Logging Contract (§12) added to `engineering-standards.md`; `security-baseline.md` §10 PII logging; gates hardened for QG-2/3/4/5 |
| **3.2.1** | 2026-03-04 | `sdd-init.sh` deterministic root: `--project` accepts name only; all projects created in `~/Desktop/projects/`; idempotency guard |
| **3.2.2** | 2026-03-04 | `inputs/` folder scaffolded in every project; PRE-JOB INPUTS SCAN added to agent entrypoint; `docs/changes/` and `jobs/archive/` dirs created; QG-2 inputs scan evidence gate; `docs-baseline.md §10` |
| **3.2.3** | 2026-03-04 | External runner removed; pure inbox-driven execution model; single visual marker in `inbox.md`; AI manages archive/clear; `workflow.md` updated with Job Execution Flow section |
| **3.2.4** | 2026-03-04 | `prompts/` directory scaffolded in every project; `prompts/00-start-job.md` (short trigger) and `prompts/02-agent-entrypoint.md` (master rules) added to bootstrap |
| **3.3.4** | 2026-03-04 | Audit file naming convention enforced (`YYYY-MM-DD_HHMM_<slug>.md`); all 10 existing audit files renamed; `docs-baseline.md §11` added; `02-agent-entrypoint.md` STEP 4 item 9 added |
| **3.3.3** | 2026-03-04 | Execution chain restored: `00-run.md` → `00-start-job.md` → `02-agent-entrypoint.md`; `00-start-job.md` re-added to scaffold with inbox-read + archive/clear logic |
| **3.3.2** | 2026-03-04 | `00-run.md` introduced as minimal 1-line launcher; `.sdd/` removed from scaffold; `00-quick-run.md` no longer copied to new projects |
| **3.3.1** | 2026-03-04 | Prompt deduplication: removed duplicate `.sdd/02-agent-entrypoint.md`; `00-quick-run.md` marked LEGACY |
| **3.3.0** | 2026-03-04 | README full realignment to reflect real framework state |

---

## Key Documents

| Document | Purpose |
|----------|---------|
| [`core/00_INDEX.md`](core/00_INDEX.md) | Master index of all core domains |
| [`core/workflow.md`](core/workflow.md) | 7-phase lifecycle, PRE-JOB scan, Job Execution Flow |
| [`core/gates.md`](core/gates.md) | QG-1 → QG-5 full pass/block criteria |
| [`core/engineering-standards.md`](core/engineering-standards.md) | API versioning, error contract, observability, logging |
| [`core/security-baseline.md`](core/security-baseline.md) | Auth, BOLA, PII redaction |
| [`core/traceability-baseline.md`](core/traceability-baseline.md) | Git contract, commit format, semver tagging |
| [`core/docs-baseline.md`](core/docs-baseline.md) | Required project docs, api-contract fields, inputs evidence |
| [`templates/project/prompts/00-start-job.md`](templates/project/prompts/00-start-job.md) | Short job trigger prompt (paste into AI) |
| [`templates/project/prompts/02-agent-entrypoint.md`](templates/project/prompts/02-agent-entrypoint.md) | Master agent rules prompt |
| [`tools/sdd-init.sh`](tools/sdd-init.sh) | Project initializer |
| [`audits/`](audits/) | Permanent audit trail of all framework changes |

---

## Audit Trail

> **Naming convention:** `YYYY-MM-DD_HHMM_<slug>.md` — newest first.

| Audit file | Covers |
|-----------|--------|
| [`2026-03-04_2026_audit-naming-convention.md`](audits/2026-03-04_2026_audit-naming-convention.md) | v3.3.4 audit naming convention |
| [`2026-03-04_2017_chain-restoration.md`](audits/2026-03-04_2017_chain-restoration.md) | v3.3.3 execution chain restoration |
| [`2026-03-04_1941_prompt-deduplication.md`](audits/2026-03-04_1941_prompt-deduplication.md) | v3.3.1 prompt deduplication |
| [`2026-03-04_1801_readme-realignment.md`](audits/2026-03-04_1801_readme-realignment.md) | v3.3.0 README realignment |
| [`2026-03-04_1757_prompts-scaffolding.md`](audits/2026-03-04_1757_prompts-scaffolding.md) | v3.2.4 prompts scaffold |
| [`2026-03-04_1733_inbox-model-simplification.md`](audits/2026-03-04_1733_inbox-model-simplification.md) | v3.2.3 inbox model |
| [`2026-03-04_1614_inputs-inbox-enforcement.md`](audits/2026-03-04_1614_inputs-inbox-enforcement.md) | v3.2.2 inputs scan |
| [`2026-03-04_1130_cli-root-enforcement.md`](audits/2026-03-04_1130_cli-root-enforcement.md) | v3.2.1 root enforcement |
| [`2026-03-04_1100_core-expansion-v3-2.md`](audits/2026-03-04_1100_core-expansion-v3-2.md) | v3.2.0 expansion |
| [`2026-03-04_1030_core-hardening.md`](audits/2026-03-04_1030_core-hardening.md) | v3.1.0 hardening pass |
| [`2026-03-04_1000_bootstrap-report.md`](audits/2026-03-04_1000_bootstrap-report.md) | v3.0.0 initial bootstrap |
