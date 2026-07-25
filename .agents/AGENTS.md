# Coding & Agent Standards - Logistics Vision AI

This document defines the strict engineering guidelines, coding patterns, folder structures, and architectural constraints that must be followed by all development agents (human and AI alike).

---

## 1. Directory Structure

All application components must be organized inside clean, domain-driven directories:

### Flutter Mobile App
```directory
lib/
├── core/
│   ├── network/            # API clients, network checkers
│   ├── database/           # SQLite connection, encryption key helpers
│   └── theme/              # High-contrast visual themes
├── domain/                 # Core domain layer (independent of frameworks)
│   ├── entities/           # Immutable data models
│   └── repositories/       # Abstract repository interfaces
├── data/                   # Data sources & concrete repository implementations
│   ├── models/             # API data transfer objects (DTOs)
│   ├── datasources/        # Local SQLite/Drift databases, remote Supabase clients
│   └── repositories_impl/  # Bridge from database/network to repository interfaces
├── presentation/           # UI elements & view state managers
│   ├── screens/            # Full-screen pages (Dashboard, Camera, etc.)
│   ├── widgets/            # Reusable components (Custom paint overlays, etc.)
│   └── providers/          # Riverpod state notifiers and async providers
└── main.dart               # App entrypoint
```

### FastAPI Python Backend
```directory
backend/
├── app/
│   ├── core/               # App configuration, security helpers
│   ├── db/                 # PostgreSQL connections and Prisma/SQLAlchemy setups
│   ├── models/             # ORM models
│   ├── schemas/            # Pydantic schemas (Request / Response validation)
│   ├── routers/            # API routing controllers
│   └── main.py             # FastAPI entrypoint
└── tests/                  # Integration and Unit tests
```

---

## 2. Coding Constraints for AI Agents

All coding tasks completed by AI agents must strictly adhere to the following rules:

> [!IMPORTANT]
> **Clean Architecture & SOLID Principles**
> *   Never mix layers. Do not reference presentation elements in the domain or data layers.
> *   Do not write direct database queries or API calls in screens or notifiers. Use repositories.
> *   Write clear interface classes in the `domain` layer and implement them in the `data` layer.

> [!IMPORTANT]
> **State Management Patterns**
> *   Only use Riverpod for state management. Avoid using raw `StatefulWidget` states for shared business state.
> *   Use `Notifier` or `AsyncNotifier` from Riverpod. Do not use legacy `ChangeNotifier` classes.
> *   Views must watch providers and react to changes via immutable state structures.

> [!WARNING]
> **Offline-First Synchronization Rules**
> *   Data writes must occur in a single database transaction: update the local table and queue a sync job in the `synchronization_queue` table in the same transaction.
> *   Never delete local records to clear space unless they have been marked as synced in the database.

> [!CRITICAL]
> **Robust Error Handling**
> *   Every network request and database operation must be wrapped in `try-catch` blocks returning `Either<Failure, Success>` patterns or raising custom Domain Exceptions.
> *   Never catch exceptions silently. Always log them through the telemetry service or local crash handler.
> *   Return clear, user-facing error states instead of raw system exceptions.

---

## 3. Linting and Validation rules
*   **Dart Code Rules**: Enforce `flutter_lints` with additional custom rules (`avoid_print: error`, `prefer_const_constructors: error`, `always_declare_return_types: error`).
*   **Python Code Rules**: Enforce `ruff` for linting and formatting. Strict type hinting (`mypy`) is required for all function arguments and return types.
*   **Test Validation**: Any new feature or bug fix must include matching unit/widget tests. Pull requests without test additions will be rejected.
