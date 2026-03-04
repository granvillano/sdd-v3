# Profile: python-fastapi-api

> **Profile ID:** `python-fastapi-api`  
> **Inherits:** `core/*` (all core SSOT rules apply)  
> **Version:** 3.0.0

---

## Stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3.11+ |
| Framework | FastAPI |
| Database | PostgreSQL via SQLAlchemy + Alembic |
| Testing | pytest + httpx |
| Linting | Ruff + Black + mypy |
| Dependency Manager | pip + pyproject.toml |
| CI | GitHub Actions |

---

## Coding Standards

- Type hints on all function signatures.
- Pydantic v2 models for all request/response bodies.
- Strict mypy: `mypy --strict` must pass.
- Google-style docstrings on all public functions and classes.
- Dependencies injected via FastAPI `Depends()`.
- Async endpoints where I/O is involved (`async def`).
- No mutable global state.

---

## Directory Structure (Canonical)

```
src/
├── main.py              ← App factory + router inclusion
├── api/
│   └── v1/
│       ├── routes/      ← FastAPI routers
│       └── deps.py      ← Dependency injection
├── core/
│   ├── config.py        ← Settings via pydantic-settings
│   └── security.py      ← Auth utilities
├── services/            ← Business logic
├── repositories/        ← SQLAlchemy data access
├── models/              ← SQLAlchemy ORM models
├── schemas/             ← Pydantic request/response schemas
└── utils/
tests/
├── unit/
└── integration/
alembic/                 ← DB migrations
```

---

## Security Additions (extends core/security-baseline.md)

- [ ] All routes protected via `Depends(get_current_user)` unless explicitly public.
- [ ] Pydantic schema rejects unknown fields by default (`model_config = ConfigDict(extra='forbid')`).
- [ ] SQL injection impossible: only SQLAlchemy ORM or parameterized text() queries.
- [ ] Alembic migration reviewed for destructive operations before applying.
- [ ] CORS settings explicit — no `allow_origins=["*"]` in production.

---

## CI Configuration

```yaml
- name: Lint
  run: ruff check src/ && black --check src/

- name: Type Check
  run: mypy src/

- name: Test
  run: pytest --cov=src --cov-report=xml
```
