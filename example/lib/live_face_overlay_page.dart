import 'dart:io';

import 'package:face_overlay_kit/face_overlay_kit.dart';
import 'package:flutter/material.dart';

import 'cover_camera_preview.dart';
import 'face_camera_controller.dart';

/// Real camera + real detector demo: adaptive face oval, dashed white
/// border, center crosshair, and a green "hold still" progress arc.
///
/// This is the only file in the example that talks to a camera or a
/// detector - `face_overlay_kit` itself never does. All the camera/ML
/// Kit glue lives in the injected [FaceCameraController]; this page is
/// pure UI wiring that controller's state into [FaceOverlay].
class LiveFaceOverlayPage extends StatefulWidget {
  const LiveFaceOverlayPage({super.key});

  @override
  State<LiveFaceOverlayPage> createState() => _LiveFaceOverlayPageState();
}

class _LiveFaceOverlayPageState extends State<LiveFaceOverlayPage>
    with SingleTickerProviderStateMixin {
  // Not const: `successWidgetBuilder`/`errorWidgetBuilder` are closures
  // returning the `SizedBox.shrink()` class directly, not routed
  // through a named method.
  static final FaceOverlayConfig _config = FaceOverlayConfig(
    activeColor: Colors.white,
    successColor: Colors.white,
    errorColor: Colors.white,
    progressColor: const Color(0xFF4CAF50),
    dashedBorder: true,
    showCenterCrosshair: true,
    successWidgetBuilder: () => const SizedBox.shrink(),
    errorWidgetBuilder: () => const SizedBox.shrink(),
  );

  late final FaceCameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FaceCameraController(vsync: this)..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No SafeArea here - the camera preview goes full-bleed behind the
    // status bar/notch.
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _controller.scanListenable]),
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final error = _controller.error;
    final cameraController = _controller.cameraController;

    if (error != null) return _ErrorView(message: error, onRetry: _controller.retry);
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // camera_android_camerax already mirrors the front-camera preview
    // for display by default; camera_avfoundation (iOS) does not.
    // Manually mirroring on Android would double-flip it back to
    // unmirrored.
    final manualMirror = _controller.isFrontCamera && Platform.isIOS;

    return Stack(
      fit: StackFit.expand,
      children: [
        CoverCameraPreview(controller: cameraController, mirror: manualMirror),
        // Oval sized off the detected face itself (FaceOverlayConfig.
        // shapeFitPadding controls the breathing room around it):
        // white dashed border, dashed crosshair, green hold-still arc,
        // direction guides/arrow, and the alignment message.
        FaceOverlay(
          faceData: _controller.faceData,
          scanProgress: _controller.scanProgress,
          config: _config,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
