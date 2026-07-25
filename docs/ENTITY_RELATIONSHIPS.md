# Entity Relationships & Aggregate Roots - Logistics Vision AI

This document establishes the transaction boundaries, aggregate structures, and relational mappings for the business domain.

---

## 1. Aggregate Roots

To maintain consistency and enforce business invariants, entities are grouped into bounded aggregates:

```
[ TruckSession (Aggregate Root) ]
   |
   +---> [ Layer ]
   |        |
   |        +---> [ Carton ]
   |        +---> [ Photo ]
   |
   +---> [ Defect ]
```

### Aggregate Root: `TruckSession`
*   **Boundary**: Controls the entire loading session transaction.
*   **Rule**: All modifications to `Layers`, `Cartons`, and `Defects` must traverse this aggregate. You cannot add a `Defect` without validating it against the parent `Layer` coordinates and ensuring the `TruckSession` is in a mutable `loading` status.

---

## 2. Mermaid Domain Mapping Diagram

```mermaid
classDiagram
    class Warehouse {
        +UUID id
        +String name
        +String locationCode
    }
    class Truck {
        +UUID id
        +String licensePlate
        +String status
    }
    class TruckSession {
        +UUID sessionId
        +UUID operatorId
        +DateTime startedAt
        +int runningTotal
    }
    class Layer {
        +UUID id
        +int layerNumber
        +int cartonCount
        +DateTime verifiedAt
    }
    class Defect {
        +UUID id
        +String defectType
        +String severity
        +bool confirmed
    }
    class Photo {
        +UUID id
        +String localPath
        +String remoteUrl
    }
    class User {
        +UUID id
        +String email
        +String role
    }

    Warehouse "1" --> "*" Truck : manages
    Truck "1" --> "*" TruckSession : schedules
    TruckSession "1" --> "*" Layer : aggregates
    Layer "1" --> "*" Defect : contains
    Layer "1" --> "*" Photo : captures
    Defect "1" --> "1" Photo : documents
    User "1" --> "*" TruckSession : loads
```
