# Coding Standards — AI-NATIVE Platform

> Last updated: 2026-03-20 | Enforced via CI/CD — not optional

---

## Universal Rules (All Languages)

1. **No secrets in code** — use environment variables; reference Vault paths in comments
2. **No raw SQL** — use ORM or parameterized queries only
3. **Validate all external input** at the boundary (API handlers, event consumers)
4. **Every public function needs a docstring** in the language-native format
5. **Error messages must not leak internals** — log detail server-side; return generic message to client
6. **No `TODO` in merged code** — convert to GitHub issues before merging

---

## Python (FastAPI / Services)

### Toolchain
| Tool | Purpose | Config file |
|------|---------|------------|
| `ruff` | Linting + formatting (replaces flake8/black/isort) | `pyproject.toml` |
| `mypy` | Static type checking (strict mode) | `pyproject.toml` |
| `pytest` | Testing | `pyproject.toml` |
| `pytest-cov` | Coverage gate: 80% minimum | `pyproject.toml` |

### Standards
```python
# Good — typed, documented, validated
from pydantic import BaseModel, field_validator

class CreateUserRequest(BaseModel):
    email: str
    display_name: str

    @field_validator("email")
    @classmethod
    def validate_email(cls, v: str) -> str:
        if "@" not in v:
            raise ValueError("Invalid email format")
        return v.lower().strip()


async def create_user(request: CreateUserRequest, db: AsyncSession) -> User:
    """Create a new user record.

    Args:
        request: Validated user creation payload.
        db: Async database session.

    Returns:
        The newly created User model instance.

    Raises:
        DuplicateEmailError: If email already exists.
    """
    ...
```

### Project Structure
```
services/api/
├── app/
│   ├── main.py              # FastAPI app factory
│   ├── config.py            # Settings via pydantic-settings
│   ├── dependencies.py      # FastAPI deps (auth, db session)
│   ├── routers/             # Route handlers — thin, delegate to services
│   ├── services/            # Business logic — no HTTP concerns
│   ├── models/              # SQLAlchemy ORM models
│   ├── schemas/             # Pydantic request/response schemas
│   └── core/
│       ├── security.py
│       ├── logging.py       # OTel structured logging
│       └── exceptions.py
├── tests/
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── pyproject.toml
└── Dockerfile
```

---

## TypeScript / Next.js (Frontend)

### Toolchain
| Tool | Purpose |
|------|---------|
| TypeScript strict mode | Type safety — `"strict": true` in tsconfig |
| ESLint + `@typescript-eslint` | Linting |
| Prettier | Formatting |
| Vitest | Unit tests |
| Playwright | E2E tests |

### Standards
```typescript
// Good — typed props, no `any`, error boundaries
interface UserCardProps {
  userId: string;
  displayName: string;
  onSelect: (userId: string) => void;
}

export function UserCard({ userId, displayName, onSelect }: UserCardProps) {
  return (
    <button onClick={() => onSelect(userId)}>
      {displayName}
    </button>
  );
}

// Never use `any` — use `unknown` + type guard instead
function parseApiResponse(data: unknown): User {
  if (!isUser(data)) throw new Error("Invalid user shape");
  return data;
}
```

---

## Terraform (Infrastructure)

```hcl
# Good — documented variable, constrained type
variable "instance_type" {
  description = "EC2 instance type for app node group"
  type        = string
  default     = "m6i.2xlarge"

  validation {
    condition     = can(regex("^m6i\\.", var.instance_type))
    error_message = "Only m6i instance family is approved for app nodes."
  }
}
```

Rules:
- All modules must have `README.md` with input/output docs
- No `count` for critical resources — use `for_each` with explicit keys
- Always `terraform fmt` before commit (enforced by pre-commit hook)
- `terraform validate` runs in CI on every PR touching `infra/`

---

## Git Commit Messages

Follow **Conventional Commits**:
```
<type>(<scope>): <short description>

[optional body]
[optional footer]
```

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `infra` | Infrastructure change |
| `docs` | Documentation only |
| `refactor` | Code change without feature/fix |
| `test` | Adding or fixing tests |
| `ci` | CI/CD pipeline changes |
| `security` | Security fix (use sparingly; don't reveal vuln details) |

Examples:
```
feat(api): add user preference endpoint
fix(ai-agent): retry on 429 rate limit from Claude API
infra(eks): increase max node count to 10
security: rotate JWT signing key rotation period to 12h
```

---

## Code Review Checklist

Before approving any PR, verify:

- [ ] No secrets or credentials in diff
- [ ] All external inputs validated
- [ ] Error handling doesn't leak internals
- [ ] New code has tests (coverage gate passes)
- [ ] OTel tracing added for new service calls
- [ ] Kubernetes resource limits set (if adding a new workload)
- [ ] ADR created for significant architectural changes
- [ ] `CLAUDE.md` updated if project context changed
