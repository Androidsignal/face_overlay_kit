import 'package:flutter/widgets.dart';

import '../animation/overlay_animation_controller.dart';
import '../animation/success_error_animations.dart';
import '../config/face_overlay_config.dart';
import '../logic/alignment_calculator.dart';
import '../logic/alignment_tolerance.dart';
import '../models/face_alignment.dart';
import '../models/face_data.dart';
import '../painting/face_overlay_painter.dart';
import 'alignment_message_widget.dart';
import 'direction_indicator.dart';

/// SDK-agnostic face alignment overlay.
///
/// Feed it [FaceData] from whatever detector you use (Binah, ML Kit,
/// MediaPipe, custom) and it renders an animated guided overlay - shape
/// cut-out, direction guides, and message - telling the user how to
/// move to get centered. This widget never touches camera frames; place
/// your own `CameraPreview` below it (as [child], or as a sibling
/// earlier in your own `Stack`).
///
/// ```dart
/// FaceOverlay(
///   faceData: faceData,
///   config: FaceOverlayConfig(shape: FaceOverlayShape.oval),
///   onAlignmentChanged: (alignment) => print(alignment),
///   child: CameraPreview(controller),
/// )
/// ```
class FaceOverlay extends StatefulWidget {
  const FaceOverlay({
    super.key,
    required this.faceData,
    this.config = const FaceOverlayConfig(),
    this.onAlignmentChanged,
    this.scanProgress,
    this.child,
  });

  /// Latest face position data. Update this on every detection frame -
  /// the overlay smoothly lerps between updates itself.
  final FaceData faceData;

  /// Visual and behavioral configuration.
  final FaceOverlayConfig config;

  /// Optional scan/hold-still progress, `0..1`. When set, an arc in
  /// [FaceOverlayConfig.progressColor] is drawn over the border. Purely
  /// visual - `face_overlay_kit` doesn't compute this; drive it from
  /// your own scan/capture timer.
  final double? scanProgress;

  /// Fires once per alignment state transition (not per frame/rebuild).
  final ValueChanged<FaceAlignment>? onAlignmentChanged;

  /// Optional content painted below the overlay layers, e.g. your own
  /// `CameraPreview`. Left `null` if you're composing `FaceOverlay`
  /// yourself inside a `Stack`.
  final Widget? child;

  @override
  State<FaceOverlay> createState() => _FaceOverlayState();
}

class _FaceOverlayState extends State<FaceOverlay>
    with SingleTickerProviderStateMixin {
  late final OverlayAnimationController _animation;
  late FaceAlignment _alignment;

  @override
  void initState() {
    super.initState();
    _animation = OverlayAnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
      curve: widget.config.animationCurve,
    );
    _alignment =
        AlignmentCalculator.calculate(widget.faceData, widget.config.tolerance);
    _applyAlignment(_alignment, widget.faceData, snap: true);
    // Defer to after this build phase - initState runs while an ancestor
    // is still building, and the callback may call setState above us.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onAlignmentChanged?.call(_alignment);
    });
  }

  @override
  void didUpdateWidget(covariant FaceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.config.animationDuration != oldWidget.config.animationDuration) {
      _animation.controller.duration = widget.config.animationDuration;
    }
    _animation.curve = widget.config.animationCurve;

    final FaceAlignment newAlignment = AlignmentCalculator.calculate(
      widget.faceData,
      widget.config.tolerance,
    );
    final bool dataChanged = widget.faceData != oldWidget.faceData;
    final bool alignmentChanged = newAlignment != _alignment;

    if (dataChanged || alignmentChanged) {
      _applyAlignment(newAlignment, widget.faceData);
    }
    if (alignmentChanged) {
      _alignment = newAlignment;
      // Defer - didUpdateWidget runs mid-build too, and the callback may
      // call setState above us.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAlignmentChanged?.call(newAlignment);
      });
    }
  }

  void _applyAlignment(FaceAlignment alignment, FaceData data, {bool snap = false}) {
    _animation.updateTarget(
      center: _centerNudgeFor(data, widget.config.tolerance),
      scale: alignment == FaceAlignment.centered ? 1.05 : 1.0,
      color: widget.config.colorForAlignment(alignment),
      indicatorOffset: _directionFor(alignment),
      faceSize: _sizeFor(data, widget.config),
    );
    if (snap) {
      // First frame: jump straight to target, nothing to animate from.
      _animation.controller.value = 1;
    }
  }

  /// Target shape size, normalized (`dx` - fraction of frame width,
  /// `dy` - fraction of frame height) - tracks the detected face's own
  /// size (with [FaceOverlayConfig.shapeFitPadding] headroom) so the
  /// shape fits each face rather than a fixed size. Falls back to
  /// [AlignmentTolerance.idealFaceSize] while no size is known yet
  /// (e.g. no face detected).
  static Offset _sizeFor(FaceData data, FaceOverlayConfig config) {
    final double ideal = config.tolerance.idealFaceSize;
    final double width = (data.width ?? ideal) * config.shapeFitPadding;
    final double height = (data.height ?? ideal * 1.3) * config.shapeFitPadding;
    return Offset(width.clamp(0.05, 1.0), height.clamp(0.05, 1.0));
  }

  static Offset _directionFor(FaceAlignment alignment) {
    switch (alignment) {
      case FaceAlignment.left:
        return const Offset(-1, 0);
      case FaceAlignment.right:
        return const Offset(1, 0);
      case FaceAlignment.top:
        return const Offset(0, -1);
      case FaceAlignment.bottom:
        return const Offset(0, 1);
      case FaceAlignment.noFace:
      case FaceAlignment.tooFar:
      case FaceAlignment.tooClose:
      case FaceAlignment.centered:
        return Offset.zero;
    }
  }

  static Offset _centerNudgeFor(FaceData data, AlignmentTolerance tolerance) {
    final Offset? faceCenter = data.centerPosition ?? data.boundingBox?.center;
    if (faceCenter == null) return const Offset(0.5, 0.5);
    final double dx = (faceCenter.dx - tolerance.targetCenterX).clamp(-0.5, 0.5);
    final double dy = (faceCenter.dy - tolerance.targetCenterY).clamp(-0.5, 0.5);
    return Offset(0.5 + dx, 0.5 + dy);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Widget? _centerContentFor(FaceAlignment alignment, Color color) {
    if (alignment == FaceAlignment.centered) {
      return widget.config.successWidgetBuilder?.call() ??
          SuccessErrorAnimations.defaultSuccessWidget(color: color);
    }
    if (alignment == FaceAlignment.noFace ||
        alignment == FaceAlignment.tooFar ||
        alignment == FaceAlignment.tooClose) {
      return widget.config.errorWidgetBuilder?.call();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.config.colorForAlignment(_alignment);
    final Widget? centerContent = _centerContentFor(_alignment, color);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.child != null) widget.child!,
        CustomPaint(
          size: Size.infinite,
          painter: FaceOverlayPainter(
            config: widget.config,
            animation: _animation,
            scanProgress: widget.scanProgress,
          ),
        ),
        DirectionIndicator(
          animation: _animation,
          config: widget.config,
          alignment: _alignment,
          color: color,
        ),
        if (centerContent != null)
          Center(
            child: AnimatedSwitcher(
              duration: widget.config.animationDuration,
              child: KeyedSubtree(
                key: ValueKey(_alignment),
                child: centerContent,
              ),
            ),
          ),
        if (widget.config.showMessage)
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: AlignmentMessageWidget(
                alignment: _alignment,
                config: widget.config,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
