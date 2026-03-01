---
applyTo: "**/*.py"
---

# Python Code Quality Conventions

## Naming
- Functions and variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private members: `_leading_underscore`

## Type Hints
Require type hints on all public function signatures. Use `from __future__ import annotations` for forward references.

## Docstrings
Public functions and classes must have docstrings (Google style preferred).

## Dead Code Signals
- Check `__all__` exports vs actual module contents
- Unused entries in `requirements.txt` or `pyproject.toml` dependencies
- Functions defined but never called across the project

## Error Handling
- No bare `except:` — always specify exception type
- No `except Exception:` without re-raising or logging
- Wrap I/O and network calls in try/except with specific exceptions

## Example
```python
def calculate_total(items: list[OrderItem], tax_rate: float = 0.0) -> Decimal:
    """Calculate the total price including tax for a list of order items."""
    subtotal = sum(item.price * item.quantity for item in items)
    return subtotal * (1 + Decimal(str(tax_rate)))
```
