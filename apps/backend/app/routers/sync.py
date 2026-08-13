# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

import json
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.security import get_current_user, require_admin
from ..db.database import get_db
from ..models.sync import SyncedRecord, SyncHistoryRecord
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
        # Serialize changes to one logical entity on PostgreSQL. Without this,
        # two devices can both read version N and race to write version N+1.
        bind = db.get_bind()
        if bind is not None and bind.dialect.name == "postgresql":
            await db.execute(
                text("SELECT pg_advisory_xact_lock(hashtext(:entity_key))"),
                {"entity_key": f"{item.entity_type}:{item.entity_id}"},
            )
        # The current entity envelope only retains the latest operation id.
        # History is the durable idempotency ledger for every older retry.
        existing_operation = await db.scalar(
            select(SyncHistoryRecord).where(
                SyncHistoryRecord.operation_id == item.operation_id
            )
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
        if current and item.version != current.version + 1:
            db.add(SyncHistoryRecord(
                operation_id=item.operation_id,
                entity_type=item.entity_type,
                entity_id=item.entity_id,
                operation=item.operation,
                status="conflict",
                payload_json=json.dumps(item.payload, separators=(",", ":")),
                version=item.version,
                employee_id=current_user.employee_id,
                device_id=item.device_id,
                client_created_at=item.created_at,
                client_updated_at=item.updated_at,
            ))
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
        db.add(SyncHistoryRecord(
            operation_id=item.operation_id,
            entity_type=item.entity_type,
            entity_id=item.entity_id,
            operation=item.operation,
            status="synced",
            payload_json=json.dumps(item.payload, separators=(",", ":")),
            version=server_version,
            employee_id=current_user.employee_id,
            device_id=item.device_id,
            client_created_at=item.created_at,
            client_updated_at=item.updated_at,
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


@router.get("/history")
async def read_sync_history(
    entity_type: str | None = None,
    entity_id: str | None = None,
    employee_id: str | None = None,
    status: str | None = None,
    cursor: datetime | None = None,
    limit: int = Query(default=50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Return the append-only operational history for admin audit screens."""
    query = select(SyncHistoryRecord)
    if entity_type:
        query = query.where(SyncHistoryRecord.entity_type == entity_type)
    if entity_id:
        query = query.where(SyncHistoryRecord.entity_id == entity_id)
    if employee_id:
        query = query.where(SyncHistoryRecord.employee_id == employee_id)
    if status:
        query = query.where(SyncHistoryRecord.status == status)
    if cursor:
        query = query.where(SyncHistoryRecord.recorded_at < cursor)
    rows = (
        await db.execute(
            query.order_by(SyncHistoryRecord.recorded_at.desc())
            .limit(limit + 1)
        )
    ).scalars().all()
    has_more = len(rows) > limit
    page = rows[:limit]
    records = [
        {
            "operation_id": row.operation_id,
            "entity_type": row.entity_type,
            "entity_id": row.entity_id,
            "operation": row.operation,
            "status": row.status,
            "payload": json.loads(row.payload_json),
            "version": row.version,
            "employee_id": row.employee_id,
            "device_id": row.device_id,
            "client_created_at": row.client_created_at,
            "client_updated_at": row.client_updated_at,
            "recorded_at": row.recorded_at,
        }
        for row in page
    ]
    return {
        "records": records,
        "has_more": has_more,
        "next_cursor": page[-1].recorded_at.isoformat()
        if has_more and page
        else None,
    }
