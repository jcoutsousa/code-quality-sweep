# Code Quality Sweep

This repository contains a code quality agent for multi-technology projects.

## Project Overview

Code Quality Sweep is a code quality audit agent that supports Python, JavaScript/TypeScript, Java/Kotlin, Go, and Flutter. It detects and fixes maintainability, scalability, and architectural issues — with a focus on repos built through rapid prototyping or vibe coding.

## How to Use

When working in a repository that has copied this agent's instructions:

- Run `/sweep` for a full code quality audit
- Run `/sweep-architecture` for an architecture assessment only
- Run `/sweep-security` for a security-focused scan
- Or invoke the `code-quality-sweep` agent directly

## Key Concepts

The agent organizes findings into 6 categories (each addressed separately):

1. **Dead Code & Unused Dependencies** — unreferenced code, stale deps
2. **Code Style & Consistency** — naming, magic numbers, paradigm mixing
3. **Error Handling & Resilience** — empty catches, missing timeouts, no retries
4. **Security & Secrets** — hardcoded keys, injection vectors, CVEs
5. **Test Quality & Coverage** — untested APIs, flaky tests, missing integration tests
6. **Architecture & Scalability** — god classes, missing API versioning, N+1 queries, microservices readiness
7. **Monorepo Hygiene** — workspace config, build orchestration, change detection, CODEOWNERS, versioning strategy
8. **Container & Infrastructure Security** — Trivy CVE scanning, Dockerfile hardening, IaC misconfigs, SBOM, license compliance

## Safety Rules

- Never delete files unless provably unreferenced
- Never modify test assertions
- Never change public API signatures without flagging as BREAKING CHANGE
- Never modify configuration values — only flag them
- When uncertain, keep original code and flag for review

## File Structure

```
.github/copilot/          # GitHub Copilot agent instructions
  agents.yml
  instructions.md
.claude/agents/            # Claude Code subagent
  code-quality-sweep.md
.claude/commands/          # Claude Code slash commands
  sweep.md
  sweep-architecture.md
  sweep-security.md
  sweep-monorepo.md
  sweep-container-security.md
docs/                      # Documentation and templates
  CONFIGURATION.md
  ARCHITECTURE_ASSESSMENT_TEMPLATE.md
configs/                   # Configuration templates
examples/                  # Sample outputs per stack
```
