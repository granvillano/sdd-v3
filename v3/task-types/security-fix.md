# Task Type: security-fix

> **Task Type ID:** `security-fix`  
> **Inherits:** `core/definition-of-done.md`, `core/security-baseline.md`  
> **Version:** 3.0.0

## Definition

A `security-fix` task addresses a confirmed or suspected security vulnerability.

## Rules

- Security fixes are HIGH PRIORITY and may bypass normal queue ordering.
- Fix must be reviewed by a second person (never self-approved).
- Affected versions must be documented for potential CVE disclosure.

## Additional DoD Criteria

- [ ] CVE/vulnerability documented with CVSS score if applicable.
- [ ] Full OWASP Top 10 category identified for this vulnerability.
- [ ] SAST and secret-scan clean after fix.
- [ ] Penetration test or manual security verification performed.
- [ ] `SECURITY.md` or security changelog updated.
- [ ] If publicly exploitable: responsible disclosure process initiated.

## Branch Pattern
```
security/<TICKET-ID>-<description>
```

## Commit Prefix
```
security(<scope>): <description> [<TICKET-ID>]
```

> ⚠️ Security PRs may be kept in draft mode until ready for a coordinated release.
