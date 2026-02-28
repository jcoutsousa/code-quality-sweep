# Example: Monorepo with Multiple Services

## Detected Structure
```
my-platform/
├── services/
│   ├── api-gateway/        # Python (FastAPI)
│   ├── order-processor/    # Go
│   └── notification/       # Python (FastAPI)
├── frontend/               # TypeScript (Next.js)
└── docker-compose.yml
```

## Cross-Service Issues
- **🔴 Shared Database:** api-gateway and order-processor both query `orders` table directly
- **🟡 Synchronous Chain:** frontend → api-gateway → order-processor → notification (3 hops)
- **🟡 No API Contracts:** hardcoded URLs, no OpenAPI specs, no contract tests
- **🟡 Inconsistent Errors:** each service uses different error format

## Scalability Score: 2.0/5

## Recommended Path
1. **Immediate:** Add health endpoints, fix shared DB access, add structured logging
2. **Short-term:** Add OpenAPI specs, contract tests, CI/CD pipeline
3. **Medium-term:** Move notification to async (message queue), add tracing
4. **Long-term:** K8s deployment, API gateway pattern, event sourcing
