import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Built-in default widgets/effects for the success and error states,
/// used when [FaceOverlayConfig.successWidgetBuilder] /
/// `errorWidgetBuilder` aren't overridden.
abstract final class SuccessErrorAnimations {
  /// Subtle pulse + checkmark fade-in shown when
  /// [FaceAlignment.centered] is reached.
  static Widget defaultSuccessWidget({
    required Color color,
    double size = 56,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('success_$color'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * value.clamp(0.0, 1.0),
            child: Icon(Icons.check_circle, color: color, size: size),
          ),
        );
      },
    );
  }

  /// Gentle horizontal shake offset for misaligned states, `t` in
  /// `0..1` (typically driven by [OverlayAnimationController]).
  static Offset shakeOffset(double t, {double magnitude = 6}) {
    final double decay = 1 - t;
    return Offset(math.sin(t * math.pi * 6) * magnitude * decay, 0);
  }
}
