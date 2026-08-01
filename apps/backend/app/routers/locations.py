from datetime import datetime, timedelta, timezone

import jwt
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, status
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.security import get_current_user, require_admin
from ..core.config import settings
from ..db.database import get_db
from ..models.location import LocationPing, LocationSession
from ..models.user import User
from ..schemas.location import LiveLocation, LocationHeartbeat

router = APIRouter()
admin_streams: set[WebSocket] = set()


async def broadcast_location(location: LiveLocation) -> None:
    disconnected = []
    for websocket in tuple(admin_streams):
        try:
            await websocket.send_json(location.model_dump(mode="json"))
        except Exception:
            disconnected.append(websocket)
    for websocket in disconnected:
        admin_streams.discard(websocket)


async def broadcast_event(event: dict) -> None:
    disconnected = []
    for websocket in tuple(admin_streams):
        try:
            await websocket.send_json(event)
        except Exception:
            disconnected.append(websocket)
    for websocket in disconnected:
        admin_streams.discard(websocket)


@router.websocket("/stream")
async def location_stream(websocket: WebSocket, db: AsyncSession = Depends(get_db)):
    """Push location updates to authenticated Admin dashboard sessions."""
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=1008, reason="Authentication required")
        return
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        employee_id = payload.get("sub")
        result = await db.execute(select(User).where(User.employee_id == employee_id))
        user = result.scalars().first()
        if user is None or not user.is_active or user.role != "Admin":
            raise ValueError("Admin access required")
    except (jwt.InvalidTokenError, ValueError):
        await websocket.close(code=1008, reason="Invalid Admin session")
        return

    await websocket.accept()
    admin_streams.add(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        admin_streams.discard(websocket)


@router.post("/heartbeat", status_code=status.HTTP_202_ACCEPTED)
async def receive_heartbeat(
    payload: LocationHeartbeat,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Receive the authenticated device's latest location.

    The employee identity always comes from the access token, never the request body.
    """
    session_result = await db.execute(
        select(LocationSession)
        .where(
            LocationSession.employee_id == current_user.employee_id,
            LocationSession.is_active.is_(True),
        )
        .order_by(LocationSession.started_at.desc())
        .limit(1)
    )
    session = session_result.scalars().first()
    if session is None:
        session = LocationSession(employee_id=current_user.employee_id)
        db.add(session)
        await db.flush()

    ping = LocationPing(
        session_id=session.id,
        employee_id=current_user.employee_id,
        latitude=payload.latitude,
        longitude=payload.longitude,
        accuracy_meters=payload.accuracy_meters,
        recorded_at=payload.recorded_at or datetime.now(timezone.utc),
    )
    db.add(ping)
    await db.commit()
    await broadcast_location(LiveLocation(
        employee_id=current_user.employee_id,
        employee_name=current_user.name,
        role=current_user.role,
        latitude=ping.latitude,
        longitude=ping.longitude,
        accuracy_meters=ping.accuracy_meters,
        recorded_at=ping.recorded_at,
        session_id=session.id,
    ))
    return {"accepted": True, "session_id": session.id}


@router.post("/stop", status_code=status.HTTP_204_NO_CONTENT)
async def stop_tracking(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(LocationSession).where(
            LocationSession.employee_id == current_user.employee_id,
            LocationSession.is_active.is_(True),
        )
    )
    for session in result.scalars().all():
        session.is_active = False
        session.ended_at = datetime.now(timezone.utc)
    await db.commit()
    await broadcast_event({"type": "offline", "employee_id": current_user.employee_id})


@router.get("/live", response_model=list[LiveLocation])
async def read_live_locations(
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Return only the latest ping from each active employee session."""
    recent_cutoff = datetime.now(timezone.utc) - timedelta(seconds=90)
    latest_ping = (
        select(
            LocationPing.employee_id,
            func.max(LocationPing.recorded_at).label("latest_recorded_at"),
        )
        .join(LocationSession, LocationSession.id == LocationPing.session_id)
        .where(
            LocationSession.is_active.is_(True),
            LocationPing.recorded_at >= recent_cutoff,
        )
        .group_by(LocationPing.employee_id)
        .subquery()
    )
    query = (
        select(LocationPing, User, LocationSession)
        .join(User, User.employee_id == LocationPing.employee_id)
        .join(LocationSession, LocationSession.id == LocationPing.session_id)
        .join(
            latest_ping,
            and_(
                latest_ping.c.employee_id == LocationPing.employee_id,
                latest_ping.c.latest_recorded_at == LocationPing.recorded_at,
            ),
        )
        .where(
            LocationSession.is_active.is_(True),
            User.is_active.is_(True),
            LocationPing.recorded_at >= recent_cutoff,
        )
    )
    rows = (await db.execute(query)).all()
    return [
        LiveLocation(
            employee_id=user.employee_id,
            employee_name=user.name,
            role=user.role,
            latitude=ping.latitude,
            longitude=ping.longitude,
            accuracy_meters=ping.accuracy_meters,
            recorded_at=ping.recorded_at,
            session_id=session.id,
        )
        for ping, user, session in rows
    ]
