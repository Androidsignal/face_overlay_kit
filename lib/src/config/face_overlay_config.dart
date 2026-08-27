import 'package:flutter/widgets.dart';

import '../logic/alignment_tolerance.dart';
import '../models/face_alignment.dart';
import 'guide_dot_style.dart';
import 'guide_line_style.dart';
import 'overlay_messages.dart';
import 'overlay_shape.dart';

/// Master configuration object for [FaceOverlay]. Every visual and
/// behavioral knob the package exposes lives here.
class FaceOverlayConfig {
  /// Shape of the cut-out overlay - oval, circle, rectangle, or custom.
  final FaceOverlayShape shape;

  /// Height/width ratio forced on the shape when [shape] is
  /// [FaceOverlayShape.oval] - a proper vertical "egg" (e.g. `1.3`)
  /// instead of whatever aspect the detector's raw bounding box
  /// happens to report. `null` uses the detected box's own aspect
  /// instead. Ignored for circle/rectangle/custom shapes.
  final double? shapeAspectRatio;

  /// Border/indicator color while the face is detected but not centered.
  final Color activeColor;

  /// Border/indicator color once [FaceAlignment.centered] is reached.
  final Color successColor;

  /// Border/indicator color for error-ish states ([FaceAlignment.noFace],
  /// [FaceAlignment.tooFar], [FaceAlignment.tooClose]).
  final Color errorColor;

  /// Width of the shape border stroke, in logical pixels.
  final double strokeWidth;

  /// Whether the shape border itself is dashed rather than solid. Uses
  /// [guideLineStyle]'s `dashLength`/`dashGap` for the dash pattern.
  final bool dashedBorder;

  /// Opacity of the scrim outside the cut-out shape, `0..1`.
  final double backgroundOpacity;

  /// Color of the scrim outside the cut-out shape. Defaults to black;
  /// set to e.g. white for a bright/washed-out look.
  final Color scrimColor;

  /// Whether to draw the built-in per-alignment text message. Turn off
  /// if your host UI renders its own instruction text elsewhere and
  /// just wants the shape/guides from this overlay.
  final bool showMessage;

  /// Whether to draw direction guide lines at the shape edges.
  final bool showGuideLines;

  /// Whether to draw a direction indicator (arrow/dot) toward the
  /// correct direction.
  final bool showDirectionIndicator;

  /// Style of the guide lines, when [showGuideLines] is `true`.
  final GuideLineStyle guideLineStyle;

  /// Style of the direction indicator dot, when [showDirectionIndicator]
  /// is `true`.
  final GuideDotStyle guideDotStyle;

  /// Whether to draw dashed crosshair lines through the shape center -
  /// a static fine-alignment reference, independent of the directional
  /// guide lines/indicator.
  final bool showCenterCrosshair;

  /// Color of the scan-progress arc drawn over the shape border when
  /// [FaceOverlay.scanProgress] is non-null.
  final Color progressColor;

  /// Multiplier applied to the detected face's normalized width/height
  /// before sizing the shape, so it frames the face with a little
  /// breathing room instead of tracing the raw bounding box. `1.0` -
  /// exact detected size, `>1.0` - looser fit.
  final double shapeFitPadding;

  /// Duration of the lerp animation between alignment states/positions.
  final Duration animationDuration;

  /// Curve of the lerp animation between alignment states/positions.
  final Curve animationCurve;

  /// Thresholds used to compute [FaceAlignment] from [FaceData].
  final AlignmentTolerance tolerance;

  /// Per-alignment text, overridable.
  final OverlayMessages messages;

  /// Fully custom direction indicator. Receives the current
  /// [FaceAlignment] and returns a widget in place of the built-in
  /// indicator.
  final Widget Function(FaceAlignment alignment)? customIndicatorBuilder;

  /// Fully custom success state widget, shown in place of the built-in
  /// pulse/checkmark when [FaceAlignment.centered] is reached.
  final Widget Function()? successWidgetBuilder;

  /// Fully custom error state widget, shown in place of the built-in
  /// color shift/shake for non-centered states.
  final Widget Function()? errorWidgetBuilder;

  const FaceOverlayConfig({
    this.shape = FaceOverlayShape.oval,
    this.shapeAspectRatio = 1.3,
    this.activeColor = const Color(0xFFFFC107),
    this.successColor = const Color(0xFF4CAF50),
    this.errorColor = const Color(0xFFF44336),
    this.strokeWidth = 4,
    this.dashedBorder = false,
    this.backgroundOpacity = 0.55,
    this.scrimColor = const Color(0xFF000000),
    this.showMessage = true,
    this.showGuideLines = true,
    this.showDirectionIndicator = true,
    this.guideLineStyle = const GuideLineStyle(),
    this.guideDotStyle = const GuideDotStyle(),
    this.showCenterCrosshair = false,
    this.progressColor = const Color(0xFF4CAF50),
    this.shapeFitPadding = 1.25,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.tolerance = const AlignmentTolerance(),
    this.messages = const OverlayMessages(),
    this.customIndicatorBuilder,
    this.successWidgetBuilder,
    this.errorWidgetBuilder,
  });

  /// Resolves the border/indicator color for [alignment].
  Color colorForAlignment(FaceAlignment alignment) {
    switch (alignment) {
      case FaceAlignment.centered:
        return successColor;
      case FaceAlignment.noFace:
      case FaceAlignment.tooFar:
      case FaceAlignment.tooClose:
        return errorColor;
      case FaceAlignment.left:
      case FaceAlignment.right:
      case FaceAlignment.top:
      case FaceAlignment.bottom:
        return activeColor;
    }
  }

  FaceOverlayConfig copyWith({
    FaceOverlayShape? shape,
    double? shapeAspectRatio,
    Color? activeColor,
    Color? successColor,
    Color? errorColor,
    double? strokeWidth,
    bool? dashedBorder,
    double? backgroundOpacity,
    Color? scrimColor,
    bool? showMessage,
    bool? showGuideLines,
    bool? showDirectionIndicator,
    GuideLineStyle? guideLineStyle,
    GuideDotStyle? guideDotStyle,
    bool? showCenterCrosshair,
    Color? progressColor,
    double? shapeFitPadding,
    Duration? animationDuration,
    Curve? animationCurve,
    AlignmentTolerance? tolerance,
    OverlayMessages? messages,
    Widget Function(FaceAlignment alignment)? customIndicatorBuilder,
    Widget Function()? successWidgetBuilder,
    Widget Function()? errorWidgetBuilder,
  }) {
    return FaceOverlayConfig(
      shape: shape ?? this.shape,
      shapeAspectRatio: shapeAspectRatio ?? this.shapeAspectRatio,
      activeColor: activeColor ?? this.activeColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      dashedBorder: dashedBorder ?? this.dashedBorder,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      scrimColor: scrimColor ?? this.scrimColor,
      showMessage: showMessage ?? this.showMessage,
      showGuideLines: showGuideLines ?? this.showGuideLines,
      showDirectionIndicator:
          showDirectionIndicator ?? this.showDirectionIndicator,
      guideLineStyle: guideLineStyle ?? this.guideLineStyle,
      guideDotStyle: guideDotStyle ?? this.guideDotStyle,
      showCenterCrosshair: showCenterCrosshair ?? this.showCenterCrosshair,
      progressColor: progressColor ?? this.progressColor,
      shapeFitPadding: shapeFitPadding ?? this.shapeFitPadding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      tolerance: tolerance ?? this.tolerance,
      messages: messages ?? this.messages,
      customIndicatorBuilder:
          customIndicatorBuilder ?? this.customIndicatorBuilder,
      successWidgetBuilder: successWidgetBuilder ?? this.successWidgetBuilder,
      errorWidgetBuilder: errorWidgetBuilder ?? this.errorWidgetBuilder,
    );
  }
}
