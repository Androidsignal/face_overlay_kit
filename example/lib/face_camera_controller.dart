import 'dart:io';
import 'package:camera/camera.dart';
import 'package:face_overlay_kit/face_overlay_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Injectable controller: owns camera + ML Kit detector, maps frames to
/// [FaceData], drives the "hold still" scan progress. Nothing in here
/// touches widgets - it's a plain [ChangeNotifier], reusable on any page.
///
/// Swap the detector for Binah/MediaPipe/whatever and only [_toFaceData]
/// (and the ML Kit import) changes; everything else - camera lifecycle,
/// rotation math, scan progress - is detector-agnostic.
class FaceCameraController extends ChangeNotifier with WidgetsBindingObserver {
  FaceCameraController({
    required TickerProvider vsync,
    Duration scanDuration = const Duration(seconds: 8),
  }) : _scanController = AnimationController(vsync: vsync, duration: scanDuration);

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final AnimationController _scanController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  CameraController? cameraController;
  CameraDescription? camera;
  FaceData faceData = FaceData.none;
  String? error;
  bool _isDetecting = false;
  bool _disposed = false;

  /// Repaint on every scan-progress tick (drive [AnimatedBuilder] with this).
  Listenable get scanListenable => _scanController;
  double get scanProgress => _scanController.value;
  bool get isFrontCamera => camera?.lensDirection == CameraLensDirection.front;

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await _setUpCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    // Camera plugins generally can't keep streaming while backgrounded
    // (and shouldn't, for privacy) - pause on the way out, resume on
    // the way back in rather than leaving a dead/frozen preview.
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (controller.value.isStreamingImages) {
          controller.stopImageStream();
        }
      case AppLifecycleState.resumed:
        if (!controller.value.isStreamingImages) {
          controller.startImageStream(_onCameraImage);
        }
    }
  }

  Future<void> _setUpCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        error = 'No camera found on this device.';
        notifyListeners();
        return;
      }
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }

      await controller.startImageStream(_onCameraImage);
      cameraController = controller;
      camera = selected;
      notifyListeners();
    } catch (e) {
      error = 'Camera error: $e';
      notifyListeners();
    }
  }

  /// Clears a prior error and retries camera setup.
  Future<void> retry() async {
    error = null;
    notifyListeners();
    await _setUpCamera();
  }

  void _onCameraImage(CameraImage image) {
    if (_isDetecting || cameraController == null || camera == null) return;
    _isDetecting = true;
    _detect(image).whenComplete(() => _isDetecting = false);
  }

  Future<void> _detect(CameraImage image) async {
    final inputImage =
        _toInputImage(image, camera!, cameraController!.value.deviceOrientation);
    if (inputImage == null) return;

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (_disposed) return;
      faceData = _toFaceData(faces, inputImage, camera!);
      notifyListeners();
      final alignment = AlignmentCalculator.calculate(faceData, const AlignmentTolerance());
      _driveScanProgress(alignment);
    } catch (_) {
      // Isolated detector hiccup - next frame retries, nothing to surface.
    }
  }

  /// Fills while centered ("hold still"), pauses otherwise - purely a
  /// demo of [FaceOverlay.scanProgress]; swap for your own capture timing.
  void _driveScanProgress(FaceAlignment alignment) {
    if (alignment == FaceAlignment.centered) {
      if (!_scanController.isAnimating && _scanController.value < 1) {
        _scanController.forward();
      }
    } else {
      _scanController.stop();
    }
  }

  /// `camera` gives raw sensor frames; ML Kit needs an [InputImage] with
  /// rotation metadata describing how to read them upright. This glue is
  /// the standard `camera` + `google_mlkit_*` pairing, reused verbatim
  /// across detector choices.
  InputImage? _toInputImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final int sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      int? rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static double _area(Face face) => face.boundingBox.width * face.boundingBox.height;

  /// Maps ML Kit's [Face] list into [FaceData] - the one place SDK
  /// output turns into `face_overlay_kit`'s SDK-agnostic input model.
  FaceData _toFaceData(List<Face> faces, InputImage inputImage, CameraDescription camera) {
    if (faces.isEmpty) return FaceData.none;

    // Largest face by area, in case more than one is in frame.
    final face = faces.reduce((a, b) => _area(a) >= _area(b) ? a : b);

    // ML Kit returns boundingBox relative to the *upright* (rotated)
    // image, so swap width/height when the rotation is sideways.
    final rotation = inputImage.metadata!.rotation;
    final rawSize = inputImage.metadata!.size;
    final sideways = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    final double imageWidth = sideways ? rawSize.height : rawSize.width;
    final double imageHeight = sideways ? rawSize.width : rawSize.height;

    double left = face.boundingBox.left / imageWidth;
    double right = face.boundingBox.right / imageWidth;
    final double top = (face.boundingBox.top / imageHeight).clamp(0.0, 1.0);
    final double bottom = (face.boundingBox.bottom / imageHeight).clamp(0.0, 1.0);

    // The preview is mirrored for the front camera (selfie UX) - mirror
    // the detection box the same way so the oval matches what's on screen.
    if (camera.lensDirection == CameraLensDirection.front) {
      final mirroredLeft = (1 - right).clamp(0.0, 1.0);
      final mirroredRight = (1 - left).clamp(0.0, 1.0);
      left = mirroredLeft;
      right = mirroredRight;
    } else {
      left = left.clamp(0.0, 1.0);
      right = right.clamp(0.0, 1.0);
    }

    return FaceData(
      faceDetected: true,
      boundingBox: Rect.fromLTRB(left, top, right, bottom),
      centerPosition: Offset((left + right) / 2, (top + bottom) / 2),
      width: right - left,
      height: bottom - top,
      rotationX: face.headEulerAngleX,
      rotationY: face.headEulerAngleY,
      rotationZ: face.headEulerAngleZ,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
