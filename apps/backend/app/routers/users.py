# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import delete
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from ..core.security import get_current_user, get_password_hash, require_admin
from ..db.database import get_db
from ..models.location import LocationPing, LocationSession
from ..models.user import User
from ..schemas.user import UserCreate, UserResponse, UserUpdate

router = APIRouter()


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
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
    _: User = Depends(require_admin),
):
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

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
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == actor.id:
        raise HTTPException(
            status_code=400, detail="You cannot disable your own account"
        )
    user.is_active = False
    await db.commit()
    return {"status": "success", "message": "User disabled"}


@router.post("/{employee_id}/activate")
async def activate_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = True
    await db.commit()
    return {"status": "success", "message": "User activated"}


@router.delete("/{employee_id}/hard", status_code=status.HTTP_200_OK)
async def hard_delete_user(
    employee_id: str,
    db: AsyncSession = Depends(get_db),
    actor: User = Depends(require_admin),
):
    """Permanently remove a user after the admin confirms the destructive action."""
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == actor.id:
        raise HTTPException(
            status_code=400, detail="You cannot delete your own account"
        )
    # Location records reference the employee by employee_id. Remove the
    # dependent tracking history before deleting the account.
    await db.execute(
        delete(LocationPing).where(LocationPing.employee_id == employee_id)
    )
    await db.execute(
        delete(LocationSession).where(LocationSession.employee_id == employee_id)
    )
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
