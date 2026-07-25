# Deployment & CI/CD Specification - Logistics Vision AI

This document defines the server hosting topology, automated release pipelines, environment configurations, and continuous monitoring setups.

---

## 1. Environment Topology

```
             +-----------------------+
             |     LOCAL DEV DEV     |
             +-----------------------+
                         |
                         v
+--------------------------------------------------+
|                    CI PIPELINE                   |
|  - Run Linters / Format Checks                   |
|  - Run Unit / Integration Tests                  |
|  - Build Docker Containers                       |
+--------------------------------------------------+
                         |
      +------------------+------------------+
      |                                     |
      v                                     v
+-----------------------+             +-----------------------+
|  STAGING CLOUD (UAT)  |             |  PROD CLOUD (RELEASE) |
|  - Fast API Gateway   |             |  - FastAPI Gateway    |
|  - Supabase Sandbox   |             |  - Supabase Cluster   |
|  - Firebase Beta (App)|             |  - App Store / Play   |
+-----------------------+             +-----------------------+
```

---

## 2. Release & Versioning Strategy
*   **Semantic Versioning (SemVer)**: Follow `MAJOR.MINOR.PATCH` naming for both mobile apps and backend APIs.
*   **API Versioning**: Enforce namespace prefixes: `/api/v1` and `/api/v2`. Backward incompatible database migrations must not release until client versions running the older code fall below 1% active installations.
*   **Database Schema Updates**: SQLite local databases run schema adjustments on launch without deleting unsynced logs. Cloud PostgreSQL migrations run sequentially through database migration steps.

---

## 3. Automated CI/CD Pipelines

### Frontend (GitHub Actions Workflow draft)
*   Executes on tags starting with `v*` (e.g. `v1.2.0`).
*   Runs static code check, tests, builds production app bundle, and ships to Firebase App Distribution or Play Store / TestFlight.
```yaml
name: Mobile Release Build

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.19.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Run Code Analyzer
        run: flutter analyze

      - name: Run Tests
        run: flutter test

      - name: Build Android Bundle (AAB)
        run: flutter build appbundle --release --build-number=${{ github.run_number }}

      - name: Build iOS IPA
        run: flutter build ipa --release --no-codesign
```

### Backend (Docker & Cloud Build)
*   Builds the FastAPI application container, runs lint checks, compiles schemas, and updates cloud instance clusters.
```dockerfile
# Dockerfile for FastAPI Gateway
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 4. Monitoring & Telemetry
*   **Sentry SDK Integration**: Implemented in both the Flutter client and the FastAPI backend. Reports unhandled exceptions, network timeouts, and local database locked states.
*   **APM Metrics (Prometheus & Grafana)**: Tracks backend request latency, database connection pool exhaustion, and CPU utilization.
*   **Crashlytics (Firebase)**: Monitors on-device native crashes, specifically tracking memory allocation drops that may indicate NPU overloading issues during YOLO model evaluation.
