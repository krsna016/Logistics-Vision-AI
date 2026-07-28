from pydantic import BaseModel, ConfigDict, Field
from typing import Literal, Optional
from datetime import datetime

class UserBase(BaseModel):
    employee_id: str = Field(min_length=1, max_length=64)
    name: str = Field(min_length=1, max_length=200)
    role: Literal["Admin", "Manager", "Supervisor", "Operator"]

class UserCreate(UserBase):
    password: str = Field(min_length=12, max_length=128)

class UserUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=200)
    role: Optional[Literal["Admin", "Manager", "Supervisor", "Operator"]] = None
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    id: str
    is_active: bool
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    employee_id: Optional[str] = None
