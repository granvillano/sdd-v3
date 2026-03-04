# Profile: react-webapp

> **Profile ID:** `react-webapp`  
> **Inherits:** `core/*` (all core SSOT rules apply)  
> **Version:** 3.0.0

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5+ |
| Framework | React 18+ (Vite or Next.js) |
| State Management | Zustand / React Query / Redux Toolkit |
| Styling | CSS Modules or Tailwind CSS |
| Testing | Vitest + React Testing Library + Playwright (E2E) |
| Linting | ESLint + Prettier |
| Build Tool | Vite or Next.js |
| CI | GitHub Actions |

---

## Coding Standards

- Functional components only — no class components.
- Custom hooks for all reusable stateful logic.
- No business logic in components — components handle only UI + event delegation.
- All side effects in `useEffect` documented with cleanup.
- Props typed with explicit TypeScript interfaces (not `any`).
- No inline styles — use CSS modules or utility classes.
- Accessibility: all interactive elements have `aria-label` or visible text.

---

## Directory Structure (Canonical)

```
src/
├── main.tsx             ← Entry point
├── App.tsx              ← Root component + routing
├── pages/               ← Route-level components (one per page)
├── components/
│   ├── ui/              ← Generic, dumb, reusable UI components
│   └── features/        ← Feature-specific smart components
├── hooks/               ← Custom React hooks
├── services/            ← API client calls
├── store/               ← Global state (Zustand/RTK)
├── types/               ← Global TypeScript types
├── utils/               ← Pure utility functions
└── styles/              ← Global CSS / tokens
tests/
├── unit/
├── integration/
└── e2e/                 ← Playwright specs
```

---

## Security Additions (extends core/security-baseline.md)

- [ ] No sensitive data in `localStorage` or `sessionStorage` without encryption.
- [ ] API tokens stored securely (httpOnly cookies preferred over localStorage).
- [ ] `dangerouslySetInnerHTML` forbidden except with explicit `DOMPurify` sanitization.
- [ ] CSP headers configured on the hosting platform.
- [ ] All external links use `rel="noopener noreferrer"`.

---

## Performance Baseline

- First Contentful Paint (FCP) < 1.5 s.
- Largest Contentful Paint (LCP) < 2.5 s.
- Cumulative Layout Shift (CLS) < 0.1.
- Bundle size monitored; lazy-load routes.

---

## CI Configuration

```yaml
- name: Type Check
  run: npx tsc --noEmit

- name: Lint
  run: npx eslint src/

- name: Unit Tests
  run: npx vitest run --coverage

- name: E2E Tests
  run: npx playwright test
```
