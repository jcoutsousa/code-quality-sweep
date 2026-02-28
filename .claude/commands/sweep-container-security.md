Use the code-quality-sweep agent to perform a Container & Infrastructure Security audit (Category 8) on this repository.

Run Trivy in all applicable modes:
1. **trivy fs** — scan for CVEs in dependencies and exposed secrets in the filesystem
2. **trivy config** — scan Dockerfiles, Terraform, Kubernetes manifests, Helm charts for misconfigurations
3. **trivy image** — build and scan container images for OS and library vulnerabilities
4. **trivy sbom** — generate Software Bill of Materials (CycloneDX + SPDX)

Also check:
- Dockerfile best practices (non-root user, pinned base images, multi-stage builds, .dockerignore, HEALTHCHECK)
- License compliance (flag GPL/AGPL dependencies)
- Secret exposure (hardcoded keys, .env files in repo)
- IaC security posture (Terraform, K8s, CloudFormation)

Fix what can be safely fixed, generate the SBOM, and flag everything else for manual review.

$ARGUMENTS
