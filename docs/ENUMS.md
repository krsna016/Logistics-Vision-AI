# Domain Enums - Logistics Vision AI

This document catalogs the standard enum definitions representing the static state spaces of the Logistics Vision AI domain.

---

## 1. Domain Enums

### Enum: `TruckStatus`
*   `loading`: Active loading in progress.
*   `completed`: Quantity verified; session closed.
*   `dispatched`: Truck has left the warehouse dock.

### Enum: `LayerStatus`
*   `scanning`: Live camera stream reading carton layers.
*   `completed`: Saved locally to device storage.
*   `synced`: Successfully pushed to cloud database.

### Enum: `DefectType`
*   `torn`: Structural paper tearing on packaging.
*   `crushed`: Box corners or faces dented or squashed.
*   `wet`: Moisture stains on packaging.
*   `broken`: Internal package damage or splits.
*   `missing_label`: Missing shipping label.
*   `open`: Box flaps unsealed or split open.

### Enum: `DefectSeverity`
*   `low`: Minor aesthetic damage; carton safe to load.
*   `medium`: Potential structural impact; requires supervisor inspection.
*   `high`: Package compromised; reject loading.

### Enum: `SyncStatus`
*   `pending`: Event in outbox queue awaiting connection.
*   `processing`: Actively transmitting payload.
*   `completed`: Upload succeeded; safe to clear local outbox records.
*   `failed`: Upload returned error; retrying in background.
