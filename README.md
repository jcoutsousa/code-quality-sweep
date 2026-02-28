# 🧹 Code Quality Sweep

A GitHub Copilot agent that performs automated code quality audits across **Python, JavaScript/TypeScript, Java/Kotlin, Go, and Flutter** projects — with a focus on **scalability, architectural health, and microservices readiness**.

Built for teams that move fast (especially with AI assistance) and need a systematic way to ensure their codebase stays production-ready as it grows.

---

## The Problem

Vibe coding gets you from zero to working prototype incredibly fast. But working prototypes become production systems, and production systems need to scale. The gap between "it works" and "it works reliably at scale" is where most projects accumulate technical debt that's expensive to fix later.

**Code Quality Sweep** bridges that gap. It scans your repo, categorizes issues by concern, and creates focused PRs that you can review and merge — one concern at a time.

---

## What It Covers

The agent organizes every finding into one of six categories, each producing its own PR:

| # | Category | What it catches |
|---|---|---|
| 1 | **Dead Code & Unused Dependencies** | Unreferenced functions, unused imports, stale dependencies, commented-out code |
| 2 | **Code Style & Consistency** | Naming violations, magic numbers, mixed paradigms, complexity |
| 3 | **Error Handling & Resilience** | Empty catch blocks, missing timeouts, no retry logic, silent failures |
| 4 | **Security & Secrets** | Hardcoded keys, SQL injection vectors, missing input validation, CVEs |
| 5 | **Test Quality & Coverage** | Untested public APIs, flaky patterns, missing integration/contract tests |
| 6 | **Architecture & Scalability** | God classes, missing API versioning, N+1 queries, microservices readiness |

Category 6 also generates an **Architecture Assessment Report** (`docs/ARCHITECTURE_ASSESSMENT.md`) with a scalability scorecard and evolution roadmap.

---

## Supported Stacks

| Stack | Detection | Analysis Tools |
|---|---|---|
| Python | `pyproject.toml`, `requirements.txt`, `setup.py` | ruff, mypy, bandit, pip-audit |
| JavaScript / TypeScript | `package.json`, `tsconfig.json` | eslint, tsc, npm audit |
| Java / Kotlin | `pom.xml`, `build.gradle(.kts)` | checkstyle, spotbugs, ktlint |
| Go | `go.mod` | go vet, staticcheck, golangci-lint |
| Flutter / Dart | `pubspec.yaml` | dart analyze, flutter test |

Multi-stack repos are fully supported — the agent detects each stack independently and creates separate PRs per stack and per category.

---

## Setup

### Prerequisites

- A **GitHub Copilot Business or Enterprise** subscription with Copilot Extensions enabled
- Your repo must be hosted on GitHub

### Option 1: Copy the agent into your repo

```bash
# Clone this repo
git clone https://github.com/jcoutsousa/code-quality-sweep.git

# Copy the agent instructions into your project
cp -r code-quality-sweep/.github/copilot your-project/.github/copilot

# Optionally copy the configuration template
cp code-quality-sweep/configs/.github/code-quality-sweep.yml your-project/.github/
```

Then commit and push. The agent is now available in your repo.

### Option 2: Reference as a shared agent

If your GitHub organization supports [shared agent repositories](https://docs.github.com/en/copilot/customizing-copilot/extending-the-functionality-of-github-copilot-in-your-organization), you can reference this repo directly in your organization's Copilot settings. This means every repo in your org gets the agent without copying files.

**How to configure:**
1. Go to your organization's **Settings → Copilot → Agent repositories**
2. Add `jcoutsousa/code-quality-sweep` as a shared agent repository
3. The agent becomes available across all repos in your org

---

## Usage

### Run a full sweep

In any Copilot Chat window (VS Code, GitHub.com, or CLI):

```
@code-quality-sweep Run a full sweep on this repository
```

### Run a specific category

```
@code-quality-sweep Scan for security issues only
@code-quality-sweep Check architecture and scalability
@code-quality-sweep Find dead code and unused dependencies
```

### Run for a specific stack

```
@code-quality-sweep Sweep the Python services only
@code-quality-sweep Check the frontend TypeScript code
```

### Generate architecture assessment only

```
@code-quality-sweep Generate an architecture assessment report
```

---

## Configuration

Create `.github/code-quality-sweep.yml` in your repo to customize behavior:

```yaml
# Stacks to scan (auto-detected if omitted)
stacks:
  - python
  - javascript

# Categories to include (all if omitted)
categories:
  - security
  - architecture
  - error-handling

# Paths to exclude
exclude:
  - "vendor/"
  - "generated/"
  - "*.pb.go"

# Minimum severity to report
min_severity: medium

# Architecture assessment
architecture:
  enabled: true
  target_pattern: microservices

# Per-stack rules
rules:
  python:
    max_function_length: 50
    max_file_length: 500
  javascript:
    max_function_length: 40
    prefer_typescript: true
```

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for the full reference.

---

## Architecture Assessment

Beyond fixing individual issues, the agent produces a **scalability scorecard** rating your repo across seven dimensions:

| Dimension | What it measures |
|---|---|
| Separation of Concerns | Are layers cleanly separated? Business logic vs infrastructure? |
| API Maturity | Versioning, contracts, pagination, health checks? |
| Data Layer | Migrations, caching, connection management, N+1 patterns? |
| Test Coverage | Unit, integration, contract, and load test presence? |
| Observability | Structured logging, tracing, metrics, health endpoints? |
| Deployment Readiness | Containers, CI/CD, IaC, environment management? |
| Microservices Readiness | Clear boundaries, async patterns, service discovery? |

Each dimension gets a 1-5 score with evidence, plus a prioritized roadmap for improvement.

---

## Monorepo & Microservices Support

For repos with multiple services, the agent additionally checks:

- **Cross-service coupling:** Shared database access, synchronous call chains
- **API contract consistency:** Do services agree on request/response shapes?
- **Event schema compatibility:** Are event producers and consumers aligned?
- **Shared library duplication:** Are utilities copy-pasted across services?
- **Service boundary clarity:** Does each service own its data and have clear APIs?

---

## Safety Guarantees

The agent follows strict safety rules:

- Never deletes files unless provably unreferenced
- Never modifies test assertions
- Never changes public API signatures without flagging as BREAKING CHANGE
- Never modifies configuration values — only flags them
- Never commits secrets — uses `<PLACEHOLDER>` syntax
- When uncertain, keeps the original code and flags for manual review
- One PR per category — never mixes concerns

---

## What Happens When Analysis Fails

| Scenario | Agent behavior |
|---|---|
| Linter not installed | Notes as infrastructure gap in Category 6; suggests adding to CI |
| Tests fail before changes | Reports test failures in PR; does not make changes to failing areas |
| A fix breaks a test | Reverts that specific fix; documents in PR under "Skipped" |
| Ambiguous finding | Keeps original code; flags in PR for manual review |
| Generated code detected | Skips entirely (checks for `gen/`, `generated/`, `build/`, `dist/`) |

---

## Troubleshooting

### "The agent doesn't detect my stack"
Ensure your manifest files are at the repo root (or in a recognized service directory). If your project structure is non-standard, add explicit `stacks` to your `.github/code-quality-sweep.yml`.

### "Too many findings — the PRs are huge"
Set `min_severity: high` in your config to focus on the most impactful issues first. You can lower the threshold in subsequent sweeps.

### "I want to exclude certain files/directories"
Use the `exclude` list in your config. Glob patterns are supported.

### "The agent flagged something that's intentional"
Add an inline suppression comment appropriate to your stack (`# noqa`, `// nolint`, `@SuppressWarnings`) and the agent will skip it on the next sweep.

### "I only want to run specific categories"
Use the `categories` list in your config, or specify the category in your Copilot Chat prompt.

---

## Examples

The [`examples/`](examples/) directory contains sample output for different project types:

- [`examples/python-fastapi/`](examples/python-fastapi/) — FastAPI microservice sweep
- [`examples/nextjs-app/`](examples/nextjs-app/) — Next.js full-stack app sweep
- [`examples/go-microservice/`](examples/go-microservice/) — Go microservice sweep
- [`examples/flutter-app/`](examples/flutter-app/) — Flutter mobile app sweep
- [`examples/monorepo-multi-service/`](examples/monorepo-multi-service/) — Multi-service monorepo sweep

---

## Contributing

Contributions are welcome. If you'd like to add support for a new stack, improve detection rules, or add example outputs:

1. Fork the repo
2. Create a branch (`feat/add-rust-support`)
3. Submit a PR with a clear description of what changed and why

Please follow the existing pattern for stack-specific configurations in `configs/`.

---

## License

MIT — see [LICENSE](LICENSE).
