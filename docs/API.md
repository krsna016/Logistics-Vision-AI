# REST API Specification - Logistics Vision AI

All endpoint URLs are prefixed with the version namespace `/api/v1`. Communication is performed over HTTPS using JSON payloads.

---

## 1. Authentication

### POST `/api/v1/auth/login`
Exchanges user credentials for a JWT token (delegated to Supabase Auth service).
*   **Request Body**:
    ```json
    {
      "email": "loader1@warehouse.com",
      "password": "secure_password_123"
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "rfr_ey...",
      "expires_in": 3600,
      "user": {
        "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        "email": "loader1@warehouse.com",
        "role": "operator"
      }
    }
    ```

---

## 2. Truck Management

### GET `/api/v1/trucks`
Lists active or completed trucks for warehouse loading assignments.
*   **Response (200 OK)**:
    ```json
    [
      {
        "id": "e0e37bc9-56b0-466d-a9a7-47bdfd92f9d1",
        "license_plate": "TX-9908-AB",
        "status": "loading",
        "created_at": "2026-07-25T10:00:00Z"
      }
    ]
    ```

---

## 3. Sync & Layer Management

### POST `/api/v1/sync/batch`
Synchronizes offline data outbox payloads. Accepts batch writes of layers and defects.
*   **Request Body**:
    ```json
    {
      "layers": [
        {
          "id": "b1b2b3b4-c5c6-d7d8-e9e0-f1f2f3f4f5f6",
          "truck_id": "e0e37bc9-56b0-466d-a9a7-47bdfd92f9d1",
          "layer_number": 3,
          "carton_count": 24,
          "operator_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
          "timestamp": "2026-07-25T11:20:00Z",
          "notes": "Slight carton slip corrected manually"
        }
      ],
      "defects": [
        {
          "id": "d1d2d3d4-e5e6-f7f8-a9a0-b1b2b3b4f5f6",
          "layer_id": "b1b2b3b4-c5c6-d7d8-e9e0-f1f2f3f4f5f6",
          "defect_type": "crushed",
          "bounding_box": {
            "x_min": 0.12,
            "y_min": 0.34,
            "x_max": 0.45,
            "y_max": 0.67
          },
          "severity": "medium",
          "confirmed_by_operator": true
        }
      ]
    }
    ```
*   **Response (200 OK)**:
    ```json
    {
      "synced_layer_ids": ["b1b2b3b4-c5c6-d7d8-e9e0-f1f2f3f4f5f6"],
      "synced_defect_ids": ["d1d2d3d4-e5e6-f7f8-a9a0-b1b2b3b4f5f6"],
      "status": "success"
    }
    ```

---

## 4. Photo Upload

### POST `/api/v1/photos/upload`
Uploads a high-resolution photo file linked to a layer. Multipart form upload.
*   **Form Parameters**:
    - `photo_id`: UUID
    - `layer_id`: UUID
    - `file`: Binary file data
*   **Response (201 Created)**:
    ```json
    {
      "photo_id": "c1c2c3c4-d5d6-e7e8-f9f0-a1a2a3a4b5b6",
      "remote_url": "https://storage.supabase.co/object/sign/photos/c1c2c3.jpg"
    }
    ```

---

## 5. Report Generation

### GET `/api/v1/reports/truck/{truck_id}`
Triggers server-side compile for a PDF loading report. Returns PDF download URL.
*   **Query Parameters**:
    - `format`: String (options: `pdf`, `csv`, `json`)
*   **Response (200 OK)**:
    ```json
    {
      "truck_id": "e0e37bc9-56b0-466d-a9a7-47bdfd92f9d1",
      "format": "pdf",
      "report_url": "https://storage.supabase.co/reports/TX-9908-AB_2026-07-25.pdf",
      "generated_at": "2026-07-25T11:45:00Z"
    }
    ```

---

## 6. System Health Check

### GET `/api/v1/health`
Checks backend dependencies status. Used by container probes and client status checks.
*   **Response (200 OK)**:
    ```json
    {
      "status": "healthy",
      "database": "connected",
      "storage_provider": "connected",
      "timestamp": "2026-07-25T11:45:12Z"
    }
    ```
*   **Response (503 Service Unavailable)**:
    ```json
    {
      "status": "unhealthy",
      "database": "disconnected",
      "storage_provider": "connected"
    }
    ```
