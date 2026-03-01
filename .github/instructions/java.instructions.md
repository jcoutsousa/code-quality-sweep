---
applyTo: "**/*.{java,kt}"
---

# Java / Kotlin Code Quality Conventions

## Java Naming
- Methods and variables: `camelCase`
- Classes and interfaces: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Packages: `lowercase` (e.g., `com.example.userservice`)

## Kotlin Naming
- Same as Java conventions
- Prefer `val` over `var` (immutability by default)
- Use data classes for DTOs and value objects

## Dead Code Signals
- Unused private methods (never called within the class)
- Dead Spring beans (defined but never injected)
- Unused `@Autowired` fields
- Unreachable branches in `when`/`switch` statements

## Error Handling
- No bare `catch (Exception e)` — use specific exception types
- No empty catch blocks — at minimum log the exception
- Use `try-with-resources` / `.use {}` for closeable resources
- Spring: use `@ExceptionHandler` or `@ControllerAdvice` for API error responses

## Example
```java
public UserProfile getUserById(String userId) {
    return userRepository.findById(userId)
        .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
}
```

```kotlin
fun getUserById(userId: String): UserProfile =
    userRepository.findById(userId)
        ?: throw UserNotFoundException("User not found: $userId")
```
