---
name: unused-imports
description: >
  Detects and removes unused imports across the Flutter/Dart codebase.
  Handles direct imports, transitive imports, show/hide directives, and
  part/part-of relationships.
---

# Unused Imports Skill

Remove all unused imports while preserving necessary dependencies.

## Step 1: Identify All Import Statements

Search for import patterns in all `.dart` files:

```
^import\s+'
^import\s+"
^export\s+'
```

Categorize each import by type:
- `dart:` — Dart SDK imports
- `package:` — Package imports (pub dependencies + project package)
- Relative imports (`../`, `./`)
- `part` / `part of` directives

## Step 2: Analyze Usage

For each import in a file:

1. **Extract imported symbols** — check for `show` / `hide` directives
2. **Search file body** — verify at least one symbol from the import is used
3. **Check transitive usage** — an import may be unused directly but re-exported

**Common false positives to avoid:**
- Imports used only in annotations (`@override`, `@JsonSerializable`)
- Imports used in type parameters (`List<SomeType>`)
- Imports used in `as` prefixes that appear in the file body
- Imports of files containing `extension` methods (may be used implicitly)
- `part` files that rely on the parent's imports

## Step 3: Verify Before Removing

For each candidate unused import:

1. Search the **entire file** (not just the import section) for any reference
2. Check if the import provides extension methods used in the file
3. Check if the import is needed for code generation (build_runner, freezed, json_serializable)
4. If uncertain, **keep the import** — false negatives are safer than false positives

## Step 4: Fix Import Organization

After removing unused imports, organize remaining imports per Dart style guide:

```dart
// 1. dart: imports (alphabetical)
import 'dart:async';
import 'dart:io';

// 2. package: imports (alphabetical)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. Relative imports (alphabetical)
import '../models/user.dart';
import '../services/api_client.dart';
```

## Step 5: Validate

Run `dart analyze` or `flutter analyze` and confirm:
- No new "unused import" warnings were introduced
- No new "undefined" errors (import was actually needed)

## Output Format

```markdown
## Unused Imports Audit

### Summary
- **Files scanned**: [count]
- **Unused imports found**: [count]
- **Files modified**: [count]

### Removed Imports

| File | Removed Import | Reason |
|------|---------------|--------|
| lib/path/file.dart | package:http/http.dart | No symbols referenced |
| lib/path/other.dart | ../models/old_model.dart | File references deprecated class |

### Kept (uncertain)

| File | Import | Reason Kept |
|------|--------|-------------|
| lib/path/file.dart | package:freezed_annotation | May be needed for code generation |
```
