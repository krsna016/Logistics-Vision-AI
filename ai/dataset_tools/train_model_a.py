#!/usr/bin/env python3
"""Train and export Model A with Ultralytics YOLO in Colab or locally."""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--model", default="yolo11n.pt")
    parser.add_argument("--epochs", type=int, default=150)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--batch", type=int, default=-1)
    parser.add_argument("--project", type=Path, default=Path("runs/model_a"))
    parser.add_argument("--name", default="carton_yolo11n")
    parser.add_argument("--export-onnx", action="store_true")
    return parser.parse_args()


def main() -> None:
    from ultralytics import YOLO

    args = parse_args()
    model = YOLO(args.model)
    result = model.train(
        data=str(args.data),
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch=args.batch,
        device=0,
        workers=4,
        patience=30,
        project=str(args.project),
        name=args.name,
        pretrained=True,
        plots=True,
    )
    print(f"Training complete: {result.save_dir}")

    best = Path(result.save_dir) / "weights" / "best.pt"
    if args.export_onnx and best.exists():
        trained = YOLO(str(best))
        exported = trained.export(format="onnx", imgsz=args.imgsz, opset=12)
        print(f"ONNX export: {exported}")


if __name__ == "__main__":
    main()
