# Vinayak SmartLoad — Engineering Audit and Production-Readiness Report

**Audit date:** 13 August 2026  
**Scope:** Flutter Android/iOS client, camera and ONNX pipeline, counting workflow, wagon/truck/layer persistence, offline authentication and storage, synchronization, reports, FastAPI/PostgreSQL service, React administration client, permissions, security, privacy, packaging, and operational readiness.

## Executive decision

**Decision: NOT YET APPROVED for an industrial production rollout.**

The audited code is materially safer and more consistent than the baseline and all runnable automated regression suites pass. Critical integrity, authentication, permission, synchronization, reporting, and release-configuration defects were repaired. It is nevertheless not responsible to claim industrial counting accuracy or full production readiness because the workspace does not contain a reproducible independent warehouse test set, no physical Android/iOS device was available for camera/thermal/battery measurements, iOS cannot build on this host, automatic carton-defect classification does not exist, local operational photos/database and shared audit archives are not application-level encrypted, and synchronization is upload-only rather than bidirectional.

The deployed experience is a **still-photo, operator-verified carton counting workflow**, not live video tracking. Its model detects one class (`carton`). Defects are entered by the operator. Documentation and report language were corrected to make those boundaries explicit.

## Audit method and evidence policy

Each stage followed the requested loop: **Inspect → Test → Measure → Diagnose → Find Root Cause → Fix → Re-test → Verify → Benchmark → Proceed**. “Verified” below means supported by code inspection plus a repeatable local test/build. Device, field, and independent model claims are explicitly marked unverified when the required hardware or data was absent.

The worktree already contained mobile camera/inference edits and an APK before this audit. Those user-owned changes were preserved. Results are for the current working tree, not a clean tagged release.

## Before/after scorecard

| Measure | Before | After | Evidence / interpretation |
|---|---:|---:|---|
| Flutter static analysis | 0 issues | 0 issues | `flutter analyze` |
| Flutter tests | 101 passed | 108 passed | Full suite; new lifecycle, offline-auth, sync, and index coverage |
| Backend tests | 2 passed | 4 passed | `pytest -q` |
| Backend lint | Not configured in the audit environment | 0 Ruff findings | `ruff check app tests` |
| Backend production dependency audit | Not measured | 0 known vulnerabilities | `pip-audit -r requirements.txt` |
| Backend type checking | Not measured | **34 errors remain** | `mypy --explicit-package-bases app`; SQLAlchemy legacy column typing |
| Admin production dependencies | 2 high-severity findings | 0 known vulnerabilities | React Router updated; `npm audit --omit=dev` |
| Admin lint/build | Passed | Passed | Vite production build |
| Admin JS bundle | 470.41 kB / 146.18 kB gzip | 470.67 kB / 146.27 kB gzip | +0.26 kB / +0.09 kB for security handling |
| Mobile DB schema | v9 | v10 | Integrity migration, indexes, uniqueness and PRAGMAs |
| Flutter tests covering record lifecycle | No atomic/cascade regression coverage | 7 additional tests overall | Full suite count 101 → 108 |
| Android package identity | `com.example.mobile` in supplied APK | `com.vinayak.smartload` in rebuilt debug APK | Verified with Android package tooling |
| Supplied APK permissions | Background location, microphone, legacy external storage | Camera/network plus opt-in location policy; transitive microphone/storage removed | Rebuilt manifest inspection |
| Release signing | Debug-signing fallback possible | Missing release secrets fail the build | Deliberate fail-fast gate |
| Host CPU ONNX latency | Not measured | load 75.3 ms; inference mean 1694.3 ms, p50 1688.6 ms, p95 1732.6 ms | Synthetic zero tensor, 960×960; **not a phone/image benchmark** |
| Model provenance | UI metrics were not clearly qualified | Model hash pinned; internal metrics labelled as non-independent | SHA-256 matches training export |

## Stage 1 — Architecture, inventory, build reproducibility

**Inspect/Test/Measure:** Mapped Flutter, FastAPI, React/Vite, AI assets, tests, manifests, build files, and documentation. Ran baseline analysis/tests/builds and inspected the dirty worktree. The supplied APK was 210 MB and used the placeholder Android package. Two roughly 94 MB ONNX assets are present, while only the 960 asset is deployed.

**Diagnose/root cause:** Release and development assumptions were mixed; production identity/signing defaults were unsafe; build artifacts could be mistaken for current output; the package graph included a discontinued Markdown dependency.

**Fix:** Made release mode default to production, introduced the production Android/iOS identity, added release signing secrets with a fail-fast gate, corrected the iOS display name, and migrated `flutter_markdown` to maintained `flutter_markdown_plus` 1.0.12.

**Re-test/verify/benchmark/proceed:** Android debug compilation and Flutter analysis pass. Release compilation stops in about three seconds when the four signing secrets are absent, as intended. The old supplied APK must not be distributed. Production versioning remains `1.0.0+1` and must be advanced by the release pipeline.

## Stage 2 — Authentication, authorization, sessions, and admin access

**Inspect/Test/Measure:** Traced mobile/admin login, JWT creation/decoding, role checks, device sessions, offline credentials, WebSockets, and user creation. Baseline tokens did not enforce all standard temporal/issuer claims; passwords accepted a weak length policy; WebSocket tokens appeared in URLs; mobile offline login was not actually connected to the remote-login flow; production exposed credential-free demo entry.

**Diagnose/root cause:** Authentication paths had evolved independently and demo tooling was not environment-gated.

**Fix:** JWTs now require `sub`, `exp`, `iat`, `iss`, `aud`, and `jti`; issuer/audience and expiry are validated; unknown-user authentication performs a dummy bcrypt check; passwords are 12–72 characters; employee IDs are normalized; expired/invalid admin sessions are cleared on HTTP 401; WebSocket JWTs use the subprotocol rather than a query string. A successful online login provisions a PBKDF2-backed secure offline credential for 24 hours; offline fallback is permitted only for connectivity/server failures, never bad credentials. Demo entry is disabled in production in both UI and notifier. Destructive demo-data replacement is non-production and administrator-only.

**Re-test/verify/benchmark/proceed:** Backend security tests and offline-auth lockout tests pass. The residual risk is the intentional 24-hour revocation window for a previously provisioned offline employee.

## Stage 3 — Permissions, location, privacy, and platform configuration

**Inspect/Test/Measure:** Compared source manifests, iOS usage descriptions, the supplied APK manifest, location lifecycle, and server retention. The supplied APK requested background location, microphone, and legacy storage; tracking behavior and user disclosure were broader than necessary.

**Diagnose/root cause:** Transitive Android plugin permissions were not explicitly removed, and tracking lifecycle was tied too closely to authentication.

**Fix:** Removed microphone and legacy external-storage permissions with manifest merger directives. Tracking now requires an explicit profile opt-in with precise/background disclosure, is stopped on logout, uses 25 m distance and 30 s intervals without a wake lock, allows iOS auto-pause, and reports stream errors. iOS must grant Always authorization before the service claims it is active. The server supplies authoritative time, rejects future timestamp manipulation, indexes location time, and removes records after the configurable 30-day retention period.

**Re-test/verify/benchmark/proceed:** Rebuilt Android manifest contains the expected camera/network and location capabilities only. No physical permission-dialog or background-termination test was possible. Application-level encryption for the SQLite database, captured photos, and exported ZIP is unresolved.

## Stage 4 — Camera capture lifecycle and image handling

**Inspect/Test/Measure:** Followed camera startup/resume, capture, crop, temporary-file handling, unsaved navigation, and performance telemetry. Current carton inference runs after a still capture; there is no live video carton detector. Temporary captures and discarded review images could persist. Timing telemetry could display stale zero phases.

**Diagnose/root cause:** File ownership across camera/review screens was ambiguous, navigation discard lacked a cleanup hook, and timing phases were not populated around the actual work.

**Fix:** Captures are copied to durable storage and the camera temporary file is removed; abandoned or incomplete workflows clean their saved images; filenames use microseconds to prevent collision; the unsaved-changes guard accepts a cleanup callback. Crop sampling was upgraded from nearest-neighbour to bilinear interpolation. Preprocess, inference, and postprocess durations are recorded from the actual still-photo operation.

**Re-test/verify/benchmark/proceed:** Navigation and image archive tests pass and analysis is clean. A device camera latency, focus, motion blur, rotation, lifecycle, and OEM compatibility matrix remains mandatory.

## Stage 5 — Model, inference, carton detections, and duplicate resistance

**Inspect/Test/Measure:** Verified ONNX inputs/outputs, preprocessing/postprocessing, thresholding, crop mapping, model metadata, training outputs, and tracking code reachability. The deployed model SHA-256 is `935a736845b1921b554174723b5b3d1c9e477e5235e41734e882374356008bc7`, identical to the stored training export. It emits detection and segmentation outputs at 960×960. Host CPU synthetic inference averaged 1694.3 ms (p95 1732.6 ms).

**Diagnose/root cause:** Product language implied real-time counting/tracking even though inference is capture-and-review. The dormant tracking engine cannot prevent duplicate cartons between successive layer photos. Model metrics came from internal validation and the original datasets needed to reproduce them are absent from the workspace.

**Fix:** Model metadata now pins the expected checksum and labels internal metrics accurately. The operator review workflow supports adding missed cartons and removing false/duplicate detections before save. Bilinear crop handling preserves more edge detail. User documentation no longer claims live detection or “extreme accuracy.”

**Re-test/verify/benchmark/proceed:** Internal final-epoch mask metrics are precision 0.95921, recall 0.94627, mAP50 0.98290, mAP50–95 0.90552. These are **not independent warehouse results** and cannot establish counting accuracy. Cross-photo duplicate prevention is achieved operationally through one saved record per unique layer plus human verification, not object tracking. No claim of improved field accuracy is made.

## Stage 6 — Wagon/truck/layer counting and session persistence

**Inspect/Test/Measure:** Exercised layer create/update/delete, cached aggregates, session resume, layer numbering, item allocation, wagon completion, and cascades. Confirmed risks included duplicate/gapped active layer numbers, totals written in separate operations, paused sessions not treated as resumable, mock operator identity, and parent deletion leaving inconsistent child sync state.

**Diagnose/root cause:** Derived totals and sync jobs were maintained separately from source-record transactions; uniqueness existed only in application logic.

**Fix:** Schema v10 enables foreign keys, WAL, `synchronous=NORMAL`, and a busy timeout; adds operational indexes; deterministically renumbers legacy active layers; and enforces a partial unique `(truck_id, layer_number)` index. Layer save/update/delete and truck/session aggregate recalculation now execute atomically with sync queue writes. Paused sessions are recoverable and only one resumable session may exist per truck. Authenticated employee identity replaces the mock operator. Wagon/truck cascades version and queue every affected child.

**Re-test/verify/benchmark/proceed:** New tests verify atomic aggregate repair, duplicate rejection, paused resume, cascade sync, item totals, and SQLite PRAGMAs. All 108 Flutter tests pass. Multi-device concurrency is not proven because synchronization does not download remote changes.

## Stage 7 — Defects, corrections, and auditability

**Inspect/Test/Measure:** Traced defect entities, layer review, correction reasons, reports, and AI classes. The only deployed model class is `carton`; defects were always manual even where report wording suggested AI.

**Diagnose/root cause:** Product/report language conflated operator-recorded defects with inferred defects.

**Fix:** Reports now say defects are recorded by operators. Historical corrections record before/after values and reason; missed photos can be attached through an audited correction path. Source-layer defect totals are recalculated with related aggregates.

**Re-test/verify/benchmark/proceed:** Lifecycle and correction/report tests pass. Automated crushed/torn/wet/open carton detection remains **not implemented**; it requires a labelled defect taxonomy, training data, acceptance metrics, and UI confidence policy.

## Stage 8 — Offline storage, backup, recovery, and data integrity

**Inspect/Test/Measure:** Reviewed Drift schema/migrations, write transactions, backups, WAL files, file inventory, offline authentication, and recovery behavior. The database previously lacked several integrity/performance protections and an audit share could be mistaken for a secure backup.

**Diagnose/root cause:** Offline features were implemented by feature rather than through a uniform transaction/recovery contract.

**Fix:** Added DB constraints/indexes/PRAGMAs, transactional local-write-plus-queue behavior, deterministic migration repair, bounded secure offline login, collision-safe images, and cleanup for discarded files. Backup tests verify create/check/restore; audit archive inventory handles optional WAL/SHM files.

**Re-test/verify/benchmark/proceed:** Backup, archive, lifecycle, and offline-auth tests pass. The database and photos remain plaintext at the application layer, and the administrator audit ZIP is unencrypted. Treat both as sensitive operational data and block unmanaged-device rollout until an encryption/MDM policy is approved.

## Stage 9 — Synchronization, API consistency, and conflicts

**Inspect/Test/Measure:** Traced local versions, queue IDs/retries, delete cascades, batch payloads, server idempotency, and concurrent writes. A correction fragment could overwrite the server’s complete JSON entity; an older accepted operation could mark a newer local edit synced; queue IDs could collide; concurrent server batches lacked per-entity serialization.

**Diagnose/root cause:** Operation metadata was used as if it were entity state, and acknowledgement did not compare the current local version.

**Fix:** Every local change increments its version and remains pending; deterministic operation IDs prevent millisecond collisions; the worker merges operation metadata into the complete durable entity; an acknowledgement marks a row synced only when its version is still current. Deletes queue each child explicitly. The API requires the next version, stores durable idempotency history, and uses a PostgreSQL advisory transaction lock per entity.

**Re-test/verify/benchmark/proceed:** Retry, complete-payload, stale-acknowledgement, and backend sync tests pass. **Residual blocker:** the client uploads but does not pull remote state; there is no multi-device conflict-resolution UI. It is safe only under a single-writer-per-record operational rule until bidirectional sync is built and tested.

## Stage 10 — Reports, exports, admin UI, and usability

**Inspect/Test/Measure:** Generated and inspected report logic, totals, permissions, audit records, admin authentication, responsive widgets, and bundle output. Reports could trust stale cached aggregates; exports were not consistently audit-logged; documentation misrepresented camera/defect behavior; iOS showed the generic name “Mobile.”

**Diagnose/root cause:** Presentation copied denormalized totals and product claims had drifted from implementation.

**Fix:** Reports derive totals from source layers, log success/failure with user/subject/file, and describe defects accurately. iOS now displays Vinayak SmartLoad. Admin authentication clears invalid sessions, password guidance matches backend policy, and production security headers were added. The worker manual now documents still-photo review, manual defect entry, offline limits, and production demo restrictions.

**Re-test/verify/benchmark/proceed:** Report, responsive, navigation-guard, and language-switch tests pass. Admin lint/build pass; final JS is 470.67 kB (146.27 kB gzip). PDF tests emit a Helvetica Unicode warning; Hindi/non-Latin operational content needs a bundled Unicode font and visual golden test before it is considered reliable.

## Stage 11 — Performance, memory, battery, crashes, and observability

**Inspect/Test/Measure:** Examined image resolution/copies, ONNX session reuse, inference timing, DB indexes/PRAGMAs, PDF isolation, sync retry, location wake behavior, and bundle sizes. The synthetic host CPU inference is about 1.7 s; this is incompatible with a true live-video claim. No integration-test device farm, crash-free telemetry, heap profile, CPU trace, thermal run, or battery run exists.

**Diagnose/root cause:** The app is optimized around still capture, while product expectations included real-time tracking; observability is mainly local logging.

**Fix:** Reused the shared ONNX session, kept inference outside live preview, recorded real timing phases, improved indexes/WAL, bounded sync retry, reduced location frequency and removed the wake lock, and kept PDF generation isolated from the UI thread. Production detailed telemetry is disabled by default.

**Re-test/verify/benchmark/proceed:** Automated tests and host benchmark pass, but device performance remains unverified. Recommended release gates are capture-to-review p95 ≤ 2.0 s on the minimum device, no sustained thermal throttling over a 30-minute shift simulation, peak RAM within the agreed device budget, and measured battery drain within the warehouse’s shift budget. These are proposed gates, not achieved measurements.

## Stage 12 — Security hardening, release packaging, and failure recovery

**Inspect/Test/Measure:** Audited dependencies, headers, CORS, upload handling, token transport, secrets, signing, platform IDs, release permissions, recovery paths, and failure behavior. Confirmed two high React Router vulnerabilities, permissive token/upload handling, debug signing fallback, placeholder identity, exposed demo bypass/actions, and broad transitive permissions.

**Diagnose/root cause:** Development conveniences and framework defaults reached the production surface.

**Fix:** Updated vulnerable React Router packages; pinned backend dependencies; added CSP, HSTS, MIME sniffing and referrer/permissions policies; tightened CORS; bounded inference upload reads to 15 MB and validated MIME plus magic bytes; hardened JWTs and WebSockets; removed broad permissions; gated demo features; and made release signing mandatory.

**Re-test/verify/benchmark/proceed:** npm and Python production audits report zero known vulnerabilities; Ruff and all runtime tests pass; Android debug builds with the production identity. iOS unsigned build reached CocoaPods but stopped because the host lacks the requested iOS 26.5 platform. Four plugins also warn that Swift Package Manager support is absent. Release packaging and recovery therefore remain conditionally blocked.

## End-to-end regression and failure matrix

| Scenario | Result | Limit |
|---|---|---|
| Wagon → truck → session → layer save/correct/delete → totals | Pass, automated repository/widget coverage | No physical camera |
| Multiple trucks/layers and item reconciliation | Pass, automated lifecycle/manifest coverage | Single-process/local DB |
| Duplicate active layer number | Pass, DB constraint | Does not track cartons across different photos |
| Pause/resume session | Pass | OS-kill behavior needs devices |
| Offline credential fallback and lockout | Pass | 24-hour revocation window |
| Queue retry/backoff, full payload, stale acknowledgement | Pass | Upload-only; no remote pull |
| Cascading wagon/truck deletes | Pass | Server multi-device reconciliation not available |
| PDF/Excel logic and export audit | Pass | Unicode visual QA and encrypted sharing unresolved |
| Backup/archive create and restore | Pass | Archive is unencrypted |
| Invalid JWT, expiry, unknown user timing | Pass | External penetration test not performed |
| Malformed/oversize inference upload | Fixed and backend-tested at validation boundary | No load test against deployed service |
| Admin lint/build/dependency audit | Pass | Browser E2E suite absent |
| Android compile/package/permission check | Pass for debug | Signed release credentials unavailable |
| iOS build | Blocked | iOS 26.5 platform unavailable on host |
| ONNX shape/hash/synthetic inference | Pass | No independent images or device benchmark |
| Real-time camera/tracking stress | Not applicable to current still-photo design | Required only if live counting is promised |
| Defect AI | Not implemented | Manual operator entry only |
| Battery/RAM/CPU/thermal/crash-free | Not run | Physical device/telemetry absent |

## Unresolved issues and release blockers

### Critical

1. **Independent accuracy evidence is absent.** The original source images/labels needed to reproduce the training and holdout audits are not present. Do not publish an accuracy claim from the internal validation CSV.
2. **No physical device acceptance.** Camera, latency, thermal, memory, battery, permissions, backgrounding, and crash-recovery behavior are unverified on Android and iOS.
3. **Sensitive local data is not application-level encrypted.** SQLite, carton photos, and administrator audit ZIPs require encryption or a formally enforced managed-device storage/export policy.
4. **Synchronization is not multi-device complete.** There is no pull path or conflict UI. Enforce single writer per wagon/truck or build bidirectional versioned sync before parallel operation.

### High

1. Automated defect detection is absent; product/UI must continue to call defects operator-recorded.
2. Signed Android release and iOS release builds are unavailable in this audit environment; iOS SDK/platform setup is incomplete.
3. Backend strict typing has 34 errors across legacy SQLAlchemy model usage in four router files.
4. No external penetration test, deployed API load test, browser E2E suite, mobile `integration_test` suite, crash reporting, or production SLO alerting exists.
5. Report archives are shareable but unencrypted; Unicode PDF fonts are not production-qualified.

### Medium

1. Seventy Flutter packages have newer versions outside current constraints; several are major upgrades and require a controlled compatibility sprint.
2. Flutter warns that some Android plugins use a Kotlin Gradle application pattern that will become unsupported; four iOS plugins lack SwiftPM support.
3. Large embedded model size produces large APKs. Use Android App Bundle/ABI delivery and measure install/download/storage budgets.
4. Backend schema evolution uses startup logic rather than a mature migration/rehearsal workflow; add Alembic and rollback drills.

## Required acceptance campaign before approval

1. Freeze a versioned, access-controlled warehouse dataset with train/validation/test provenance and perceptual duplicate leakage checks. Use an untouched test split stratified by truck, site, carton type, density, occlusion, lighting, angle, damage, and phone.
2. Pre-register field gates. Recommended starting gates: exact layer-count rate ≥ 99%, mean absolute count error ≤ 0.10 carton/layer, zero unreviewed saves, and separate results for dense/occluded/night conditions. Business owners must approve the actual thresholds.
3. Run at least the minimum and target Android devices plus supported iPhones through 30-minute capture cycles, screen lock/resume, incoming-call overlay, low storage, low battery, permission denial/revocation, OS kill, and offline/reconnect cases. Record p50/p95 latency, peak RAM, CPU, thermal state, battery drain, and crash-free sessions.
4. Add API concurrency/load/soak tests, browser E2E tests, Flutter integration tests, and multi-device conflict tests against a staging PostgreSQL service.
5. Choose one defect strategy: explicitly manual, or create a labelled multi-class defect model with its own safety/accuracy gates. Never infer defect accuracy from the carton-only model.
6. Implement SQLCipher-equivalent database protection and encrypted photo/export handling, or enforce audited MDM hardware encryption, remote wipe, data-loss prevention, and export controls.
7. Provision Android signing in a secure CI secret store, install the required iOS platform/certificates/profiles, update the version, build AAB/IPA, generate SBOMs, sign artifacts, and repeat permission/dependency checks on those exact artifacts.
8. Resolve all backend mypy errors, add database migrations, deploy crash/error monitoring with redaction, define SLOs/runbooks, and perform backup/restore plus rollback drills.

## Final disposition

The application’s **local, single-device, operator-verified loading workflow is substantially hardened and its automated regression suite is green**. The repaired code should move to a controlled staging and field-validation campaign. It should not yet be described or deployed as a proven industrial-grade real-time counter, automated defect detector, encrypted multi-device system, or fully production-ready release.
