from datetime import datetime

from pydantic import BaseModel, Field


class LocationHeartbeat(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    accuracy_meters: float | None = Field(default=None, ge=0, le=100000)
    recorded_at: datetime | None = None


class LiveLocation(BaseModel):
    employee_id: str
    employee_name: str
    role: str
    latitude: float
    longitude: float
    accuracy_meters: float | None
    recorded_at: datetime
    session_id: str
