import 'package:flutter/widgets.dart';

import '../animation/overlay_animation_controller.dart';
import '../config/face_overlay_config.dart';
import '../config/guide_dot_style.dart';
import '../config/guide_line_style.dart';
import 'face_overlay_painter.dart';

/// Paints the direction guide lines and indicator dot pointing toward
/// the current misalignment direction, from the edge of the overlay
/// shape.
///
/// Separate paint layer from [FaceOverlayPainter] so the indicator can
/// be composed independently (e.g. behind a `showDirectionIndicator`
/// toggle) while still sharing the same shape geometry via
/// [FaceOverlayPainter.shapeRectForSize].
class DirectionIndicatorPainter extends CustomPainter {
  DirectionIndicatorPainter({
    required this.animation,
    required this.config,
    required this.color,
    required this.showGuideLines,
    required this.showDot,
    required this.lineStyle,
    required this.dotStyle,
  }) : super(repaint: animation.controller);

  final OverlayAnimationController animation;
  final FaceOverlayConfig config;
  final Color color;
  final bool showGuideLines;
  final bool showDot;
  final GuideLineStyle lineStyle;
  final GuideDotStyle dotStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset direction = animation.indicatorOffset;
    final double magnitude = direction.distance;
    if (magnitude < 0.01) return;

    final Rect shapeRect =
        FaceOverlayPainter.shapeRectForSize(size, animation, config);
    final Offset dir = direction / magnitude;
    final Offset edgePoint = shapeRect.center +
        Offset(dir.dx * shapeRect.width / 2, dir.dy * shapeRect.height / 2);

    if (showGuideLines) {
      final Offset lineEnd = edgePoint + dir * lineStyle.length;
      final Paint linePaint = Paint()
        ..color = lineStyle.color ?? color
        ..strokeWidth = lineStyle.strokeWidth
        ..style = PaintingStyle.stroke;
      if (lineStyle.dashed) {
        _drawDashedLine(canvas, edgePoint, lineEnd, linePaint);
      } else {
        canvas.drawLine(edgePoint, lineEnd, linePaint);
      }
    }

    if (showDot) {
      final Offset dotCenter = edgePoint + dir * dotStyle.spacing;
      final Paint dotPaint = Paint()..color = dotStyle.color ?? color;
      canvas.drawCircle(dotCenter, dotStyle.size / 2, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double totalLength = (end - start).distance;
    if (totalLength == 0) return;
    final Offset step = (end - start) / totalLength;
    final double segment = lineStyle.dashLength + lineStyle.dashGap;
    double distance = 0;
    while (distance < totalLength) {
      final double dashEnd =
          (distance + lineStyle.dashLength).clamp(0, totalLength);
      canvas.drawLine(
        start + step * distance,
        start + step * dashEnd,
        paint,
      );
      distance += segment;
    }
  }

  @override
  bool shouldRepaint(covariant DirectionIndicatorPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.config != config ||
        oldDelegate.color != color ||
        oldDelegate.showGuideLines != showGuideLines ||
        oldDelegate.showDot != showDot ||
        oldDelegate.lineStyle != lineStyle ||
        oldDelegate.dotStyle != dotStyle;
  }
}
