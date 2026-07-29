# Carton model audit

This directory is for validating the trained YOLO checkpoint before it is
connected to the Flutter camera. It is intentionally separate from the mobile
assets and does not change the app model.

Copy the checkpoint and validation dataset here (or pass absolute paths):

```text
ai/model_audit/carton_yolo11n/best.pt
ai/model_audit/carton_yolo11n/data.yaml
ai/model_audit/carton_yolo11n/validation/images/
ai/model_audit/carton_yolo11n/validation/labels/
```

Run:

```bash
python3 ai/model_audit/validate_model.py \
  --model ai/model_audit/carton_yolo11n/best.pt \
  --data ai/model_audit/carton_yolo11n/data.yaml \
  --split test
```

The report includes standard YOLO validation metrics plus carton-count
metrics: exact-count accuracy, mean absolute count error, undercount rate, and
overcount rate. A model should not be integrated into the camera based only on
mAP; the count metrics must also be checked on representative warehouse
images.
