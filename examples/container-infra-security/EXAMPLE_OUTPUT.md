# Example: Container & Infrastructure Security Sweep

## Repository: my-platform (3 Python services + Terraform + K8s manifests)

### Trivy Scan Summary

| Scan Mode | Findings | Critical | High | Medium |
|---|---|---|---|---|
| `trivy fs` (CVEs) | 23 | 3 | 8 | 12 |
| `trivy fs` (secrets) | 4 | 2 | 2 | 0 |
| `trivy config` (IaC) | 18 | 2 | 7 | 9 |
| `trivy image` (api-gateway) | 31 | 1 | 12 | 18 |
| `trivy image` (user-service) | 28 | 1 | 11 | 16 |
| `trivy image` (worker) | 45 | 5 | 18 | 22 |

---

## PR — `sweep(container-infra-security): Fix critical CVEs, Dockerfile hardening, Terraform misconfigs`

**Files changed:** 14 | **Severity:** 8 critical, 11 high

### Filesystem Vulnerabilities (trivy fs)

| Package | Current | Fixed | Severity | CVE |
|---|---|---|---|---|
| `cryptography` | 41.0.1 | 42.0.4 | 🔴 Critical | CVE-2024-26130 |
| `pillow` | 9.5.0 | 10.3.0 | 🔴 Critical | CVE-2024-28219 |
| `werkzeug` | 2.3.6 | 3.0.6 | 🔴 Critical | CVE-2024-34069 |
| `requests` | 2.28.0 | 2.32.0 | 🟠 High | CVE-2024-35195 |
| `flask` | 2.3.2 | 3.0.3 | 🟠 High | CVE-2024-34064 |

**Fixed:** Updated `requirements.txt` in all 3 services with patched versions. Ran `pip install -r requirements.txt && pytest` to verify no regressions.

### Secrets Detected (trivy fs)

| File | Secret Type | Severity |
|---|---|---|
| `services/api-gateway/config.py` | AWS Access Key ID | 🔴 Critical |
| `services/worker/tasks.py` | Stripe API Key | 🔴 Critical |
| `infra/scripts/deploy.sh` | Database password | 🟠 High |
| `.env.staging` | JWT signing secret | 🟠 High |

**Fixed:** Replaced all hardcoded secrets with environment variable references. Added `.env.staging` to `.gitignore`. Added comment `# ROTATED — old key compromised` to flag for team.

### Dockerfile Misconfigurations (trivy config)

| File | Issue | Severity |
|---|---|---|
| `services/api-gateway/Dockerfile` | Running as root | 🔴 Critical |
| `services/user-service/Dockerfile` | Running as root | 🔴 Critical |
| `services/api-gateway/Dockerfile` | Using `latest` tag for base image | 🟠 High |
| `services/worker/Dockerfile` | No HEALTHCHECK instruction | 🟠 High |
| `services/*/Dockerfile` | `COPY . .` copies secrets and tests into image | 🟠 High |

**Fixed:**
- Added non-root user (`appuser`) to all Dockerfiles
- Pinned base images to specific SHA digests
- Added `.dockerignore` files to exclude `.env*`, `tests/`, `.git/`
- Added HEALTHCHECK instructions
- Switched to multi-stage builds to reduce image size

### Terraform Misconfigurations (trivy config)

| File | Issue | Severity |
|---|---|---|
| `infra/terraform/rds.tf` | RDS publicly accessible | 🟠 High |
| `infra/terraform/rds.tf` | No encryption at rest | 🟠 High |
| `infra/terraform/s3.tf` | S3 bucket without server-side encryption | 🟠 High |
| `infra/terraform/s3.tf` | S3 bucket without versioning | 🟡 Medium |
| `infra/terraform/ecs.tf` | ECS task with excessive IAM permissions | 🟡 Medium |
| `infra/terraform/sg.tf` | Security group allows 0.0.0.0/0 on port 22 | 🟠 High |

**Fixed:** Applied least-privilege security groups, enabled encryption, disabled public access on RDS, enabled S3 versioning. Added `# tfsec:ignore` comments where intentional (e.g., public S3 for static assets).

### Container Image Vulnerabilities (trivy image)

| Image | OS Vulns | Lib Vulns | Image Size | Base |
|---|---|---|---|---|
| api-gateway | 18 | 13 | 1.2 GB | `python:3.11` |
| user-service | 16 | 12 | 1.1 GB | `python:3.11` |
| worker | 29 | 16 | 1.4 GB | `python:3.11` |

**Fixed:** Switched all images from `python:3.11` to `python:3.11-slim` (reduces OS vulns by ~60% and image size by ~70%). Remaining OS vulnerabilities are in `libc6` and `openssl` — marked as "will not fix" upstream.

### SBOM Generated

- `sbom.cdx.json` — CycloneDX format (all dependencies across all services)
- `sbom.spdx.json` — SPDX format (for compliance)

### License Compliance

| License | Packages | Status |
|---|---|---|
| MIT | 127 | ✅ Allowed |
| Apache-2.0 | 43 | ✅ Allowed |
| BSD-3-Clause | 18 | ✅ Allowed |
| GPL-3.0 | 2 (`chardet`, `readline`) | ⚠️ Restricted — needs legal review |
| AGPL-3.0 | 0 | ✅ None found |

### Skipped (manual review needed)

- **Secret rotation:** Found 4 exposed secrets. Replacements made in code, but the old secrets need to be rotated in AWS/Stripe/DB — this is an ops action.
- **worker Dockerfile:** Has a custom `apt-get install` for system deps that may break with `slim` base. Needs testing.
- **ECS task role:** Reduced permissions but team should verify the service still has access to required resources.
- **GPL dependencies:** `chardet` and `readline` need legal team review for commercial use.

### How to Verify

```bash
# Install Trivy locally
brew install trivy  # or: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Filesystem scan (CVEs + secrets)
trivy fs . --severity HIGH,CRITICAL

# IaC misconfiguration scan
trivy config . --severity HIGH,CRITICAL

# Build and scan a specific image
docker build -t api-gateway:test -f services/api-gateway/Dockerfile .
trivy image api-gateway:test --severity HIGH,CRITICAL

# Generate SBOM
trivy fs . --format cyclonedx --output sbom.cdx.json

# Check license compliance
trivy fs . --scanners license --severity HIGH,CRITICAL
```
