# Domain Model Specification - Logistics Vision AI

This document defines the core business entities forming the Logistics Vision AI domain.

---

## 1. Domain Entities

### Entity: Warehouse
*   **Purpose**: Represents a physical logistics node or warehouse where trucks are loaded.
*   **Responsibilities**: Groups dock doors, manages local device registration lists, and links active loading operations.
*   **Lifecycle**: Created by admin, remains active, modified when layout changes, deactivated on shutdown.
*   **Relationships**: Owns many Dock Doors and Trucks.
*   **Business Rules**: Must have a valid location code (e.g. ISO-3166 + site ID).
*   **Validation Rules**: Name must not be empty. Latitude/longitude must fall within valid geographic bounds.
*   **Example Instance**:
    ```json
    {
      "id": "wh_austin_01",
      "name": "Austin Fulfillment Center South",
      "location_code": "US-TX-AUS1",
      "dock_doors": ["door_101", "door_102"],
      "created_at": "2026-07-25T10:00:00Z"
    }
    ```

### Entity: Truck
*   **Purpose**: Represents the logistics transport vehicle assigned for loading.
*   **Responsibilities**: Tracks the license plates, loading progress, and current operational states.
*   **Lifecycle**: Created on scheduling, shifts from `loading` to `completed`, archived after dispatch.
*   **Relationships**: Belongs to a Warehouse. Linked to one active `TruckSession` at a time.
*   **Business Rules**: Cannot be dispatched unless total loading quantity matches carrier manifest.
*   **Validation Rules**: License plate must follow strict alphanumeric format validation.
*   **Example Instance**:
    ```json
    {
      "id": "truck_tx_9908",
      "license_plate": "TX-9908-AB",
      "status": "loading",
      "max_capacity_cartons": 1200
    }
    ```

### Entity: TruckSession (Aggregate Root)
*   **Purpose**: Tracks the loading event journey for a specific truck.
*   **Responsibilities**: Computes layers sequence, aggregates running totals, and maintains loading logs.
*   **Lifecycle**: Starts when worker unlocks the truck, ends when manager signs off loading operations.
*   **Relationships**: Contains many `Layers`, `Defects`, and `Photos`.
*   **Business Rules**:
    *   $\text{Truck Total} = \sum \text{Layer Counts}$.
    *   No duplicate layer numbers allowed.
*   **Example Instance**:
    ```json
    {
      "session_id": "session_aus1_tx9908_20260725",
      "truck_id": "truck_tx_9908",
      "operator_id": "usr_loader_01",
      "started_at": "2026-07-25T11:00:00Z",
      "current_layer_number": 3,
      "running_total": 48
    }
    ```

### Entity: Layer
*   **Purpose**: A single stacked layer of cartons verified inside a truck.
*   **Responsibilities**: Holds the carton count, operator identity, notes, and verification timestamp.
*   **Lifecycle**: Drafted during scanning, confirmed by operator, committed to local database, synced to cloud.
*   **Relationships**: Belongs to a `TruckSession`. References many `Cartons` and `Photos`.
*   **Business Rules**: Carton count must not exceed maximum physical layer volume thresholds.
*   **Example Instance**:
    ```json
    {
      "layer_id": "layer_tx9908_03",
      "session_id": "session_aus1_tx9908_20260725",
      "layer_number": 3,
      "carton_count": 24,
      "notes": "Slight carton slip corrected manually",
      "verified_at": "2026-07-25T11:20:00Z"
    }
    ```

### Entity: Defect
*   **Purpose**: Captures damage details for a specific carton.
*   **Responsibilities**: Identifies damage categories (torn, wet, crushed) and links image evidence coordinates.
*   **Lifecycle**: Tagged automatically by AI pipeline or added manually, confirmed by loader, saved, resolved.
*   **Relationships**: References a specific `Layer` and `Photo`.
*   **Business Rules**: Must include a high-contrast bounding box coordinate set and confirmation boolean.
*   **Example Instance**:
    ```json
    {
      "defect_id": "def_aus1_9908_101",
      "layer_id": "layer_tx9908_03",
      "defect_type": "crushed",
      "severity": "medium",
      "bounding_box": {"x_min": 0.12, "y_min": 0.34, "x_max": 0.45, "y_max": 0.67},
      "confirmed_by_operator": true
    }
    ```

### Entity: User
*   **Purpose**: Represents authorized warehouse operators and office managers.
*   **Relationships**: Has a `Role` defining active operational `Permissions`.
*   **Example Instance**:
    ```json
    {
      "id": "usr_loader_01",
      "email": "loader1@warehouse.com",
      "role": "operator",
      "status": "active"
    }
    ```

### Entity: SyncQueue & SyncJob
*   **Purpose**: Outbox mechanism for offline operation resilience.
*   **Responsibilities**: Logs serialized database actions to execute in order once network is established.
*   **Example Instance**:
    ```json
    {
      "job_id": "job_sync_9080",
      "action": "INSERT",
      "table": "layers",
      "payload": {"layer_id": "layer_tx9908_03", "count": 24},
      "attempts": 0,
      "status": "pending"
    }
    ```
