---
name: dead-code
description: >
  Detects and removes dead code including unused classes, functions, methods,
  variables, entire files, deprecated wrappers, empty lifecycle overrides,
  and commented-out code blocks.
---

# Dead Code Skill

Remove all dead code while preserving symbols that are referenced anywhere in the project.

## Step 1: Identify Candidate Dead Code

Search for these categories:

### Unused Functions & Methods
```
# Top-level functions — search for definition, then search for invocations
^[A-Za-z<>_]+ [a-z][a-zA-Z0-9_]*\(

# Private methods — prefixed with underscore
_[a-z][a-zA-Z0-9_]*\(
```

### Unused Classes
```
# Class definitions
^class [A-Z][a-zA-Z0-9_]+

# Mixin definitions
^mixin [A-Z][a-zA-Z0-9_]+

# Enum definitions
^enum [A-Z][a-zA-Z0-9_]+
```

### Unused Variables & Constants
```
# Top-level constants
^const [a-z]
^final [a-z]
^const [A-Z]  # screaming case constants

# Static members
static const
static final
```

### Entire Unused Files

A file is dead if:
- No other file in the project imports it (search for its filename in all import statements)
- It is not referenced in `pubspec.yaml` or build configuration
- It is not a generated file (`.g.dart`, `.freezed.dart`)

### Empty Lifecycle Overrides
```dart
// These are dead code if they only call super:
@override
void dispose() {
  super.dispose();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
}

@override
void didUpdateWidget(covariant OldWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
}
```

### Deprecated Wrappers
```
@deprecated
@Deprecated(
// deprecated — called by nothing
```

### Commented-Out Code
```
// Large blocks of commented-out code (>3 consecutive lines)
^\s*//\s*[a-zA-Z].*\(
^\s*/\*[\s\S]*?\*/
```

## Step 2: Verify Each Candidate

For every candidate symbol:

1. **Search the entire project** (`lib/`, `test/`, `integration_test/`, `bin/`) for references
2. **Check re-exports** — a symbol may be exported from a barrel file
3. **Check reflection usage** — some frameworks use symbols by name
4. **Check generated code** — `.g.dart` and `.freezed.dart` files may reference it
5. **Check pubspec.yaml** — for entry points and asset references

**Keep the symbol if:**
- It appears in any test file (even if unused in production code)
- It is part of a public API (exported from the package)
- It is used via reflection or code generation
- You are not 100% certain it is unused

## Step 3: Remove Dead Code

Order of removal:
1. **Entire dead files** first (removes the most code)
2. **Dead classes and mixins** (may cascade to removing related methods)
3. **Dead functions and methods**
4. **Dead variables and constants**
5. **Empty lifecycle overrides**
6. **Commented-out code blocks** (>3 lines)

After removing, clean up any imports that become unused as a result.

## Step 4: Validate

After removal:
1. `flutter analyze` — no new errors
2. `flutter test` — all tests still pass
3. If a test fails, the symbol was NOT dead — restore it

## Output Format

```markdown
## Dead Code Audit

### Summary
- **Symbols scanned**: [count]
- **Dead symbols found**: [count]
- **Dead files found**: [count]
- **Lines removed**: [count]

### Dead Files Removed

| File | Reason | Lines |
|------|--------|-------|
| lib/utils/error_messages.dart | Zero imports across project | 45 |

### Dead Symbols Removed

| File | Symbol | Type | Lines |
|------|--------|------|-------|
| lib/viewmodels/settings_viewmodel.dart | _onLegacyToggle() | method | 23 |
| lib/services/api_client.dart | sendVisionQueryLegacy() | method | 67 |

### Commented-Out Code Removed

| File | Lines | Description |
|------|-------|-------------|
| lib/views/home_screen.dart:45-62 | 17 | Old navigation logic |

### Kept (uncertain)

| Symbol | Reason Kept |
|--------|-------------|
| BaseService.init() | May be used via reflection |
```
