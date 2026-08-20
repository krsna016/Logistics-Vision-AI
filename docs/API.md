# REST API Specification - Logistics Vision AI

All currently implemented endpoint URLs are prefixed with `/api`. Communication must be performed over HTTPS outside local development.

---

## 1. Authentication

### POST `/api/auth/login`
Exchanges an employee ID and password for a short-lived JWT token and the
authenticated employee profile in one response. Returning both avoids a
second profile request on the critical login path.
*   **Request Body**:
    ```json
    username=EMP-001&password=secure_password_123
    ```
*   **Response (200 OK)**:
    ```json
    {
        "access_token": "eyJhbGciOi...",
        "token_type": "bearer",
        "user": {
          "id": "e0e37bc9-56b0-466d-a9a7-47bdfd92f9d1",
          "employee_id": "EMP-001",
          "name": "Priya Sharma",
          "role": "Supervisor",
          "is_active": true,
          "created_at": "2026-08-14T09:00:00Z",
          "updated_at": null
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

## 3. Local operational data

Truck, wagon, layer, defect, photo, report, and audit data are stored on the
device. There is no operational-data upload or synchronization API.

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
