# Testing Strategy - Logistics Vision AI

This document establishes the test frameworks, quality standards, and automated evaluation steps for Logistics Vision AI.

---

## 1. Quality Target Budgets

| Category | Target Metric | Metric Definition |
| :--- | :--- | :--- |
| **Code Coverage** | $\ge 85\%$ | Combined branch coverage for Application, Domain, and Data Layers. |
| **AI Inference Latency**| $\le 150\text{ ms}$ | Average processing latency of YOLO object detection on mobile target devices. |
| **AI Model Precision** | $\ge 96.5\%$ | mAP@0.5 score on validated carton test sets. |
| **UI Responsiveness** | 60 / 120 FPS | Zero stuttering (jank frames) on presentation layer during live camera overlay drawing. |

---

## 2. Test Execution Protocols

### Unit & Domain Testing
*   **Target**: Core business logic, parsing engines, state transitions, and database mappings.
*   **Strategy**: Mock external systems using `mocktail` or Drift's in-memory SQLite wrapper.
*   **Command**:
    ```bash
    flutter test test/unit/
    ```

### Widget & UI State Testing
*   **Target**: Component styling, layout boundaries, and provider state bindings.
*   **Strategy**: Exercise screens using simulated tap sequences. Verify that loading spinners appear during asynchronous states and that validation errors block submit actions.
*   **Command**:
    ```bash
    flutter test test/widget/
    ```

### Integration Testing (On-Device)
*   **Target**: Full end-to-end device journeys including camera input simulations and database writes.
*   **Strategy**: Run `patrol` tests to execute app logic on real simulator instances.
*   **Command**:
    ```bash
    patrol test --target integration_test/app_flow_test.dart
    ```

### Offline & Synchronization Resiliency Testing
*   **Target**: Synchronization queue behavior, local caches, and conflict resolutions.
*   **Strategy**:
    1. Populate the local outbox.
    2. Programmatically cut off network connections (by changing network conditions via emulator profiles).
    3. Trigger sync operations and assert that records remain queued.
    4. Restore the connection and confirm records update to the cloud.

### AI Model Validation (Computer Vision Testing)
*   **Target**: Quantized YOLO model evaluation under various environments.
*   **Strategy**:
    *   Maintain a gold-standard dataset of 1,000 warehouse images representing different warehouse layouts, occlusion rates, and low-light scenarios.
    *   Run regression evaluations before updating the mobile `.onnx` assets to ensure new model builds do not decrease regression precision score metrics.

### Security & Privacy Audits
*   **Target**: Sensitive data storage and network transfers.
*   **Strategy**: Run static code analyzers (like `dart_code_metrics` or `sonar-scanner`) to verify secret configurations are not checked in, and run network interceptors (OWASP ZAP) to assert all remote API communication strictly mandates SSL/TLS pinning.
