# Profile: node-typescript-api

> **Profile ID:** `node-typescript-api`  
> **Inherits:** `core/*` (all core SSOT rules apply)  
> **Version:** 3.0.0

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5+ / Node.js 20 LTS |
| Framework | Express.js or Fastify |
| Database | PostgreSQL / MySQL via Prisma or TypeORM |
| Testing | Jest + Supertest |
| Linting | ESLint (Airbnb config) + Prettier |
| Dependency Manager | npm / pnpm |
| CI | GitHub Actions |

---

## Coding Standards

- Strict TypeScript: `"strict": true` in `tsconfig.json`.
- No `any` type — use `unknown` and narrow explicitly.
- Interfaces over `type` for object shapes (extensible).
- Module resolution: `ESM` preferred.
- All async code uses `async/await` — no raw Promises or callbacks.
- Error handling via typed error classes extending `Error`.
- Environment variables typed and validated at startup (e.g., via `zod` schema).

---

## Directory Structure (Canonical)

```
src/
├── app.ts               ← App factory (no listen here)
├── server.ts            ← Entry point (binds port)
├── routes/              ← Express Router definitions
├── controllers/         ← Request handlers (thin, delegate to services)
├── services/            ← Business logic
├── repositories/        ← Data access (Prisma/TypeORM calls)
├── models/              ← TypeScript interfaces / DTOs
├── middleware/          ← Auth, error-handler, rate-limiter
├── config/              ← Env validation, constants
└── utils/               ← Pure utility functions
tests/
├── unit/
└── integration/
```

---

## Security Additions (extends core/security-baseline.md)

- [ ] Helmet.js configured for HTTP security headers.
- [ ] CORS policy explicitly configured — no wildcard `*` in production.
- [ ] Rate limiting via `express-rate-limit` on all public routes.
- [ ] Input validation via `zod` or `joi` on all request bodies.
- [ ] JWT validated on every protected route via middleware.
- [ ] SQL injection impossible: all queries via ORM with parameterized inputs.

---

## CI Configuration

```yaml
- name: Type Check
  run: npx tsc --noEmit

- name: Lint
  run: npx eslint src/

- name: Test
  run: npx jest --coverage
```
