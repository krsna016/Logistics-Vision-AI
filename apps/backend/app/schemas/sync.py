from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class SyncRecordIn(BaseModel):
    operation_id: str = Field(min_length=1, max_length=128)
    entity_type: str = Field(min_length=1, max_length=64)
    entity_id: str = Field(min_length=1, max_length=128)
    operation: str = Field(pattern="^(INSERT|UPDATE|DELETE|ARCHIVE|RESTORE)$")
    payload: dict[str, Any] = Field(default_factory=dict)
    version: int = Field(default=1, ge=1)
    device_id: str | None = Field(default=None, max_length=128)
    created_at: datetime | None = None
    updated_at: datetime | None = None
    is_deleted: bool = False


class SyncRecordResult(BaseModel):
    operation_id: str
    entity_type: str
    entity_id: str
    status: str
    server_version: int
    conflict_payload: dict[str, Any] | None = None


class SyncBatchIn(BaseModel):
    records: list[SyncRecordIn] = Field(max_length=100)


class SyncBatchOut(BaseModel):
    results: list[SyncRecordResult]
