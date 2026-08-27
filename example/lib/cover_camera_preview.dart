import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fills the available space with the camera preview, cropping to
/// cover (never letterboxing) and mirroring for the front camera.
class CoverCameraPreview extends StatelessWidget {
  const CoverCameraPreview({super.key, required this.controller, required this.mirror});

  final CameraController controller;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox.shrink();

    // Camera sensors report landscape-native dimensions even when the
    // device is held in portrait, so width/height are swapped here.
    final Widget preview = ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );

    if (!mirror) return preview;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: preview,
    );
  }
}
