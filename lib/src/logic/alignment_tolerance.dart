/// Thresholds [AlignmentCalculator] uses to decide [FaceAlignment].
///
/// All values are normalized (`0..1`), matching [FaceData]'s coordinate
/// space, and are fully overridable via [FaceOverlayConfig.tolerance].
class AlignmentTolerance {
  /// Max allowed distance (in normalized units) between the face center
  /// and the target center before the face counts as off-position.
  final double positionTolerance;

  /// Minimum acceptable normalized face size (width/height average)
  /// before the face is considered too far away.
  final double minFaceSize;

  /// Maximum acceptable normalized face size (width/height average)
  /// before the face is considered too close.
  final double maxFaceSize;

  /// Ideal normalized face size, used only for guidance/UI purposes
  /// (e.g. sizing the overlay shape); not read by the calculator itself.
  final double idealFaceSize;

  /// Target center of the overlay, in normalized `0..1` space.
  /// Defaults to the middle of the frame, `Offset(0.5, 0.5)`.
  final double targetCenterX;
  final double targetCenterY;

  const AlignmentTolerance({
    this.positionTolerance = 0.08,
    this.minFaceSize = 0.28,
    this.maxFaceSize = 0.62,
    this.idealFaceSize = 0.42,
    this.targetCenterX = 0.5,
    this.targetCenterY = 0.5,
  })  : assert(positionTolerance > 0),
        assert(minFaceSize > 0),
        assert(maxFaceSize > minFaceSize);

  AlignmentTolerance copyWith({
    double? positionTolerance,
    double? minFaceSize,
    double? maxFaceSize,
    double? idealFaceSize,
    double? targetCenterX,
    double? targetCenterY,
  }) {
    return AlignmentTolerance(
      positionTolerance: positionTolerance ?? this.positionTolerance,
      minFaceSize: minFaceSize ?? this.minFaceSize,
      maxFaceSize: maxFaceSize ?? this.maxFaceSize,
      idealFaceSize: idealFaceSize ?? this.idealFaceSize,
      targetCenterX: targetCenterX ?? this.targetCenterX,
      targetCenterY: targetCenterY ?? this.targetCenterY,
    );
  }
}
