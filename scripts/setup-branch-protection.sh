#!/usr/bin/env bash
# setup-branch-protection.sh — Configure branch protection rules via GitHub API
#
# Prerequisites:
#   - gh CLI authenticated with admin access
#   - Repository must exist on GitHub
#
# Usage:
#   ./scripts/setup-branch-protection.sh <owner/repo> [branch]
#
# Example:
#   ./scripts/setup-branch-protection.sh jcoutsousa/code-quality-sweep main

set -euo pipefail

REPO="${1:?Usage: $0 <owner/repo> [branch]}"
BRANCH="${2:-main}"

echo "Configuring branch protection for ${REPO} (branch: ${BRANCH})"

# Verify gh CLI is authenticated
if ! gh auth status &>/dev/null; then
  echo "Error: gh CLI is not authenticated. Run 'gh auth login' first."
  exit 1
fi

# Verify repository exists and user has admin access
if ! gh api "repos/${REPO}" --jq '.permissions.admin' | grep -q true; then
  echo "Error: You need admin access to ${REPO} to configure branch protection."
  exit 1
fi

# Configure branch protection with required status checks
gh api --method PUT "repos/${REPO}/branches/${BRANCH}/protection" \
  --field "required_status_checks[strict]=true" \
  --field "required_status_checks[checks][][context]=Security Gate — Result" \
  --field "required_status_checks[checks][][context]=Vulnerabilities — CVEs" \
  --field "required_status_checks[checks][][context]=Secrets — Leaked Credentials" \
  --field "required_status_checks[checks][][context]=Licenses — Compliance Check" \
  --field "enforce_admins=true" \
  --field "required_pull_request_reviews[required_approving_review_count]=1" \
  --field "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  --field "restrictions=null" \
  --silent

echo "Branch protection configured successfully for ${BRANCH}:"
echo "  - Required status checks: Security Gate, Vulnerabilities, Secrets, Licenses"
echo "  - Strict status checks: enabled (branch must be up to date)"
echo "  - Required reviewers: 1"
echo "  - Dismiss stale reviews: enabled"
echo "  - Enforce admins: enabled"

# Verify the configuration was applied
echo ""
echo "Verifying configuration..."
gh api "repos/${REPO}/branches/${BRANCH}/protection/required_status_checks" \
  --jq '{strict: .strict, contexts: .checks | map(.context)}'

echo ""
echo "Done. Branch protection is active for ${REPO}:${BRANCH}"
