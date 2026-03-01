---
applyTo: "**/*.{js,ts,jsx,tsx}"
---

# JavaScript / TypeScript Code Quality Conventions

## Naming
- Functions and variables: `camelCase`
- Classes and components: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- File names: `kebab-case.ts` for utilities, `PascalCase.tsx` for components

## TypeScript
Prefer TypeScript over JavaScript when `tsconfig.json` exists. Avoid `any` — use `unknown` and narrow with type guards.

## Dead Code Signals
- Tree-shaking candidates (exported but never imported elsewhere)
- Unused `package.json` dependencies (declared but never imported)
- Unused React components (defined but not rendered)

## Error Handling
- No unhandled promises — always `.catch()` or `try/catch` in async functions
- No empty `catch {}` blocks
- API calls must handle error responses, not just network failures

## Example
```typescript
async function fetchUserProfile(userId: string): Promise<UserProfile> {
  const response = await fetch(`/api/v1/users/${encodeURIComponent(userId)}`);
  if (!response.ok) {
    throw new ApiError(`Failed to fetch user: ${response.status}`, response.status);
  }
  return response.json() as Promise<UserProfile>;
}
```
