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
    """Run the exact Roboflow Universe model ``box-counting/4``.

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

    url = f"{settings.ROBOFLOW_API_URL.rstrip('/')}/{settings.ROBOFLOW_MODEL_ID}"
    params = {
        "api_key": settings.ROBOFLOW_API_KEY,
        "confidence": "40",
        "overlap": "30",
    }
    files = {
        "file": (
            image.filename or "frame.jpg",
            content,
            image.content_type or "image/jpeg",
        )
    }
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(url, params=params, files=files)
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail="Roboflow inference unavailable") from exc

    if response.is_error:
        raise HTTPException(status_code=502, detail="Roboflow inference failed")
    result = response.json()
    return {
        "predictions": result.get("predictions", []),
        "image": result.get("image", {"width": 0, "height": 0}),
        "model": settings.ROBOFLOW_MODEL_ID,
    }
