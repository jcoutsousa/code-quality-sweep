---
name: inconsistent-patterns
description: >
  Detects and fixes inconsistent naming conventions, coding patterns, import
  styles, async patterns, and error handling across the codebase. Enforces
  Dart/Flutter style guide compliance.
---

# Inconsistent Patterns Skill

Standardize naming conventions, coding patterns, and style across the codebase.

## Step 1: Naming Convention Audit

### File Names (lowercase_with_underscores)
```
# Correct: user_profile.dart, api_client.dart
# Wrong: UserProfile.dart, apiClient.dart, user-profile.dart

# Search for violations:
find lib/ -name "*.dart" | grep -E '[A-Z]|[^_a-z0-9.]'
```

### Class Names (UpperCamelCase)
```dart
// Correct: UserProfile, ApiClient, HomeScreen
// Wrong: userProfile, API_Client, home_screen

// Search pattern:
^class [a-z]|^class [A-Z]+[_]
```

### Variable & Function Names (lowerCamelCase)
```dart
// Correct: userName, fetchData(), isLoading
// Wrong: user_name, fetch_data(), is_loading

// Search for snake_case in Dart (excluding constants):
\b[a-z]+_[a-z]+\b  // in function bodies, not in string literals
```

### Constants (lowerCamelCase or SCREAMING_CAPS — be consistent)
```dart
// Dart style guide prefers lowerCamelCase for constants:
const maxRetries = 3;
const defaultTimeout = Duration(seconds: 30);

// But if the project uses SCREAMING_CAPS consistently, maintain that:
const MAX_RETRIES = 3;

// The key is: be consistent throughout the project
```

### Private Members (prefixed with underscore)
```dart
// Correct: _isLoading, _fetchData(), _UserState
// Check for private members that should be public or vice versa
```

## Step 2: Async Pattern Audit

### Mixed async/await and .then()
```dart
// Inconsistent — mixing styles in the same codebase:
// File A:
final data = await fetchData();

// File B:
fetchData().then((data) {
  // ...
}).catchError((e) {
  // ...
});

// Standardize to async/await (preferred in Dart):
try {
  final data = await fetchData();
} catch (e) {
  // ...
}
```

### Search for .then() patterns that should be async/await:
```
\.then\(
\.catchError\(
\.whenComplete\(
```

## Step 3: Error Handling Pattern Audit

### Mixed error handling styles
```dart
// Check for consistency in:

// 1. Try/catch granularity
try { /* too much code */ } catch (e) { /* generic */ }  // Bad
try { /* specific operation */ } on SpecificException { /* specific */ }  // Good

// 2. Error reporting
print(e);           // Some files
debugPrint(e);      // Other files
logger.error(e);    // Yet others

// Standardize to one approach
```

### Search patterns:
```
catch\s*\(e\)\s*\{[\s]*\}     # Empty catch blocks
print\(.*error\|exception      # Print-based error handling
rethrow                         # Rethrow usage consistency
```

## Step 4: Import Style Audit

### Relative vs Package Imports
```dart
// Check for consistency — the project should use one style:

// Package imports (preferred for libraries):
import 'package:myapp/models/user.dart';

// Relative imports (acceptable for app code):
import '../models/user.dart';

// Never mix both styles for the same file
```

### Import Organization
```dart
// Standard order (check all files follow this):
// 1. dart: imports
// 2. package: imports (external packages first, then project package)
// 3. Relative imports
// Alphabetical within each section
```

## Step 5: Widget Pattern Audit

### Const Constructor Usage
```dart
// Missing const where possible:
Container(child: Text('hello'))      // Bad
const SizedBox(height: 16)           // Good — search for missing const
```

### Key Usage in Lists
```dart
// Missing keys in list items:
ListView(children: [
  ListTile(title: Text('item')),     // Missing Key
])

// Search for list builders without keys:
itemBuilder.*=>(?!.*key:)
```

## Step 6: Apply Fixes

For each inconsistency category:
1. Determine the **dominant pattern** in the codebase (>60% usage)
2. Standardize all files to the dominant pattern
3. If no dominant pattern exists, follow the Dart style guide
4. Make a single commit with all pattern standardizations

## Output Format

```markdown
## Inconsistent Patterns Audit

### Summary
- **Pattern categories checked**: [count]
- **Inconsistencies found**: [count]
- **Files modified**: [count]

### Naming Convention Fixes

| File | Before | After | Rule |
|------|--------|-------|------|
| lib/utils/api_helper.dart | fetch_data() | fetchData() | lowerCamelCase |

### Async Pattern Standardization

| File | Before | After |
|------|--------|-------|
| lib/services/auth.dart:45 | .then().catchError() | async/await + try/catch |

### Import Style Fixes

| File | Issue | Fix |
|------|-------|-----|
| lib/views/home.dart | Mixed relative and package imports | Standardized to relative |

### Error Handling Standardization

| File | Before | After |
|------|--------|-------|
| lib/services/api.dart:23 | print(error) | debugPrint(error) |
```
