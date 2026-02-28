# Example: Go Microservice Sweep

## Category 3: Error Handling
- Replaced bare `return err` with `fmt.Errorf("context: %w", err)` across 8 functions
- Added `http.Client{Timeout: 10s}` — was using `http.DefaultClient` (no timeout) — **Critical**
- Added connection pool limits (`SetMaxOpenConns`, `SetMaxIdleConns`, `SetConnMaxLifetime`)
- Added graceful shutdown with `signal.NotifyContext`

## Category 6: Architecture
- Created `/healthz` and `/readyz` endpoints
- Replaced `log.Println` with `slog.Info` (structured JSON logging)
- Added `/api/v1/` prefix to all routes
- Added multi-stage Dockerfile with non-root user

**Scalability Score: 2.8/5** — Good separation of concerns, weak observability and test coverage.
