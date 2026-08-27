import 'package:flutter/widgets.dart';

import '../config/face_overlay_config.dart';
import '../models/face_alignment.dart';

/// Shows the current alignment message (from
/// [FaceOverlayConfig.messages]) in the alignment's color, with a
/// crossfade between message changes.
class AlignmentMessageWidget extends StatelessWidget {
  const AlignmentMessageWidget({
    super.key,
    required this.alignment,
    required this.config,
    required this.color,
    this.style,
  });

  final FaceAlignment alignment;
  final FaceOverlayConfig config;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final String message = config.messages.forAlignment(alignment);
    return AnimatedSwitcher(
      duration: config.animationDuration,
      switchInCurve: config.animationCurve,
      switchOutCurve: config.animationCurve,
      child: Text(
        message,
        key: ValueKey(message),
        textAlign: TextAlign.center,
        style: (style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            .copyWith(color: color),
      ),
    );
  }
}
