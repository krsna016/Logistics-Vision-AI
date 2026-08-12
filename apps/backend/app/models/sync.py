import uuid

from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text, UniqueConstraint
from sqlalchemy.sql import func

from ..db.database import Base


class SyncedRecord(Base):
    """Company A's durable operational record envelope.

    Domain payloads stay JSON so older mobile releases can sync while the
    normalized admin views are introduced incrementally.
    """

    __tablename__ = "synced_records"
    __table_args__ = (UniqueConstraint("entity_type", "entity_id", name="uq_sync_entity"),)

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    entity_type = Column(String, nullable=False, index=True)
    entity_id = Column(String, nullable=False, index=True)
    operation_id = Column(String, nullable=False, unique=True, index=True)
    operation = Column(String, nullable=False)
    payload_json = Column(Text, nullable=False)
    version = Column(Integer, nullable=False, default=1)
    employee_id = Column(String, nullable=False, index=True)
    device_id = Column(String, nullable=True)
    client_created_at = Column(DateTime(timezone=True), nullable=True)
    client_updated_at = Column(DateTime(timezone=True), nullable=True)
    is_deleted = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
