# Value Objects Specification - Logistics Vision AI

Value Objects are immutable, do not possess a unique identity, and are defined entirely by their attributes.

---

## 1. Value Objects Registry

### Value Object: `BoundingBox`
*   **Attributes**: `xMin` (double), `yMin` (double), `xMax` (double), `yMax` (double).
*   **Business Rules**: Coordinates must be normalized between $0.0$ and $1.0$. $x_{min}$ must be less than $x_{max}$.

### Value Object: `GeoLocation`
*   **Attributes**: `latitude` (double), `longitude` (double), `accuracy` (double).
*   **Business Rules**: Latitude must be between $-90$ and $90$; longitude between $-180$ and $180$.

### Value Object: `ConfidenceScore`
*   **Attributes**: `value` (double).
*   **Business Rules**: Must represent a percentage score between $0.0$ and $1.0$.

### Value Object: `TruckNumber`
*   **Attributes**: `plate` (string), `jurisdiction` (string).
*   **Business Rules**: Must match standard alphanumeric state/provincial registration standards.

### Value Object: `ModelVersion`
*   **Attributes**: `major` (int), `minor` (int), `patch` (int), `architecture` (string).
*   **Business Rules**: Must follow semantic versioning.
