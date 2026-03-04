# implementation-log.md — [PROJECT NAME]

> **Purpose:** Running log of all deployments, significant changes, and incidents.  
> **Format:** SDD v3 docs-baseline.md §3  
> **Owner:** `devops_agent`, `docs_agent`

---

## Log Format

```markdown
## [YYYY-MM-DD] — v[X.Y.Z] — [Environment: dev/staging/production]

| Field | Value |
|-------|-------|
| Author | [Name / Agent] |
| Tickets | PROJ-42, PROJ-43 |
| Description | [Brief summary] |
| Rollback | [Steps or "automated rollback available"] |
| Status | ✅ Success / ❌ Failed / ⚠️ Partial |
```

---

## Entries

<!-- Add new entries at the TOP of this section, most recent first -->

## [YYYY-MM-DD] — v0.0.0 — bootstrap

| Field | Value |
|-------|-------|
| Author | sdd-init.sh |
| Tickets | — |
| Description | Project bootstrapped from SDD v3 templates |
| Rollback | N/A |
| Status | ✅ Success |
