# core/traceability-baseline.md — SDD v3 Traceability Baseline

> **SSOT Domain:** Traceability | **Inherits:** none  
> **Reference:** Conventional Commits v1.0.0, Semantic Versioning 2.0.0

---

## Purpose

Every change in an SDD v3 project must be traceable from its origin (spec requirement) to its production deployment. This document defines the **Git contract** that enforces this traceability.

---

## 1. Traceability Chain

The complete chain that MUST exist for every shipped feature:

```
Spec Requirement (spec.md §X.Y)
    ↓
Ticket ID (e.g., PROJ-42)
    ↓
Branch Name (feat/PROJ-42-short-description)
    ↓
Commit(s) (feat(scope): message [PROJ-42])
    ↓
Pull Request (links to ticket + spec section + Change Impact sections)
    ↓
Merge to main
    ↓
Release Tag (semver — major bump required if BREAKING CHANGE present)
    ↓
CHANGELOG entry (with Observability / Error Contract / Versioning impact)
    ↓
implementation-log.md deploy record
```

If any link in this chain is missing, the RELEASE GATE (QG-5) is blocked.

---

## 2. Branch Naming Contract

```
<type>/<TICKET-ID>-<short-description-kebab-case>
```

### Types
| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behavior change) |
| `security` | Security fix |
| `perf` | Performance improvement |
| `chore` | Maintenance (deps, CI, config) |
| `docs` | Documentation only |
| `release` | Release preparation branch |

### Examples
```
feat/PROJ-42-user-authentication
fix/PROJ-99-null-pointer-in-payment
security/PROJ-110-sanitize-file-upload
chore/PROJ-77-upgrade-node-to-20
```

### Rules
- Branch names are lowercase kebab-case.
- Branch names MUST include the ticket ID.
- No `master` — use `main`. No `dev` without a ticket — use feature branches.
- Long-running branches (release, hotfix) are the only exceptions and require team sign-off.

---

## 3. Commit Message Contract

All commits MUST follow **Conventional Commits v1.0.0**:

```
<type>(<scope>): <description> [<TICKET-ID>]

[optional body]

[optional footer: BREAKING CHANGE: description]
```

### Type Values
Same as branch types: `feat`, `fix`, `refactor`, `security`, `perf`, `chore`, `docs`, `test`, `ci`.

### Examples
```
feat(auth): add JWT refresh token endpoint [PROJ-42]
fix(payment): handle null card expiry date [PROJ-99]
security(upload): restrict file types to allow-list [PROJ-110]
docs(api): update OpenAPI spec for /users endpoint [PROJ-55]
refactor(user): extract UserService from UserController [PROJ-71]
```

### Rules
- Description in lowercase, imperative mood, no period at end.
- Scope is the module/component name.
- Ticket ID in square brackets at end of subject line.
- **`BREAKING CHANGE:` in the commit footer is MANDATORY** for any change that matches the breaking change criteria in `core/engineering-standards.md §9.3`. This footer directly triggers a major version bump and blocks a minor/patch release tag.

---

## 3.1 Diff Verification Rule (Mandatory)

Before creating any commit, the staged diff MUST be inspected.

This verification ensures that:
- Only files related to the current ticket are included.
- No unrelated documentation, configuration, or dependency changes are mixed.
- The commit remains atomic and traceable.

The required workflow is:

1. Stage only the files related to the ticket.
2. Inspect the staged diff.

```bash
git diff --cached
```

---

## 4. Pull Request Contract

Every PR MUST include:

```markdown
## Summary
[Brief description of what this PR does]

## Spec Reference
- Spec section: spec.md §X.Y
- Ticket: PROJ-42

## Changes Made
- [Bullet list of significant changes]

## Testing
- [ ] Unit tests pass
- [ ] E2E tests pass
- [ ] QG-3 BUILD GATE: CI green

## Change Impact
### Observability Impact
[What changed in logs/metrics/tracing, or "N/A"]

### Error Contract Impact
[New/changed error codes or format, or "N/A"]

### Versioning Impact
[Breaking changes, new versions, deprecations, or "N/A"]

## Checklist
- [ ] DoD complete (core/definition-of-done.md)
- [ ] No secrets committed
- [ ] Documentation updated
- [ ] api-contract.md updated (if API changed)
- [ ] BREAKING CHANGE footer in commit if applicable
```

### Rules
- PRs must not mix multiple ticket IDs (one ticket = one PR, ideally).
- Draft PRs are allowed but must not be reviewed until CI is green.
- Squash merge preferred for feature branches (clean history).
- Merge commit required for release branches.
- The **Change Impact** section is mandatory from v3.2.0 — PRs without it are blocked from review.

---

## 5. Release Tagging Contract

```
v<MAJOR>.<MINOR>.<PATCH>
```

Following **Semantic Versioning 2.0.0**:

| Type | Version bump |
|------|-------------|
| Bug fix | PATCH (v1.0.1) |
| New feature (backward-compatible) | MINOR (v1.1.0) |
| Breaking change | MAJOR (v2.0.0) |

### Breaking Change → Major Bump (Mandatory)

From v3.2.0, the following is a hard rule:

> **If any commit in the release range contains a `BREAKING CHANGE:` footer, the release tag MUST be a major version bump.** Creating a minor or patch tag when a breaking change exists is a RELEASE GATE (QG-5) violation.

The `traceability_agent` MUST scan all commit messages in the release range for `BREAKING CHANGE:` footers before approving the tag.

### Pre-release Tags
```
v1.2.0-rc.1    ← release candidate
v1.2.0-beta.1  ← beta
```

### Tag Command
```bash
git tag -a v2.0.0 -m "Release v2.0.0: [brief summary, list breaking changes]"
git push origin v2.0.0
```

### Release Notes Required Sections

Every release tag MUST be accompanied by release notes (in GitHub Releases, CHANGELOG.md, or equivalent) that include:

```markdown
## v[X.Y.Z] — [Date]

### Breaking Changes (if any — must be present for major bumps)
- [Description of breaking change + migration guide or link]

### New Features
- [Feature description] [TICKET-ID]

### Bug Fixes
- [Bug fix description] [TICKET-ID]

### Security
- [Security fix description] [TICKET-ID]

### Observability Changes
- [Changes to logging, metrics, or tracing] [TICKET-ID]

### API Deprecations
- [Deprecated endpoints or versions with sunset dates]
```

---

## 6. Traceability Verification (QG-5)

Before tagging a release, the `traceability_agent` MUST verify:
1. Every merged PR in this release links to a ticket.
2. Every ticket links to a spec requirement.
3. No commits without ticket IDs exist in the release range.
4. `CHANGELOG.md` has an entry for this version with linked ticket IDs.
5. `implementation-log.md` has a deploy record.
6. **[v3.2]** All commits with `BREAKING CHANGE:` footer are covered by a major version bump in the tag.
7. **[v3.2]** All PRs include the three Change Impact subsections (Observability, Error Contract, Versioning).
8. **[v3.2]** Any deprecated endpoint with a `Sunset` date within the next 14 days is called out in the release notes.

---

## 7. Commit Scope Rules (Framework vs Projects)

To prevent accidental cross-repository contamination, the following hard rule applies:

- **When operating inside the SDD framework repository (`SDD-V3`):** All Git commits MUST target the framework repository exclusively. 
- **Arbitrary Project Repos:** You MUST NOT commit to external project repositories (e.g. `~/Desktop/projects/*`) unless the job explicitly targets them AND that repo is strictly in scope for the task. 

Cross-repo commits in a single session mask the traceability chain. Stay within the operational boundary defined by the job.

## 8. Target Detection + Auto-Git Protocol

To ensure framework changes are strictly documented and isolated, every agent MUST apply the following deterministic rules when saving work:

**Detection Rules:**
- **FrameworkChanged:** `true` IF any modified file path begins with `v3/core`, `v3/tools`, `v3/templates`, `v3/agents`, `v3/profiles`, `v3/task-types`, `v3/prompts`, or touches `v3/README.md`, `v3/CHANGELOG.md`, `v3/audits`.
- **ProjectChanged:** `true` IF any modified file path falls under `[PROJECT_ROOT]` (Note: this protocol does not apply to projects, only the framework).

**Auto-Git Protocol (If FrameworkChanged == true):**
The agent MUST autonomously execute the following BEFORE finishing the job:
1. Update `v3/CHANGELOG.md` with an entry for the change (Mandatory).
2. Update `v3/README.md` IF runtime behavior, workflow, or rules changed.
3. Create `v3/audits/YYYY-MM-DD_HHMM_<slug>.md` (Mandatory).
4. Create precisely **1 Conventional Commit** in the framework repository `SDD-V3/v3/`. 
   - Format: `<type>(<scope>): <summary>`
   - The commit body MUST include the filename of the generated audit note.
5. Push the commit if a remote exists; otherwise, print instructions for the user to push.

---

## 9. Version SSOT Constraint

Framework version is defined ONLY in `README.md` and `CHANGELOG.md`.  
No `core/*.md` document may declare its own version or changelog.

