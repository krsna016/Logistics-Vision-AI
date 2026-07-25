# Domain Events Specification - Logistics Vision AI

Domain events represent key business occurrences in the lifecycle of the system. They are published to trigger secondary actions (like writing sync queues, updating cache, or generating reports).

---

## 1. Events Registry

### Event: `TruckCreated`
*   **Occurrence**: Triggered when a new truck assignment is scheduled or entered by dock operations.
*   **Payload**:
    ```json
    {
      "event_id": "evt_9081",
      "timestamp": "2026-07-25T10:00:00Z",
      "truck_id": "truck_tx_9908",
      "license_plate": "TX-9908-AB"
    }
    ```

### Event: `LayerStarted`
*   **Occurrence**: Triggered when a loader navigates to the scanning screen for a new layer.
*   **Payload**:
    ```json
    {
      "event_id": "evt_9082",
      "timestamp": "2026-07-25T11:15:00Z",
      "session_id": "session_aus1_tx9908_20260725",
      "layer_number": 3
    }
    ```

### Event: `LayerCompleted`
*   **Occurrence**: Triggered when the loader confirms the count and saves the layer.
*   **Payload**:
    ```json
    {
      "event_id": "evt_9083",
      "timestamp": "2026-07-25T11:20:00Z",
      "layer_id": "layer_tx9908_03",
      "carton_count": 24,
      "operator_id": "usr_loader_01"
    }
    ```

### Event: `DefectDetected`
*   **Occurrence**: Triggered when a defect is flagged by the pipeline or manually by the loader.
*   **Payload**:
    ```json
    {
      "event_id": "evt_9084",
      "timestamp": "2026-07-25T11:20:05Z",
      "defect_id": "def_aus1_9908_101",
      "defect_type": "crushed",
      "severity": "medium"
    }
    ```

### Event: `SyncCompleted`
*   **Occurrence**: Triggered when the synchronization queue manager successfully uploads a batch to the cloud database.
*   **Payload**:
    ```json
    {
      "event_id": "evt_9085",
      "timestamp": "2026-07-25T11:45:00Z",
      "batch_job_id": "job_sync_9080",
      "synced_records_count": 5
    }
    ```
