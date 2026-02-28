Use the code-quality-sweep agent to perform a Monorepo Hygiene audit (Category 7) on this repository.

Analyze the monorepo structure and evaluate:
- Workspace management (pnpm/npm/yarn workspaces, Lerna)
- Dependency strategy (hoisting, version alignment, phantom deps)
- Build orchestration (Turborepo, Nx, Bazel, Lerna, custom)
- Change detection in CI (affected packages only, or full rebuild?)
- Code ownership (CODEOWNERS file, review routing)
- Versioning strategy (changesets, conventional commits, coordinated releases)
- Boundary enforcement (shared package APIs, import restrictions)
- CI/CD efficiency (caching, parallelism, Docker layer optimization)

Produce a Monorepo Hygiene Scorecard (1-5 per dimension), fix what can be fixed, and suggest configuration templates from configs/templates/ where applicable.

$ARGUMENTS
