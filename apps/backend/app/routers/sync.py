# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

import json

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.security import get_current_user, require_admin
from ..db.database import get_db
from ..models.sync import SyncedRecord
from ..models.user import User
from ..schemas.sync import SyncBatchIn, SyncBatchOut, SyncRecordResult

router = APIRouter()


@router.post("/batch", response_model=SyncBatchOut)
async def upload_batch(
    batch: SyncBatchIn,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    results: list[SyncRecordResult] = []
    for item in batch.records:
        # Retrying the same operation is safe and returns the original result.
        existing_operation = await db.scalar(
            select(SyncedRecord).where(SyncedRecord.operation_id == item.operation_id)
        )
        if existing_operation:
            results.append(SyncRecordResult(
                operation_id=item.operation_id,
                entity_type=item.entity_type,
                entity_id=item.entity_id,
                status="already_synced",
                server_version=existing_operation.version,
            ))
            continue

        current = await db.scalar(
            select(SyncedRecord).where(
                SyncedRecord.entity_type == item.entity_type,
                SyncedRecord.entity_id == item.entity_id,
            )
        )
        if current and item.version < current.version:
            results.append(SyncRecordResult(
                operation_id=item.operation_id,
                entity_type=item.entity_type,
                entity_id=item.entity_id,
                status="conflict",
                server_version=current.version,
                conflict_payload=json.loads(current.payload_json),
            ))
            continue

        if current:
            current.operation_id = item.operation_id
            current.operation = item.operation
            current.payload_json = json.dumps(item.payload, separators=(",", ":"))
            current.version = max(current.version + 1, item.version)
            current.employee_id = current_user.employee_id
            current.device_id = item.device_id
            current.client_created_at = item.created_at
            current.client_updated_at = item.updated_at
            current.is_deleted = item.is_deleted or item.operation == "DELETE"
            server_version = current.version
        else:
            record = SyncedRecord(
                entity_type=item.entity_type,
                entity_id=item.entity_id,
                operation_id=item.operation_id,
                operation=item.operation,
                payload_json=json.dumps(item.payload, separators=(",", ":")),
                version=item.version,
                employee_id=current_user.employee_id,
                device_id=item.device_id,
                client_created_at=item.created_at,
                client_updated_at=item.updated_at,
                is_deleted=item.is_deleted or item.operation == "DELETE",
            )
            db.add(record)
            server_version = item.version

        results.append(SyncRecordResult(
            operation_id=item.operation_id,
            entity_type=item.entity_type,
            entity_id=item.entity_id,
            status="synced",
            server_version=server_version,
        ))
    await db.commit()
    return SyncBatchOut(results=results)


@router.get("/records")
async def read_records(
    entity_type: str | None = None,
    employee_id: str | None = None,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    query = select(SyncedRecord).order_by(SyncedRecord.updated_at.desc())
    if entity_type:
        query = query.where(SyncedRecord.entity_type == entity_type)
    if employee_id:
        query = query.where(SyncedRecord.employee_id == employee_id)
    rows = (await db.execute(query.limit(1000))).scalars().all()
    return [
        {
            "entity_type": row.entity_type,
            "entity_id": row.entity_id,
            "operation": row.operation,
            "payload": json.loads(row.payload_json),
            "version": row.version,
            "employee_id": row.employee_id,
            "device_id": row.device_id,
            "is_deleted": row.is_deleted,
            "created_at": row.created_at,
            "updated_at": row.updated_at,
        }
        for row in rows
    ]
