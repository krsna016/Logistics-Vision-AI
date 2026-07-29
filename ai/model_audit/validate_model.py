"""Validate a YOLO carton detector and measure per-image counting accuracy."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--split", default="test", choices=("train", "val", "test"))
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--conf", type=float, default=0.25)
    parser.add_argument("--iou", type=float, default=0.45)
    parser.add_argument("--device", default=None)
    return parser.parse_args()


def label_path(image_path: Path) -> Path:
    parts = list(image_path.parts)
    if "images" in parts:
        parts[parts.index("images")] = "labels"
    return Path(*parts).with_suffix(".txt")


def ground_truth_count(image_path: Path) -> int:
    labels = label_path(image_path)
    if not labels.exists():
        raise FileNotFoundError(f"Missing label file for {image_path}: {labels}")
    return sum(1 for line in labels.read_text().splitlines() if line.strip())


def image_paths(value: object, data_file: Path) -> Iterable[Path]:
    path = Path(value) if isinstance(value, str) else None
    if path is None:
        raise ValueError(f"Unsupported {data_file.name} split value: {value!r}")
    if not path.is_absolute():
        path = (data_file.parent / path).resolve()
    if path.is_dir():
        yield from sorted(
            p for p in path.rglob("*") if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp"}
        )
    else:
        yield from (Path(line.strip()) for line in path.read_text().splitlines() if line.strip())


def main() -> None:
    args = parse_args()
    if not args.model.exists():
        raise SystemExit(f"Model not found: {args.model}")
    if not args.data.exists():
        raise SystemExit(f"Dataset YAML not found: {args.data}")

    try:
        import yaml
        from ultralytics import YOLO
    except ImportError as exc:
        raise SystemExit("Install dependencies first: python3 -m pip install ultralytics pyyaml") from exc

    config = yaml.safe_load(args.data.read_text())
    images = list(image_paths(config[args.split], args.data))
    if not images:
        raise SystemExit(f"No images found for split '{args.split}'")

    model = YOLO(str(args.model))
    validation = model.val(
        data=str(args.data),
        split=args.split,
        imgsz=args.imgsz,
        conf=args.conf,
        iou=args.iou,
        device=args.device,
        verbose=False,
    )

    absolute_errors: list[int] = []
    exact = under = over = 0
    for image in images:
        prediction = model.predict(
            source=str(image),
            imgsz=args.imgsz,
            conf=args.conf,
            iou=args.iou,
            device=args.device,
            verbose=False,
        )[0]
        predicted = 0 if prediction.boxes is None else len(prediction.boxes)
        actual = ground_truth_count(image)
        error = predicted - actual
        absolute_errors.append(abs(error))
        exact += error == 0
        under += error < 0
        over += error > 0

    total = len(images)
    print(f"Images evaluated       : {total}")
    print(f"mAP50                  : {validation.box.map50:.4f}")
    print(f"mAP50-95               : {validation.box.map:.4f}")
    print(f"Precision              : {validation.box.mp:.4f}")
    print(f"Recall                 : {validation.box.mr:.4f}")
    print(f"Exact count accuracy   : {exact / total:.4%}")
    print(f"Mean absolute count err: {sum(absolute_errors) / total:.4f}")
    print(f"Undercount rate        : {under / total:.4%}")
    print(f"Overcount rate         : {over / total:.4%}")


if __name__ == "__main__":
    main()
