# Technology Stack Evaluation - Logistics Vision AI

This document evaluates the proposed technology stack, confirms its suitability for our enterprise logistics scenario, and introduces specific library selections and optimizations needed for production-grade scale.

---

## 1. Summary of Recommended Tech Stack

| Layer | Proposed Component | Recommendation | Business & Technical Rationale |
| :--- | :--- | :--- | :--- |
| **Frontend Framework** | Flutter & Dart | **Confirm** | Single codebase compile target for Android and iOS. High-performance rendering pipeline suitable for drawing real-time bounding box overlays on camera feeds. |
| **State Management** | Riverpod | **Confirm** | Type-safe, avoids global mutable state, and makes testing repositories and notifier logic easy. |
| **Routing** | GoRouter | **Confirm** | Native Flutter-supported routing framework with clean parameter passing and declarative layout structure. |
| **Local Database** | SQLite | **Confirm with Drift** | Drift (formerly Moor) wraps SQLite in Dart to provide type-safe queries, stream-based updates, and clean database migration APIs. |
| **Local Encryption** | *None specified* | **SQLCipher** | Essential for enterprise applications to encrypt local SQLite DB files at rest using keys from the Android Keystore & iOS Keychain. |
| **Cloud Database** | Supabase & Postgres | **Confirm** | Offers built-in Row Level Security (RLS), instant REST endpoints, and simplified real-time synchronization hooks. |
| **Backend API Gateway**| FastAPI & Python | **Confirm** | Async python framework with native OpenAPI doc generation. Ideal for executing asynchronous PDF generation and system integration tasks. |
| **AI Architecture** | YOLO | **YOLOv8-Nano / YOLOv10-Nano** | Standard YOLO models are too heavy. YOLO-Nano models quantized to **INT8** balance execution speed ($\le 100\text{ ms}$ per frame) and precision. |
| **Inference Engine** | ONNX Runtime | **Confirm** | Multi-platform engine. Leverages NNAPI (Android) and CoreML (iOS) to bypass CPU processing and run inference directly on device NPUs. |
| **CI/CD & DevOps** | GitHub Actions & Docker| **Confirm** | Reusable action containers compile mobile build nodes and deploy FastAPI servers to production clusters securely. |

---

## 2. Deep-Dive Evaluations & Alternatives

### Local Database: Why Drift over raw SQLite?
Raw SQLite requires writing manual SQL strings and parsing raw maps back to Dart objects. By integrating **Drift**, we achieve:
1. **Type-Safe Queries**: Drift generates Dart classes for all tables and queries, eliminating runtime typos.
2. **Reactive Streams**: Changes to local records auto-update UI components listening to matching streams.
3. **Clean Migrations**: Drift provides step-by-step schema upgrade guides, making it easy to release schema changes across thousands of remote active devices.

### AI Engine: ONNX Runtime vs. TensorFlow Lite
While TensorFlow Lite (TFLite) is widely used, **ONNX Runtime** is recommended here because:
*   **Model Compatibility**: Exporters from PyTorch (where YOLO is trained) directly target ONNX. TFLite requires intermediate conversion steps, which often break custom layers.
*   **Optimized Performance**: ONNX Runtime consistently displays superior execution times on Apple NPU hardware via the CoreML Execution Provider.

### Backend: FastAPI vs. Node.js (NestJS)
FastAPI is chosen over Node.js because the core AI development team uses Python. Using Python for both model training (YOLO) and backend tooling makes it easy to share image processing scripts, data validation code, and evaluation utilities.
