import 'package:flutter/widgets.dart';

/// Wraps a single [AnimationController] and smoothly interpolates
/// (lerps) the overlay's animated values - shape center offset, shape
/// scale, border color, and indicator position - between their previous
/// and newly requested targets.
///
/// [FaceOverlay] drives repaint off this controller directly (it's a
/// [Listenable]) rather than calling `setState` per frame, so 60 FPS
/// updates never touch the widget tree.
class OverlayAnimationController {
  OverlayAnimationController({
    required TickerProvider vsync,
    required Duration duration,
    this.curve = Curves.easeOutCubic,
  }) : controller = AnimationController(vsync: vsync, duration: duration) {
    _centerTween = ConstantTween(_center);
    _scaleTween = ConstantTween(_scale);
    _colorTween = ColorTween(begin: _color, end: _color);
    _indicatorTween = ConstantTween(_indicatorOffset);
    _faceSizeTween = ConstantTween(_faceSize);
  }

  /// The underlying controller. Pass directly as a [CustomPainter]
  /// `repaint` listenable.
  final AnimationController controller;

  /// Curve applied to [controller]'s linear `0..1` value.
  Curve curve;

  Offset _center = const Offset(0.5, 0.5);
  double _scale = 1.0;
  Color _color = const Color(0xFFFFFFFF);
  Offset _indicatorOffset = Offset.zero;
  Offset _faceSize = const Offset(0.42, 0.55);

  late Tween<Offset> _centerTween;
  late Tween<double> _scaleTween;
  late ColorTween _colorTween;
  late Tween<Offset> _indicatorTween;
  late Tween<Offset> _faceSizeTween;

  double get _t => curve.transform(controller.value);

  /// Current animated shape center, normalized `0..1`.
  Offset get center => _centerTween.transform(_t);

  /// Current animated shape scale multiplier.
  double get scale => _scaleTween.transform(_t);

  /// Current animated border/indicator color.
  Color get color => _colorTween.transform(_t) ?? _color;

  /// Current animated direction-indicator offset, normalized `0..1`.
  Offset get indicatorOffset => _indicatorTween.transform(_t);

  /// Current animated shape size - `dx` is normalized width (fraction
  /// of frame width), `dy` is normalized height (fraction of frame
  /// height), tracking the detected face's own size rather than a
  /// fixed shape.
  Offset get faceSize => _faceSizeTween.transform(_t);

  /// Retargets the animation: current animated values become the new
  /// "begin", the given values become the new "end", and the controller
  /// replays from `0` to `1`.
  ///
  /// Any parameter left `null` keeps its current target unchanged.
  void updateTarget({
    Offset? center,
    double? scale,
    Color? color,
    Offset? indicatorOffset,
    Offset? faceSize,
  }) {
    final Offset beginCenter = this.center;
    final double beginScale = this.scale;
    final Color beginColor = this.color;
    final Offset beginIndicator = this.indicatorOffset;
    final Offset beginFaceSize = this.faceSize;

    _center = center ?? _center;
    _scale = scale ?? _scale;
    _color = color ?? _color;
    _indicatorOffset = indicatorOffset ?? _indicatorOffset;
    _faceSize = faceSize ?? _faceSize;

    _centerTween = Tween(begin: beginCenter, end: _center);
    _scaleTween = Tween(begin: beginScale, end: _scale);
    _colorTween = ColorTween(begin: beginColor, end: _color);
    _indicatorTween = Tween(begin: beginIndicator, end: _indicatorOffset);
    _faceSizeTween = Tween(begin: beginFaceSize, end: _faceSize);

    controller
      ..value = 0
      ..forward();
  }

  void dispose() => controller.dispose();
}
