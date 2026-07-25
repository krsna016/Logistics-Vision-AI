# Domain Scalability Planning - Logistics Vision AI

This document details how the business domain scales over a 10-year lifecycle to support multi-tenancy, ERP systems integrations, and physical sensor attachments.

---

## 1. Architectural Scaling Mappings

### Multi-Tenancy (Multiple Companies)
*   **Design**: Introduce a `tenant_id` column to all top-level aggregates (`Warehouse`, `User`, `Truck`). Enforce tenant-level data segregation at the API router level and use PostgreSQL Row-Level Security (RLS) policies in the cloud backend.

### ERP Integrations (SAP, Oracle)
*   **Design**: The `TruckCalculationService` acts as an integration gateway interface. When a truck session is closed, the system publishes a `TruckLoadingFinalized` event. An external integration listener translates this event into an OData/RFC service payload, shipping it directly to SAP/Oracle inventory sub-ledgers.

### IoT Camera & Barcode Expansion
*   **Design**: The camera scanning module interacts with a generic image provider stream. If the warehouse mounts stationary dock cameras, the application can subscribe to those RTSP/IP camera streams by swapping the image provider implementation without modifying the downstream `FrameScheduler` or `ONNXInferenceRepository` modules.
