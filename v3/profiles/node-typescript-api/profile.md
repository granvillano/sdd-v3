# Profile: node-typescript-api

> **Profile ID:** `node-typescript-api`  
> **Inherits:** `core/*` (all core SSOT rules apply), `core/tooling-baseline.md`  
> **Version:** 3.3.5

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5+ / Node.js 20 LTS |
| Framework | Express.js or Fastify |
| Database | PostgreSQL / MySQL via Prisma or TypeORM |
| Testing | Jest + Supertest |
| Linting | ESLint (TypeScript Airbnb config) — see `core/tooling-baseline.md §1` |
| Formatting | Prettier — see `core/tooling-baseline.md §2` |
| Commit enforcement | commitlint + Husky — see `core/tooling-baseline.md §3-4` |
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

## Mandatory Tooling Config Files

Every new project created with this profile MUST include the following files. These are not optional.

### `eslint.config.js`

```js
import js from '@eslint/js';
import tsPlugin from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.ts'],
    languageOptions: {
      parser: tsParser,
      parserOptions: { project: './tsconfig.json' },
    },
    plugins: { '@typescript-eslint': tsPlugin },
    rules: {
      // Zero-tolerance — block commit and CI
      'no-console': 'error',
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',
      'eqeqeq': ['error', 'always'],

      // Enforced
      '@typescript-eslint/explicit-function-return-type': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
  {
    // Test files — relax some rules
    files: ['tests/**/*.ts'],
    rules: { 'no-console': 'off' },
  },
];
```

### `prettier.config.js`

```js
module.exports = {
  semi: true,
  singleQuote: true,
  trailingComma: 'all',
  printWidth: 100,
  tabWidth: 2,
  arrowParens: 'always',
};
```

### `commitlint.config.js`

```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert',
    ]],
    'subject-case': [2, 'never', ['upper-case', 'pascal-case', 'start-case']],
    'subject-max-length': [2, 'always', 100],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never'],
  },
};
```

### `.husky/pre-commit`

```sh
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx lint-staged
```

### `.husky/commit-msg`

```sh
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx --no-install commitlint --edit "$1"
```

---

## Required `package.json` Additions

```json
{
  "scripts": {
    "prepare": "husky",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "format": "prettier --write src/",
    "format:check": "prettier --check src/"
  },
  "lint-staged": {
    "src/**/*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "src/**/*.{json,md}": ["prettier --write"]
  },
  "devDependencies": {
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0",
    "@typescript-eslint/eslint-plugin": "^7.0.0",
    "@typescript-eslint/parser": "^7.0.0",
    "eslint": "^9.0.0",
    "prettier": "^3.0.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0"
  }
}
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

## CI Configuration (extends core/tooling-baseline.md §6)

```yaml
- name: Type Check
  run: npx tsc --noEmit

- name: Lint
  run: npm run lint

- name: Format Check
  run: npm run format:check

- name: Test (with coverage)
  run: npx jest --coverage
```

---

## QG-3 BUILD GATE additions (this profile)

In addition to core QG-3 criteria:
- [ ] `npm run lint` exits 0 — no ESLint errors
- [ ] `npm run format:check` exits 0 — Prettier clean
- [ ] `npx tsc --noEmit` exits 0 — TypeScript strict mode passes
- [ ] No `@ts-ignore` or `@ts-expect-error` without a linked ticket comment

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-05 | 3.3.5 | Added mandatory tooling: eslint.config.js, prettier.config.js, commitlint.config.js, Husky hooks, lint-staged; added package.json additions; added QG-3 BUILD GATE additions |
| 2026-03-04 | 3.0.0 | Initial profile bootstrap |
