import 'package:flutter/widgets.dart';

import '../animation/overlay_animation_controller.dart';
import '../config/face_overlay_config.dart';
import '../models/face_alignment.dart';
import '../painting/direction_indicator_painter.dart';

/// Direction guide layer for [FaceOverlay].
///
/// Renders [FaceOverlayConfig.customIndicatorBuilder] when provided,
/// otherwise the built-in [DirectionIndicatorPainter] (guide lines/dot
/// pointing toward the correct direction).
class DirectionIndicator extends StatelessWidget {
  const DirectionIndicator({
    super.key,
    required this.animation,
    required this.config,
    required this.alignment,
    required this.color,
  });

  final OverlayAnimationController animation;
  final FaceOverlayConfig config;
  final FaceAlignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final builder = config.customIndicatorBuilder;
    if (builder != null) {
      return builder(alignment);
    }

    if (!config.showGuideLines && !config.showDirectionIndicator) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: DirectionIndicatorPainter(
        animation: animation,
        config: config,
        color: color,
        showGuideLines: config.showGuideLines,
        showDot: config.showDirectionIndicator,
        lineStyle: config.guideLineStyle,
        dotStyle: config.guideDotStyle,
      ),
    );
  }
}
