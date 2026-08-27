import 'dart:ui';

/// Visual style of the direction indicator dot/arrow shown when the
/// face isn't centered.
class GuideDotStyle {
  /// Diameter of the dot, in logical pixels.
  final double size;

  /// Color of the dot. Defaults to `null`, meaning "use the current
  /// alignment color" (active/success/error) from [FaceOverlayConfig].
  final Color? color;

  /// Distance the dot sits outside the overlay shape edge, in logical
  /// pixels.
  final double spacing;

  const GuideDotStyle({
    this.size = 10,
    this.color,
    this.spacing = 16,
  });

  GuideDotStyle copyWith({
    double? size,
    Color? color,
    double? spacing,
  }) {
    return GuideDotStyle(
      size: size ?? this.size,
      color: color ?? this.color,
      spacing: spacing ?? this.spacing,
    );
  }
}
