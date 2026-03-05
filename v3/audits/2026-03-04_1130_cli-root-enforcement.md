# CLI_ROOT_ENFORCEMENT_PATCH.md — SDD v3.2.1 Patch Note

> **Generated:** 2026-03-04  
> **Patch:** v3.2.0 → v3.2.1  
> **Type:** PATCH — CLI behavior change (no core rule changes)  
> **File modified:** `tools/sdd-init.sh`

---

## Summary

Enforced deterministic project root for `sdd-init.sh`. All projects are now created strictly inside `~/Desktop/projects/<project-name>`. The `--project` flag no longer accepts paths.

---

## Behavior Changes

### Before (v3.2.0)
```bash
# --project accepted any path
bash sdd-init.sh --project ~/arbitrary/path/my-project --profile node-typescript-api
```
- The user controlled where projects were created.
- No validation on the value of `--project`.
- No guarantee of co-location between projects.

### After (v3.2.1)
```bash
# --project accepts a name only
bash sdd-init.sh --project VTC-API-Node --profile node-typescript-api
# → creates ~/Desktop/projects/VTC-API-Node
```
- `--project` only accepts a simple project name (no `/`, no `~`, no spaces).
- Full path is **always** resolved as `$HOME/Desktop/projects/<project-name>`.
- Input validation fails immediately with a clear, actionable error message.

---

## New Validation Rules

| Condition | Result |
|-----------|--------|
| `--project` value starts with `/` | `ERROR: --project must be a project name only` → exit 1 |
| `--project` value starts with `~` | `ERROR: --project must be a project name only` → exit 1 |
| `--project` value contains `/` | `ERROR: --project must be a project name only` → exit 1 |
| `--project` value contains spaces | `ERROR: --project must be a project name only` → exit 1 |
| Project folder already exists | `ERROR: Project directory already exists` → exit 1 (idempotency guard) |

---

## Idempotency Guard

The script now refuses to initialize a project if the target directory already exists.  
**Rationale:** `sdd-init` is a one-shot bootstrapper, not an updater. Overwriting an existing project would destroy developer work.

To re-initialize a project, the user must explicitly remove or rename the existing directory.

---

## sdd.config.yml Changes

The generated `sdd.config.yml` now includes two additional fields:

```yaml
sdd_version: "3.2.1"     # was "3.0.0" — now reflects actual initializer version
project_slug: "my-project"  # NEW — the raw --project arg (useful for scripting)
project_root: "/Users/..." # NEW — absolute resolved path (aids agent context loading)
```

---

## Help Text & Examples Updated

All usage examples in `sdd-init.sh` updated:
- Old: `bash sdd-init.sh --project ~/projects/my-api --profile ...`
- New: `bash sdd-init.sh --project my-api --profile ...`

Invalid usage examples added to `--help` output so the error is self-documenting.

---

## Files NOT Modified

| Scope | Status |
|-------|--------|
| `core/*` | ✅ Untouched |
| `profiles/*` | ✅ Untouched |
| `agents/*` | ✅ Untouched |
| `templates/*` | ✅ Untouched |
| `task-types/*` | ✅ Untouched |

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-04 | 3.2.1 | Enforced deterministic project root at `~/Desktop/projects`; project-name-only validation; idempotency guard; sdd.config.yml version bump |
| 2026-03-04 | 3.2.0 | API versioning, error format, observability, structured logging (core expansion) |
| 2026-03-04 | 3.1.0 | Idempotency rules, BOLA protection, gate hardening (core hardening) |
| 2026-03-04 | 3.0.0 | Initial bootstrap |
