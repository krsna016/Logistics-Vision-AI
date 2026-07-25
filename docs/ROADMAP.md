# Project Roadmap - Logistics Vision AI

This document establishes the delivery phases, milestones, and development timeline for Logistics Vision AI.

---

## 1. Phase Milestones

```
+----------------------------------------------------------------------------------------+
|  PHASE 1: PROTOTYPE & AI VALIDATION                                                    |
|  - Train Quantized YOLO model (mAP >= 95%)                                             |
|  - Basic Flutter Camera screen with ONNX Runtime bindings                              |
+----------------------------------------------------------------------------------------+
                                           |
                                           v
+----------------------------------------------------------------------------------------+
|  PHASE 2: CORE OFFLINE MOBILE ENGINE                                                   |
|  - SQLite + Drift implementation (encryption enabled)                                  |
|  - App State Management (Riverpod) & Local Review Screens                              |
+----------------------------------------------------------------------------------------+
                                           |
                                           v
+----------------------------------------------------------------------------------------+
|  PHASE 3: BACKEND CORE & SYNC PIPELINE                                                 |
|  - FastAPI Gateway implementation with Supabase integrations                           |
|  - Robust transaction-safe Synchronization Worker with network detection               |
+----------------------------------------------------------------------------------------+
                                           |
                                           v
+----------------------------------------------------------------------------------------+
|  PHASE 4: ENTERPRISE FEATURES & POLISH                                                 |
|  - PDF reporting exports & Manager Dashboard views                                     |
|  - Comprehensive patrol integration tests, crash analytics (Sentry), telemetry         |
+----------------------------------------------------------------------------------------+
```

---

## 2. Milestone Deliverables

### Phase 1: Prototype & AI Validation (Weeks 1 - 4)
*   **Goal**: Establish real-time carton count performance on target mobile hardware.
*   **Key Deliverables**:
    - quantized model (`.onnx`) loaded on device.
    - Camera overlay view executing object detection in $\le 150\text{ ms}$.
    - Verification report detailing detection precision across baseline warehouse images.

### Phase 2: Core Offline Mobile Engine (Weeks 5 - 8)
*   **Goal**: Enable complete user flows without cloud connectivity.
*   **Key Deliverables**:
    - Local SQLite database implementation with schema definitions for `trucks`, `layers`, `defects`, and `photos`.
    - User journey screens (Truck selection, Layer review, Defect adjustments).
    - Offline database state unit tests achieving $\ge 80\%$ coverage.

### Phase 3: Backend Core & Sync Pipeline (Weeks 9 - 12)
*   **Goal**: Secure, scalable user login and automated data syncing.
*   **Key Deliverables**:
    - FastAPI gateway endpoints configured with Supabase JWT validation.
    - Transactional synchronization queue syncing offline records to cloud PostgreSQL.
    - Robust handling of dropouts and batch conflict resolution logic.

### Phase 4: Enterprise Features & Monitoring (Weeks 13 - 16)
*   **Goal**: Analytics, compliance, and production deployment preparation.
*   **Key Deliverables**:
    - Automated PDF reports with defect details compiled and printable.
    - Sentry telemetry monitoring, Docker build configurations, and CI/CD pipelines.
    - On-device performance stress testing and security scans.
