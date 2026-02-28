# Configuration Reference

The agent reads configuration from `.github/code-quality-sweep.yml` in your repo root. All settings are optional — the agent uses sensible defaults when no configuration is provided.

---

## Full Configuration Schema

```yaml
# .github/code-quality-sweep.yml

# ─── Stack Detection ─────────────────────────────────────────────
stacks:
  - python
  - javascript
  - go

# ─── Category Selection ──────────────────────────────────────────
categories:
  - dead-code
  - code-style
  - error-handling
  - security
  - test-quality
  - architecture
  - monorepo-hygiene
  - container-infra-security

# ─── Path Exclusions ─────────────────────────────────────────────
exclude:
  - "vendor/"
  - "generated/"
  - "migrations/"
  - "*.pb.go"
  - "**/*.generated.ts"

# ─── Severity Threshold ──────────────────────────────────────────
min_severity: medium  # low | medium | high | critical

# ─── Architecture Assessment ─────────────────────────────────────
architecture:
  enabled: true
  target_pattern: microservices
  output_path: docs/ARCHITECTURE_ASSESSMENT.md

# ─── PR Behavior ─────────────────────────────────────────────────
pr:
  branch_prefix: sweep
  auto_assign_reviewers: false
  labels:
    - code-quality
    - automated
    - tech-debt
  max_files_per_pr: 50

# ─── Stack-Specific Rules ────────────────────────────────────────
rules:
  python:
    max_function_length: 50
    max_file_length: 500
    required_docstrings: public  # none | public | all
    min_python_version: "3.10"
    require_type_hints: true
  javascript:
    max_function_length: 40
    max_file_length: 400
    prefer_typescript: true
    framework: null  # auto-detected: react, vue, nextjs, express, nestjs
  java:
    max_method_length: 40
    max_class_length: 500
    prefer_kotlin: false
    framework: null  # auto-detected: spring-boot, quarkus, micronaut
  go:
    max_function_length: 60
    max_file_length: 600
    require_error_wrapping: true
  flutter:
    max_widget_depth: 5
    max_file_length: 400
    state_management: null  # auto-detected: bloc, riverpod, provider, getx

# ─── Container & Infrastructure Security ─────────────
container_security:
  enabled: auto  # auto | true | false (auto = only when Dockerfiles/IaC present)
  trivy_severity: "HIGH,CRITICAL"  # Severity threshold for Trivy scans
  scan_modes:
    - fs           # CVEs in dependencies
    - secret       # Hardcoded secrets
    - config       # IaC misconfigurations
    - image        # Container image vulnerabilities
    - sbom         # Software Bill of Materials
  generate_sbom: true
  sbom_formats:
    - cyclonedx
    - spdx-json
  license_policy:
    forbidden:
      - AGPL-1.0
      - AGPL-3.0
    restricted:
      - GPL-2.0
      - GPL-3.0
      - LGPL-2.1
      - LGPL-3.0
  dockerfile:
    require_non_root: true
    require_healthcheck: true
    require_pinned_base: true  # Pin to SHA digest, not just tag
    max_image_size_mb: 500
  ignore_cves: []  # CVEs to suppress (e.g., ["CVE-2024-99999"])

# ─── Monorepo Hygiene Rules ──────────────────────────
monorepo_hygiene:
  enabled: auto  # auto | true | false (auto = only when monorepo detected)
  preferred_task_runner: turborepo  # turborepo | nx | lerna | none
  preferred_package_manager: pnpm  # pnpm | npm | yarn
  enforce_codeowners: true
  enforce_changesets: true
  max_ci_duration_minutes: 10  # flag if CI exceeds this
  boundary_enforcement: strict  # strict | moderate | none

# ─── Monorepo Settings ───────────────────────────────────────────
monorepo:
  service_dirs:
    - "services/"
    - "packages/"
    - "apps/"
  cross_service_analysis: true
  shared_dirs:
    - "libs/"
    - "shared/"
```

---

## Default Exclusions

These paths are always excluded: `node_modules/`, `vendor/`, `build/`, `dist/`, `.dart_tool/`, `__pycache__/`, `.mypy_cache/`, `.pytest_cache/`, `.next/`, `target/`, `bin/` (Go).

---

## Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `SWEEP_CONFIG_PATH` | Alternative path to config file | `.github/code-quality-sweep.yml` |
| `SWEEP_DRY_RUN` | If `true`, report findings without creating PRs | `false` |
| `SWEEP_VERBOSE` | If `true`, include debug information in PR descriptions | `false` |

---

## Configuration Precedence

1. Inline suppression comments (highest priority)
2. `.github/code-quality-sweep.yml` settings
3. Agent defaults (lowest priority)
