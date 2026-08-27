import 'dart:ui';

/// Helpers for working with normalized (`0..1`) bounding boxes.
///
/// [FaceData.boundingBox] is a plain `dart:ui` [Rect] whose coordinates
/// are normalized to the preview size rather than pixels. These
/// extensions keep that convention explicit at call sites and centralize
/// the small amount of math [AlignmentCalculator] needs.
extension NormalizedBoundingBox on Rect {
  /// Center of the box, in normalized `0..1` space.
  Offset get normalizedCenter => center;

  /// Clamp this box into the `0..1` unit square.
  Rect clampToUnit() {
    return Rect.fromLTRB(
      left.clamp(0.0, 1.0),
      top.clamp(0.0, 1.0),
      right.clamp(0.0, 1.0),
      bottom.clamp(0.0, 1.0),
    );
  }

  /// Whether this box is fully within the `0..1` unit square.
  bool get isWithinUnitSquare =>
      left >= 0 && top >= 0 && right <= 1 && bottom <= 1;
}
