# Changelog

All notable changes to the SDD v3 framework will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.6.0] - 2026-03-05
### Added
- **Framework Change Protocol (Mandatory):** Requires `CHANGELOG.md` updates and `README.md` updates (if behavior/workflow changes) whenever the framework repo is modified.
- **Runtime Enforcement:** Binary PASS/STOP check for framework changes injected into `02-agent-entrypoint.md` (template + VTC-API-Node).

## [3.5.0] - 2026-03-05
### Added
- Mandatory Framework Consistency Inspection added to lifecycle.
- Commit scope rules for framework vs project repos codified in traceability baseline.

## [3.4.0] - 2026-03-05
### Added
- `core/agent-routing.md` SSOT added.
- Binary PASS/STOP routing enforcement injected into `02-agent-entrypoint.md` (template + existing projects) based on task category vs agent role.

## [3.3.4] - 2026-03-04
### Changed
- Audit file naming convention enforced (`YYYY-MM-DD_HHMM_<slug>.md`).
- All 10 existing audit files renamed.
- `docs-baseline.md §11` added.
- `02-agent-entrypoint.md` STEP 4 item 9 added.

## [3.3.3] - 2026-03-04
### Changed
- Execution chain restored: `00-run.md` → `00-start-job.md` → `02-agent-entrypoint.md`.
- `00-start-job.md` re-added to scaffold with inbox-read + archive/clear logic.

## [3.3.2] - 2026-03-04
### Changed
- `00-run.md` introduced as minimal 1-line launcher.
- `.sdd/` removed from scaffold.
- `00-quick-run.md` no longer copied to new projects.

## [3.3.1] - 2026-03-04
### Changed
- Prompt deduplication: removed duplicate `.sdd/02-agent-entrypoint.md`.
- `00-quick-run.md` marked LEGACY.

## [3.3.0] - 2026-03-04
### Changed
- README full realignment to reflect real framework state.

## [3.2.4] - 2026-03-04
### Added
- `prompts/` directory scaffolded in every project.
- `prompts/00-start-job.md` (short trigger) and `prompts/02-agent-entrypoint.md` (master rules) added to bootstrap.

## [3.2.3] - 2026-03-04
### Changed
- External runner removed; pure inbox-driven execution model.
- Single visual marker in `inbox.md`.
- AI manages archive/clear.
- `workflow.md` updated with Job Execution Flow section.

## [3.2.2] - 2026-03-04
### Added
- `inputs/` folder scaffolded in every project.
- PRE-JOB INPUTS SCAN added to agent entrypoint.
- `docs/changes/` and `jobs/archive/` dirs created.
- QG-2 inputs scan evidence gate.
- `docs-baseline.md §10`.

## [3.2.1] - 2026-03-04
### Changed
- `sdd-init.sh` deterministic root: `--project` accepts name only; all projects created in `~/Desktop/projects/`.
- Idempotency guard.

## [3.2.0] - 2026-03-04
### Added
- Core expansion: API Versioning Contract (§9), Standard Error Contract (§10), Observability Baseline (§11), Structured Logging Contract (§12) added to `engineering-standards.md`.
- `security-baseline.md` §10 PII logging.
- Gates hardened for QG-2/3/4/5.

## [3.1.0] - 2026-03-04
### Changed
- Core hardening: idempotency contract and BOLA protection in `engineering-standards.md` and `security-baseline.md`; QG-2/QG-4 gate criteria hardened.

## [3.0.0] - 2026-03-04
### Added
- Initial bootstrap. 8 core SSOT files, 5 profiles, 9 task-types, 9 agents, project templates, `sdd-init.sh`.
