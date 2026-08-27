import 'dart:ui';

import '../config/overlay_shape.dart';

/// Builds the [Path] for a [FaceOverlayShape] within given bounds.
///
/// Thin delegator - each [FaceOverlayShape] variant owns its own path
/// construction (see `overlay_shape.dart`) so it stays exhaustive over
/// private subtypes; this exists as the stable entry point painters call.
abstract final class ShapePathBuilder {
  static Path build(FaceOverlayShape shape, Rect bounds) =>
      shape.buildPath(bounds);
}
