"""Local YOLO segmentation benchmark for numbered carton counting."""

from __future__ import annotations

import base64
import hashlib
import io
import os
import re
import time
from pathlib import Path
from threading import Lock
from typing import Any

import numpy as np
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse
from PIL import Image, ImageDraw, ImageFont, ImageOps
from ultralytics import YOLO


APP_DIR = Path(__file__).resolve().parent
MODEL_PATH = Path(os.getenv("CARTON_MODEL_PATH", APP_DIR / "models" / "best.pt"))
MODEL_DIR = APP_DIR / "models"
MODEL_DIR.mkdir(parents=True, exist_ok=True)
MAX_UPLOAD_BYTES = int(os.getenv("MAX_UPLOAD_MB", "25")) * 1024 * 1024
MAX_MODEL_BYTES = int(os.getenv("MAX_MODEL_MB", "350")) * 1024 * 1024
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}

app = FastAPI(title="Carton Counter", version="1.0.0")
_models: dict[str, YOLO] = {}
_model_lock = Lock()


def registered_models() -> dict[str, Path]:
    return {path.name: path for path in sorted(MODEL_DIR.glob("*.pt")) if path.is_file()}


def model_descriptor(path: Path) -> dict[str, Any]:
    loaded = _models.get(path.name)
    return {"id": path.name, "name": path.stem, "filename": path.name, "size_mb": round(path.stat().st_size / 1024 / 1024, 1), "task": loaded.task if loaded else "not_loaded", "classes": loaded.names if loaded else None, "loaded": loaded is not None, "default": path.resolve() == MODEL_PATH.resolve()}


def get_model(model_id: str = "best.pt") -> YOLO:
    models = registered_models()
    path = models.get(model_id)
    if path is None:
        raise HTTPException(status_code=400, detail=f"Unknown carton model: {model_id}")
    if model_id not in _models:
        with _model_lock:
            if model_id not in _models:
                _models[model_id] = YOLO(str(path))
    return _models[model_id]


def reading_order(boxes: list[list[float]]) -> list[int]:
    """Return top-to-bottom, left-to-right order, tolerant of uneven carton rows."""
    if not boxes:
        return []
    items = []
    for index, (x1, y1, x2, y2) in enumerate(boxes):
        items.append({"index": index, "cx": (x1 + x2) / 2, "cy": (y1 + y2) / 2, "h": max(1.0, y2 - y1)})
    remaining = sorted(items, key=lambda item: item["cy"])
    rows: list[list[dict[str, float | int]]] = []
    while remaining:
        anchor = remaining.pop(0)
        tolerance = max(8.0, float(anchor["h"]) * 0.45)
        row = [anchor]
        rest = []
        for item in remaining:
            if abs(float(item["cy"]) - float(anchor["cy"])) <= max(tolerance, float(item["h"]) * 0.35):
                row.append(item)
            else:
                rest.append(item)
        rows.append(sorted(row, key=lambda item: item["cx"]))
        remaining = rest
    return [int(item["index"]) for row in rows for item in row]


def palette(index: int) -> tuple[int, int, int]:
    colors = [(35, 231, 174), (47, 181, 255), (255, 190, 64), (188, 123, 255), (255, 101, 132)]
    return colors[(index - 1) % len(colors)]


def annotate(image: Image.Image, boxes: list[list[float]], polygons: list[list[list[float]]], confidences: list[float]) -> tuple[Image.Image, list[dict[str, Any]]]:
    canvas = image.convert("RGBA")
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    line_width = max(3, round(min(canvas.size) / 320))
    ordered = reading_order(boxes)
    detections: list[dict[str, Any]] = []

    for number, source_index in enumerate(ordered, start=1):
        box = boxes[source_index]
        polygon = polygons[source_index] if source_index < len(polygons) else []
        confidence = confidences[source_index]
        color = palette(number)
        if len(polygon) >= 3:
            points = [(round(x), round(y)) for x, y in polygon]
            overlay_draw.polygon(points, fill=(*color, 52), outline=(*color, 235), width=line_width)
        overlay_draw.rectangle(tuple(round(value) for value in box), outline=(*color, 245), width=line_width)
        detections.append({
            "number": number,
            "confidence": round(confidence, 4),
            "box": [round(value, 1) for value in box],
            "polygon": [[round(x, 1), round(y, 1)] for x, y in polygon],
        })

    canvas = Image.alpha_composite(canvas, overlay)
    draw = ImageDraw.Draw(canvas)
    font_size = max(15, round(min(canvas.size) / 42))
    try:
        font = ImageFont.truetype("Arial Bold.ttf", font_size)
    except OSError:
        font = ImageFont.load_default()

    for number, source_index in enumerate(ordered, start=1):
        x1, y1, x2, y2 = boxes[source_index]
        color = palette(number)
        radius = max(13, round(font_size * 0.82))
        cx = max(radius + 3, min(canvas.width - radius - 3, round(x1 + radius)))
        cy = max(radius + 3, min(canvas.height - radius - 3, round(y1 + radius)))
        draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=(4, 20, 27, 240), outline=(*color, 255), width=max(2, line_width))
        label = str(number)
        text_box = draw.textbbox((0, 0), label, font=font)
        draw.text((cx - (text_box[2] - text_box[0]) / 2, cy - (text_box[3] - text_box[1]) / 2 - 1), label, fill=(255, 255, 255, 255), font=font)
    return canvas.convert("RGB"), detections


def data_url(image: Image.Image) -> str:
    buffer = io.BytesIO()
    image.save(buffer, format="JPEG", quality=92, optimize=True)
    return "data:image/jpeg;base64," + base64.b64encode(buffer.getvalue()).decode("ascii")


@app.get("/")
def index() -> FileResponse:
    return FileResponse(APP_DIR / "static" / "index.html")


@app.get("/styles.css")
def styles() -> FileResponse:
    return FileResponse(APP_DIR / "static" / "styles.css", media_type="text/css")


@app.get("/readability.css")
def readability_styles() -> FileResponse:
    return FileResponse(APP_DIR / "static" / "readability.css", media_type="text/css")


@app.get("/app.js")
def javascript() -> FileResponse:
    return FileResponse(APP_DIR / "static" / "app.js", media_type="application/javascript")


@app.get("/api/health")
def health() -> dict[str, Any]:
    models = registered_models()
    return {"status": "ready" if models else "model_missing", "model": MODEL_PATH.name, "model_path": str(MODEL_PATH), "model_size_mb": round(MODEL_PATH.stat().st_size / 1024 / 1024, 1) if MODEL_PATH.is_file() else None, "models": len(models)}


@app.get("/api/models")
def list_models() -> list[dict[str, Any]]:
    return [model_descriptor(path) for path in registered_models().values()]


@app.post("/api/models")
async def upload_model(model: UploadFile = File(...)) -> dict[str, Any]:
    filename = Path(model.filename or "uploaded-model.pt").name
    if not filename.lower().endswith(".pt"):
        raise HTTPException(status_code=415, detail="Only trusted Ultralytics/PyTorch .pt model files are supported.")
    payload = await model.read(MAX_MODEL_BYTES + 1)
    if len(payload) > MAX_MODEL_BYTES:
        raise HTTPException(status_code=413, detail=f"Model is larger than {MAX_MODEL_BYTES // 1024 // 1024} MB.")
    if not payload:
        raise HTTPException(status_code=422, detail="The model file is empty.")
    digest = hashlib.sha256(payload).hexdigest()[:10]
    safe_stem = re.sub(r"[^a-zA-Z0-9_-]+", "-", Path(filename).stem).strip("-") or "carton-model"
    target = MODEL_DIR / f"{safe_stem}-{digest}.pt"
    if target.exists():
        return model_descriptor(target)
    target.write_bytes(payload)
    try:
        loaded = YOLO(str(target))
        _models[target.name] = loaded
        if loaded.task not in {"segment", "detect"}:
            raise ValueError(f"Unsupported model task: {loaded.task}")
    except Exception as exc:
        _models.pop(target.name, None)
        target.unlink(missing_ok=True)
        raise HTTPException(status_code=422, detail=f"This checkpoint could not be loaded as a YOLO detection/segmentation model: {exc}") from exc
    return model_descriptor(target)


@app.post("/api/count")
async def count_cartons(image: UploadFile = File(...), model_id: str = Form("best.pt"), confidence: float = Form(0.27), iou: float = Form(0.70), image_size: int = Form(960), ground_truth: str = Form("")) -> dict[str, Any]:
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=415, detail="Please upload a JPEG, PNG, or WebP image.")
    if not 0.05 <= confidence <= 0.95 or not 0.1 <= iou <= 0.95:
        raise HTTPException(status_code=400, detail="Confidence or IoU is outside the allowed range.")
    if image_size not in {640, 960, 1280}:
        raise HTTPException(status_code=400, detail="Image size must be 640, 960, or 1280.")
    payload = await image.read(MAX_UPLOAD_BYTES + 1)
    if len(payload) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail=f"Image is larger than {MAX_UPLOAD_BYTES // 1024 // 1024} MB.")
    try:
        original = ImageOps.exif_transpose(Image.open(io.BytesIO(payload))).convert("RGB")
    except Exception as exc:
        raise HTTPException(status_code=422, detail="The uploaded image could not be opened.") from exc

    started = time.perf_counter()
    try:
        result = get_model(model_id).predict(source=np.asarray(original), conf=confidence, iou=iou, imgsz=image_size, retina_masks=True, max_det=1000, verbose=False)[0]
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Carton-model inference failed: {exc}") from exc

    boxes = result.boxes.xyxy.detach().cpu().tolist() if result.boxes is not None else []
    confidences = result.boxes.conf.detach().cpu().tolist() if result.boxes is not None else []
    polygons = [polygon.tolist() for polygon in result.masks.xy] if result.masks is not None else [[] for _ in boxes]
    marked, detections = annotate(original, boxes, polygons, confidences)
    elapsed_ms = round((time.perf_counter() - started) * 1000)
    verified = int(ground_truth) if ground_truth.strip().isdigit() else None
    predicted = len(detections)
    return {
        "model_id": model_id,
        "model_name": Path(model_id).stem,
        "predicted_count": predicted,
        "ground_truth_count": verified,
        "count_error": predicted - verified if verified is not None else None,
        "exact": predicted == verified if verified is not None else None,
        "average_confidence": round(sum(confidences) / len(confidences), 4) if confidences else 0,
        "elapsed_ms": elapsed_ms,
        "image_width": original.width,
        "image_height": original.height,
        "annotated_image": data_url(marked),
        "detections": detections,
        "parameters": {"confidence": confidence, "iou": iou, "image_size": image_size},
    }
