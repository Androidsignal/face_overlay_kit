import 'dart:ui';

import 'package:face_overlay_kit/face_overlay_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tolerance = AlignmentTolerance(
    positionTolerance: 0.08,
    minFaceSize: 0.28,
    maxFaceSize: 0.62,
  );

  FaceAlignment calc(FaceData data) => AlignmentCalculator.calculate(data, tolerance);

  group('AlignmentCalculator', () {
    test('no face detected -> noFace', () {
      expect(calc(FaceData.none), FaceAlignment.noFace);
    });

    test('face smaller than minFaceSize -> tooFar', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.2,
        height: 0.2,
      );
      expect(calc(data), FaceAlignment.tooFar);
    });

    test('face larger than maxFaceSize -> tooClose', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.7,
        height: 0.7,
      );
      expect(calc(data), FaceAlignment.tooClose);
    });

    test('centered face within tolerance -> centered', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.centered);
    });

    test('face shifted left of target -> left', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.3, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.left);
    });

    test('face shifted right of target -> right', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.7, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.right);
    });

    test('face shifted above target -> top', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.3),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.top);
    });

    test('face shifted below target -> bottom', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.7),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.bottom);
    });

    test('dominant axis wins when both axes exceed tolerance', () {
      // dx = 0.25 (dominant), dy = 0.1
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.75, 0.6),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.right);
    });

    test('boundary exactly at positionTolerance stays centered', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5 + 0.08, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.centered);
    });

    test('boundary just past positionTolerance is off-center', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5 + 0.081, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.right);
    });

    test('boundary exactly at minFaceSize stays acceptable', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.28,
        height: 0.28,
      );
      expect(calc(data), FaceAlignment.centered);
    });

    test('boundary exactly at maxFaceSize stays acceptable', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.62,
        height: 0.62,
      );
      expect(calc(data), FaceAlignment.centered);
    });

    test('falls back to boundingBox center when centerPosition is absent', () {
      final data = FaceData(
        faceDetected: true,
        boundingBox: Rect.fromCenter(center: const Offset(0.3, 0.5), width: 0.42, height: 0.42),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(data), FaceAlignment.left);
    });

    test('size check takes priority over position check', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.9, 0.9), // way off-position too
        width: 0.2,
        height: 0.2,
      );
      expect(calc(data), FaceAlignment.tooFar);
    });

    test('rotation fields present do not affect alignment result', () {
      final withRotation = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.42,
        height: 0.42,
        rotationX: 12,
        rotationY: -8,
        rotationZ: 3,
      );
      final withoutRotation = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
        width: 0.42,
        height: 0.42,
      );
      expect(calc(withRotation), calc(withoutRotation));
      expect(calc(withRotation), FaceAlignment.centered);
    });

    test('missing size data skips size check and falls through to position', () {
      final data = FaceData(
        faceDetected: true,
        centerPosition: const Offset(0.5, 0.5),
      );
      expect(calc(data), FaceAlignment.centered);
    });
  });
}
