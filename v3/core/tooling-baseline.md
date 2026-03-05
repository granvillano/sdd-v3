# core/tooling-baseline.md — SDD v3 Developer Tooling Baseline

> **SSOT Domain:** Code Quality / Developer Tooling | **Inherits:** engineering-standards.md  
> **Version:** 3.3.5

---

## Purpose

This document defines the mandatory developer tooling that all SDD v3 projects must configure. Tooling automates enforcement of rules defined in `core/engineering-standards.md`. Profiles may extend the baseline with stack-specific tools; they may **not** omit or weaken it.

---

## 1. Linting

### 1.1 Rule

Every project MUST have a linter configured and executed in CI. Linting failures MUST block the build (QG-3 BUILD GATE).

### 1.2 Requirements

| Requirement | Detail |
|------------|--------|
| No `console.log` in production paths | `no-console: error` (or equivalent) |
| No unused variables | `no-unused-vars: error` (or equivalent) |
| No `any` type (TypeScript) | `@typescript-eslint/no-explicit-any: error` |
| Lint runs in CI | `eslint src/` in build pipeline |
| Lint runs pre-commit | Via `lint-staged` (see §4) |

### 1.3 Zero-tolerance rules

These produce an **error** (not a warning) and block commit and CI:

```
no-console
no-unused-vars
no-implicit-any (TS)
no-undef
eqeqeq
```

---

## 2. Code Formatting

### 2.1 Rule

Every project MUST have an automated formatter. Formatting disagreements are not discussed in code review — the formatter is always right.

### 2.2 Requirements

| Requirement | Detail |
|------------|--------|
| Formatter configured | `prettier.config.js` or equivalent |
| Format runs pre-commit | Via `lint-staged` |
| CI checks format | `prettier --check src/` or equivalent |
| Editor config present | `.editorconfig` for cross-IDE consistency |

### 2.3 Required `prettier.config.js`

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

---

## 3. Commit Message Enforcement

### 3.1 Rule

Every repository MUST enforce the **Conventional Commits** specification via a `commit-msg` git hook. Non-conforming commits MUST be rejected at the local commit stage.

### 3.2 Conventional Commits format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Allowed types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Special footer keywords:**
- `BREAKING CHANGE:` → triggers major version bump at QG-5
- `Closes #123` → links commit to ticket

### 3.3 Required `commitlint.config.js`

```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert'
    ]],
    'subject-case': [2, 'never', ['upper-case', 'pascal-case', 'start-case']],
    'subject-max-length': [2, 'always', 100],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never'],
  },
};
```

---

## 4. Git Hooks (Husky + lint-staged)

### 4.1 Rule

Every project MUST configure Husky git hooks to automate pre-commit and commit-msg checks. Hooks run automatically on every commit with no manual step required.

### 4.2 Required hooks

| Hook | File | Action |
|------|------|--------|
| `pre-commit` | `.husky/pre-commit` | Runs `lint-staged` |
| `commit-msg` | `.husky/commit-msg` | Runs `commitlint` |

### 4.3 Required `.husky/pre-commit`

```sh
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx lint-staged
```

### 4.4 Required `.husky/commit-msg`

```sh
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx --no-install commitlint --edit "$1"
```

### 4.5 Required `lint-staged` config (in `package.json`)

```json
{
  "lint-staged": {
    "src/**/*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "src/**/*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

---

## 5. Tooling Installation

### 5.1 Required dev dependencies

Every project MUST include these in `devDependencies`:

```json
{
  "devDependencies": {
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0",
    "eslint": "^9.0.0",
    "prettier": "^3.0.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.0.0"
  }
}
```

### 5.2 Required `package.json` scripts

```json
{
  "scripts": {
    "prepare": "husky",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "format": "prettier --write src/",
    "format:check": "prettier --check src/"
  }
}
```

### 5.3 Initialization command (for new projects)

```bash
npm install
npx husky init
echo "npx lint-staged" > .husky/pre-commit
echo "npx --no-install commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/pre-commit .husky/commit-msg
```

---

## 6. CI Integration

All tooling checks MUST run in CI in addition to pre-commit hooks. **Hooks alone are insufficient** — they can be bypassed with `--no-verify`.

### Required CI steps

```yaml
- name: Lint
  run: npm run lint

- name: Format check
  run: npm run format:check

- name: Type check (TypeScript)
  run: npx tsc --noEmit

- name: Test
  run: npx jest --coverage
```

---

## 7. QG Enforcement

| Gate | Tooling check |
|------|--------------|
| **QG-3 BUILD GATE** | ESLint passes (0 errors), Prettier check passes, tsc passes, all tests pass |
| **QG-5 RELEASE GATE** | Commit history validated — all commits follow Conventional Commits; `BREAKING CHANGE` footer present if API contract broken |

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-03-05 | 3.3.5 | Initial creation — Linting, Formatting, Commitlint, Husky, lint-staged baseline |
