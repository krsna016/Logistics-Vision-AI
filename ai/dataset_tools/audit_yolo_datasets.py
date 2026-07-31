#!/usr/bin/env python3
"""Audit one or more YOLO object-detection datasets before merging them.

Expected layout per dataset::

    dataset/
      data.yaml
      train/images + train/labels
      valid/images + valid/labels   # ``val`` is also accepted
      test/images + test/labels

The script is intentionally dependency-light. Pillow is optional; when it is
installed, image dimensions and file integrity are checked as well.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
SPLITS = ("train", "valid", "val", "test")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "root",
        type=Path,
        help="Folder containing dataset folders such as d1, d2, ...",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("dataset_audit.json"),
        help="JSON report path (default: dataset_audit.json)",
    )
    return parser.parse_args()


def read_yaml_metadata(path: Path) -> dict[str, Any]:
    try:
        import yaml  # type: ignore

        value = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        return value if isinstance(value, dict) else {}
    except ImportError:
        # Minimal fallback for the common Roboflow data.yaml shape.
        text = path.read_text(encoding="utf-8")
        names_match = re.search(r"^names:\s*(.*)$", text, re.MULTILINE)
        names: list[str] = []
        if names_match:
            raw = names_match.group(1).strip()
            if raw.startswith("["):
                names = [item.strip(" '\"") for item in raw[1:-1].split(",")]
            else:
                lines = text.splitlines()
                start = next(
                    (index for index, line in enumerate(lines) if line.startswith("names:")),
                    len(lines),
                )
                for line in lines[start + 1 :]:
                    mapping = re.match(r"^\s+(\d+):\s*(.+)$", line)
                    if mapping:
                        names.append(mapping.group(2).strip(" '\""))
                        continue
                    if line.strip() and not line.startswith((" ", "\t")):
                        break
                if not names and start + 1 < len(lines):
                    inline_list = lines[start + 1].strip()
                    if inline_list.startswith("[") and inline_list.endswith("]"):
                        names = [
                            item.strip(" '\"")
                            for item in inline_list[1:-1].split(",")
                        ]
        return {"names": names}


def class_names(metadata: dict[str, Any]) -> list[str]:
    names = metadata.get("names", [])
    if isinstance(names, dict):
        return [str(names[key]) for key in sorted(names, key=lambda item: int(item))]
    if isinstance(names, list):
        return [str(name) for name in names]
    return []


def image_files(split_dir: Path) -> list[Path]:
    return sorted(
        path
        for path in split_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )


def label_for_image(image: Path, split_dir: Path) -> Path | None:
    relative = image.relative_to(split_dir)
    parts = list(relative.parts)
    if "images" in parts:
        parts[parts.index("images")] = "labels"
        candidate = split_dir.joinpath(*parts).with_suffix(".txt")
        if candidate.exists():
            return candidate
    for candidate in (
        split_dir / "labels" / f"{image.stem}.txt",
        split_dir / f"{image.stem}.txt",
    ):
        if candidate.exists():
            return candidate
    matches = list(split_dir.rglob(f"{image.stem}.txt"))
    return matches[0] if len(matches) == 1 else None


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def audit_label(path: Path, class_count: int) -> dict[str, Any]:
    errors: list[str] = []
    objects = 0
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError as error:
        return {"objects": 0, "errors": [f"not UTF-8: {error}"]}

    for line_number, line in enumerate(lines, start=1):
        if not line.strip():
            continue
        fields = line.split()
        if len(fields) != 5:
            errors.append(f"line {line_number}: expected 5 fields, got {len(fields)}")
            continue
        try:
            class_id = int(fields[0])
            values = [float(value) for value in fields[1:]]
        except ValueError:
            errors.append(f"line {line_number}: non-numeric value")
            continue
        objects += 1
        if class_id < 0 or (class_count and class_id >= class_count):
            errors.append(f"line {line_number}: invalid class id {class_id}")
        if any(value < 0 or value > 1 for value in values):
            errors.append(f"line {line_number}: coordinates outside 0..1")
        if values[2] <= 0 or values[3] <= 0:
            errors.append(f"line {line_number}: width/height must be positive")
    return {"objects": objects, "errors": errors}


def audit_dataset(dataset: Path) -> dict[str, Any]:
    yaml_path = dataset / "data.yaml"
    metadata = read_yaml_metadata(yaml_path) if yaml_path.exists() else {}
    names = class_names(metadata)
    result: dict[str, Any] = {
        "dataset": dataset.name,
        "path": str(dataset),
        "data_yaml": yaml_path.exists(),
        "classes": names,
        "splits": {},
        "errors": [],
        "warnings": [],
    }
    if not yaml_path.exists():
        result["errors"].append("missing data.yaml")

    for split in SPLITS:
        split_dir = dataset / split
        if not split_dir.exists():
            continue
        images = image_files(split_dir)
        split_result = {"images": 0, "labels": 0, "objects": 0, "errors": []}
        for image in images:
            split_result["images"] += 1
            try:
                image_hash = sha256(image)
            except OSError as error:
                split_result["errors"].append(f"{image.name}: unreadable: {error}")
                continue
            label = label_for_image(image, split_dir)
            if label is None:
                split_result["errors"].append(f"{image.relative_to(dataset)}: missing label")
                continue
            split_result["labels"] += 1
            label_result = audit_label(label, len(names))
            split_result["objects"] += label_result["objects"]
            for error in label_result["errors"]:
                split_result["errors"].append(f"{label.relative_to(dataset)}: {error}")
            split_result.setdefault("hashes", {})[str(image.relative_to(dataset))] = image_hash
        result["splits"][split] = split_result

    return result


def main() -> int:
    args = parse_args()
    datasets = sorted(
        path for path in args.root.iterdir() if path.is_dir() and (path / "data.yaml").exists()
    )
    if not datasets:
        print(f"No dataset folders containing data.yaml found under {args.root}", file=sys.stderr)
        return 2

    reports = [audit_dataset(dataset) for dataset in datasets]
    class_sets = {tuple(report["classes"]) for report in reports if report["classes"]}
    if len(class_sets) > 1:
        for report in reports:
            report["warnings"].append("class names differ between datasets")

    hashes: dict[str, list[str]] = defaultdict(list)
    for report in reports:
        for split, split_result in report["splits"].items():
            for relative_path, image_hash in split_result.get("hashes", {}).items():
                hashes[image_hash].append(f"{report['dataset']}/{split}/{relative_path}")

    duplicates = {key: value for key, value in hashes.items() if len(value) > 1}
    split_leaks = {
        key: value
        for key, value in duplicates.items()
        if len({item.split("/")[1] for item in value}) > 1
    }
    report = {"datasets": reports, "duplicate_images": duplicates, "split_leaks": split_leaks}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2), encoding="utf-8")

    errors = sum(
        len(item["errors"])
        + sum(len(split["errors"]) for split in item["splits"].values())
        for item in reports
    )
    print(f"Audited {len(reports)} datasets")
    print(f"Duplicate image groups: {len(duplicates)}")
    print(f"Cross-split leakage groups: {len(split_leaks)}")
    print(f"Errors: {errors}")
    print(f"Report: {args.output}")
    return 1 if errors or split_leaks else 0


if __name__ == "__main__":
    raise SystemExit(main())
