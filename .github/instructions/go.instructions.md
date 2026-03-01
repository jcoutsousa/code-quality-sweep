---
applyTo: "**/*.go"
---

# Go Code Quality Conventions

## Naming
- Unexported: `camelCase` (functions, variables, types)
- Exported: `PascalCase` (functions, variables, types)
- Acronyms fully uppercase: `HTTPServer`, `JSONParser`, `URL` (not `HttpServer`, `JsonParser`, `Url`)
- Interfaces: single-method interfaces use `-er` suffix (`Reader`, `Writer`, `Handler`)

## Dead Code Signals
- Unexported functions never called within the same package
- Exported functions never imported by other packages
- Unused struct fields

## Error Handling
- Always check `err != nil` — never discard errors with `_`
- Wrap errors with context: `fmt.Errorf("failed to fetch user: %w", err)`
- Return errors rather than logging and continuing
- Use sentinel errors or custom error types for callers to inspect

## HTTP Clients
- Always set timeouts on `http.Client`
- Use `context.Context` for cancellation and deadlines
- Close response bodies with `defer resp.Body.Close()`

## Example
```go
func (s *UserService) GetByID(ctx context.Context, id string) (*User, error) {
	user, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("get user %s: %w", id, err)
	}
	return user, nil
}
```
