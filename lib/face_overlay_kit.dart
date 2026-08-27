/// Reusable, SDK-agnostic face alignment overlay UI for Flutter.
///
/// Feed [FaceData] from any detector (Binah, ML Kit, MediaPipe, custom)
/// and get a smooth, animated guided overlay in return. This package
/// contains no camera or detection logic - it's a pure UI toolkit.
library;

// Models
export 'src/models/face_data.dart';
export 'src/models/face_bounding_box.dart';
export 'src/models/face_alignment.dart';

// Logic
export 'src/logic/alignment_calculator.dart';
export 'src/logic/alignment_tolerance.dart';

// Config
export 'src/config/face_overlay_config.dart';
export 'src/config/overlay_shape.dart';
export 'src/config/guide_line_style.dart';
export 'src/config/guide_dot_style.dart';
export 'src/config/overlay_messages.dart';

// Painting
export 'src/painting/face_overlay_painter.dart';
export 'src/painting/shape_path_builder.dart';
export 'src/painting/direction_indicator_painter.dart';

// Animation
export 'src/animation/overlay_animation_controller.dart';
export 'src/animation/success_error_animations.dart';

// Widgets
export 'src/widgets/face_overlay.dart';
export 'src/widgets/direction_indicator.dart';
export 'src/widgets/alignment_message_widget.dart';
export 'src/widgets/face_overlay_settings_panel.dart';
