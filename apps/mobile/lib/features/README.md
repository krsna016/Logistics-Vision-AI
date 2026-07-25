# Feature Layout Structure

Every feature under this directory must follow the domain-driven clean architecture structure below:

```
features/<feature_name>/
├── presentation/
│   ├── screens/         # Full layouts (e.g. Scanning screen)
│   ├── widgets/         # Domain-specific UI blocks (e.g. live count card)
│   └── controllers/     # Riverpod notifiers and state managers
│
├── application/
│   └── usecases/        # Orchestrates business logic and repository triggers
│
├── domain/
│   ├── entities/        # Immutable models (e.g. CartonState)
│   └── repositories/    # Interfaces specifying access rules
│
└── data/
    ├── datasources/     # Raw database or API endpoints
    ├── models/          # DTO mappers
    └── repositories/    # Concrete data layer implementations
```
