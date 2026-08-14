import sys
from datetime import datetime, timezone
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock

import jwt
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import settings
from app.core.security import create_access_token
from app.models.user import User
from app.routers import auth
from app.routers.inference import _has_supported_image_signature
from app.schemas.sync import SyncBatchIn
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


def test_sync_batch_rejects_unbounded_or_invalid_records():
    with pytest.raises(ValueError):
        SyncBatchIn(
            records=[
                {
                    "operation_id": "op-1",
                    "entity_type": "Layer",
                    "entity_id": "layer-1",
                    "operation": "UPSERT",
                    "version": 1,
                }
            ]
        )
    valid_record = {
        "operation_id": "op-valid",
        "entity_type": "Layer",
        "entity_id": "layer-1",
        "operation": "INSERT",
        "version": 1,
    }
    with pytest.raises(ValueError):
        SyncBatchIn(records=[valid_record] * 101)


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
        SimpleNamespace(username=" op-105 ", password="correct-password"),
        db,
    )

    parsed = Token.model_validate(response)
    assert parsed.access_token == "test-token"
    assert parsed.user.employee_id == "OP-105"
    db.commit.assert_not_awaited()
    query = str(db.execute.await_args.args[0])
    assert "upper(" not in query.lower()
