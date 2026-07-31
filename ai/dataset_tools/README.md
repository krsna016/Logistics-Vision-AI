# Dataset tools

These scripts are for the Model A carton-detection pipeline.

## Audit before merging

```bash
python3 ai/dataset_tools/audit_yolo_datasets.py \
  "/path/to/Logistics Vision Model Datasets" \
  --output ai/dataset_tools/dataset_audit.json
```

The audit must be clean before merging. Review `dataset_audit.json`, especially
missing labels, class-name differences, duplicate images, and split leakage.

The script expects each dataset folder (`d1` through `d5`) to contain a
`data.yaml` and `train`, `valid`/`val`, and `test` folders. It accepts either
`split/images` + `split/labels` or the equivalent nested layout.

## Merge after audit

The merge command keeps exact duplicate images in the strongest available
holdout split (`test`, then `val`, then `train`) so an image cannot leak across
training and evaluation:

```bash
python3 ai/dataset_tools/merge_yolo_datasets.py \
  datasets \
  ai/datasets/carton_detection_v1 \
  --dry-run
```

Review the counts and duplicate list, then run the same command without
`--dry-run`. Use `--overwrite` only when intentionally regenerating the output.

## Colab Pro training

Upload `ai/datasets/carton_detection_v1` to Google Drive, enable a GPU
runtime, and run:

```bash
!pip install -q ultralytics
!python /content/Logistics\ Vision\ AI/ai/dataset_tools/train_model_a.py \
  --data /content/drive/MyDrive/carton_detection_v1/data.yaml \
  --model yolo11n.pt \
  --epochs 150 \
  --imgsz 640 \
  --batch -1 \
  --export-onnx
```

Evaluate `best.pt` on the test split before copying any model into the mobile
app. Keep the test images untouched during training.
