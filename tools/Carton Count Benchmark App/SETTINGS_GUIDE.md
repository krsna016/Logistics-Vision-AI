# Carton Inspection Lab — Settings Guide

## Recommended starting values

- Confidence: **0.27**
- NMS IoU: **0.70**
- Resolution: **960**

Use the same verified images when comparing settings. Change only one value at a time.

## Model settings

### Model library

Choose the checkpoint used for prediction. Drag a trusted Ultralytics/PyTorch `.pt` checkpoint into **Add model**, or click it to browse. The app validates the model and keeps it in the local model library after restart.

PyTorch checkpoints can contain executable data. Only upload files you trained yourself or received from a trusted source.

### Verified carton count

The correct count entered by a person. It does not affect prediction. It only shows whether the model is exact, undercounting, or overcounting.

### Confidence threshold

The minimum certainty required to keep a detected carton.

- Lower confidence: finds more cartons but can add false detections.
- Higher confidence: removes weak detections but can miss real cartons.
- If the model undercounts, try lowering it slightly.
- If the model overcounts, try increasing it slightly.

### NMS IoU

Controls when overlapping predictions are treated as duplicates. Keep it at **0.70** initially. Adjust it only after visually confirming that the same carton has multiple boxes.

### Inference resolution

- **640:** Fastest, but small cartons may be harder to detect.
- **960:** Recommended balance of accuracy and speed.
- **1280:** More detail for small or distant cartons, but slower.

## Overlay controls

These controls change only the displayed result. They do not change the model prediction.

- **Polygon masks:** Show the exact segmented carton shapes.
- **Bounding boxes:** Show rectangles around detections.
- **Carton numbers:** Number cartons from top to bottom and left to right.
- **Confidence labels:** Show certainty for each carton.
- **Mask opacity:** Control how strongly mask colors cover the photograph.

## Safe tuning order

1. Start with `0.27 / 0.70 / 960`.
2. Enter the verified human count.
3. Inspect missing and extra cartons visually.
4. Adjust confidence slightly.
5. Try resolution 1280 only when cartons are small.
6. Keep final settings fixed and test them on a larger locked image set.

## Compare verification marks

After running the model:

1. Open **Compare**.
2. Verification turns on automatically.
3. Click the center of a carton on either photograph.
4. The same numbered green tick appears on both original and annotated images.
5. Click the same tick again to remove it, or use **Undo** and **Clear**.
6. Use **Export review** to save the prediction settings and verification coordinates.

These ticks are manual review aids. They do not change the model prediction or carton count.
