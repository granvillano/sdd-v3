# Profile: react-native-app

> **Profile ID:** `react-native-app`  
> **Inherits:** `core/*` (all core SSOT rules apply)  
> **Version:** 3.0.0

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5+ |
| Framework | React Native (Expo or bare workflow) |
| Navigation | React Navigation v6+ |
| State | Zustand / React Query |
| Testing | Jest + React Native Testing Library + Detox (E2E) |
| Linting | ESLint + Prettier |
| Build | EAS Build (Expo) or Gradle/Xcode |
| CI | GitHub Actions + EAS |

---

## Coding Standards

- Functional components only.
- StyleSheet.create() for styles — no inline style objects.
- Platform-specific code in `.ios.tsx` / `.android.tsx` files.
- All navigation params typed via typed navigation props.
- Async storage encrypted for sensitive data (react-native-encrypted-storage).
- No hardcoded API URLs — all from environment config.

---

## Directory Structure (Canonical)

```
src/
├── App.tsx
├── navigation/
│   └── RootNavigator.tsx
├── screens/             ← One folder per screen
├── components/
│   ├── ui/              ← Primitive, theme-aware components
│   └── features/        ← Feature-specific smart components
├── hooks/
├── services/            ← API calls
├── store/               ← Zustand stores
├── types/
└── utils/
tests/
├── unit/
└── e2e/                 ← Detox specs
```

---

## Security Additions (extends core/security-baseline.md)

- [ ] No sensitive data in `AsyncStorage` unencrypted.
- [ ] SSL pinning implemented for API calls in production.
- [ ] Biometric auth offered for sensitive actions where appropriate.
- [ ] Deep links validated and sanitized.
- [ ] App Transport Security (ATS) enforced on iOS.
- [ ] ProGuard/R8 obfuscation enabled on Android release builds.

---

## Performance Baseline

- App launch time < 3 s on mid-range device.
- No `FlatList` without `keyExtractor` and `getItemLayout`.
- Heavy operations off the JS thread (use Reanimated worklets or native modules).
- Memory leaks checked with Flipper or React DevTools Profiler.

---

## CI Configuration

```yaml
- name: Type Check
  run: npx tsc --noEmit

- name: Lint
  run: npx eslint src/

- name: Unit Tests
  run: npx jest --coverage

- name: EAS Build (Preview)
  run: eas build --platform all --profile preview
```
