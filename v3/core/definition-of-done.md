# core/definition-of-done.md — SDD v3 Definition of Done

> **SSOT Domain:** Acceptance Criteria | **Inherits:** none  
> **Version:** 3.5.0

This checklist applies to **every task** regardless of type, profile or agent.  
Task-types may add additional criteria but may never remove items from this list.

---

## DoD Checklist

### 1. Specification Alignment
- [ ] The implementation matches the acceptance criteria in the linked ticket.
- [ ] Any deviation from the spec is documented with an approved ADR.
- [ ] No feature was built that is not in the current spec (no scope creep).

### 2. Code Quality
- [ ] Code passes all configured linters with zero warnings.
- [ ] No commented-out code, `console.log`, `dd()`, `var_dump()`, or debug stubs left in production paths.
- [ ] Naming conventions follow `core/engineering-standards.md` and the project profile.
- [ ] Functions/methods are short, focused, and do one thing (Single Responsibility).
- [ ] No magic numbers or strings — all constants are named and explained.
- [ ] No duplication — common logic is extracted (DRY principle).

### 3. Testing
- [ ] All unit tests pass (`npm test`, `phpunit`, `pytest`, or equivalent).
- [ ] New code has ≥ 80% test coverage.
- [ ] Happy path and at least 2 edge cases/error cases are tested.
- [ ] E2E test written for user-facing flows (see `core/workflow.md` Phase 6).

### 4. Security
- [ ] No secrets, passwords, or tokens hardcoded.
- [ ] All inputs are validated and sanitized.
- [ ] Authentication and authorization enforced on all protected routes/actions.
- [ ] OWASP Top 10 checklist reviewed for this change (see `core/security-baseline.md`).

### 5. Documentation
- [ ] `implementation-log.md` updated with a summary of changes made.
- [ ] Public API changes reflected in `api-contract.md` or Swagger spec.
- [ ] README updated if new environment variables or dependencies were added.
- [ ] ADR created for any significant architectural decision.

### 6. Traceability
- [ ] Branch name matches ticket ID pattern (see `core/traceability-baseline.md`).
- [ ] All commits follow Conventional Commits format.
- [ ] PR description links to ticket ID and spec requirement.
- [ ] `CHANGELOG.md` updated for user-visible changes.

### 7. Quality Gates
- [ ] **QG-3 BUILD GATE:** CI is green before requesting PR review.
- [ ] **QG-4 E2E GATE:** All E2E tests pass before merging.
- [ ] PR has at least 1 reviewer approval (human or designated agent).
- [ ] Product owner confirmed the implementation matches the business goal.

### 8. Framework Modifications (SDD Maintainers Only)
- [ ] If touching `core/`, `prompts/`, `templates/`, `profiles/`, or `tools/`: The **Framework Consistency Inspection** (see `core/workflow.md`) MUST be completed.
- [ ] Appropriate framework version bump applied and changelog updated.
- [ ] Explicit audit note created in `audits/` via standard naming convention.

---

## DoD for Specific Task Types

Task-type files in `task-types/` may extend this DoD with additional domain-specific requirements.  
See:
- `task-types/security-fix.md` — extra OWASP verification steps
- `task-types/release.md` — additional release gate criteria
- `task-types/migration.md` — rollback and data integrity requirements
