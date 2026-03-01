---
applyTo: "**/*.dart"
---

# Flutter / Dart Code Quality Conventions

## Naming
- Variables and functions: `lowerCamelCase`
- Classes, enums, typedefs: `UpperCamelCase`
- Constants: `lowerCamelCase` (Dart convention — not UPPER_SNAKE_CASE)
- Libraries and packages: `lowercase_with_underscores`
- Private members: `_leadingUnderscore`

## Widget Structure
- Maximum widget nesting depth: 5 levels — extract sub-widgets beyond this
- Prefer `const` constructors where possible
- Separate business logic from widget build methods

## Dead Code Signals
- Unused widgets (defined but never instantiated)
- Unused asset declarations in `pubspec.yaml`
- Unused imports flagged by `dart analyze`

## Testing
- Widget tests should use `pumpWidget` and verify rendered output
- Use `setUp`/`tearDown` for shared test state
- Mock external dependencies with `mocktail` or `mockito`

## Example
```dart
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
        title: Text(user.displayName),
        subtitle: Text(user.email),
      ),
    );
  }
}
```
