# Logistics Vision AI - Project Foundation

Welcome to the foundation of **Logistics Vision AI**, an enterprise-grade, offline-first mobile application designed for warehouse truck-loading operations. Using camera-based AI, the app automates carton counting, synchronizing offline work to a secure cloud backend if available.

This repository is organized as a monorepo to separate frontend, backend, AI pipeline code, and shared packages.

---

## 1. Monorepo Structure

```directory
Logistics Vision AI/
├── LICENSE                    # Proprietary License for enterprise IP protection
├── README.md                  # Root project overview (this file)
├── .gitignore                 # Excludes local developer files and build cache
│
├── apps/
│   ├── mobile/                # Flutter mobile application
│   └── backend/               # FastAPI backend services
│
├── packages/
│   ├── shared_models/         # Common JSON models
│   ├── shared_utils/          # Shared validators and calculations
│   └── design_system/         # Shared style guides
│
├── ai/
│   ├── models/                # Quantized YOLO/ONNX model files
│   ├── datasets/              # Model training/validation frames
│   ├── training/              # Training scripts (PyTorch / YOLO)
│   └── inference/             # Offline inference wrapper tests
│
├── docs/                      # Architectural & DDD documentation directory
│   ├── PRD.md                 # Product Requirements Document
│   ├── ARCHITECTURE.md        # System Architecture Spec
│   ├── DATABASE.md            # DB Schema and Indexing
│   ├── TECH_STACK.md          # Tech Stack Evaluation
│   ├── API.md                 # REST API Endpoint Spec
│   ├── TESTING_STRATEGY.md    # Testing Plan
│   ├── DEPLOYMENT.md          # CI/CD and Deploy Spec
│   ├── RISKS.md               # Risk Registry and Mitigation
│   ├── ROADMAP.md             # Project Roadmap
│   ├── AGENTS.md              # Coding standards and constraints
│   ├── TASKS.md               # Micro-task implementation list
│   # DDD Domain Model Specification Registry:
│   ├── DOMAIN_MODEL.md        # Business Entities (Warehouse, Truck, Layers, etc.)
│   ├── ENTITY_RELATIONSHIPS.md# Aggregate boundaries and class mappings
│   ├── BUSINESS_RULES.md      # Validation constraints and state transitions
│   ├── DOMAIN_EVENTS.md       # Event-driven triggers registry
│   ├── DOMAIN_SERVICES.md     # Stateless business computations
│   ├── VALUE_OBJECTS.md       # Immutable data structures (Boxes, Locations)
│   ├── ENUMS.md               # Domain state space enums
│   ├── REPOSITORIES.md        # Persistence interface contracts
│   ├── SCALABILITY.md         # Multi-tenant and ERP scaling spec
│   # AI Engine Design:
│   └── AI_PIPELINE.md         # Model lifecycle, dataset formats, and ONNX conversions
│
├── .github/
│   └── workflows/
│       └── ci.yml             # CI build, lint, format and test pipeline
```

---

## 2. Technical Decisions & Foundation

### Domain-Driven Design (DDD)
*   The business logic is organized into bounded contexts and aggregate roots to ensure data consistency in offline environments. Read the domain documentation registry under `docs/` before implementing any models or database sync operations.

### State Management & Dependency Injection: Riverpod
*   **Riverpod** handles both UI reactive states and dependency injection.
*   By using Riverpod providers (`Provider`, `NotifierProvider`, `AsyncNotifierProvider`), we avoid using service locators (like `GetIt`) or inheritance-based setups. Providers are scoped compile-time safe instances, making mocking and testing repositories trivial.

### Declarative Routing: GoRouter
*   The application uses **GoRouter** to maintain a declarative URL-based route map. Route guards and deep links can easily inspect Riverpod auth states to verify sessions before entering dashboards or camera layouts.

---

## 3. Getting Started

### Local Setup
1.  **Clone the Repository**:
    Ensure git is installed and clone the project.
2.  **Mobile Workspace Setup**:
    Navigate to the mobile directory and run:
    ```bash
    cd apps/mobile
    flutter pub get
    ```
3.  **Run Development Build**:
    ```bash
    flutter run --dart-define=ENV=development
    ```
