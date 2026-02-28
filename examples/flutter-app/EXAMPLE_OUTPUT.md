# Example: Flutter Mobile App Sweep

## Key Findings
- **12 widgets exceed nesting depth 5** — extract sub-widgets
- **7 Firebase calls without error handling** — silent failures in checkout flow
- **12% test coverage** — 4 widget tests, 2 unit tests across 47 files
- **Widgets call FirebaseFirestore.instance directly** — no repository layer
- **No dependency injection** — Firebase instances created inline

**Scalability Score: 1.8/5**

**Immediate actions:** Create repository layer, add models with serialization, implement DI, add error states to BLoC.
