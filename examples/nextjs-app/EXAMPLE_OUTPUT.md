# Example: Next.js Full-Stack App Sweep

## Key Findings
- **14 unused React components** and **6 unused npm dependencies** (leftovers from AI-generated code)
- **3 tRPC procedures without auth middleware** (`createOrder`, `deleteUser`, `updateSettings`)
- **No service layer** — 400-line procedure files doing validation + DB + email
- **Prisma client not singleton** — connection pool exhaustion risk

**Scalability Score: 2.2/5**

**Immediate actions:** Extract data access layer, add auth middleware, singleton Prisma client.
