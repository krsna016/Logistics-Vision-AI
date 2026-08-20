# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from ..core.security import get_current_user, get_password_hash, require_admin
from ..db.database import get_db
from ..models.user import AdminAuditEvent, User
from ..schemas.user import UserCreate, UserResponse, UserUpdate

router = APIRouter()


async def _active_admin_ids_for_update(db: AsyncSession) -> set[str]:
    result = await db.execute(
        select(User)
        .where(User.role == "Administrator", User.is_active.is_(True))
        .with_for_update()
    )
    return {user.id for user in result.scalars().all()}


def _record_admin_event(
    db: AsyncSession,
    actor: User,
    target_employee_id: str,
    action: str,
    details: str | None = None,
) -> None:
    db.add(
        AdminAuditEvent(
            actor_employee_id=actor.employee_id,
            target_employee_id=target_employee_id,
            action=action,
            details=details,
        )
    )


def _reject_last_admin_change(user: User, active_admin_ids: set[str]) -> None:
    if user.id in active_admin_ids and len(active_admin_ids) == 1:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="At least one active administrator must remain",
        )


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    result = await db.execute(
        select(User).where(User.employee_id == user_in.employee_id)
    )
    user = result.scalars().first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="User with this employee ID already exists",
        )

    hashed_password = get_password_hash(user_in.password)
    db_user = User(
        employee_id=user_in.employee_id,
        name=user_in.name,
        role=user_in.role,
        hashed_password=hashed_password,
    )
    db.add(db_user)
    _record_admin_event(db, actor, db_user.employee_id, "user_created")
    await db.commit()
    await db.refresh(db_user)
    return db_user


@router.get("/", response_model=list[UserResponse])
async def read_users(
    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)
):
    result = await db.execute(select(User))
    users = result.scalars().all()
    return users


@router.get("/{employee_id}", response_model=UserResponse)
async def read_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.employee_id != employee_id and current_user.role != "Administrator":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Access denied"
        )
    if current_user.employee_id == employee_id:
        return current_user
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{employee_id}", response_model=UserResponse)
async def update_user(
    employee_id: str,
    user_in: UserUpdate,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    active_admin_ids = await _active_admin_ids_for_update(db)
    result = await db.execute(
        select(User).where(User.employee_id == employee_id).with_for_update()
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_in.model_dump(exclude_unset=True, exclude_none=True)
    removes_admin_access = (
        user.role == "Administrator"
        and user.is_active
        and (
            update_data.get("role", user.role) != "Administrator"
            or update_data.get("is_active", user.is_active) is False
        )
    )
    if removes_admin_access:
        _reject_last_admin_change(user, active_admin_ids)
    for field, value in update_data.items():
        setattr(user, field, value)

    _record_admin_event(
        db,
        actor,
        employee_id,
        "user_updated",
        f"fields={','.join(sorted(update_data))}",
    )
    await db.commit()
    await db.refresh(user)
    return user


@router.delete("/{employee_id}")
async def disable_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    # We soft-delete by setting is_active to False
    active_admin_ids = await _active_admin_ids_for_update(db)
    result = await db.execute(
        select(User).where(User.employee_id == employee_id).with_for_update()
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == actor.id:
        raise HTTPException(
            status_code=400, detail="You cannot disable your own account"
        )
    _reject_last_admin_change(user, active_admin_ids)
    user.is_active = False
    _record_admin_event(db, actor, employee_id, "user_disabled")
    await db.commit()
    return {"status": "success", "message": "User disabled"}


@router.post("/{employee_id}/activate")
async def activate_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    result = await db.execute(
        select(User).where(User.employee_id == employee_id).with_for_update()
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = True
    _record_admin_event(db, actor, employee_id, "user_activated")
    await db.commit()
    return {"status": "success", "message": "User activated"}


@router.delete("/{employee_id}/hard", status_code=status.HTTP_200_OK)
async def hard_delete_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    """Permanently remove a user after the admin confirms the destructive action."""
    active_admin_ids = await _active_admin_ids_for_update(db)
    result = await db.execute(
        select(User).where(User.employee_id == employee_id).with_for_update()
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == actor.id:
        raise HTTPException(
            status_code=400, detail="You cannot delete your own account"
        )
    _reject_last_admin_change(user, active_admin_ids)
    _record_admin_event(db, actor, employee_id, "user_hard_deleted")
    await db.delete(user)
    try:
        await db.commit()
    except SQLAlchemyError:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User could not be deleted because it is still referenced by another record",
        )
    return {"status": "success", "message": "User permanently deleted"}
