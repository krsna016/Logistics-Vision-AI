# System Architecture - Logistics Vision AI

This document details the clean, multi-layered architecture designed for Logistics Vision AI. The architecture separates concerns, supports offline-first operations, ensures smooth local AI execution, and secures data synchronization to the cloud.

---

## 1. Architectural Blueprint

```
+-----------------------------------------------------------------------------------+
|                                 PRESENTATION LAYER                                |
|          (Flutter Widgets / Pages, UI State Providers, Custom Paint Overlays)    |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                                 APPLICATION LAYER                                 |
|            (Riverpod Notifiers, State Machine Managers, Use Case Handlers)        |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                                   DOMAIN LAYER                                    |
|          (Plain Dart Entities, Repository Interfaces, Core Business Rules)        |
+-----------------------------------------------------------------------------------+
                     |                                         |
                     v                                         v
+------------------------------------------+  +-------------------------------------+
|                DATA LAYER                |  |              AI LAYER               |
|  (Local Sqlite, Remote API Client, Cache)|  |  (ONNX Runtime, Pre/Post Processor) |
+------------------------------------------+  +-------------------------------------+
                     |                                         |
                     +--------------------+--------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                              SYNCHRONIZATION LAYER                                |
|        (Outbox Queue Manager, Conflict Resolver, Background Sync Worker)         |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                                    CLOUD LAYER                                    |
|      (Supabase Auth & Database, FastAPI Services, CDN Storage for Photos)         |
+-----------------------------------------------------------------------------------+
```

---

## 2. Layer Analysis

### Presentation Layer
*   **Purpose**: Manages UI rendering and handles user interactions.
*   **Technologies**: Flutter, CustomPainter (for real-time AI bounding box rendering).
*   **Design**: Stateless widgets consuming state from Riverpod providers. Screen layouts react purely to immutable state objects.

### Application Layer
*   **Purpose**: Connects the presentation layer to domain logic. Orchestrates the flow of data through Use Cases.
*   **Technologies**: Riverpod StateNotifiers / AsyncNotifiers.
*   **Design**: Decouples UI screens from business details. Translates user commands (e.g., "Confirm Layer") into repository calls.

### Domain Layer
*   **Purpose**: Represents the core business rules and models.
*   **Technologies**: Pure Dart (no external framework dependencies like Flutter or Riverpod).
*   **Design**: Contains business entities (e.g., `Truck`, `Layer`, `Defect`) and abstract repository definitions. This layer is completely testable without any UI or database engine mocks.

### Data Layer
*   **Purpose**: Concrete implementation of domain repository interfaces. Handles file management and data fetching.
*   **Technologies**: SQLite (via `drift` or `sqflite`), Supabase REST client, local disk storage (for high-resolution photos).
*   **Design**: Automatically maps local SQLite schemas into clean domain entities. Encapsulates remote HTTP/RPC requests.

### AI Layer
*   **Purpose**: Performs real-time carton and defect inference locally on the device.
*   **Technologies**: ONNX Runtime Mobile, YOLOv8/v10 quantization, Custom Dart image converters.
*   **Design**: Loads quantized models (`.onnx` format) using NNAPI (Android) or CoreML (iOS) hardware acceleration where possible. Implements custom pre-processing (scaling, normalization) and post-processing (non-maximum suppression).

### Synchronization Layer
*   **Purpose**: Manages local data propagation to the cloud servers.
*   **Technologies**: SQLite Transaction-backed Outbox Queue, `WorkManager` (Android) / `BackgroundFetch` (iOS).
*   **Design**: Monitors connectivity. When online, pops the oldest outbox entry, posts it to the FastAPI Gateway, and marks it as synced in the local database upon a `200 OK` response.

### Cloud Layer
*   **Purpose**: Centralized storage, user authentication, and data consolidation.
*   **Technologies**: Supabase, PostgreSQL, FastAPI (Python), AWS S3 / Supabase Storage.
*   **Design**: Supabase handles Row-Level Security (RLS) for reports and user login. FastAPI provides high-throughput integration endpoints and reporting utilities.

### Reporting Layer
*   **Purpose**: Generates operational reports and data exports.
*   **Technologies**: PDF and CSV generator libraries.
*   **Design**: Generated on-device for direct sharing (PDF/CSV/JSON) or compiled on the FastAPI server for batch email delivery.

### Security Layer
*   **Purpose**: Protects data at rest, in transit, and client-server entry points.
*   **Technologies**: AES-256 local database encryption (via `SQLCipher`), HTTPS/TLS 1.3, Supabase JWT authentication.
*   **Design**: Local database keys are securely stored in the iOS Keychain and Android Keystore (via `flutter_secure_storage`).

### Monitoring & Telemetry Layer
*   **Purpose**: Performance metric tracking, usage statistics, and exception reporting.
*   **Technologies**: Sentry/Crashlytics, custom server-side Prometheus/Grafana stacks.
*   **Design**: Captures client-side performance benchmarks (like AI inference speeds and memory usage) and ships them during sync windows.
