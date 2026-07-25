# Repository Specifications - Logistics Vision AI

Repositories define the persistence contracts for the domain aggregates. They manage data fetching, local queries, and database write transactions.

---

## 1. Repository Interfaces

### Repository: `TruckRepository`
*   **Purpose**: Manages truck sessions, license plate queries, and schedules.
*   **Signature**:
    *   `Future<Truck?> getTruckById(UUID id);`
    *   `Future<List<Truck>> getActiveTrucks();`
    *   `Future<void> updateTruckStatus(UUID id, TruckStatus status);`

### Repository: `LayerRepository`
*   **Purpose**: Handles saving completed layer logs and tracking totals.
*   **Signature**:
    *   `Future<void> saveLayer(Layer layer);`
    *   `Future<List<Layer>> getLayersBySession(UUID sessionId);`
    *   `Future<int> getTruckRunningTotal(UUID sessionId);`

### Repository: `SyncRepository`
*   **Purpose**: Manages local outbox queues and synchronization retries.
*   **Signature**:
    *   `Future<void> queueSyncAction(SyncJob job);`
    *   `Future<List<SyncJob>> getPendingJobs(int limit);`
    *   `Future<void> markJobComplete(UUID jobId);`
    *   `Future<void> updateJobFailure(UUID jobId, String error);`
