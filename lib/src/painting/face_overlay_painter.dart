import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../animation/overlay_animation_controller.dart';
import '../config/face_overlay_config.dart';
import '../config/overlay_shape.dart';
import 'shape_path_builder.dart';

/// Paints the translucent scrim with a cut-out shape, plus the border
/// stroke, for [FaceOverlay].
///
/// Repaints are driven by [animation] (an [AnimationController]) rather
/// than widget rebuilds - `shouldRepaint` only compares the handful of
/// values that actually affect this paint, so unrelated config changes
/// don't force redundant repaints mid-animation.
class FaceOverlayPainter extends CustomPainter {
  FaceOverlayPainter({
    required this.config,
    required this.animation,
    this.scanProgress,
  }) : super(repaint: animation.controller);

  final FaceOverlayConfig config;
  final OverlayAnimationController animation;

  /// Scan/hold-still progress, `0..1`. When non-null, an arc in
  /// [FaceOverlayConfig.progressColor] is drawn over the border,
  /// starting at 12 o'clock and sweeping clockwise - e.g. "how long
  /// you've held still" for a host app's own scan/capture flow.
  final double? scanProgress;

  /// Computes the current shape bounds in canvas coordinates, shared
  /// with [DirectionIndicatorPainter] so both layers agree on where the
  /// shape sits.
  ///
  /// Sized off [OverlayAnimationController.faceSize] - the actual
  /// detected face's normalized width/height - so the shape fits each
  /// user's face rather than a fixed on-screen size. For
  /// [FaceOverlayShape.oval], height is instead forced to
  /// `width * config.shapeAspectRatio` (when set) for a proper vertical
  /// egg proportion, independent of the detector's raw box aspect.
  static Rect shapeRectForSize(
    Size size,
    OverlayAnimationController animation,
    FaceOverlayConfig config,
  ) {
    final double shortest =
        size.width < size.height ? size.width : size.height;
    final Offset faceSize = animation.faceSize;
    final double width = size.width * faceSize.dx * animation.scale;
    final double? aspectRatio = config.shapeAspectRatio;
    final double height = config.shape == FaceOverlayShape.oval && aspectRatio != null
        ? width * aspectRatio
        : size.height * faceSize.dy * animation.scale;
    final Offset nudge =
        (animation.center - const Offset(0.5, 0.5)) * shortest * 0.08;
    final Offset center =
        Offset(size.width / 2, size.height / 2) + nudge;
    return Rect.fromCenter(center: center, width: width, height: height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Rect shapeRect = shapeRectForSize(size, animation, config);
    final Path shapePath = ShapePathBuilder.build(config.shape, shapeRect);

    final Path scrimPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      shapePath,
    );
    final Paint scrimPaint = Paint()
      ..color = config.scrimColor.withValues(alpha: config.backgroundOpacity);
    canvas.drawPath(scrimPath, scrimPaint);

    final Paint borderPaint = Paint()
      ..color = animation.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth;
    if (config.dashedBorder) {
      _drawDashedPath(
        canvas,
        shapePath,
        borderPaint,
        config.guideLineStyle.dashLength,
        config.guideLineStyle.dashGap,
      );
    } else {
      canvas.drawPath(shapePath, borderPaint);
    }

    if (config.showCenterCrosshair) {
      _drawCrosshair(canvas, shapeRect);
    }

    final double? progress = scanProgress;
    if (progress != null) {
      final Paint progressPaint = Paint()
        ..color = config.progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = config.strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        shapeRect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  void _drawCrosshair(Canvas canvas, Rect shapeRect) {
    final style = config.guideLineStyle;
    final Paint paint = Paint()
      ..color = style.color ?? animation.color
      ..strokeWidth = style.strokeWidth
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      Offset(shapeRect.left, shapeRect.center.dy),
      Offset(shapeRect.right, shapeRect.center.dy),
      paint,
      style.dashLength,
      style.dashGap,
    );
    _drawDashedLine(
      canvas,
      Offset(shapeRect.center.dx, shapeRect.top),
      Offset(shapeRect.center.dx, shapeRect.bottom),
      paint,
      style.dashLength,
      style.dashGap,
    );
  }

  /// Draws [path] as a dashed line by walking each of its contours in
  /// [dashLength]/[dashGap] segments via [Path.computeMetrics] - works
  /// for any path (oval, rect, custom), not just straight lines.
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double dashGap,
  ) {
    final double segment = dashLength + dashGap;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double dashEnd = (distance + dashLength).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, dashEnd), paint);
        distance += segment;
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLength,
    double dashGap,
  ) {
    final double totalLength = (end - start).distance;
    if (totalLength == 0) return;
    final Offset step = (end - start) / totalLength;
    final double segment = dashLength + dashGap;
    double distance = 0;
    while (distance < totalLength) {
      final double dashEnd = (distance + dashLength).clamp(0, totalLength);
      canvas.drawLine(start + step * distance, start + step * dashEnd, paint);
      distance += segment;
    }
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.config.shape != config.shape ||
        oldDelegate.config.shapeAspectRatio != config.shapeAspectRatio ||
        oldDelegate.config.strokeWidth != config.strokeWidth ||
        oldDelegate.config.dashedBorder != config.dashedBorder ||
        oldDelegate.config.guideLineStyle != config.guideLineStyle ||
        oldDelegate.config.backgroundOpacity != config.backgroundOpacity ||
        oldDelegate.config.scrimColor != config.scrimColor ||
        oldDelegate.config.showCenterCrosshair != config.showCenterCrosshair ||
        oldDelegate.config.progressColor != config.progressColor ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.animation != animation;
  }
}
