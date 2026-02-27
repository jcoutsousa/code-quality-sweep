---
name: duplicated-constants
description: >
  Detects hardcoded values and duplicated constants scattered across files.
  Centralizes colors, strings, numbers, URLs, emails, padding values, and
  TextStyles into appropriate constants or theme files.
---

# Duplicated Constants Skill

Find hardcoded values repeated across files and centralize them into a single source of truth.

## Step 1: Scan for Hardcoded Values

### Colors
```
Color\(0x[0-9A-Fa-f]+\)
Color\.fromARGB\(\s*\d+
Color\.fromRGBO\(\s*\d+
Colors\.[a-zA-Z]+
```

Build a frequency map: which color values appear in more than one file?

### Magic Numbers
```
# Padding, margin, radius values
EdgeInsets\.(all|symmetric|only|fromLTRB)\(\s*\d+
BorderRadius\.circular\(\s*\d+
SizedBox\((width|height):\s*\d+
\.0\)  # decimal values like 16.0, 24.0
```

### Hardcoded Strings
```
# URLs
https?://[^\s'"]+

# Email addresses
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# API paths
'/api/[^\s'"]+
"/api/[^\s'"]+
```

### TextStyle Definitions
```
TextStyle\(
  fontSize:\s*\d+
  fontWeight:\s*FontWeight\.\w+
  color:\s*
```

### Duration Values
```
Duration\((milliseconds|seconds|minutes):\s*\d+\)
```

## Step 2: Group and Categorize

For each duplicated value:

1. **Count occurrences** across files
2. **Identify the semantic meaning** (e.g., `Color(0xFF1A237E)` → "NOS primary blue")
3. **Determine the right home**:
   - Colors → `constants.dart` or `theme.dart` as a `NosColors` class
   - Spacing/sizing → `constants.dart` or `theme.dart` as a `NosSpacing` class
   - URLs/endpoints → `constants.dart` as `ApiEndpoints` or `AppConfig`
   - Strings → `constants.dart` as `AppInfo` or localization files
   - Durations → `constants.dart` as `AppDurations`
   - TextStyles → `theme.dart` or `TextTheme` extension

## Step 3: Centralize

For each category:

1. **Create or update** the appropriate constants file
2. **Define named constants** with descriptive names:

```dart
// Good:
class NosColors {
  static const Color primary = Color(0xFF1A237E);
  static const Color surface = Color(0xFF121212);
  static const Color error = Color(0xFFCF6679);
}

// Bad:
static const color1 = Color(0xFF1A237E);
```

3. **Replace all occurrences** with the centralized constant
4. **Verify no occurrence was missed** by searching for the raw value

## Step 4: Handle Duplicate Constant Definitions

If the same constant is defined in multiple files:

1. **Choose the canonical location** (usually `constants.dart` or the most central file)
2. **Update all imports** to point to the canonical location
3. **Remove duplicate definitions**

Example:
```dart
// Before: defined in both settings_viewmodel.dart and constants.dart
// settings_viewmodel.dart
const supportEmail = 'support@example.com';
// constants.dart
static const email = 'support@example.com';

// After: single definition in constants.dart
class AppInfo {
  static const supportEmail = 'support@example.com';
}
```

## Step 5: Validate

1. Search for raw values to ensure none were missed
2. `flutter analyze` — no new errors
3. `flutter test` — all tests pass

## Output Format

```markdown
## Duplicated Constants Audit

### Summary
- **Hardcoded values found**: [count]
- **Unique values duplicated**: [count]
- **Files modified**: [count]
- **Constants centralized**: [count]

### Colors Centralized

| Raw Value | Constant Name | Occurrences | Files |
|-----------|--------------|-------------|-------|
| Color.fromARGB(255, 26, 35, 126) | NosColors.primary | 8 | 5 |
| Color.fromARGB(255, 18, 18, 18) | NosColors.surface | 6 | 4 |

### Strings Centralized

| Value | Constant Name | Occurrences |
|-------|--------------|-------------|
| support@example.com | AppInfo.supportEmail | 3 |

### Duplicate Definitions Consolidated

| Constant | Was In | Moved To |
|----------|--------|----------|
| supportEmail | settings_viewmodel.dart, constants.dart | constants.dart only |
```
