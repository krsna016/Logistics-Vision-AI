# Business Rules & Invariants - Logistics Vision AI

This document details the domain rules, state transition invariants, validation formulas, and recovery behaviors.

---

## 1. Core Business Rules

### Rule BR-01: Unique Layer Numbers per Truck Session
*   **Purpose**: Prevent double counting or accidental overwrites of completed layers.
*   **Validation**: The system checks if `LayerNumber` already exists in the `layers` table for the target `SessionID`.
*   **Failure Behavior**: Blocks write action, throws `DuplicateLayerException`.
*   **Recovery Behavior**: Suggests the user increments the layer number or loads the existing layer state for edits.

### Rule BR-02: Truck Loading Completion Constraint
*   **Purpose**: Prevent trucks from being dispatched with incorrect carton quantities.
*   **Validation**:
    $$\sum \text{Layer Counts} == \text{Carrier Manifest Carton Count}$$
*   **Failure Behavior**: Rejects status change to `completed`. Banners a quantity warning.
*   **Recovery Behavior**: Prompts the user to review layers, add missing carton annotations, or request a supervisor override.

### Rule BR-03: Bounding Box Collision Deduplication
*   **Purpose**: Filter duplicate carton counts from high-frequency AI inference runs.
*   **Validation**:
    $$\text{IoU}(\text{Box A}, \text{Box B}) \ge 0.70 \implies \text{Deduplicate Box B}$$
*   **Failure Behavior**: Filters Box B from the final detection layer payload.
*   **Recovery Behavior**: Transparent operation inside the pre-commit model decorator.

### Rule BR-04: Report Deletion Authority
*   **Purpose**: Protect data audit trails for client disputes.
*   **Validation**: Check user role context. Requires `role == 'manager'` or `'admin'`.
*   **Failure Behavior**: Returns authorization exception.
*   **Recovery Behavior**: Displays access denied dialog; prompts for supervisor credentials.

---

## 2. Sync Conflict Resolution Policies
*   **Policy**: The device timestamp of the first operator write wins for a given layer. If a second operator attempts to write to the same `(truck_id, layer_number)` from another device, the cloud transaction rejects the write, saves the attempt to `sync_errors`, and flags the supervisor dashboard for manual conflict resolution.
