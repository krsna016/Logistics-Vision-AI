# Logistics Vision AI — Project Knowledge Base and Current-State Audit

**Audit date:** 2026-08-20  
**Scope:** repository contents, implementation paths, documentation, configuration, and static validation.  
**Working-tree policy:** inspected but did not modify the user's uncommitted camera-flow work.

## Executive summary

Vinayak SmartLoad / Logistics Vision AI is a monorepo for a warehouse loading workflow. Its primary product is a portrait-oriented Flutter application that operates locally, counts cartons from a captured image with an embedded ONNX segmentation model, lets an operator review and correct the count, and persists wagon/truck/layer records into a Drift/SQLite database. A FastAPI service supplies authentication, user administration, location tracking, batch upload sync, and optional server-side Roboflow inference. A small React/Vite site is the administrator console. Dataset conversion, auditing, merging, and training scripts live under `ai/dataset_tools`; a separate Flask-style carton-count benchmark utility is under `tools/`.

The repository has considerable implementation depth (about 61.9k lines of mobile Dart and 1.3k lines of backend Python). The mobile sync worker has now been removed for the requested local-only mode; old queue/table fields remain only for database compatibility. The existing 2026-08-13 readiness report is valuable historical evidence, but its “all tests green” claim is not current evidence for this checkout.

## Repository map

| Area | Purpose | Important entry points |
|---|---|---|
| `apps/mobile` | Primary offline-first Flutter operational application | `lib/main.dart`, `lib/navigation/app_router.dart`, `lib/core/database/app_database.dart` |
| `apps/backend` | FastAPI API/control plane | `app/main.py`, `app/routers/`, `app/core/security.py` |
| `apps/admin-web` | React/Vite administrator console | `src/App.jsx`, `src/pages/Dashboard.jsx`, `src/api.js` |
| `ai/dataset_tools` | Dataset audit, merge, conversion and training utilities | `README.md`, `audit_yolo_datasets.py`, `build_stage1_seg_dataset.py` |
| `tools/Carton Count Benchmark App` | Separate local carton-count benchmark UI and model | `app.py`, `models/best.pt` |
| `docs` | Product, DDD, architecture and historic audit material | `PRD.md`, `ARCHITECTURE.md`, `DATABASE.md`, `PRODUCTION_READINESS_AUDIT_2026-08-13.md` |
| root `patch_*.py`, `fix_*.py`, `debug_camera.py` | One-off local repair/debug scripts, currently untracked | Not part of a documented build or release path |

The root `README.md` describes intended `packages/` and `ai/models|datasets|training|inference` directories that do not exist in this checkout. Treat the actual source tree above—not that topology—as authoritative.

## Product workflow and mobile navigation

The intended operator flow is:

1. Start at splash, establish a remote or bounded-offline session, then enter the wagon list.
2. Create/select a wagon, create/select a truck, and start or resume a loading session.
3. Open the capture workspace at `/trucks/:id/camera`; the active product behaviour is still-image capture, not continuous live carton inference.
4. Crop/select the counting region, run local ONNX carton segmentation, then open `/trucks/:id/review`.
5. Review detections, make manual corrections, save the layer, and update truck/wagon/register/report aggregates.
6. Optionally export reports, back up local data, and use settings, analytics, profile, manual, and legal pages.

Routes are declared centrally in `apps/mobile/lib/navigation/app_router.dart`. The router guards unauthenticated routes, redirects inactive users to login, blocks login for an active user, and limits `/admin/*` views to the administrator role. The mobile app has its own administrator/security screens in addition to the web console.

The root app establishes a Riverpod `ProviderScope`, GoRouter, global exception logging, portrait orientation, system UI settings, and the normalized reference viewport. It uses the title `Vinayak SmartLoad`.

## Mobile architecture and persistence

The mobile source follows feature-oriented folders with domain entities/repositories, data implementations, and presentation providers/screens/widgets. The dominant capabilities are:

- **Wagons, trucks, layers, and sessions:** local repositories use Drift transactions and generally enqueue corresponding sync records in the same transaction.
- **Counting:** `ModelManager` loads the bundled ONNX model, validates its SHA-256, creates/reuses an ONNX session, and serializes inference runs. Preprocessing, postprocessing, validation, tracking utilities, and timing support sit under `core/ai_engine`.
- **Camera/review:** camera capture is implemented in the camera feature, and the review screen supports operator adjustment. The user’s uncommitted changes heavily affect this flow: the previous `split_layer_camera_screen.dart` is deleted, the remaining camera screen has substantial edits, and there are many untracked patch scripts.
- **Authentication:** remote login stores a JWT in `flutter_secure_storage`; local/offline authentication, password hashing, sessions, audit logs, device sessions, roles, and user controls exist separately.
- **Offline support:** SQLite uses Drift, schema version 11, migrations, foreign-key/WAL/index setup, backups/archive support, image storage, connectivity/sync abstractions, and sync queue records.
- **Other features:** operator-entered defects, digital registers, reports (PDF/CSV/Excel/print/share), analytics, location tracking, legal/manual content, and camera settings.

`AppDatabase` declares 19 tables: `warehouses`, `wagons`, `trucks`, `layers`, `detections`, `digital_registers`, `loading_sessions`, `audit_logs`, `sync_queues`, `dataset_images`, `image_metadata`, `image_quality`, `annotations`, `dataset_exports`, `model_history`, `device_sessions`, `report_exports`, `users`, and `settings`.

Important semantics:

- A partial unique index enforces one active layer number per truck (introduced in schema v10).
- Layer/truck/wagon repositories contain the most critical write/aggregate/cascade logic. Change those with matching database and lifecycle tests.
- Local records still carry versions and older repository paths may write legacy queue rows. No mobile sync engine, connectivity listener, worker, or upload path is active; those queue rows are inert compatibility data.
- Local database files, captured photos, and exported archives are sensitive; application-layer encryption is not implemented.

## Model and data pipeline

The embedded active model is `assets/models/stage1_carton_yolo26m_seg_960.onnx` (about 94.6 MB). `AIModel.modelB()` identifies it as **YOLO26m Stage 1 Carton Segmentation**, version `yolo26m_carton_seg_stage1_v1`, 960×960 input, and one `carton` class. Its pinned checksum is `935a736845b1921b554174723b5b3d1c9e477e5235e41734e882374356008bc7`.

The code labels precision 0.95921, recall 0.94627, and mAP50 0.98290 as internal validation metrics, explicitly not independent warehouse acceptance. Do not describe the model as independently field-validated, real-time, or a defect model. Defects in the application are manual/operator-recorded. The old duplicate 94.3 MB model asset, `stage1_carton_yolo26m_seg.onnx`, remains tracked but is not listed in the Flutter asset manifest and appears unused.

Dataset tools expect source data outside the repository. They audit YOLO datasets, preserve split separation while merging, and can construct the stage-1 segmentation package. Original train/validation/test source images and labels are absent, so the shipped model’s reported metrics cannot be independently reproduced from this checkout.

## Backend/API knowledge

The FastAPI application prefixes functional routes with `/api`; its root health endpoint is `/health` (not `/api/v1/health` as older docs describe). On startup it validates a 32+-character `SECRET_KEY`, creates SQLAlchemy metadata, applies compatibility DDL, canonicalizes roles, and can bootstrap/reset `ADMIN` only when explicitly configured.

| Endpoint family | Access and behaviour |
|---|---|
| `POST /api/auth/login` | OAuth2 form login using employee ID as username; bcrypt verification, lockout after five failures for 15 minutes, HS256 JWT with issuer/audience/jti |
| `/api/users/*` | Administrator creates/lists/updates/disables/activates/hard-deletes users; users can read themselves |
| `POST /api/inference/box-counting` | Authenticated upload, 15 MB cap, JPEG/PNG/WebP MIME and magic-byte validation, server-side Roboflow call |
| `POST /api/sync/batch` | Authenticated upload-only operation envelope; idempotency history, version conflict response, PostgreSQL per-entity advisory lock |
| `GET /api/sync/records`, `/history` | Administrator inspection of current envelopes and append-only sync history |
| `/api/locations/*` | Authenticated heartbeat/stop; administrators read current locations and connect to authenticated WebSocket stream |

Server persistence is a comparatively thin control-plane schema: users, location sessions/pings, current synced JSON envelopes, and append-only sync history. It does not store normalized mobile truck/layer domain tables. It uses SQLAlchemy `create_all` plus startup ALTER statements instead of Alembic/versioned database migrations.

Authentication details that matter in future changes: mobile and admin clients both default to `https://logistics-vision-ai.onrender.com/api`; web tokens are held in `sessionStorage`, mobile tokens in secure storage; server identity comes from JWT subject rather than client-supplied IDs. CORS is composed from `ADMIN_CORS_ORIGINS` plus the hard-coded Vercel site.

## Admin web application

`apps/admin-web` is a JavaScript React 19/Vite 8 application with routes for login, dashboard, and create-user. It guards client navigation by checking decoded JWT expiration and role, while the backend remains the authorization authority. The dashboard administers users, polls user and sync history data, and subscribes to location updates using a WebSocket subprotocol token rather than a query-string token. It has no browser E2E suite.

Its own README is still the Vite starter text; it is not reliable operational documentation.

## Documentation and implementation drift

The documentation corpus is useful design intent but contains material drift:

- `README.md` is foundation-era and names absent directories.
- `API.md` uses older `/api/v1/*` paths and specifies truck/photo/report APIs not implemented by this FastAPI service.
- `AGENTS.md` requires Riverpod-only shared state, strict `Either`/custom-exception handling, Ruff, mypy, and feature tests. The implementation is only partially aligned: several direct/fallback patterns remain and mypy is configured in CI install but not invoked.
- `DEPLOYMENT.md` includes draft Docker/Cloud Build material; no Dockerfile is present in the repository.
- `apps/mobile/README.md` and `apps/admin-web/README.md` are template READMEs.
- `PRODUCTION_READINESS_AUDIT_2026-08-13.md` is an important prior audit. Its residual risks—no encryption, no independent accuracy study, no device acceptance campaign, no bidirectional sync/conflict UI, no signed release proof, limited observability—remain relevant. Its passing-test statements must be revalidated against the current checkout.

## Current quality and release evidence (2026-08-20)

### Validation run

After removing the mobile sync worker/providers and obsolete sync test/scratch script, `flutter analyze` completes with **0 errors** and 45 warnings/info diagnostics. The remaining diagnostics are non-blocking cleanup items, mostly duplicate/unused imports and unused fields in recently edited camera/review/timeline code.

The focused reference viewport test passes. The full Flutter suite runs 111 tests but currently has six UI failures in camera/layout tests affected by the user's uncommitted camera changes; these are unrelated to synchronization.

Backend tests and Ruff could not be run locally because the host Python installation does not contain `pytest` or `ruff`. Dependencies are pinned in `requirements*.txt`, and CI installs/runs them. No dependency installation was performed by this audit.

### Working tree state

The worktree is deliberately dirty. It has modifications to camera state/notifier/screen, count methods, resizable crop region, layer review, truck details/timeline, wagon list, and router; it deletes `split_layer_camera_screen.dart`; and it has numerous untracked debug/patch Python scripts. These are likely in-progress camera-flow work, not audit-generated changes. Resolve and commit or remove them deliberately before a release branch; do not blanket-delete them.

### Release risks, ranked

**Blockers now**

1. Mobile static analysis does not compile cleanly.
2. Local sync engine code is inconsistent with its interface; decide whether to restore a functional sync engine or intentionally remove/replace the unused abstraction cleanly.
3. Current camera-flow changes are uncommitted and include a deleted screen; they need focused device and regression verification.

**High risk before production rollout**

1. SQLite/photos/archives are not application-layer encrypted.
2. The service is upload-only and lacks remote pull/conflict resolution; enforce a single-writer operational model until bidirectional sync exists.
3. No independent model dataset/field acceptance evidence; carton model metrics are internal only.
4. No physical Android/iOS camera, thermal, battery, lifecycle, crash-recovery, signed-artifact, or browser E2E evidence.
5. No versioned backend migration system, deployment files, error monitoring/SLOs, or load/soak test evidence.

**Maintenance risks**

1. Large duplicate ONNX artifacts inflate source history/package review complexity.
2. Product, API, deployment, and application README documents have drift.
3. One-off root patch scripts have no owner, invocation guide, or cleanup policy.

## Recommended order of future work

1. Finish the local-only quality gate: resolve the six camera/layout test failures, format the changed files, and run analyzer plus the full Flutter suite.
2. Stabilize and review the current camera work as one changeset; exercise capture → crop → inference → review → correction → save → reopen history on physical devices.
3. Reconcile the READMEs/API/deployment docs with actual endpoints and repository layout, retaining the historical audit as an evidence record rather than current status.
4. Choose a release security posture: implement encryption, or formally constrain deployment to managed/encrypted devices with export controls.
5. If multi-device operation is ever needed, reintroduce synchronization as a deliberate separate feature with versioned conflict handling.
6. Establish a versioned, access-controlled evaluation set and publish only pre-agreed field metrics.
7. Add Alembic migrations, staging load/E2E/integration tests, signed artifacts, telemetry, runbooks, and device acceptance gates.

## How to use this guide

For future questions, start with this file, then consult the named source file for implementation truth. Use `docs/PRD.md` and DDD documents for intended behaviour, but where they disagree with code, state that explicitly and treat code plus current validation as the actual current state. Treat the model and security claims conservatively until the acceptance work above has been completed.
