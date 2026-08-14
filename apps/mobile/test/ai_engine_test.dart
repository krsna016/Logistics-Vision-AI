import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/ai_engine/models/detection_result.dart';
import 'package:mobile/core/ai_engine/modules/postprocessor.dart';
import 'package:mobile/core/ai_engine/modules/detection_validator.dart';
import 'package:mobile/core/ai_engine/modules/tracking_engine.dart';

DetectionResult box(
  String id,
  double left,
  double top,
  double right,
  double bottom,
) {
  return DetectionResult(
    id: id,
    label: 'carton',
    confidence: 0.9,
    xMin: left,
    yMin: top,
    xMax: right,
    yMax: bottom,
  );
}

void main() {
  test('tracking preserves IDs when a carton moves between frames', () {
    final tracker = TrackingEngine();
    final first = tracker.update([box('raw-0', 0.10, 0.10, 0.30, 0.30)]);
    final second = tracker.update([box('raw-0', 0.11, 0.10, 0.31, 0.30)]);

    expect(first.single.id, 'tracked_0');
    expect(second.single.id, first.single.id);
  });

  test('tracking expires an unseen carton after missed frames', () {
    final tracker = TrackingEngine(maxMissedFrames: 2);
    tracker.update([box('raw-0', 0.10, 0.10, 0.30, 0.30)]);

    expect(tracker.update(const []).isEmpty, isTrue);
    expect(tracker.update(const []).isEmpty, isTrue);
    expect(tracker.update(const []).isEmpty, isTrue);
    final newTrack = tracker.update([box('raw-0', 0.10, 0.10, 0.30, 0.30)]);
    expect(newTrack.single.id, 'tracked_1');
  });

  test('postprocessor rejects malformed model output safely', () {
    final postprocessor = Postprocessor();
    expect(
      postprocessor.process(
        const <dynamic>[
          <dynamic>[1, 2],
        ],
        imageWidth: 1280,
        imageHeight: 720,
      ),
      isEmpty,
    );
  });

  test('postprocessor decodes YOLO26 end-to-end segmentation rows', () {
    final row = <double>[
      64,
      128,
      320,
      384,
      0.91,
      0,
      ...List<double>.filled(32, 0),
    ];
    final detections = Postprocessor().process(
      <dynamic>[
        <dynamic>[
          <dynamic>[row],
        ],
      ],
      imageWidth: 640,
      imageHeight: 640,
    );

    expect(detections, hasLength(1));
    expect(detections.single.confidence, 0.91);
    expect(detections.single.xMin, closeTo(0.10, 0.001));
    expect(detections.single.yMin, closeTo(0.20, 0.001));
    expect(detections.single.xMax, closeTo(0.50, 0.001));
    expect(detections.single.yMax, closeTo(0.60, 0.001));
  });

  test('validator does not override a configurable low confidence threshold',
      () {
    const detection = DetectionResult(
      id: 'low-but-allowed',
      label: 'carton',
      confidence: .10,
      xMin: .1,
      yMin: .1,
      xMax: .2,
      yMax: .2,
    );

    expect(DetectionValidator().validate([detection]), [detection]);
  });

  test('postprocessor preserves adjacent overlapping cartons below NMS IoU',
      () {
    List<double> row(double left, double right, double confidence) => <double>[
          left,
          100,
          right,
          300,
          confidence,
          0,
          ...List<double>.filled(32, 0),
        ];

    final detections = Postprocessor(iouThreshold: 0.70).process(
      <dynamic>[
        <dynamic>[
          <dynamic>[
            row(100, 300, 0.95),
            row(230, 430, 0.94),
          ],
        ],
      ],
      imageWidth: 640,
      imageHeight: 640,
      decodeMasks: false,
    );

    expect(detections, hasLength(2));
  });

  test('postprocessor removes true duplicate cartons above configured IoU', () {
    List<double> row(double left, double right, double confidence) => <double>[
          left,
          100,
          right,
          300,
          confidence,
          0,
          ...List<double>.filled(32, 0),
        ];

    final detections = Postprocessor(iouThreshold: 0.70).process(
      <dynamic>[
        <dynamic>[
          <dynamic>[
            row(100, 300, 0.95),
            row(110, 310, 0.94),
          ],
        ],
      ],
      imageWidth: 640,
      imageHeight: 640,
      decodeMasks: false,
    );

    expect(detections, hasLength(1));
  });

  test('960 postprocessor maps model coordinates to the captured image', () {
    final row = <double>[
      96,
      192,
      480,
      576,
      0.91,
      0,
      ...List<double>.filled(32, 0),
    ];
    final detection = Postprocessor(inputWidth: 960, inputHeight: 960).process(
      <dynamic>[
        <dynamic>[
          <dynamic>[row],
        ],
      ],
      imageWidth: 960,
      imageHeight: 960,
      decodeMasks: false,
    ).single;

    expect(detection.xMin, closeTo(0.10, 0.001));
    expect(detection.yMin, closeTo(0.20, 0.001));
    expect(detection.xMax, closeTo(0.50, 0.001));
    expect(detection.yMax, closeTo(0.60, 0.001));
  });

  test('landscape Gallery coordinates are not rotated', () {
    final row = <double>[
      96,
      336,
      288,
      528,
      0.91,
      0,
      ...List<double>.filled(32, 0),
    ];
    final detection = Postprocessor(inputWidth: 960, inputHeight: 960).process(
      <dynamic>[
        <dynamic>[
          <dynamic>[row],
        ],
      ],
      imageWidth: 800,
      imageHeight: 400,
      decodeMasks: false,
    ).single;

    expect(detection.xMin, closeTo(0.10, 0.001));
    expect(detection.yMin, closeTo(0.20, 0.001));
    expect(detection.xMax, closeTo(0.30, 0.001));
    expect(detection.yMax, closeTo(0.60, 0.001));
  });

  test('raw landscape sensor coordinates rotate only when requested', () {
    final row = <double>[
      96,
      336,
      288,
      528,
      0.91,
      0,
      ...List<double>.filled(32, 0),
    ];
    final detection = Postprocessor(inputWidth: 960, inputHeight: 960).process(
      <dynamic>[
        <dynamic>[
          <dynamic>[row],
        ],
      ],
      imageWidth: 800,
      imageHeight: 400,
      decodeMasks: false,
      rotateLandscapeSensorToPortrait: true,
    ).single;

    expect(detection.xMin, closeTo(0.40, 0.001));
    expect(detection.yMin, closeTo(0.10, 0.001));
    expect(detection.xMax, closeTo(0.80, 0.001));
    expect(detection.yMax, closeTo(0.30, 0.001));
  });

  test('mask decoder traces concave boundaries instead of row envelopes', () {
    final row = <double>[
      0,
      0,
      960,
      960,
      0.95,
      0,
      10,
      ...List<double>.filled(31, 0),
    ];
    final shape = List<List<double>>.generate(
      8,
      (y) => List<double>.generate(
        8,
        (x) => (x >= 1 && x <= 3 && y >= 1 && y <= 6) ||
                (x >= 3 && x <= 6 && y >= 4 && y <= 6)
            ? 1
            : -1,
      ),
    );
    final prototypes = <List<List<double>>>[
      shape,
      ...List<List<List<double>>>.generate(
        31,
        (_) => List<List<double>>.generate(
          8,
          (_) => List<double>.filled(8, 0),
        ),
      ),
    ];

    final polygon = Postprocessor(inputWidth: 960, inputHeight: 960)
        .process(
          <dynamic>[
            <dynamic>[
              <dynamic>[row],
            ],
            <dynamic>[prototypes],
          ],
          imageWidth: 960,
          imageHeight: 960,
        )
        .single
        .polygon;

    expect(polygon.length, greaterThanOrEqualTo(6));
    expect(polygon.every((point) => point.length == 2), isTrue);
    expect(
      polygon.any(
        (point) => point.any(
          (coordinate) =>
              ((coordinate * 8) - (coordinate * 8).round()).abs() > 0.01,
        ),
      ),
      isTrue,
      reason: 'The contour should cross between prototype pixels.',
    );
    expect(
      polygon.every(
        (point) =>
            point.every((coordinate) => coordinate >= 0 && coordinate <= 1),
      ),
      isTrue,
    );
  });
}
