# Domain Services - Logistics Vision AI

Domain Services implement business operations that are stateless, execute computations involving multiple entities, or interface with external systems.

---

## 1. Domain Services Registry

### Service: `CountingService`
*   **Responsibility**: Coordinates with the model inference outputs and the manual edit overrides to calculate the final validated layer count.
*   **Why a Service?**: The counting process does not belong to a single `Layer` entity, as it spans AI bounding boxes, tracking ID trails over frame sequences, and operator corrections.

### Service: `SyncService`
*   **Responsibility**: Evaluates the `SyncQueue` state, parses connection statuses, executes batch uploads, and resolves synchronization conflicts.
*   **Why a Service?**: It is an infrastructure/data orchestration service requiring database transaction management and remote network checking APIs.

### Service: `ReportService`
*   **Responsibility**: Aggregates loading logs, operators data, and high-resolution defect images to compile PDF/CSV summary reports.
*   **Why a Service?**: Compiling data into a visual report is a transformation process rather than a domain model entity.

### Service: `TruckCalculationService`
*   **Responsibility**: Compares the sum of saved layers against the digital shipping manifest to check for quantity discrepancies.
*   **Why a Service?**: Spans both the `Truck` scheduling model and the external `ERP/Manifest` systems.
