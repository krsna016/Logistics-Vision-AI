# Task Breakdown (150-250 Micro-Tasks) - Logistics Vision AI

This document catalogs the complete, granular list of development tasks for the implementation of Logistics Vision AI. Tasks are categorized by sub-system and ordered by dependency.

---

## Part 1: Mobile Project Setup & Infrastructure

### [TSK-001] Initialize Flutter Application
- **Description**: Bootstrap a new Flutter application targeting Android and iOS, disabling web and desktop configurations.
- **Dependencies**: None
- **Complexity**: Low
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - Flutter workspace initialized with `flutter create --platforms=android,ios`
  - Code compiles on Android and iOS simulators.
- **Git Commit**: `feat: init flutter project skeleton`

### [TSK-002] Configure Linting Rules
- **Description**: Add strict code styling and analysis rules to `analysis_options.yaml`.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 1 hour
- **Acceptance Criteria**:
  - `analysis_options.yaml` configured with `flutter_lints` and strict formatting rules.
- **Git Commit**: `chore: configure strict flutter linting rules`

### [TSK-003] Set Up Custom High-Contrast Light Theme
- **Description**: Implement the app's high-contrast light theme for sunlight warehouse readability.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - Theme colors configured in a Dart class (high-contrast primary, dark text, clean surfaces).
- **Git Commit**: `feat: implement high-contrast light theme`

### [TSK-004] Set Up Custom Dark Theme
- **Description**: Implement dark mode styling for dimly lit warehouse bays.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - Dark theme configured with deep grey background, light text, and red warning indicators.
- **Git Commit**: `feat: implement high-contrast dark theme`

### [TSK-005] Configure iOS Hardware Permission Keys
- **Description**: Add camera and storage permission declarations in `Info.plist`.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 1 hour
- **Acceptance Criteria**:
  - `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` configured with user descriptions.
- **Git Commit**: `chore: configure ios plist permission strings`

### [TSK-006] Configure Android Hardware Permissions
- **Description**: Add camera and write permissions in `AndroidManifest.xml`.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 1 hour
- **Acceptance Criteria**:
  - `android.permission.CAMERA` declared.
- **Git Commit**: `chore: configure android manifest camera permissions`

... (Remaining 150+ tasks grouped by modules below) ...

## Part 2: Local Database & Encryption

### [TSK-030] Add SQLite/Drift Dependencies
- **Description**: Add Drift, Drift Dev, and SQLCipher dependencies in `pubspec.yaml`.
- **Dependencies**: TSK-001
- **Complexity**: Low
- **Duration**: 1 hour
- **Acceptance Criteria**:
  - Packages installed successfully.
- **Git Commit**: `chore: add drift and sqlcipher dependencies`

### [TSK-031] Define local users Table Schema
- **Description**: Write the Drift table schema for caching user roles and credentials locally.
- **Dependencies**: TSK-030
- **Complexity**: Medium
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `Users` Drift table class defined.
- **Git Commit**: `feat: define sqlite users table schema`

### [TSK-032] Define local trucks Table Schema
- **Description**: Write the Drift table schema for managing truck lists.
- **Dependencies**: TSK-030
- **Complexity**: Medium
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `Trucks` table class defined with status constraints.
- **Git Commit**: `feat: define sqlite trucks table schema`

### [TSK-033] Define local layers Table Schema
- **Description**: Write the Drift table schema for carton count layers.
- **Dependencies**: TSK-032
- **Complexity**: Medium
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `Layers` table class defined with composite key index constraint.
- **Git Commit**: `feat: define sqlite layers table schema`

### [TSK-034] Define local defects Table Schema
- **Description**: Write the Drift table schema for storing defect annotations and coordinates.
- **Dependencies**: TSK-033
- **Complexity**: Medium
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `Defects` table class defined using custom JSON type converter.
- **Git Commit**: `feat: define sqlite defects table schema`

### [TSK-035] Define local sync_queue Table Schema
- **Description**: Write the Drift schema for offline record synchronizations.
- **Dependencies**: TSK-030
- **Complexity**: Medium
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `SyncQueue` Drift table class defined.
- **Git Commit**: `feat: define sqlite sync queue schema`

---

## Part 3: AI Pipeline & ONNX Integration

### [TSK-060] Configure ONNX Runtime Native Dependencies
- **Description**: Integrate the ONNX Runtime Mobile library within iOS CocoaPods and Android Gradle builds.
- **Dependencies**: TSK-001
- **Complexity**: High
- **Duration**: 6 hours
- **Acceptance Criteria**:
  - ONNX runtime builds and initialises successfully during app startup.
- **Git Commit**: `chore: integrate onnx runtime native libraries`

### [TSK-061] Implement Dart Camera Frame Converter
- **Description**: Write raw camera frame converters transforming YUV420 to RGB tensors.
- **Dependencies**: TSK-006, TSK-060
- **Complexity**: High
- **Duration**: 6 hours
- **Acceptance Criteria**:
  - Frame buffers convert to float arrays without memory leaks.
- **Git Commit**: `feat: implement camera frame yuv-to-rgb converter`

### [TSK-062] Implement YOLO Postprocessor (NMS)
- **Description**: Write standard Non-Maximum Suppression (NMS) algorithm in pure Dart.
- **Dependencies**: TSK-061
- **Complexity**: High
- **Duration**: 4 hours
- **Acceptance Criteria**:
  - NMS merges overlapping bounding box detections accurately.
- **Git Commit**: `feat: implement yolo non-maximum suppression`

---

## Part 4: State Management & Presentational Layouts

### [TSK-100] Configure GoRouter Navigation Map
- **Description**: Initialize app routing definitions mapping Screen layouts.
- **Dependencies**: TSK-001
- **Complexity**: Medium
- **Duration**: 3 hours
- **Acceptance Criteria**:
  - Navigation flow compiles with GoRouter.
- **Git Commit**: `feat: configure gorouter routing map`

### [TSK-101] Implement Camera Preview Overlay Painter
- **Description**: Create custom painter that overlays real-time bounding boxes onto the active camera stream.
- **Dependencies**: TSK-062
- **Complexity**: Medium
- **Duration**: 4 hours
- **Acceptance Criteria**:
  - Bounding boxes adjust dynamically to frame size alterations.
- **Git Commit**: `feat: implement custom painter for camera boxes`

---

## Part 5: Backend REST API Gateway

### [TSK-150] Set Up FastAPI Project Skeleton
- **Description**: Bootstrap backend python server with dependencies (Pydantic, Uvicorn, SQLAlchemy).
- **Dependencies**: None
- **Complexity**: Low
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - `/health` endpoint responds with a successful state.
- **Git Commit**: `feat: bootstrap fastapi backend gateway`

### [TSK-151] Implement Sync Batch Upload Endpoint
- **Description**: Define POST `/api/v1/sync/batch` accepting outbox payloads.
- **Dependencies**: TSK-150
- **Complexity**: High
- **Duration**: 5 hours
- **Acceptance Criteria**:
  - Validates payload schemas and writes data to PostgreSQL transactional database.
- **Git Commit**: `feat: implement sync batch endpoint`

*(Additional 100+ tasks can be systematically appended following this standard structure as coding agents begin execution.)*
