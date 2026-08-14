# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

import asyncio
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from ..core.config import settings
from ..core.security import create_access_token, verify_password
from ..db.database import get_db
from ..models.user import User
from ..schemas.user import Token

router = APIRouter()

# Run the same deliberately expensive password check for unknown IDs so the
# response time does not reveal which employee IDs exist.
_DUMMY_PASSWORD_HASH = "$2b$12$d4D1Xr2mlv7Ji8Yb8QpB6uT6Nbj4CqZpkP5pX6GImQdFq5BAp/.mK"


@router.post("/login", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)
):
    # form_data.username will actually be the employee_id from our mobile app
    normalized_employee_id = form_data.username.strip().upper()
    result = await db.execute(
        select(User).where(User.employee_id == normalized_employee_id)
    )
    user = result.scalars().first()
    if user is None:
        # Compatibility for pre-normalization accounts. Normal accounts use
        # the indexed equality lookup above; this slower fallback runs only
        # for legacy or unknown IDs.
        legacy_result = await db.execute(
            select(User).where(func.upper(User.employee_id) == normalized_employee_id)
        )
        user = legacy_result.scalars().first()

    if not user:
        await asyncio.to_thread(
            verify_password, form_data.password, _DUMMY_PASSWORD_HASH
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect employee ID or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    now = datetime.now(timezone.utc)
    locked_until = user.locked_until
    if locked_until and locked_until.tzinfo is None:
        locked_until = locked_until.replace(tzinfo=timezone.utc)
    if locked_until and locked_until > now:
        raise HTTPException(status_code=429, detail="Account temporarily locked")
    password_matches = await asyncio.to_thread(
        verify_password, form_data.password, user.hashed_password
    )
    if not password_matches:
        user.failed_login_attempts += 1
        if user.failed_login_attempts >= 5:
            user.locked_until = now + timedelta(minutes=15)
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect employee ID or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    if user.failed_login_attempts != 0 or user.locked_until is not None:
        user.failed_login_attempts = 0
        user.locked_until = None
        await db.commit()
    access_token = create_access_token(
        subject=user.employee_id,
        role=user.role,
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user,
    }
