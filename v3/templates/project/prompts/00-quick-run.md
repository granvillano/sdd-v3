# 00-quick-run.md — SDD v3 Quick-Run Prompt (LEGACY)

> ⚠️ **LEGACY PROMPT — Not the canonical job launcher for SDD v3.2+**  
> This file is kept for backwards compatibility only.  
> **For new projects:** use `prompts/00-start-job.md` instead.

---

## What this is

`00-quick-run.md` was the original SDD v3.0.0 onboarding prompt. It requires the human to fill in bracketed placeholders and describe the task inline. It was superseded in v3.2.3 by the **inbox-driven model** (`prompts/00-start-job.md` + `jobs/inbox.md`).

This file lives in `.sdd/` (the internal framework directory) and is **not referenced by any current workflow**.

## When to use

- If you need a one-off AI session without writing to `jobs/inbox.md`.
- If you are on SDD v3.0.0 or v3.1.0 and have not migrated to the inbox model.

## Canonical workflow (v3.2.3+)

1. Paste task in `jobs/inbox.md` below the marker.
2. Paste `prompts/00-start-job.md` into Antigravity.
3. AI handles everything.

---

## Prompt (fill in brackets, then paste)

```
You are operating as an SDD v3 AI development assistant on the [PROJECT NAME] project.

## Framework Context
- SDD v3 Framework location: [PATH TO SDD-V3/v3]
- Project location: [PATH TO PROJECT ROOT]
- Active profile: [PROFILE-ID]  (e.g., php-wordpress-api, node-typescript-api)

## Load Order (mandatory)
1. Read: SDD-V3/v3/core/00_INDEX.md
2. Read: SDD-V3/v3/core/workflow.md
3. Read: SDD-V3/v3/core/gates.md
4. Read: SDD-V3/v3/core/definition-of-done.md
5. Read: SDD-V3/v3/core/engineering-standards.md
6. Read: SDD-V3/v3/core/security-baseline.md
7. Read: SDD-V3/v3/profiles/[PROFILE-ID]/profile.md
8. Read: [PROJECT ROOT]/sdd.config.yml
9. Read: [PROJECT ROOT]/docs/spec.md
10. Read: [PROJECT ROOT]/docs/implementation-log.md

## Current Task
[Describe what you need done. Reference ticket IDs and spec sections.]

## Constraints
- Never deviate from the spec without explicit approval.
- Never bypass quality gates.
- Always commit using Conventional Commits format.
- Always update implementation-log.md after completing work.
```
