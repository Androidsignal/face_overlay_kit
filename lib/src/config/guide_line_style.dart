import 'dart:ui';

/// Visual style of the direction guide lines drawn at the edges of the
/// overlay.
class GuideLineStyle {
  /// Whether lines are dashed (`true`) or solid (`false`).
  final bool dashed;

  /// Length of each dash segment, in logical pixels. Ignored if
  /// [dashed] is `false`.
  final double dashLength;

  /// Gap between dash segments, in logical pixels. Ignored if
  /// [dashed] is `false`.
  final double dashGap;

  /// Color of the guide lines. Defaults to `null`, meaning "use the
  /// current alignment color" (active/success/error) from
  /// [FaceOverlayConfig].
  final Color? color;

  /// Stroke width of the guide lines, in logical pixels.
  final double strokeWidth;

  /// Length each guide line extends from the shape edge, in logical
  /// pixels.
  final double length;

  const GuideLineStyle({
    this.dashed = true,
    this.dashLength = 6,
    this.dashGap = 4,
    this.color,
    this.strokeWidth = 2,
    this.length = 24,
  });

  GuideLineStyle copyWith({
    bool? dashed,
    double? dashLength,
    double? dashGap,
    Color? color,
    double? strokeWidth,
    double? length,
  }) {
    return GuideLineStyle(
      dashed: dashed ?? this.dashed,
      dashLength: dashLength ?? this.dashLength,
      dashGap: dashGap ?? this.dashGap,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      length: length ?? this.length,
    );
  }
}
