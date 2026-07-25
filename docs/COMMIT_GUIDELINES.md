# Commit Guidelines - Logistics Vision AI

We enforce the **Conventional Commits** specification. This ensures our commit history remains legible and automated changelogs can be generated easily.

---

## 1. Commit Structure
Every commit must follow this layout:
```
<type>(<scope>): <subject> [Task reference]

[optional body]
```

### Allowed Types
*   **feat**: A new feature implementation.
*   **fix**: A bug repair.
*   **docs**: Documentations modifications.
*   **style**: Code styling adjustments (no functional code changes).
*   **refactor**: Reworking existing code without changing behavior.
*   **perf**: Code modifications to improve execution speed.
*   **test**: Writing or adjusting tests.
*   **chore**: Tooling, settings, or dependency configurations updates.

### Scope
Specifies the affected module, such as `mobile`, `backend`, `sync`, or `ai`.

---

## 2. Examples
*   `feat(mobile): add camera flash toggle UI [TSK-101]`
*   `fix(sync): retry batch upload on 503 service unavailable error [TSK-151]`
*   `chore(deps): upgrade GoRouter version to v13 [TSK-001]`
