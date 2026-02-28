# Example: Monorepo Hygiene Sweep

## Repository: my-platform (Node.js monorepo, 4 services + 1 frontend)

### Detected Structure
```
my-platform/
├── services/
│   ├── api-gateway/        # Express.js
│   ├── user-service/       # NestJS
│   ├── order-service/      # NestJS
│   └── notification/       # Fastify
├── apps/
│   └── web/                # Next.js
├── packages/
│   ├── shared/             # Shared types & utils
│   └── ui/                 # Component library
├── package.json            # Root (no workspaces configured!)
└── .github/workflows/
    └── ci.yml              # Runs everything on every push
```

---

## PR — `sweep(monorepo-hygiene): Fix workspace config, add CODEOWNERS, optimize CI`

**Files changed:** 12 | **Severity:** 1 critical, 4 high, 6 medium

### Monorepo Hygiene Scorecard

| Dimension | Score | Evidence |
|---|---|---|
| **Workspace Management** | 1/5 | No workspace config — each service installs deps independently, massive duplication |
| **Dependency Strategy** | 1/5 | Mixed package managers (npm in root, yarn in 2 services, pnpm in 1). No hoisting. |
| **Build Orchestration** | 1/5 | No task runner. CI runs full `npm test` in every service on every push. |
| **Change Detection** | 1/5 | No affected/changed filtering. Full CI on every PR regardless of what changed. |
| **Code Ownership** | 0/5 | No CODEOWNERS file. PRs have no auto-assigned reviewers. |
| **Versioning Strategy** | 1/5 | Manual version bumps, no changelog generation, no coordinated releases. |
| **Boundary Enforcement** | 2/5 | Services mostly isolated but `shared/` has no API contract — anyone imports anything. |
| **CI/CD Efficiency** | 1/5 | ~18 min CI runs. No caching. No parallelism. Docker builds on every PR. |

**Overall: 1.0/5** 🔴

---

### Changes Made

| # | Change | Severity | Rationale |
|---|---|---|---|
| 1 | Added `pnpm-workspace.yaml` with all service/package paths | 🔴 Critical | Without workspaces, deps are duplicated ~4x and versions drift |
| 2 | Added `turbo.json` with task pipeline and caching config | 🟠 High | Enables incremental builds — estimated CI reduction from 18min → 4min |
| 3 | Added `.github/CODEOWNERS` with team-based ownership | 🟠 High | Zero code ownership means PRs lack domain-expert review |
| 4 | Added `.changeset/config.json` for versioning | 🟡 Medium | Manual version bumps lead to drift and missing changelogs |
| 5 | Replaced `ci.yml` with change-detection workflow | 🟠 High | Old CI rebuilds everything on every push — wastes ~14min/run |
| 6 | Added `packages/shared/index.ts` barrel export | 🟡 Medium | Enforces public API surface for shared package |
| 7 | Added `.npmrc` with `shamefully-hoist=true` for compat | 🟡 Medium | Prevents phantom dependency issues during migration |
| 8 | Added `packages/eslint-config/` shared lint config | 🟡 Medium | Each service had different or missing eslint configs |
| 9 | Added `packages/tsconfig/` shared TypeScript configs | 🟡 Medium | 3 different `target` settings across services |
| 10 | Standardized all services to pnpm | 🟠 High | Mixed package managers cause lockfile conflicts and CI failures |

### Skipped (manual review needed)

- **Docker build contexts:** Services use `COPY . .` instead of multi-stage with workspace-aware contexts. Fix requires testing each Dockerfile individually.
- **Shared database migrations:** `user-service` and `order-service` both have migrations for the same DB. Needs architectural decision on data ownership.
- **Turborepo remote caching:** Requires `TURBO_TOKEN` and `TURBO_TEAM` secrets. Added to CI template but secrets need manual setup.
- **Nx migration:** Alternative to Turborepo with stronger boundary enforcement. Team should evaluate.

### How to Verify

```bash
# Install deps with workspaces
pnpm install

# Run full build with Turborepo
pnpm turbo build

# Run only affected tests (simulating a change in user-service)
pnpm turbo test --filter=user-service...

# Verify CODEOWNERS syntax
cat .github/CODEOWNERS | grep -v '^#' | grep -v '^$'

# Verify change detection locally
npx turbo run build --dry-run --filter='...[main]'
```
