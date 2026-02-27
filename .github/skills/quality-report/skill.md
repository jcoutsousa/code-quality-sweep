---
name: quality-report
description: >
  Generates a comprehensive code quality report aggregating findings from all
  sweep skills. Produces a structured summary with metrics, before/after
  comparisons, and the PR body content.
---

# Quality Report Skill

Aggregate all sweep findings into a comprehensive quality report.

## Report Generation Process

### Step 1: Collect Results from All Skills

Gather findings from:
- Unused imports audit
- Dead code audit
- Duplicated constants audit
- Duplicated logic audit
- Inconsistent patterns audit
- Spaghetti code audit

### Step 2: Calculate Metrics

| Metric | How to Calculate |
|--------|-----------------|
| Total files scanned | Count all `.dart` files in `lib/` |
| Files modified | Count unique files changed across all categories |
| Lines removed | Sum of all deleted lines (net) |
| Lines added | Sum of all new lines (shared utilities, constants files) |
| Net line delta | Lines added - Lines removed |
| Issues found | Sum of all issues across categories |
| Issues fixed | Sum of all fixes applied |

### Step 3: Validation Summary

| Check | Command | Expected |
|-------|---------|----------|
| Static analysis | `flutter analyze` | 0 new issues |
| Tests | `flutter test` | 0 new failures |
| Pre-existing issues | — | Documented, not introduced |

### Step 4: Generate Report

## Output Format

```markdown
## Code Quality Sweep Report

### Overview

| Metric | Value |
|--------|-------|
| Files scanned | [count] |
| Files modified | [count] |
| Lines removed | [count] |
| Lines added | [count] |
| **Net reduction** | **-[count] lines** |

### Validation

| Check | Status | Details |
|-------|--------|---------|
| `flutter analyze` | PASS/FAIL | [X] issues (Y pre-existing) |
| `flutter test` | PASS/FAIL | [X] passed, [Y] failed, [Z] skipped |

### Changes by Category

#### 1. Unused Imports
- **Files modified**: [count]
- **Imports removed**: [count]

#### 2. Dead Code
- **Files deleted**: [count]
- **Symbols removed**: [count]
- **Lines removed**: [count]

<details>
<summary>Dead symbols removed</summary>

| File | Symbol | Type | Lines |
|------|--------|------|-------|
| ... | ... | ... | ... |

</details>

#### 3. Duplicated Constants
- **Constants centralized**: [count]
- **Hardcoded values replaced**: [count]
- **New constant classes**: [list]

<details>
<summary>Centralized constants</summary>

| Value | Constant | Occurrences |
|-------|----------|-------------|
| ... | ... | ... |

</details>

#### 4. Duplicated Logic
- **Patterns extracted**: [count]
- **New shared files**: [count]
- **Lines saved**: [count]

#### 5. Inconsistent Patterns
- **Naming fixes**: [count]
- **Async standardizations**: [count]
- **Import fixes**: [count]

#### 6. Spaghetti Code
- **Functions refactored**: [count]
- **Build methods split**: [count]
- **Nesting reduced**: [count]
- **Concerns separated**: [count]

### Commits

| # | Message | Files | Lines |
|---|---------|-------|-------|
| 1 | refactor: remove unused imports | [X] | -[Y] |
| 2 | refactor: remove dead code and unused symbols | [X] | -[Y] |
| 3 | refactor: centralize duplicated constants and hardcoded values | [X] | +[A]/-[B] |
| 4 | refactor: extract duplicated logic into shared utilities | [X] | +[A]/-[B] |
| 5 | refactor: standardize naming conventions and patterns | [X] | ~[Y] |
| 6 | refactor: improve code structure and reduce complexity | [X] | +[A]/-[B] |

### Remaining Items (out of scope)

Items detected but intentionally not fixed:
- Pre-existing `flutter analyze` warnings: [count]
- Test-only symbols (kept for testing): [count]
- Patterns requiring architectural decisions: [list]

---

> This sweep was performed by the [code-quality-sweep](https://github.com/nosportugal/code-quality-sweep) agent.
> No business logic was changed. All modifications are structural refactoring only.
```
