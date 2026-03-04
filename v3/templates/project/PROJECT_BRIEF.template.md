# PROJECT_BRIEF.template.md — SDD v3 Project Brief

> **Template:** `templates/project/PROJECT_BRIEF.template.md`  
> **Usage:** Copy this file to the project root as `PROJECT_BRIEF.md` and complete all sections.  
> **This is the #2 document to paste to an AI assistant** (after the entrypoint prompt).  
> Fill in all `[BRACKETED]` fields. Remove template instructions before using.

---

# [PROJECT NAME] — Project Brief

**Date:** [YYYY-MM-DD]  
**Version:** 1.0  
**SDD Profile:** [php-wordpress-api | node-typescript-api | python-fastapi-api | react-webapp | react-native-app]  
**Status:** [Draft | Active | Frozen]

---

## 1. Project Overview

### What are we building?
[One paragraph describing the product. What is it? Who uses it?]

### Problem Statement
[What specific problem does this solve? Why does it need to exist?]

### Success Criteria
[How will we know the project is successful? List 3-5 measurable outcomes.]

1. [Criterion 1]
2. [Criterion 2]
3. [Criterion 3]

---

## 2. Users & Stakeholders

| Role | Description | Needs |
|------|-------------|-------|
| [User Type 1] | [Who they are] | [What they need from the product] |
| [User Type 2] | [Who they are] | [What they need from the product] |

---

## 3. Scope

### In Scope (v1)
- [Feature / capability 1]
- [Feature / capability 2]
- [Feature / capability 3]

### Out of Scope (Future)
- [What will NOT be built in v1]
- [Deferred features]

---

## 4. Technical Context

### Stack
- **Profile:** [Profile ID from sdd.config.yml]
- **Runtime:** [e.g., PHP 8.2, Node 20, Python 3.11]
- **Database:** [e.g., MySQL, PostgreSQL]
- **Hosting:** [e.g., AWS, VPS, Vercel]

### External Integrations
| Service | Purpose | Auth Method |
|---------|---------|------------|
| [Service] | [Why] | [API Key / OAuth2 / etc] |

---

## 5. Non-Functional Requirements

| Category | Requirement | Target |
|----------|-------------|--------|
| Performance | Response time | < 200 ms p95 |
| Availability | Uptime | 99.5% |
| Security | Auth | [JWT / Session / etc] |
| Compliance | [GDPR / PCI / etc] | [Scope] |

---

## 6. Constraints & Assumptions

### Constraints
- [Budget, timeline, or technical constraint]
- [Platform or compatibility requirement]

### Assumptions
- [Thing we are assuming is true that, if wrong, changes scope]

---

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Risk description] | High/Med/Low | High/Med/Low | [How we address it] |

---

## 8. SDD Framework Config

**sdd.config.yml location:** `[PROJECT ROOT]/sdd.config.yml`  
**SDD v3 root:** `[ABSOLUTE PATH TO SDD-V3/v3]`  
**Active phase:** Phase [1-7]  
**Last gate passed:** [QG-0 (none) | QG-1 | QG-2 | QG-3 | QG-4 | QG-5]
