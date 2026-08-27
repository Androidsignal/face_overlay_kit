import 'dart:ui';

/// Shape used to cut out the overlay scrim and draw the border stroke.
///
/// Path construction lives on each variant so it stays exhaustive and
/// private-subtype-safe within this file; [ShapePathBuilder] just calls
/// through to it.
sealed class FaceOverlayShape {
  const FaceOverlayShape();

  /// Oval inscribed within the overlay bounds. The common face-alignment
  /// shape.
  static const FaceOverlayShape oval = _OvalShape();

  /// Circle inscribed within the overlay bounds (uses the smaller of
  /// width/height as the diameter).
  static const FaceOverlayShape circle = _CircleShape();

  /// Rectangle matching the overlay bounds.
  static const FaceOverlayShape rectangle = _RectangleShape();

  /// Fully custom shape - build any [Path] you want from the given bounds.
  const factory FaceOverlayShape.custom(
    Path Function(Rect bounds) pathBuilder,
  ) = _CustomShape;

  /// Builds the [Path] for this shape within [bounds].
  Path buildPath(Rect bounds);
}

final class _OvalShape extends FaceOverlayShape {
  const _OvalShape();

  @override
  Path buildPath(Rect bounds) => Path()..addOval(bounds);
}

final class _CircleShape extends FaceOverlayShape {
  const _CircleShape();

  @override
  Path buildPath(Rect bounds) {
    final double diameter = bounds.shortestSide;
    final Rect square = Rect.fromCenter(
      center: bounds.center,
      width: diameter,
      height: diameter,
    );
    return Path()..addOval(square);
  }
}

final class _RectangleShape extends FaceOverlayShape {
  const _RectangleShape();

  @override
  Path buildPath(Rect bounds) => Path()..addRect(bounds);
}

final class _CustomShape extends FaceOverlayShape {
  final Path Function(Rect bounds) pathBuilder;
  const _CustomShape(this.pathBuilder);

  @override
  Path buildPath(Rect bounds) => pathBuilder(bounds);
}
