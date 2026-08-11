from pathlib import Path

from build_stage1_seg_dataset import Sample, stratified_select, validate_polygon_label


def test_validate_polygon_label_accepts_segmentation(tmp_path: Path) -> None:
    label = tmp_path / "sample.txt"
    label.write_text("0 0.1 0.1 0.9 0.1 0.9 0.9 0.1 0.9\n", encoding="utf-8")
    objects, errors = validate_polygon_label(label)
    assert objects == 1
    assert errors == []


def test_validate_polygon_label_rejects_box_row(tmp_path: Path) -> None:
    label = tmp_path / "sample.txt"
    label.write_text("0 0.5 0.5 0.2 0.2\n", encoding="utf-8")
    _, errors = validate_polygon_label(label)
    assert errors


def test_stratified_select_is_deterministic() -> None:
    samples = [
        Sample("oscd", "train", Path(f"{index}.jpg"), Path(f"{index}.txt"), index, str(index))
        for index in range(1, 41)
    ]
    first = stratified_select(samples, 20, 42)
    second = stratified_select(samples, 20, 42)
    assert first == second
    assert len(first) == 20
