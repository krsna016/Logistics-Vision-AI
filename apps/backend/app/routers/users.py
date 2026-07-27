from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from ..db.database import get_db
from ..models.user import User
from ..schemas.user import UserCreate, UserResponse, UserUpdate
from ..core.security import get_password_hash

router = APIRouter()

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.employee_id == user_in.employee_id))
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

@router.get("/", response_model=List[UserResponse])
async def read_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User))
    users = result.scalars().all()
    return users

@router.get("/{employee_id}", response_model=UserResponse)
async def read_user(employee_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/{employee_id}", response_model=UserResponse)
async def update_user(employee_id: str, user_in: UserUpdate, db: AsyncSession = Depends(get_db)):
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
async def disable_user(employee_id: str, db: AsyncSession = Depends(get_db)):
    # We soft-delete by setting is_active to False
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.is_active = False
    await db.commit()
    return {"status": "success", "message": "User disabled"}

@router.post("/{employee_id}/activate")
async def activate_user(employee_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.is_active = True
    await db.commit()
    return {"status": "success", "message": "User activated"}

@router.delete("/{employee_id}/hard")
async def hard_delete_user(employee_id: str, db: AsyncSession = Depends(get_db)):
    # Permanently delete the user from the database
    result = await db.execute(select(User).where(User.employee_id == employee_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    await db.delete(user)
    await db.commit()
    return {"status": "success", "message": "User permanently deleted"}
