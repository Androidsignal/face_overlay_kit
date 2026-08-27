/// Result of comparing [FaceData] against [AlignmentTolerance].
///
/// Produced by `AlignmentCalculator.calculate` and consumed by the
/// widget/painting layer to drive color, message, and guide direction.
enum FaceAlignment {
  /// No face detected in the current frame.
  noFace,

  /// Face is smaller than [AlignmentTolerance.minFaceSize] - user is too far.
  tooFar,

  /// Face is larger than [AlignmentTolerance.maxFaceSize] - user is too close.
  tooClose,

  /// Face center is left of the tolerance box - user should move right.
  left,

  /// Face center is right of the tolerance box - user should move left.
  right,

  /// Face center is above the tolerance box - user should move down.
  top,

  /// Face center is below the tolerance box - user should move up.
  bottom,

  /// Face is within size and position tolerance.
  centered,
}
