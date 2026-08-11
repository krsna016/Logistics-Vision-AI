#!/usr/bin/env python3
"""Convert COCO object-detection datasets to Ultralytics YOLO format."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from collections import Counter, defaultdict
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="COCO root containing images/ and annotations/")
    parser.add_argument("output", type=Path, help="Destination YOLO dataset directory")
    parser.add_argument("--overwrite", action="store_true")
    return parser.parse_args()


def convert_split(
    source: Path,
    output: Path,
    coco_split: str,
    yolo_split: str,
    category_map: dict[int, int],
) -> dict[str, int]:
    annotation_path = source / "annotations" / f"instances_{coco_split}.json"
    image_source = source / "images" / coco_split
    data = json.loads(annotation_path.read_text(encoding="utf-8"))

    images = {image["id"]: image for image in data["images"]}
    annotations: dict[int, list[dict]] = defaultdict(list)
    for annotation in data["annotations"]:
        annotations[annotation["image_id"]].append(annotation)

    image_output = output / yolo_split / "images"
    label_output = output / yolo_split / "labels"
    image_output.mkdir(parents=True, exist_ok=True)
    label_output.mkdir(parents=True, exist_ok=True)

    instance_count = 0
    clipped_point_count = 0
    bbox_fallback_count = 0
    for image_id, image in images.items():
        width = float(image["width"])
        height = float(image["height"])
        source_image = image_source / image["file_name"]
        if not source_image.is_file():
            raise FileNotFoundError(f"Missing image: {source_image}")

        destination_image = image_output / source_image.name
        shutil.copy2(source_image, destination_image)

        rows: list[str] = []
        for annotation in annotations.get(image_id, []):
            category_id = annotation["category_id"]
            if category_id not in category_map:
                raise ValueError(f"Unknown category ID {category_id} in {annotation_path}")
            segments = annotation.get("segmentation", [])
            polygon = segments[0] if isinstance(segments, list) and segments else []
            if len(polygon) < 6 or len(polygon) % 2:
                x, y, box_width, box_height = map(float, annotation["bbox"])
                polygon = [x, y, x + box_width, y, x + box_width, y + box_height, x, y + box_height]
                bbox_fallback_count += 1

            normalized: list[float] = []
            for index in range(0, len(polygon), 2):
                original_x, original_y = float(polygon[index]), float(polygon[index + 1])
                clipped_x = max(0.0, min(width, original_x))
                clipped_y = max(0.0, min(height, original_y))
                clipped_point_count += (clipped_x, clipped_y) != (original_x, original_y)
                normalized.extend((clipped_x / width, clipped_y / height))

            if len({(normalized[i], normalized[i + 1]) for i in range(0, len(normalized), 2)}) < 3:
                continue
            coordinates = " ".join(f"{value:.8f}" for value in normalized)
            rows.append(f"{category_map[category_id]} {coordinates}")
            instance_count += 1

        (label_output / f"{source_image.stem}.txt").write_text(
            "\n".join(rows) + ("\n" if rows else ""), encoding="utf-8"
        )

    return {
        "images": len(images),
        "labels": len(images),
        "instances": instance_count,
        "clipped_points": clipped_point_count,
        "bbox_polygon_fallbacks": bbox_fallback_count,
        "empty_images": sum(not annotations.get(image_id) for image_id in images),
    }


def remove_exact_duplicates(output: Path) -> list[dict[str, str]]:
    """Keep duplicates in the strongest holdout split (valid before train)."""
    seen: dict[str, Path] = {}
    removed: list[dict[str, str]] = []
    for split in ("valid", "train"):
        for image_path in sorted((output / split / "images").iterdir()):
            digest = hashlib.sha256(image_path.read_bytes()).hexdigest()
            if digest not in seen:
                seen[digest] = image_path
                continue
            kept = seen[digest]
            label_path = output / split / "labels" / f"{image_path.stem}.txt"
            image_path.unlink()
            label_path.unlink()
            removed.append({"removed": str(image_path.relative_to(output)), "kept": str(kept.relative_to(output))})
    return removed


def summarize_split(
    output: Path, split: str, clipped_points: int, bbox_polygon_fallbacks: int
) -> dict[str, int]:
    images = list((output / split / "images").iterdir())
    labels = list((output / split / "labels").glob("*.txt"))
    rows = [label.read_text(encoding="utf-8").splitlines() for label in labels]
    return {
        "images": len(images),
        "labels": len(labels),
        "instances": sum(len(lines) for lines in rows),
        "clipped_points": clipped_points,
        "bbox_polygon_fallbacks": bbox_polygon_fallbacks,
        "empty_images": sum(not lines for lines in rows),
    }


def main() -> None:
    args = parse_args()
    source = args.source.resolve()
    output = args.output.resolve()
    train_json = source / "annotations" / "instances_train2017.json"
    val_json = source / "annotations" / "instances_val2017.json"
    if not train_json.is_file() or not val_json.is_file():
        raise FileNotFoundError("Expected instances_train2017.json and instances_val2017.json")
    if output.exists():
        if not args.overwrite:
            raise FileExistsError(f"Output already exists: {output}; pass --overwrite to replace it")
        shutil.rmtree(output)

    train_data = json.loads(train_json.read_text(encoding="utf-8"))
    categories = sorted(train_data["categories"], key=lambda item: item["id"])
    category_map = {category["id"]: index for index, category in enumerate(categories)}
    class_names = [category["name"].lower() for category in categories]

    initial_splits = {
        "train": convert_split(source, output, "train2017", "train", category_map),
        "valid": convert_split(source, output, "val2017", "valid", category_map),
    }
    duplicates = remove_exact_duplicates(output)
    report = {
        "source": str(source),
        "format": "YOLO segmentation (normalized polygon points)",
        "classes": class_names,
        "duplicate_policy": "keep exact duplicates in valid before train",
        "duplicates_removed": duplicates,
        "splits": {
            split: summarize_split(
                output,
                split,
                values["clipped_points"],
                values["bbox_polygon_fallbacks"],
            )
            for split, values in initial_splits.items()
        },
    }
    report["totals"] = dict(
        Counter(
            {
                key: sum(split[key] for split in report["splits"].values())
                for key in next(iter(report["splits"].values()))
            }
        )
    )

    names_yaml = "\n".join(f"  {index}: {name}" for index, name in enumerate(class_names))
    (output / "data.yaml").write_text(
        "train: train/images\nval: valid/images\n\nnames:\n"
        + names_yaml
        + "\n",
        encoding="utf-8",
    )
    (output / "conversion_report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
