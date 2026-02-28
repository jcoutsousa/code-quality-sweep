# Example: Python FastAPI Microservice Sweep

## PR #1 — `sweep(dead-code): Remove unused imports and stale dependencies`

**Files changed:** 8 | **Severity:** 0 critical, 2 high, 4 medium

Removed 12 unused imports, 3 unused utility functions, and 2 unused dependencies (`requests`, `pyyaml`).

## PR #4 — `sweep(security): Fix hardcoded secrets and add input validation`

**Files changed:** 5 | **Severity:** 2 critical, 3 high

Found hardcoded `DATABASE_URL` with credentials, a hardcoded API key, missing input validation on 3 endpoints, and 1 SQL injection vector. Replaced secrets with environment variable references.

### Skipped
- `python-jose==3.3.0` has CVE-2024-33663 — upgrade needed but may require JWT implementation changes
- CORS `allow_origins=["*"]` may be intentional for dev
