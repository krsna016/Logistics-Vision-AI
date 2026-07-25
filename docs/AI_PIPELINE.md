# AI Pipeline & Model Lifecycle - Logistics Vision AI

This document establishes the dataset architecture, annotation policies, model training strategies, evaluation benchmarks, and deployment workflows for the Logistics Vision AI computer vision engine.

---

## 1. Dataset Folder Structure

To support scalable model training and future active learning updates:

```directory
ai/
├── datasets/
│   └── carton_inspection_v1/
│       ├── train/
│       │   ├── images/         # High-resolution JPEG/PNG warehouse photos
│       │   └── labels/         # YOLO-format text files containing bounding boxes
│       ├── val/
│       │   ├── images/
│       │   └── labels/
│       └── test/
│           ├── images/
│           └── labels/
├── models/
│   ├── yolov8n.onnx            # Production quantized ONNX model
│   └── defectnet.onnx          # Future defect classifier model
├── training/
│   ├── train.py                # Ultralytics training script
│   └── export_onnx.py          # PyTorch to ONNX conversion and quantization code
└── inference/
    └── test_inference.py       # Local benchmark scripts
```

### Label Format (YOLO-standard txt)
Each label file corresponds to an image, representing carton bounding coordinates normalized between $0.0$ and $1.0$:
$$\langle \text{class\_id} \rangle \quad \langle \text{x\_center} \rangle \quad \langle \text{y\_center} \rangle \quad \langle \text{width} \rangle \quad \langle \text{height} \rangle$$
*   **Class Mapping**: `0`: Carton, `1`: Torn, `2`: Crushed, `3`: Wet, `4`: Open, `5`: Missing Label.

---

## 2. Model Selection Strategy

We evaluate three architectures for mobile real-time performance:

| Architecture | mAP@0.5 | Inference Latency (Mobile NPU) | Binary File Size | ONNX CoreML/NNAPI Compatibility | Recommendation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **YOLOv8-Nano** | $96.2\%$ | $\approx 45\text{ ms}$ | $6.4\text{ MB}$ | High | **Recommended MVP** (Excellent balance of latency, memory footprint, and detection precision). |
| **YOLOv10-Nano**| $96.8\%$ | $\approx 50\text{ ms}$ | $5.8\text{ MB}$ | Medium (Custom layers need NPU wrappers) | Candidate for next release phase. |
| **RT-DETR** | $98.1\%$ | $\approx 220\text{ ms}$ | $58.0\text{ MB}$ | Low (Transformer layers run slow on mobile NPUs) | Not suitable for mobile devices; target for server-side processing only. |

---

## 3. Training & Augmentation Pipeline
*   **Augmentations**: Applied during training to handle warehouse light variability:
    - Random Brightness/Contrast Adjustment ($\pm 25\%$)
    - Scale/Translation transforms ($\pm 15\%$)
    - Mosaic augmentation ($4$-image crop stitching, disabled for final 10 epochs to restore bounding box accuracy).
*   **Training Script (Ultralytics YOLO)**:
    ```python
    from ultralytics import YOLO

    # Load Nano model structure
    model = YOLO("yolov8n.pt")

    # Execute training
    model.train(
        data="ai/datasets/carton_inspection_v1/dataset.yaml",
        epochs=150,
        imgsz=640,
        batch=16,
        device="0", # CUDA GPU
        workers=8,
    )
    ```

---

## 4. Export & ONNX Quantization Workflow
Exporting PyTorch models to INT8 ONNX enables NPUs/GPUs on iOS and Android to execute calculations in $\le 50\text{ ms}$ without draining mobile batteries.

```
+------------------+      Ultralytics      +------------------+
| PyTorch (.pt)    | --------------------> | FP32 ONNX (.onnx)|
+------------------+                       +------------------+
                                                    |
                                                    | ONNXRuntime Quantizer
                                                    v
+------------------+                       +------------------+
| Mobile App Asset | <-------------------- | INT8 ONNX (.onnx)|
+------------------+                       +------------------+
```

### Quantization Script (`export_onnx.py`)
```python
import onnx
from onnxruntime.quantization import quantize_dynamic, QuantType

# Step 1: Export FP32 ONNX model
model = YOLO("yolov8n.pt")
model.export(format="onnx", imgsz=640, opset=12)

# Step 2: Quantize dynamically to INT8
quantize_dynamic(
    model_input="ai/models/yolov8n.onnx",
    model_output="ai/models/yolov8n_quantized.onnx",
    weight_type=QuantType.QUInt8,
)
```

---

## 5. Model Versioning & Deployment
*   **Versioning Layout**: Named as `v<MAJOR>.<MINOR>.<PATCH>_<ARCHITECTURE>` (e.g. `v1.0.0_yolov8n.onnx`).
*   **Asset Bundles**: Quantized files are checked in as assets inside the Flutter application package.
*   **OTA updates**: The application checks the `/api/v1/health` endpoint for newer versions, downloads model updates asynchronously in the background, verifies files using MD5 hashes, and updates local cache references to reload the inference session on subsequent restarts.
