# Contributing Guidelines - Logistics Vision AI

Thank you for contributing to the Logistics Vision AI project. To maintain the quality of our enterprise-grade code, please follow the guidelines below.

---

## 1. Branch Management
*   **Production Branch**: `main` (only updated via automated release deployments from `develop`).
*   **Development Branch**: `develop` (all feature branches merge here via Pull Request).
*   **Feature Branches**: Named as `feature/TSK-XXX-short-description` matching task identifiers in the task registry.
*   **Hotfix Branches**: Named as `hotfix/short-description`.

---

## 2. Pull Request (PR) Requirements
Before submitting a PR, make sure your branch compiles and satisfies all validations:
1.  **Format Code**:
    ```bash
    flutter format lib/ test/
    ```
2.  **Run Linter**:
    ```bash
    flutter analyze
    ```
3.  **Execute Tests**:
    - Ensure all unit, widget, and integration tests pass locally.
    - Write unit tests for new business cases and entities added.
4.  **No Unrelated Modifications**: Ensure changes are strictly isolated to files under the target task's scope.
