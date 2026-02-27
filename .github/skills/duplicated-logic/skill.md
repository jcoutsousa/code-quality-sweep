---
name: duplicated-logic
description: >
  Detects duplicated or near-duplicated functions, methods, code blocks, and
  widget patterns across files. Extracts shared logic into utilities, mixins,
  or reusable widgets.
---

# Duplicated Logic Skill

Find duplicated code blocks and extract them into shared utilities or reusable components.

## Step 1: Identify Duplication Patterns

### Exact Duplicates

Search for identical or near-identical code blocks (>5 lines) appearing in multiple files:

1. **Functions with identical bodies** — same logic, possibly different names
2. **Copy-pasted code blocks** — same sequence of statements in different methods
3. **Identical widget subtrees** — same widget composition in multiple build methods

### Near Duplicates (structural clones)

Look for functions/blocks that:
- Have the same structure but different variable names
- Differ only in 1-2 parameters or constants
- Follow the same pattern with minor variations

### Common Flutter Duplication Patterns

```dart
// 1. Repeated error handling / snackbar logic
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(...), backgroundColor: ...),
);

// 2. Repeated dialog patterns
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(...),
    content: Text(...),
    actions: [...],
  ),
);

// 3. Repeated API call patterns
try {
  final response = await apiClient.someMethod();
  // handle success
} catch (e) {
  // handle error (same pattern)
}

// 4. Repeated navigation patterns
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => SomeScreen()),
);

// 5. Repeated widget decoration
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: someColor,
    boxShadow: [...],
  ),
  child: ...
)

// 6. Repeated list item builders
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    // Same structure, different data
  },
)
```

## Step 2: Analyze Duplication

For each duplicate found:

1. **Count occurrences** — how many times does this pattern appear?
2. **Measure similarity** — exact duplicate, structural clone, or similar pattern?
3. **Assess extraction difficulty** — simple extract vs. needs parameterization
4. **Evaluate benefit** — is extraction worth the abstraction cost?

**Rules of thumb:**
- 3+ exact duplicates → always extract
- 2 exact duplicates > 10 lines → extract
- 2 near-duplicates → extract only if the abstraction is natural and clear
- If extraction would require >3 parameters → consider whether the abstraction is worth it

## Step 3: Extract Shared Logic

Choose the appropriate extraction pattern:

### Utility Functions
For duplicated logic that is stateless and reusable:
```dart
// Before: same validation logic in 3 files
if (email == null || !email.contains('@') || email.length < 5) { ... }

// After: shared utility
// lib/utils/validators.dart
bool isValidEmail(String? email) =>
    email != null && email.contains('@') && email.length >= 5;
```

### Reusable Widgets
For duplicated widget compositions:
```dart
// Before: same card pattern in 4 screens
Container(
  decoration: BoxDecoration(...),
  padding: EdgeInsets.all(16),
  child: Column(children: [...]),
)

// After: reusable widget
// lib/widgets/info_card.dart
class InfoCard extends StatelessWidget {
  final List<Widget> children;
  const InfoCard({required this.children});
  // ...
}
```

### Mixins
For duplicated behavior shared across classes:
```dart
// Before: same loading state logic in multiple ViewModels
bool _isLoading = false;
void setLoading(bool value) { ... }

// After: shared mixin
mixin LoadingMixin on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) { _isLoading = value; notifyListeners(); }
}
```

### Extension Methods
For duplicated operations on existing types:
```dart
// Before: same string formatting in multiple places
text.replaceAll('\n', ' ').trim().toLowerCase()

// After: extension
extension StringFormatting on String {
  String normalizeWhitespace() => replaceAll('\n', ' ').trim();
}
```

## Step 4: Update All Call Sites

After extraction:
1. Replace all duplicate occurrences with calls to the shared utility
2. Update imports in all affected files
3. Verify no occurrence was missed with a project-wide search

## Step 5: Validate

1. `flutter analyze` — no new errors
2. `flutter test` — all tests pass
3. Manual review: does the extraction improve or hurt readability?

## Output Format

```markdown
## Duplicated Logic Audit

### Summary
- **Duplicate patterns found**: [count]
- **Extractions performed**: [count]
- **Lines saved**: [count]
- **New shared files created**: [count]

### Extractions Performed

| Pattern | Occurrences | Extracted To | Type |
|---------|-------------|-------------|------|
| Error snackbar display | 4 | lib/utils/ui_helpers.dart | Utility function |
| Card decoration widget | 3 | lib/widgets/info_card.dart | Widget |
| API error handling | 5 | lib/services/base_service.dart | Mixin |

### Duplicates Kept (not worth extracting)

| Pattern | Occurrences | Reason |
|---------|-------------|--------|
| Simple null check | 2 | Too simple, extraction adds complexity |
```
