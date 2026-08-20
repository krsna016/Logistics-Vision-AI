import sys
from datetime import datetime, timezone
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock

import jwt
import pytest
from fastapi import HTTPException

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.core.security import create_access_token, get_password_hash, verify_password
from app.models.user import User
from app.routers import auth, users
from app.routers.inference import _has_supported_image_signature
from app.schemas.user import Token, UserCreate


def test_access_token_contains_subject_and_role(monkeypatch):
    monkeypatch.setattr(settings, "SECRET_KEY", "x" * 32)
    token = create_access_token("EMP-1", "Administrator")
    claims = jwt.decode(
        token,
        settings.SECRET_KEY,
        algorithms=["HS256"],
        issuer=settings.JWT_ISSUER,
        audience=settings.JWT_AUDIENCE,
    )
    assert claims["sub"] == "EMP-1"
    assert claims["role"] == "Administrator"
    assert claims["exp"] > claims["iat"]
    assert claims["jti"]


def test_production_refuses_unsafe_database_and_host_settings(monkeypatch):
    monkeypatch.setattr(settings, "ENVIRONMENT", "production")
    monkeypatch.setattr(settings, "SECRET_KEY", "x" * 32)
    monkeypatch.setattr(settings, "DATABASE_URL", "sqlite+aiosqlite:///./unsafe.sqlite")
    monkeypatch.setattr(settings, "AUTO_CREATE_SCHEMA", False)
    monkeypatch.setattr(settings, "ADMIN_CORS_ORIGINS", "https://admin.example.com")
    monkeypatch.setattr(settings, "TRUSTED_HOSTS", "api.example.com")
    with pytest.raises(RuntimeError, match="managed PostgreSQL"):
        settings.validate_runtime_secrets()

    monkeypatch.setattr(
        settings,
        "DATABASE_URL",
        "postgresql+asyncpg://user:password@db.example.com/smartload",
    )
    monkeypatch.setattr(settings, "AUTO_CREATE_SCHEMA", True)
    with pytest.raises(RuntimeError, match="AUTO_CREATE_SCHEMA"):
        settings.validate_runtime_secrets()


def test_user_creation_accepts_only_the_two_supported_roles():
    valid = UserCreate(
        employee_id="EMP-1",
        name="Supervisor",
        role="Supervisor",
        password="a-secure-passphrase",
    )
    assert valid.role == "Supervisor"
    admin = UserCreate(
        employee_id="ADM-1",
        name="Admin",
        role="Administrator",
        password="another-secure-passphrase",
    )
    assert admin.role == "Administrator"
    normalized = UserCreate(
        employee_id=" op-105 ",
        name=" Operator ",
        role="Supervisor",
        password="another-secure-passphrase",
    )
    assert normalized.employee_id == "OP-105"
    assert normalized.name == "Operator"
    with pytest.raises(ValueError):
        UserCreate(
            employee_id="EMP-1",
            name="User",
            role="Operator",
            password="long-enough-password",
        )
    with pytest.raises(ValueError):
        UserCreate(
            employee_id="EMP-1",
            name="User",
            role="Manager",
            password="long-enough-password",
        )
    with pytest.raises(ValueError):
        UserCreate(employee_id="EMP-1", name="User", role="Supervisor", password="")
    with pytest.raises(ValueError):
        UserCreate(
            employee_id="EMP-1", name="User", role="Supervisor", password="too-short"
        )
    with pytest.raises(ValueError, match="72 UTF-8 bytes"):
        UserCreate(
            employee_id="EMP-1",
            name="User",
            role="Supervisor",
            password="€" * 25,
        )


def test_bcrypt_helpers_reject_oversized_utf8_passwords_without_crashing():
    stored = get_password_hash("a-secure-passphrase")
    assert verify_password("a-secure-passphrase", stored)
    assert not verify_password("€" * 25, stored)
    with pytest.raises(ValueError, match="72 UTF-8 bytes"):
        get_password_hash("€" * 25)


def test_last_active_administrator_cannot_be_removed():
    administrator = User(
        id="admin-1",
        employee_id="ADMIN",
        name="Administrator",
        role="Administrator",
        hashed_password="unused",
        is_active=True,
    )
    with pytest.raises(HTTPException) as error:
        users._reject_last_admin_change(administrator, {"admin-1"})
    assert error.value.status_code == 409

    users._reject_last_admin_change(administrator, {"admin-1", "admin-2"})


def test_inference_upload_signature_validation():
    assert _has_supported_image_signature(b"\xff\xd8\xffjpeg")
    assert _has_supported_image_signature(b"\x89PNG\r\n\x1a\nbytes")
    assert _has_supported_image_signature(b"RIFF\x00\x00\x00\x00WEBPbytes")
    assert not _has_supported_image_signature(b"<script>alert(1)</script>")


@pytest.mark.asyncio
async def test_login_returns_profile_without_redundant_success_commit(monkeypatch):
    user = User(
        id="user-1",
        employee_id="OP-105",
        name="Operator",
        role="Supervisor",
        hashed_password="stored-hash",
        is_active=True,
        failed_login_attempts=0,
        locked_until=None,
        created_at=datetime.now(timezone.utc),
    )
    scalar_result = Mock()
    scalar_result.first.return_value = user
    query_result = Mock()
    query_result.scalars.return_value = scalar_result
    db = SimpleNamespace(
        execute=AsyncMock(return_value=query_result),
        commit=AsyncMock(),
    )
    monkeypatch.setattr(auth, "verify_password", lambda *_: True)
    monkeypatch.setattr(auth, "create_access_token", lambda **_: "test-token")

    response = await auth.login_for_access_token(
        SimpleNamespace(client=SimpleNamespace(host="127.0.0.1")),
        SimpleNamespace(username=" op-105 ", password="correct-password"),
        db,
    )

    parsed = Token.model_validate(response)
    assert parsed.access_token == "test-token"
    assert parsed.user.employee_id == "OP-105"
    db.commit.assert_not_awaited()
    query = str(db.execute.await_args.args[0])
    assert "upper(" not in query.lower()
