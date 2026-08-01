from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class UserBase(BaseModel):
    employee_id: str = Field(min_length=1, max_length=64)
    name: str = Field(min_length=1, max_length=200)
    role: Literal["Admin", "Manager", "Supervisor", "Operator"]

class UserCreate(UserBase):
    password: str = Field(min_length=1, max_length=128)

class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    role: Literal["Admin", "Manager", "Supervisor", "Operator"] | None = None
    is_active: bool | None = None

class UserResponse(UserBase):
    id: str
    is_active: bool
    created_at: datetime | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    employee_id: str | None = None
