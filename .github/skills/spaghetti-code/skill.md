---
name: spaghetti-code
description: >
  Detects and refactors spaghetti code including overly long functions, deeply
  nested widget trees, mixed business/UI logic, excessive coupling, and god
  classes. Improves code structure and maintainability.
---

# Spaghetti Code Skill

Detect and refactor structural code issues that harm maintainability and readability.

## Step 1: Function Length Analysis

### Find Long Functions (>50 lines)

Scan all `.dart` files for functions and methods exceeding 50 lines of code (excluding comments and blank lines).

**Thresholds:**
| Length | Severity | Action |
|--------|----------|--------|
| >100 lines | Critical | Must refactor |
| 50-100 lines | Warning | Should refactor |
| 30-50 lines | Info | Review for clarity |

### Refactoring Strategy for Long Functions

1. **Identify logical sections** — look for comment blocks or blank lines that separate concerns
2. **Extract methods** — each logical section becomes a named method
3. **Name methods descriptively** — the name should explain WHAT, not HOW
4. **Preserve the original method** as a high-level orchestrator

```dart
// Before: 120-line _handleSubmit method
void _handleSubmit() {
  // validation (20 lines)
  // ...
  // API call (30 lines)
  // ...
  // state update (25 lines)
  // ...
  // navigation (15 lines)
  // ...
}

// After: orchestrator + focused methods
void _handleSubmit() {
  if (!_validateForm()) return;
  final result = await _submitToApi();
  _updateState(result);
  _navigateToConfirmation();
}
```

## Step 2: Widget Build Method Analysis

### Find Long Build Methods (>100 lines)

Widget `build()` methods over 100 lines should be broken into smaller widgets.

**Search pattern:**
```
Widget build\(BuildContext context\)
```

### Refactoring Strategy for Long Build Methods

1. **Extract widget subtrees** into private widget methods or separate widget classes
2. **Prefer separate widget classes** over private methods (better performance with const)
3. **Name extracted widgets** by their purpose, not their structure

```dart
// Before: 150-line build method with nested Column > ListView > Cards

// After:
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),           // or const HeaderSection()
      _buildContentList(),      // or const ContentList()
      _buildActionButtons(),    // or const ActionButtons()
    ],
  );
}
```

## Step 3: Nesting Depth Analysis

### Find Deep Nesting (>3 levels of indentation in logic, >5 in widgets)

**Logic nesting (if/for/while):**
```dart
// Bad: >3 levels
if (condition1) {
  if (condition2) {
    for (var item in items) {
      if (condition3) {
        // 4 levels deep — too much
      }
    }
  }
}

// Fix: early returns and extraction
if (!condition1) return;
if (!condition2) return;
for (var item in items) {
  _processItem(item);
}
```

**Widget nesting:**
```dart
// Bad: >5 levels of widget nesting without extraction
Scaffold(
  body: SafeArea(
    child: Padding(
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: // 7 levels deep
                )
              ]
            )
          )
        ]
      )
    )
  )
)
```

## Step 4: Mixed Concerns Analysis

### Business Logic in UI Code

Search for these anti-patterns in widget files:

```dart
// API calls directly in widgets
http.get(
await apiClient.
await repository.

// Data transformation in build methods
items.where(
items.map(
items.sort(

// Complex calculations in widgets
if (price * quantity * tax > threshold) {

// State mutations in build methods (outside of callbacks)
setState(() {
  // complex logic here
});
```

**Fix:** Move business logic to ViewModel, Controller, or Service classes.

### UI Logic in Business Classes

Search for these in service/viewmodel/repository files:

```dart
// UI framework imports in non-UI files
import 'package:flutter/material.dart';  // in a service file
import 'package:flutter/widgets.dart';   // in a repository file

// Navigation in business logic
Navigator.of(context)

// Scaffold/SnackBar in business logic
ScaffoldMessenger

// BuildContext in service methods
void doSomething(BuildContext context)
```

**Fix:** Return data/state, let the UI layer handle presentation.

## Step 5: God Class Detection

### Find Classes with Too Many Responsibilities

**Indicators:**
- Class has >500 lines
- Class has >15 public methods
- Class imports from >10 different files
- Class name is vague (`Manager`, `Helper`, `Utils`, `Handler`)

**Fix:** Split into focused classes following Single Responsibility Principle.

## Step 6: Excessive Coupling Detection

### Find Tight Coupling

```dart
// Direct instantiation of dependencies (instead of injection)
final service = ApiService();  // in a widget

// Long method chains
widget.parent.context.service.repository.method()

// Circular dependencies
// file_a.dart imports file_b.dart AND file_b.dart imports file_a.dart
```

## Step 7: Apply Fixes

Priority order:
1. **Critical**: Functions >100 lines, build methods >150 lines
2. **High**: Mixed concerns (business logic in UI)
3. **Medium**: Deep nesting, god classes
4. **Low**: Minor coupling issues

## Output Format

```markdown
## Spaghetti Code Audit

### Summary
- **Long functions found**: [count] (>[50 lines])
- **Long build methods found**: [count] (>[100 lines])
- **Deep nesting found**: [count] (>[3 levels])
- **Mixed concerns found**: [count]
- **God classes found**: [count]

### Refactored Functions

| File | Method | Before | After | Extraction |
|------|--------|--------|-------|------------|
| lib/views/settings.dart | build() | 180 lines | 45 lines | 4 sub-widgets |
| lib/services/auth.dart | login() | 85 lines | 30 lines | 3 helper methods |

### Mixed Concerns Fixed

| File | Issue | Fix |
|------|-------|-----|
| lib/views/home.dart:45 | API call in build() | Moved to ViewModel |
| lib/services/api.dart:23 | Navigator in service | Returns result, UI navigates |

### Nesting Reduced

| File | Method | Before | After | Technique |
|------|--------|--------|-------|-----------|
| lib/utils/parser.dart:67 | parse() | 5 levels | 2 levels | Early returns |
```
