# FastAPI dependencies are intentionally declared as parameter defaults.
# ruff: noqa: B008

import base64

import httpx
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from ..core.config import settings
from ..core.security import get_current_user
from ..models.user import User

router = APIRouter()
MAX_IMAGE_BYTES = 15 * 1024 * 1024
SUPPORTED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}


def _has_supported_image_signature(content: bytes) -> bool:
    return (
        content.startswith((b"\xff\xd8\xff", b"\x89PNG\r\n\x1a\n"))
        or (len(content) >= 12 and content[:4] == b"RIFF" and content[8:12] == b"WEBP")
    )


@router.post("/box-counting")
async def detect_cardboxes(
    image: UploadFile = File(...),
    _: User = Depends(get_current_user),
):
    """Run the configured Roboflow carton-counting workflow.

    The Roboflow key stays server-side; the mobile client only receives the
    normalized prediction payload it needs to draw boxes and count cartons.
    """
    if not settings.ROBOFLOW_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Roboflow inference is not configured",
        )

    if image.content_type not in SUPPORTED_IMAGE_TYPES:
        raise HTTPException(status_code=415, detail="Only JPEG, PNG, or WebP images are supported")

    # Bound the read itself. Checking size only after an unbounded read lets a
    # malicious upload consume arbitrary worker memory before being rejected.
    content = await image.read(MAX_IMAGE_BYTES + 1)
    if not content:
        raise HTTPException(status_code=400, detail="Image file is empty")
    if len(content) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image is too large")
    if not _has_supported_image_signature(content):
        raise HTTPException(status_code=415, detail="Uploaded data is not a supported image")

    url = (
        f"{settings.ROBOFLOW_API_URL.rstrip('/')}/"
        f"{settings.ROBOFLOW_WORKSPACE}/workflows/{settings.ROBOFLOW_WORKFLOW_ID}"
    )
    payload = {
        "api_key": settings.ROBOFLOW_API_KEY,
        "inputs": {
            "image": {
                "type": "base64",
                "value": base64.b64encode(content).decode("ascii"),
            },
            "classes": settings.ROBOFLOW_CLASSES,
        },
        "use_cache": True,
    }
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(url, json=payload)
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail="Roboflow inference unavailable") from exc

    if response.is_error:
        raise HTTPException(status_code=502, detail="Roboflow inference failed")
    try:
        result = response.json()
    except ValueError as exc:
        raise HTTPException(status_code=502, detail="Roboflow returned an invalid response") from exc
    return {"predictions": _find_predictions(result), "image": {"width": 0, "height": 0}, "workflow": settings.ROBOFLOW_WORKFLOW_ID}


def _find_predictions(value):
    if isinstance(value, dict):
        predictions = value.get("predictions")
        if isinstance(predictions, list):
            return predictions
        for child in value.values():
            found = _find_predictions(child)
            if found:
                return found
    elif isinstance(value, list):
        for child in value:
            found = _find_predictions(child)
            if found:
                return found
    return []
