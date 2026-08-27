import 'dart:ui';

import '../models/face_alignment.dart';
import '../models/face_data.dart';
import 'alignment_tolerance.dart';

/// Pure logic that turns [FaceData] into a [FaceAlignment].
///
/// No Flutter widget dependency (only `dart:ui` types), fully
/// unit-testable in isolation. Priority order:
///
/// 1. [FaceAlignment.noFace] if no face is detected.
/// 2. Size checks - [FaceAlignment.tooFar] / [FaceAlignment.tooClose].
/// 3. Position checks - [FaceAlignment.left] / [FaceAlignment.right] /
///    [FaceAlignment.top] / [FaceAlignment.bottom].
/// 4. [FaceAlignment.centered] otherwise.
abstract final class AlignmentCalculator {
  /// Computes alignment for [data] against [tolerance].
  static FaceAlignment calculate(FaceData data, AlignmentTolerance tolerance) {
    if (!data.faceDetected) {
      return FaceAlignment.noFace;
    }

    final double? size = _averageSize(data);
    if (size != null) {
      if (size < tolerance.minFaceSize) return FaceAlignment.tooFar;
      if (size > tolerance.maxFaceSize) return FaceAlignment.tooClose;
    }

    final Offset? center = _resolveCenter(data);
    if (center != null) {
      final double dx = center.dx - tolerance.targetCenterX;
      final double dy = center.dy - tolerance.targetCenterY;

      // Largest offset axis wins so only one direction is reported at a
      // time, avoiding ambiguous combined states like "left" and "top"
      // firing simultaneously.
      if (dx.abs() >= dy.abs() && dx.abs() > tolerance.positionTolerance) {
        return dx < 0 ? FaceAlignment.left : FaceAlignment.right;
      }
      if (dy.abs() > tolerance.positionTolerance) {
        return dy < 0 ? FaceAlignment.top : FaceAlignment.bottom;
      }
    }

    return FaceAlignment.centered;
  }

  static double? _averageSize(FaceData data) {
    final double? w = data.width;
    final double? h = data.height;
    if (w != null && h != null) return (w + h) / 2;
    return w ?? h;
  }

  static Offset? _resolveCenter(FaceData data) {
    if (data.centerPosition != null) return data.centerPosition;
    return data.boundingBox?.center;
  }
}
