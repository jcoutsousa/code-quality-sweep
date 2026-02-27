# Code Quality Sweep

A GitHub Copilot custom agent that performs comprehensive code quality sweeps on **Flutter/Dart** applications to identify and fix duplicated code, dead code, inconsistent patterns, and structural issues.

## What it does

When invoked in a Flutter project repository, the agent:

1. **Scans** the entire `lib/` directory for code smells and quality issues
2. **Identifies** unused imports, dead code, duplicated constants, duplicated logic, inconsistent patterns, and spaghetti code
3. **Fixes** each category with a separate, focused commit
4. **Validates** changes with `flutter analyze` and `flutter test`
5. **Creates a PR** with a structured quality report — never merges automatically

## Sweep Coverage

| Category | Skill | What it Finds |
|----------|-------|---------------|
| Unused Imports | `unused-imports` | Unreferenced imports, disorganized import order |
| Dead Code | `dead-code` | Unused classes, functions, files, empty lifecycle overrides, commented-out code |
| Duplicated Constants | `duplicated-constants` | Hardcoded colors, strings, URLs, padding values repeated across files |
| Duplicated Logic | `duplicated-logic` | Copy-pasted functions, repeated widget patterns, near-duplicate code blocks |
| Inconsistent Patterns | `inconsistent-patterns` | Mixed naming conventions, async styles, import styles, error handling |
| Spaghetti Code | `spaghetti-code` | Long functions (>50 lines), deep nesting (>3 levels), mixed UI/business logic, god classes |

## Installation

### Option 1: Copy into your repository

```bash
# Clone this repo
git clone https://github.com/nosportugal/code-quality-sweep.git

# Copy agent and skills into your Flutter project
cp -r code-quality-sweep/.github/agents your-flutter-project/.github/
cp -r code-quality-sweep/.github/skills your-flutter-project/.github/

# Commit
cd your-flutter-project
git add .github/agents .github/skills
git commit -m "ci: add code quality sweep copilot agent"
git push
```

### Option 2: Reference directly

If your organization supports shared agent repositories, reference this repo directly in your Copilot configuration.

## Usage

### In VS Code (Copilot Chat)

```
@code-quality-sweep run a full sweep on flutter_app/lib/
```

### On GitHub.com (Copilot Coding Agent)

1. Open an Issue with the title: `Code quality sweep`
2. In the body, write:
   ```
   @code-quality-sweep perform a full code quality sweep
   ```
3. Copilot creates a branch, applies fixes, and opens a PR

### Individual Skills

You can invoke specific skills directly:

```
@code-quality-sweep find and remove dead code
@code-quality-sweep centralize duplicated constants
@code-quality-sweep check for inconsistent naming conventions
@code-quality-sweep refactor spaghetti code in lib/views/
```

## How it works

### Workflow

```
Phase 1: Setup
├── git checkout -b refactor/code-cleanup
└── flutter analyze (baseline)

Phase 2: Discovery (read-only)
└── Scan lib/ → build dependency map → categorize issues

Phase 3: Fix by Category (one commit each)
├── 1. Remove unused imports
├── 2. Remove dead code
├── 3. Centralize duplicated constants
├── 4. Extract duplicated logic
├── 5. Standardize patterns
└── 6. Refactor spaghetti code

Phase 4: Validation
├── flutter analyze (zero new issues)
└── flutter test (zero new failures)

Phase 5: Pull Request
└── Create PR with quality report — DO NOT merge
```

### Safety Guarantees

- **No business logic changes** — only structural refactoring
- **No test modifications** — except removing imports of deleted code
- **Incremental commits** — easy to cherry-pick or revert individual categories
- **Validation gates** — `flutter analyze` + `flutter test` after all changes
- **Never merges** — always leaves PR for human review
- **Conservative removal** — when uncertain if code is used, keeps it

## Adapting to Other Languages

While designed for Flutter/Dart, the agent can be adapted:

| What to Change | Dart/Flutter | JavaScript/TypeScript | Python |
|---------------|-------------|----------------------|--------|
| Source directory | `lib/` | `src/` | `src/` or root |
| Analysis command | `flutter analyze` | `eslint .` | `ruff check .` or `pylint` |
| Test command | `flutter test` | `npm test` | `pytest` |
| Naming conventions | lowerCamelCase | camelCase | snake_case |
| Import style | `import 'package:...'` | `import ... from '...'` | `from ... import ...` |
| Constants file | `constants.dart` | `constants.ts` | `constants.py` |

Edit the agent and skill files to match your language's conventions.

## Repository Structure

```
.github/
├── agents/
│   └── code-quality-sweep.agent.md    # Main agent orchestrator
└── skills/
    ├── unused-imports/skill.md         # Import cleanup
    ├── dead-code/skill.md              # Dead code removal
    ├── duplicated-constants/skill.md   # Constant centralization
    ├── duplicated-logic/skill.md       # Logic deduplication
    ├── inconsistent-patterns/skill.md  # Pattern standardization
    ├── spaghetti-code/skill.md         # Structure improvement
    └── quality-report/skill.md         # Report generation
```

## Output Example

After a sweep, the PR body contains a structured report:

```
## Code Quality Sweep Report

| Metric         | Value       |
|----------------|-------------|
| Files scanned  | 42          |
| Files modified | 19          |
| Lines removed  | 483         |
| Lines added    | 125         |
| Net reduction  | -358 lines  |

### Validation
| Check            | Status |
|------------------|--------|
| flutter analyze  | PASS   |
| flutter test     | PASS (448 passed, 0 failed) |

### Changes by Category
1. Unused Imports — 12 imports removed
2. Dead Code — 3 files deleted, 14 methods removed
3. Duplicated Constants — 30 Color values centralized into NosColors
4. Duplicated Logic — 2 widget patterns extracted
5. Inconsistent Patterns — async standardized in 4 files
6. Spaghetti Code — 3 build methods split
```

## License

MIT

## References

- [GitHub Copilot Custom Agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- [Effective Dart Style Guide](https://dart.dev/effective-dart/style)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
