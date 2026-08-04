import base64

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
import httpx

from ..core.config import settings
from ..core.security import get_current_user
from ..models.user import User

router = APIRouter()


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

    content = await image.read()
    if not content:
        raise HTTPException(status_code=400, detail="Image file is empty")
    if len(content) > 15 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Image is too large")

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
    result = response.json()
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
