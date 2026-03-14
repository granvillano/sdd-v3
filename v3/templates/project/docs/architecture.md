# docs/architecture.md — System Architecture

> **Version:** 1.0  
> **Status:** Draft

---

## 1. Repository Structure

| Directory | Purpose |
|-----------|---------|
| `src/` | Application source code (logic, components, services). |
| `docs/` | **SSOT Documentation**. Master specs, architecture, and contracts. |
| `jobs/` | Task inbox and historical archive of completed jobs. |
| `prompts/` | Operational AI prompts (entrypoint, start-job, etc.). |
| `scripts/` | Project operational tooling and automation scripts. |
| `inputs/` | External reference materials (read-only for AI). |
| `tests/` | Test suites (unit, integration, e2e). |

---

## 2. Global Design

[Describe the high-level architecture: Monolith vs Microservices, Layered, Hexagonal, etc.]

## 3. Technology Stack

- **Runtime:** [e.g. Node 20 / PHP 8.2]
- **Framework:** [e.g. Express / Fastify / WordPress]
- **Database:** [e.g. PostgreSQL / MySQL]

## 4. Key Components

### 4.1 Component A
[Description]

### 4.2 Component B
[Description]

## 5. Data Flow

[Describe how data moves through the system]

## 6. Deployment Architecture

[Describe infrastructure, CI/CD, and environment strategy]
