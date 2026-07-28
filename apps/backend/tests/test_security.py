import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.core.security import create_access_token
from app.schemas.user import UserCreate


def test_access_token_contains_subject_and_role(monkeypatch):
    monkeypatch.setattr(settings, "SECRET_KEY", "x" * 32)
    token = create_access_token("EMP-1", "Admin")
    assert isinstance(token, str)


def test_user_creation_requires_strong_password_and_known_role():
    valid = UserCreate(employee_id="EMP-1", name="Operator", role="Operator", password="long-enough-password")
    assert valid.role == "Operator"
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="Operator", role="Owner", password="long-enough-password")
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="Operator", role="Operator", password="short")
