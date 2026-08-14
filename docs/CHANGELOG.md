# Changelog - Logistics Vision AI

All notable changes to this project will be documented in this file.

---

## [Unreleased]
### Changed
- Reduced visible login time by returning the authenticated profile with the token, removing redundant database work, and keeping indexed employee-ID lookup.
- Moved mobile offline-credential hashing and AI model warm-up off the dashboard navigation path without weakening password hashing.
- Layer History photos now keep layer/carton context visible and can optionally reproduce the verified AI mask polygons saved with new layers.

## [1.0.0-alpha] - 2026-07-25
### Added
- Monorepo directory structure layout initialized (`apps/`, `packages/`, `ai/`, `docs/`, `infrastructure/`).
- Mobile project foundation bootstrapped inside `apps/mobile`.
- GoRouter navigation system configuration skeleton.
- Riverpod state management and dependency injection outline.
- Centralized exception handlers, failures classes, and logger utilities.
- High-contrast light and dark Material 3 theme configurations.
- GitHub Actions CI/CD workflows and `.gitignore` file configurations.
- Developer standard documentation guidelines.
