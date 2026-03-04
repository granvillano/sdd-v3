# Profile: php-wordpress-api

> **Profile ID:** `php-wordpress-api`  
> **Inherits:** `core/*` (all core SSOT rules apply)  
> **Version:** 3.0.0

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | PHP 8.2+ |
| Framework | WordPress Plugin API / REST API |
| Database | MySQL via `$wpdb` |
| Testing | PHPUnit + WP_Mock |
| Linting | PHPCS (WordPress Coding Standards) |
| Dependency Manager | Composer |
| CI | GitHub Actions (or equivalent) |

---

## Coding Standards

- Follow **WordPress Coding Standards** (WPCS via PHPCS).
- PHP files use `<?php` only — no closing `?>` tag.
- Hook names in `snake_case`.
- All functions namespaced or in classes; no global function pollution.
- Use `$wpdb->prepare()` for ALL custom queries — never concatenate SQL.
- Sanitize with `sanitize_text_field()`, `absint()`, `esc_html()`, etc.
- Escape output: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses()`.
- Nonce verification on ALL admin forms and AJAX handlers.
- Capability checks: `current_user_can()` on all privileged actions.

---

## Directory Structure (Canonical)

```
plugin-root/
├── plugin-name.php         ← Bootstrap file (plugin header)
├── composer.json
├── src/
│   ├── Controllers/         ← REST API RouteControllers
│   ├── Services/            ← Business logic
│   ├── Repositories/        ← Database access via $wpdb
│   ├── Models/              ← DTOs / Value Objects
│   └── Hooks/               ← add_action / add_filter registrations
├── tests/
│   ├── Unit/
│   └── Integration/
└── docs/
```

---

## Security Additions (extends core/security-baseline.md)

- [ ] All AJAX endpoints validate `check_ajax_referer()`.
- [ ] REST endpoints use `permission_callback` (never `__return_true` in production).
- [ ] No direct file access: `if (!defined('ABSPATH')) exit;` at top of every PHP file.
- [ ] Table prefix always via `$wpdb->prefix` — never hardcoded.
- [ ] Option names prefixed with plugin slug to avoid conflicts.

---

## CI Configuration

```yaml
# .github/workflows/ci.yml (excerpt)
- name: Run PHPCS
  run: vendor/bin/phpcs --standard=WordPress src/

- name: Run PHPUnit
  run: vendor/bin/phpunit --coverage-clover coverage.xml
```

---

## Tooling

- PHPCS: `composer require --dev squizlabs/php_codesniffer wp-coding-standards/wpcs`
- PHPUnit: `composer require --dev phpunit/phpunit wp-phpunit/wp-phpunit`
- WP-CLI for scaffolding: `wp scaffold plugin-tests`
