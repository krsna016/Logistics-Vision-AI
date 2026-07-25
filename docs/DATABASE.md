# Database Schema Design - Logistics Vision AI

This document defines the schema structure, indexing strategy, and data migration guidelines for the offline SQLite database and the cloud PostgreSQL database.

---

## 1. Entity-Relationship (ER) Model

```
+---------------+        +---------------+        +----------------------+
|     users     |        |    trucks     |        | synchronization_queue|
+---------------+        +---------------+        +----------------------+
| id (PK)       |        | id (PK)       |        | id (PK)              |
| email         |        | license_plate |        | action_type          |
| role          |        | status        |        | payload (JSON)       |
+-------+-------+        +-------+-------+        | created_at           |
        |                        |                +----------------------+
        |                        |
        |                        v
        |                +---------------+        +----------------------+
        |                |    layers     |        |      audit_logs      |
        +--------------->| id (PK)       |        +----------------------+
                         | truck_id (FK) |        | id (PK)              |
                         | count         |        | user_id (FK)         |
                         | operator (FK) |        | action               |
                         +-------+-------+        | timestamp            |
                                 |                +----------------------+
                                 |
                     +-----------+-----------+
                     |                       |
                     v                       v
             +---------------+       +---------------+
             |    photos     |       |    defects    |
             +---------------+       +---------------+
             | id (PK)       |       | id (PK)       |
             | layer_id (FK) |       | layer_id (FK) |
             | local_path    |       | defect_type   |
             | remote_url    |       | bounding_box  |
             +---------------+       +---------------+
```

---

## 2. Table Definitions

### Table: `users`
Tracks authorized warehouse workers and managers.
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('operator', 'manager', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Table: `trucks`
Represents the target trucks being loaded.
```sql
CREATE TABLE trucks (
    id UUID PRIMARY KEY,
    license_plate VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'loading' CHECK (status IN ('loading', 'completed', 'dispatched')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Table: `layers`
Records discrete layers counted and saved for a given truck.
```sql
CREATE TABLE layers (
    id UUID PRIMARY KEY,
    truck_id UUID NOT NULL REFERENCES trucks(id) ON DELETE CASCADE,
    layer_number INTEGER NOT NULL,
    carton_count INTEGER NOT NULL CHECK (carton_count >= 0),
    operator_id UUID NOT NULL REFERENCES users(id),
    notes TEXT,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    synced BOOLEAN DEFAULT FALSE,
    UNIQUE (truck_id, layer_number)
);
```

### Table: `photos`
Maintains images associated with saved layers (especially those containing defects).
```sql
CREATE TABLE photos (
    id UUID PRIMARY KEY,
    layer_id UUID NOT NULL REFERENCES layers(id) ON DELETE CASCADE,
    local_path VARCHAR(512),
    remote_url VARCHAR(512),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Table: `defects`
Tracks individual carton defects detected within a layer.
```sql
CREATE TABLE defects (
    id UUID PRIMARY KEY,
    layer_id UUID NOT NULL REFERENCES layers(id) ON DELETE CASCADE,
    defect_type VARCHAR(50) NOT NULL CHECK (defect_type IN ('torn', 'crushed', 'wet', 'broken', 'missing_label', 'open')),
    bounding_box JSONB NOT NULL, -- Format: {"x_min": float, "y_min": float, "x_max": float, "y_max": float}
    severity VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high')),
    confirmed_by_operator BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Table: `synchronization_queue`
Offline outbox for recording changes to sync to the cloud.
```sql
CREATE TABLE synchronization_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Auto-increment on SQLite
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    payload JSONB NOT NULL,
    attempts INTEGER DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Table: `audit_logs`
System-wide security logging for operational transparency.
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    action VARCHAR(255) NOT NULL,
    target_table VARCHAR(100) NOT NULL,
    target_id UUID NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

---

## 3. Indexing Strategy
To maintain performance on mobile devices with high volume writes and lookup queries:
*   **Layer Lookups**: Create a composite index on `layers(truck_id, layer_number)` to fetch and calculate total carton counts instantly:
    ```sql
    CREATE INDEX idx_layers_truck_lookup ON layers(truck_id, layer_number);
    ```
*   **Sync Processing**: Index `synchronization_queue(created_at)` to process the sync outbox chronologically:
    ```sql
    CREATE INDEX idx_sync_queue_chronological ON synchronization_queue(created_at);
    ```
*   **Defect Queries**: Index `defects(layer_id)` for quick inspection report generation:
    ```sql
    CREATE INDEX idx_defects_layer_id ON defects(layer_id);
    ```

---

## 4. Migration Plan
*   **SQLite Migrations**: Drift manages schema upgrades using migrations defined in Dart. On schema modification, Drift's `migration` helper performs tables reconstruction or structural additions during application launch.
*   **Cloud Migrations**: Database changes are deployed via Supabase CLI or Prisma schema deployments in matching CD pipelines.
*   **Validation**: Every schema update must run unit tests verifying that older client schemas migrate cleanly to the target version without dropping un-synchronized local records.
