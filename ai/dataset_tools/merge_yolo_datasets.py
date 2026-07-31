#!/usr/bin/env python3
"""Merge YOLO detection datasets while removing exact-image leakage."""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from audit_yolo_datasets import (
    SPLITS,
    audit_dataset,
    class_names,
    image_files,
    label_for_image,
    read_yaml_metadata,
    sha256,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path, help="Folder containing d1, d2, ...")
    parser.add_argument("output", type=Path, help="Merged YOLO dataset folder")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    return parser.parse_args()


def normalized_split(split: str) -> str:
    return "val" if split == "valid" else split


def main() -> int:
    args = parse_args()
    datasets = sorted(
        path for path in args.root.iterdir() if path.is_dir() and (path / "data.yaml").exists()
    )
    if not datasets:
        raise SystemExit("No dataset folders containing data.yaml were found")

    all_classes = [class_names(read_yaml_metadata(dataset / "data.yaml")) for dataset in datasets]
    if any(names != all_classes[0] for names in all_classes[1:]):
        raise SystemExit(f"Class names differ: {all_classes}")
    if all_classes[0] != ["carton"]:
        raise SystemExit(f"Expected one class named carton, found {all_classes[0]}")

    if args.output.exists() and not args.overwrite:
        raise SystemExit(f"Output exists; use --overwrite: {args.output}")
    if args.output.exists() and args.overwrite and not args.dry_run:
        shutil.rmtree(args.output)

    # Keep holdout copies when an identical image appears in multiple splits.
    # This guarantees the same pixels cannot appear in both training and test.
    split_priority = {"test": 0, "valid": 1, "val": 1, "train": 2}
    selected: dict[str, tuple[int, Path, Path, str]] = {}
    duplicates: list[dict[str, str]] = []

    for dataset in datasets:
        for split in SPLITS:
            split_dir = dataset / split
            if not split_dir.exists():
                continue
            for image in image_files(split_dir):
                label = label_for_image(image, split_dir)
                if label is None:
                    raise SystemExit(f"Missing label for {image}")
                image_hash = sha256(image)
                candidate = (split_priority[split], dataset, image, str(label))
                current = selected.get(image_hash)
                if current is None or candidate[0] < current[0]:
                    if current is not None:
                        duplicates.append(
                            {"kept": str(image), "dropped": str(current[2]), "hash": image_hash}
                        )
                    selected[image_hash] = candidate
                else:
                    duplicates.append(
                        {"kept": str(current[2]), "dropped": str(image), "hash": image_hash}
                    )

    counts = {"train": 0, "val": 0, "test": 0}
    if not args.dry_run:
        for split in counts:
            (args.output / "images" / split).mkdir(parents=True, exist_ok=True)
            (args.output / "labels" / split).mkdir(parents=True, exist_ok=True)

    for _, (_, dataset, image, label_string) in selected.items():
        source_split = next(split for split in SPLITS if (dataset / split) in image.parents)
        split = normalized_split(source_split)
        destination_stem = f"{dataset.name}_{image.stem}"
        if not args.dry_run:
            shutil.copy2(image, args.output / "images" / split / f"{destination_stem}{image.suffix.lower()}")
            shutil.copy2(Path(label_string), args.output / "labels" / split / f"{destination_stem}.txt")
        counts[split] += 1

    if not args.dry_run:
        (args.output / "data.yaml").write_text(
            "path: .\ntrain: images/train\nval: images/val\ntest: images/test\nnames: [carton]\n",
            encoding="utf-8",
        )
        (args.output / "merge_report.json").write_text(
            json.dumps(
                {
                    "source_datasets": [dataset.name for dataset in datasets],
                    "counts": counts,
                    "dropped_exact_duplicates": duplicates,
                },
                indent=2,
            ),
            encoding="utf-8",
        )

    print(f"Selected images: {len(selected)}")
    print(f"Train: {counts['train']} | Val: {counts['val']} | Test: {counts['test']}")
    print(f"Exact duplicates removed: {len(duplicates)}")
    print(f"Output: {args.output} {'(dry run)' if args.dry_run else ''}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
