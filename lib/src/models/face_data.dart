import 'dart:ui';

/// SDK-agnostic input model describing a single face detection result.
///
/// Map whatever your detector returns (Binah, Google ML Kit `Face`,
/// MediaPipe landmarks, a custom model, ...) into this shape. This
/// package never inspects camera frames or runs detection itself -
/// it only consumes already-computed face position data.
///
/// All spatial values are normalized to the `0..1` range, relative to
/// the preview/viewport size the detection was computed against.
class FaceData {
  /// Whether a face was detected in the current frame.
  final bool faceDetected;

  /// Normalized bounding box of the face, relative to preview size.
  final Rect? boundingBox;

  /// Normalized center position of the face (`0..1`, `0..1`).
  final Offset? centerPosition;

  /// Normalized face width, relative to preview width.
  final double? width;

  /// Normalized face height, relative to preview height.
  final double? height;

  /// Pitch, in degrees. Optional - omit if the detector doesn't provide it.
  final double? rotationX;

  /// Yaw, in degrees. Optional - omit if the detector doesn't provide it.
  final double? rotationY;

  /// Roll, in degrees. Optional - omit if the detector doesn't provide it.
  final double? rotationZ;

  /// Detection confidence, `0..1`. Defaults to `1.0` when unknown.
  final double confidence;

  const FaceData({
    required this.faceDetected,
    this.boundingBox,
    this.centerPosition,
    this.width,
    this.height,
    this.rotationX,
    this.rotationY,
    this.rotationZ,
    this.confidence = 1.0,
  });

  /// Convenience constant for "no face in frame".
  static const FaceData none = FaceData(faceDetected: false);

  FaceData copyWith({
    bool? faceDetected,
    Rect? boundingBox,
    Offset? centerPosition,
    double? width,
    double? height,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    double? confidence,
  }) {
    return FaceData(
      faceDetected: faceDetected ?? this.faceDetected,
      boundingBox: boundingBox ?? this.boundingBox,
      centerPosition: centerPosition ?? this.centerPosition,
      width: width ?? this.width,
      height: height ?? this.height,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceData &&
        other.faceDetected == faceDetected &&
        other.boundingBox == boundingBox &&
        other.centerPosition == centerPosition &&
        other.width == width &&
        other.height == height &&
        other.rotationX == rotationX &&
        other.rotationY == rotationY &&
        other.rotationZ == rotationZ &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
        faceDetected,
        boundingBox,
        centerPosition,
        width,
        height,
        rotationX,
        rotationY,
        rotationZ,
        confidence,
      );

  @override
  String toString() =>
      'FaceData(faceDetected: $faceDetected, boundingBox: $boundingBox, '
      'centerPosition: $centerPosition, width: $width, height: $height, '
      'rotationX: $rotationX, rotationY: $rotationY, rotationZ: $rotationZ, '
      'confidence: $confidence)';
}
