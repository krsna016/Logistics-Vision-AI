# Carton Inspection Lab

A local benchmark app for the `best.pt` YOLO segmentation model. It uploads one truck/warehouse image, marks every detected carton, numbers detections in visual reading order, displays the total, and lets you download the annotated image.

## Start

Double-click `Open Carton Counter.command`. It starts the server and automatically opens the app in your default browser. The first start installs the required Python packages and can take several minutes.

`http://127.0.0.1:8011`

If macOS blocks the launcher, right-click `Open Carton Counter.command`, choose **Open**, then confirm.

## Recommended first test

- Confidence: `0.27` (selected from the validation experiment)
- Duplicate IoU: `0.70`
- Inference size: `960`

Enter the human-verified carton count before running if you want the app to show exact/error status. Keep a fixed set of images and change only one inference setting at a time.

## Privacy

The app binds only to `127.0.0.1`. The model and uploaded images stay on this computer. Uploaded images are processed in memory and are not saved by the server.

## Important

The app measures the current model; it does not improve the model. Do not claim near-100% enterprise accuracy from the 13-image custom validation set. Use a larger, locked, camera-specific acceptance set before deployment.
