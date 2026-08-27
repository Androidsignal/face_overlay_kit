import '../models/face_alignment.dart';

/// Text shown for each [FaceAlignment] state. Every string is
/// overridable so hosts can localize or restyle copy without touching
/// package internals.
class OverlayMessages {
  final String noFace;
  final String tooFar;
  final String tooClose;
  final String left;
  final String right;
  final String top;
  final String bottom;
  final String centered;

  const OverlayMessages({
    this.noFace = 'Place Your Face Inside',
    this.tooFar = 'Move Closer',
    this.tooClose = 'Move Away',
    this.left = 'Move Right',
    this.right = 'Move Left',
    this.top = 'Move Down',
    this.bottom = 'Move Up',
    this.centered = 'Perfect!',
  });

  /// Looks up the message for [alignment].
  String forAlignment(FaceAlignment alignment) {
    switch (alignment) {
      case FaceAlignment.noFace:
        return noFace;
      case FaceAlignment.tooFar:
        return tooFar;
      case FaceAlignment.tooClose:
        return tooClose;
      case FaceAlignment.left:
        return left;
      case FaceAlignment.right:
        return right;
      case FaceAlignment.top:
        return top;
      case FaceAlignment.bottom:
        return bottom;
      case FaceAlignment.centered:
        return centered;
    }
  }

  OverlayMessages copyWith({
    String? noFace,
    String? tooFar,
    String? tooClose,
    String? left,
    String? right,
    String? top,
    String? bottom,
    String? centered,
  }) {
    return OverlayMessages(
      noFace: noFace ?? this.noFace,
      tooFar: tooFar ?? this.tooFar,
      tooClose: tooClose ?? this.tooClose,
      left: left ?? this.left,
      right: right ?? this.right,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      centered: centered ?? this.centered,
    );
  }
}
