#!/usr/bin/env python3
"""Build the Stage-1 carton instance-segmentation dataset.

The builder is deterministic, validates YOLO polygon labels, removes exact
cross-split duplicates, downsizes unnecessarily large source images, and keeps
an auditable source manifest. Custom train images can be repeated to increase
their effective sampling weight without contaminating custom holdouts.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import random
import shutil
from concurrent.futures import ThreadPoolExecutor
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageOps


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


@dataclass(frozen=True)
class Sample:
    source: str
    source_split: str
    image: Path
    label: Path
    objects: int
    image_hash: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--custom", type=Path, required=True)
    parser.add_argument("--lscd", type=Path, required=True)
    parser.add_argument("--oscd", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--oscd-train-count", type=int, default=4000)
    parser.add_argument("--lscd-val-count", type=int, default=700)
    parser.add_argument("--oscd-val-count", type=int, default=400)
    parser.add_argument("--custom-weight", type=int, default=10)
    parser.add_argument("--max-dimension", type=int, default=1920)
    parser.add_argument("--jpeg-quality", type=int, default=90)
    parser.add_argument("--conversion-workers", type=int, default=8)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--resume", action="store_true")
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_polygon_label(path: Path) -> tuple[int, list[str]]:
    errors: list[str] = []
    objects = 0
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        fields = line.split()
        if len(fields) < 7 or len(fields) % 2 == 0:
            errors.append(
                f"{path}: line {line_number}: expected class plus at least 3 xy points"
            )
            continue
        try:
            class_id = int(fields[0])
            coordinates = [float(value) for value in fields[1:]]
        except ValueError:
            errors.append(f"{path}: line {line_number}: non-numeric value")
            continue
        if class_id != 0:
            errors.append(f"{path}: line {line_number}: expected class 0, got {class_id}")
        if any(value < 0.0 or value > 1.0 for value in coordinates):
            errors.append(f"{path}: line {line_number}: coordinate outside 0..1")
        points = list(zip(coordinates[::2], coordinates[1::2]))
        area = abs(
            sum(
                x1 * y2 - x2 * y1
                for (x1, y1), (x2, y2) in zip(points, points[1:] + points[:1])
            )
        ) / 2.0
        if area <= 1e-8:
            errors.append(f"{path}: line {line_number}: zero-area polygon")
        objects += 1
    return objects, errors


def collect(
    root: Path, source: str, split: str
) -> tuple[list[Sample], list[str], list[dict[str, object]]]:
    image_dir = root / split / "images"
    label_dir = root / split / "labels"
    samples: list[Sample] = []
    errors: list[str] = []
    excluded: list[dict[str, object]] = []
    if not image_dir.exists():
        return samples, [f"Missing image directory: {image_dir}"], excluded
    images = sorted(
        path
        for path in image_dir.iterdir()
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )
    for image in images:
        label = label_dir / f"{image.stem}.txt"
        if not label.exists():
            errors.append(f"Missing label for {image}")
            continue
        objects, label_errors = validate_polygon_label(label)
        if label_errors:
            excluded.append(
                {
                    "source": source,
                    "split": split,
                    "image": str(image),
                    "label": str(label),
                    "reasons": label_errors,
                }
            )
            continue
        try:
            with Image.open(image) as opened:
                opened.verify()
        except (OSError, ValueError) as error:
            errors.append(f"Unreadable image {image}: {error}")
            continue
        samples.append(Sample(source, split, image, label, objects, sha256(image)))
    label_stems = {path.stem for path in label_dir.glob("*.txt")}
    image_stems = {path.stem for path in images}
    for orphan in sorted(label_stems - image_stems):
        errors.append(f"Label without image: {label_dir / (orphan + '.txt')}")
    return samples, errors, excluded


def stratified_select(samples: list[Sample], count: int, seed: int) -> list[Sample]:
    """Select deterministically across sparse, medium, and dense scenes."""
    if count >= len(samples):
        return sorted(samples, key=lambda item: str(item.image))
    rng = random.Random(seed)
    buckets = {
        "sparse": [item for item in samples if item.objects <= 2],
        "medium": [item for item in samples if 3 <= item.objects <= 15],
        "dense": [item for item in samples if item.objects >= 16],
    }
    # Dense scenes dominate because touching cartons are the target problem.
    targets = {"sparse": round(count * 0.10), "medium": round(count * 0.35)}
    targets["dense"] = count - targets["sparse"] - targets["medium"]
    selected: list[Sample] = []
    remainder: list[Sample] = []
    for name, bucket in buckets.items():
        ordered = sorted(bucket, key=lambda item: str(item.image))
        rng.shuffle(ordered)
        take = min(targets[name], len(ordered))
        selected.extend(ordered[:take])
        remainder.extend(ordered[take:])
    if len(selected) < count:
        rng.shuffle(remainder)
        selected.extend(remainder[: count - len(selected)])
    return sorted(selected, key=lambda item: (item.objects, str(item.image)))


def deduplicate_by_holdout(
    groups: Iterable[tuple[str, list[Sample]]],
) -> tuple[dict[str, list[Sample]], list[dict[str, str]]]:
    """Keep exact duplicates in the strongest holdout group."""
    kept_hashes: set[str] = set()
    output: dict[str, list[Sample]] = {}
    dropped: list[dict[str, str]] = []
    for group_name, samples in groups:
        output[group_name] = []
        for sample in samples:
            if sample.image_hash in kept_hashes:
                dropped.append(
                    {
                        "group": group_name,
                        "source": str(sample.image),
                        "reason": "exact duplicate of stronger holdout or earlier sample",
                    }
                )
                continue
            kept_hashes.add(sample.image_hash)
            output[group_name].append(sample)
    return output, dropped


def write_image(source: Path, destination: Path, max_dimension: int, quality: int) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as opened:
        image = ImageOps.exif_transpose(opened).convert("RGB")
        if max(image.size) > max_dimension:
            image.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
        image.save(destination, "JPEG", quality=quality, optimize=True, progressive=True)


def write_group(
    output: Path,
    group: str,
    samples: list[Sample],
    max_dimension: int,
    quality: int,
    manifest: list[dict[str, object]],
    repeats: int = 1,
    workers: int = 8,
) -> list[dict[str, object]]:
    jobs: list[tuple[Sample, int, Path, Path, dict[str, object]]] = []
    for index, sample in enumerate(samples):
        for repeat in range(repeats):
            name = f"{sample.source}_{index:06d}"
            if repeats > 1:
                name += f"_w{repeat:02d}"
            image_destination = output / "images" / group / f"{name}.jpg"
            label_destination = output / "labels" / group / f"{name}.txt"
            jobs.append(
                (
                    sample,
                    repeat,
                    image_destination,
                    label_destination,
                    {
                    **asdict(sample),
                    "image": str(sample.image),
                    "label": str(sample.label),
                    "output_split": group,
                    "output_image": str(image_destination.relative_to(output)),
                    "repeat_index": repeat,
                    "is_weighted_copy": repeat > 0,
                    },
                )
            )

    def convert(
        job: tuple[Sample, int, Path, Path, dict[str, object]]
    ) -> dict[str, object] | None:
        sample, _, image_destination, label_destination, _ = job
        if image_destination.exists() and label_destination.exists():
            return None
        try:
            write_image(sample.image, image_destination, max_dimension, quality)
            label_destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(sample.label, label_destination)
        except OSError as error:
            image_destination.unlink(missing_ok=True)
            label_destination.unlink(missing_ok=True)
            return {
                "source": sample.source,
                "split": sample.source_split,
                "image": str(sample.image),
                "label": str(sample.label),
                "reason": f"full image decode failed: {error}",
            }
        return None

    with ThreadPoolExecutor(max_workers=workers) as executor:
        conversion_results = list(executor.map(convert, jobs))
    failed_outputs = {
        str(result["image"])
        for result in conversion_results
        if result is not None
    }
    manifest.extend(
        job[4] for job in jobs if str(job[0].image) not in failed_outputs
    )
    return [result for result in conversion_results if result is not None]


def main() -> int:
    args = parse_args()
    if args.overwrite and args.resume:
        raise SystemExit("Choose either --overwrite or --resume, not both")
    if args.output.exists():
        if args.overwrite:
            shutil.rmtree(args.output)
        elif not args.resume:
            raise SystemExit(f"Output exists; use --overwrite or --resume: {args.output}")

    collected: dict[str, list[Sample]] = {}
    errors: list[str] = []
    invalid_annotations: list[dict[str, object]] = []
    for source, root, splits in (
        ("custom", args.custom, ("train", "valid", "test")),
        ("lscd", args.lscd, ("train", "valid")),
        ("oscd", args.oscd, ("train", "valid")),
    ):
        for split in splits:
            key = f"{source}_{split}"
            collected[key], found_errors, found_invalid = collect(root, source, split)
            errors.extend(found_errors)
            invalid_annotations.extend(found_invalid)
    if errors:
        args.output.mkdir(parents=True, exist_ok=True)
        (args.output / "audit_errors.json").write_text(
            json.dumps(errors, indent=2), encoding="utf-8"
        )
        raise SystemExit(f"Audit failed with {len(errors)} errors; see audit_errors.json")

    selected_oscd_train = stratified_select(
        collected["oscd_train"], args.oscd_train_count, args.seed
    )
    selected_lscd_val = stratified_select(
        collected["lscd_valid"], args.lscd_val_count, args.seed + 1
    )
    selected_oscd_val = stratified_select(
        collected["oscd_valid"], args.oscd_val_count, args.seed + 2
    )

    # Holdouts are processed first so their pixels can never enter training.
    groups, dropped = deduplicate_by_holdout(
        (
            ("test", collected["custom_test"]),
            ("domain_val", collected["custom_valid"]),
            ("val", selected_lscd_val + selected_oscd_val),
            (
                "train_public",
                collected["lscd_train"] + selected_oscd_train,
            ),
            ("train_custom", collected["custom_train"]),
        )
    )

    manifest: list[dict[str, object]] = []
    conversion_exclusions: list[dict[str, object]] = []
    conversion_exclusions.extend(write_group(
        args.output,
        "train",
        groups["train_public"],
        args.max_dimension,
        args.jpeg_quality,
        manifest,
        workers=args.conversion_workers,
    ))
    conversion_exclusions.extend(write_group(
        args.output,
        "train",
        groups["train_custom"],
        args.max_dimension,
        args.jpeg_quality,
        manifest,
        repeats=args.custom_weight,
        workers=args.conversion_workers,
    ))
    for group in ("val", "domain_val", "test"):
        conversion_exclusions.extend(write_group(
            args.output,
            group,
            groups[group],
            args.max_dimension,
            args.jpeg_quality,
            manifest,
            workers=args.conversion_workers,
        ))

    (args.output / "data.yaml").write_text(
        "train: images/train\nval: images/val\ntest: images/test\nnames:\n  0: carton\n",
        encoding="utf-8",
    )
    (args.output / "domain_val.yaml").write_text(
        "train: images/train\nval: images/domain_val\ntest: images/test\nnames:\n  0: carton\n",
        encoding="utf-8",
    )
    manifest_path = args.output / "source_manifest.csv"
    with manifest_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(manifest[0]))
        writer.writeheader()
        writer.writerows(manifest)

    unique_counts = {
        key: len(value)
        for key, value in groups.items()
    }
    output_counts = {
        split: len(list((args.output / "images" / split).glob("*.jpg")))
        for split in ("train", "val", "domain_val", "test")
    }
    report = {
        "parameters": {
            key: str(value) if isinstance(value, Path) else value
            for key, value in vars(args).items()
        },
        "source_counts": {key: len(value) for key, value in collected.items()},
        "unique_selected_counts": unique_counts,
        "output_counts": output_counts,
        "dropped_exact_duplicates": dropped,
        "excluded_invalid_annotations": invalid_annotations,
        "excluded_decode_failures": conversion_exclusions,
        "notes": [
            "Custom validation and test images were never admitted to training.",
            "Custom train repetitions are sampling weights, not unique images.",
            "Public validation selects LSCD and OSCD deterministically by density strata.",
        ],
    }
    (args.output / "build_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
