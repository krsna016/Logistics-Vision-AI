import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.core.security import create_access_token
from app.schemas.user import UserCreate


def test_access_token_contains_subject_and_role(monkeypatch):
    monkeypatch.setattr(settings, "SECRET_KEY", "x" * 32)
    token = create_access_token("EMP-1", "Administrator")
    assert isinstance(token, str)


def test_user_creation_accepts_only_the_two_supported_roles():
    valid = UserCreate(employee_id="EMP-1", name="Supervisor", role="Supervisor", password="x")
    assert valid.role == "Supervisor"
    admin = UserCreate(employee_id="ADM-1", name="Admin", role="Administrator", password="x")
    assert admin.role == "Administrator"
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="User", role="Operator", password="long-enough-password")
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="User", role="Manager", password="long-enough-password")
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="User", role="Supervisor", password="")
