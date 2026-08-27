import 'package:flutter/material.dart';

import '../config/face_overlay_config.dart';
import '../config/overlay_shape.dart';

/// Default color swatches offered by [FaceOverlaySettingsPanel].
const List<Color> kFaceOverlayColorSwatches = [
  Colors.white,
  Color(0xFFFFC107),
  Color(0xFF4CAF50),
  Color(0xFFF44336),
  Color(0xFF2196F3),
  Color(0xFFE91E63),
];

/// A ready-made settings UI for [FaceOverlayConfig] - drop it into any
/// app built on `face_overlay_kit` to let end users tweak the overlay
/// (border color, shape, dashed/guides/arrow/crosshair/message
/// toggles, stroke width) live, without writing that UI yourself.
///
/// Fully controlled, like a form field: it never holds its own state.
/// You own a `FaceOverlayConfig` (e.g. in a `StatefulWidget`'s field)
/// and pass it in; this widget calls [onConfigChanged] with an updated
/// copy (via [FaceOverlayConfig.copyWith]) whenever the user changes
/// something, and you feed that straight back into `FaceOverlay`.
///
/// ```dart
/// FaceOverlaySettingsPanel(
///   config: _config,
///   onConfigChanged: (next) => setState(() => _config = next),
/// )
/// ```
///
/// The border color swatches set [FaceOverlayConfig.activeColor],
/// `successColor`, and `errorColor` together, for a single "border
/// color" control - set those three individually on the config itself
/// if you want per-alignment-state colors instead.
///
/// [FaceOverlayConfig] has no progress-arc toggle (scan progress is a
/// per-frame value passed to `FaceOverlay.scanProgress`, not a static
/// config field) - pass [showProgressArc]/[onShowProgressArcChanged] to
/// surface that control too; omit both to hide that row.
class FaceOverlaySettingsPanel extends StatelessWidget {
  const FaceOverlaySettingsPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
    this.showProgressArc,
    this.onShowProgressArcChanged,
    this.colorSwatches = kFaceOverlayColorSwatches,
    this.backgroundColor = const Color(0xFF111111),
    this.labelColor = Colors.white70,
  });

  /// Current overlay configuration - this panel reflects and edits it.
  final FaceOverlayConfig config;

  /// Fires with an updated config whenever a control changes.
  final ValueChanged<FaceOverlayConfig> onConfigChanged;

  /// Current "show progress arc" state, if you're wiring
  /// `FaceOverlay.scanProgress`. `null` hides that row.
  final bool? showProgressArc;

  /// Fires when the progress-arc toggle changes. `null` hides that row.
  final ValueChanged<bool>? onShowProgressArcChanged;

  /// Border color options shown as tappable swatches.
  final List<Color> colorSwatches;

  /// Background color of the panel itself.
  final Color backgroundColor;

  /// Color of the section labels ("Color", "Shape", "Toggles", "Stroke").
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelLabel('Color', labelColor),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colorSwatches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final color = colorSwatches[i];
                final selected = color.toARGB32() == config.activeColor.toARGB32();
                return GestureDetector(
                  onTap: () => onConfigChanged(config.copyWith(
                    activeColor: color,
                    successColor: color,
                    errorColor: color,
                  )),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.white24,
                        width: selected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _PanelLabel('Shape', labelColor),
          Wrap(
            spacing: 8,
            children: [
              _ShapeChip(
                label: 'Oval',
                selected: config.shape == FaceOverlayShape.oval,
                onTap: () => onConfigChanged(config.copyWith(shape: FaceOverlayShape.oval)),
              ),
              _ShapeChip(
                label: 'Circle',
                selected: config.shape == FaceOverlayShape.circle,
                onTap: () => onConfigChanged(config.copyWith(shape: FaceOverlayShape.circle)),
              ),
              _ShapeChip(
                label: 'Rectangle',
                selected: config.shape == FaceOverlayShape.rectangle,
                onTap: () =>
                    onConfigChanged(config.copyWith(shape: FaceOverlayShape.rectangle)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PanelLabel('Toggles', labelColor),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _ToggleChip(
                label: 'Dashed',
                value: config.dashedBorder,
                onChanged: (v) => onConfigChanged(config.copyWith(dashedBorder: v)),
              ),
              _ToggleChip(
                label: 'Guide lines',
                value: config.showGuideLines,
                onChanged: (v) => onConfigChanged(config.copyWith(showGuideLines: v)),
              ),
              _ToggleChip(
                label: 'Arrow',
                value: config.showDirectionIndicator,
                onChanged: (v) =>
                    onConfigChanged(config.copyWith(showDirectionIndicator: v)),
              ),
              _ToggleChip(
                label: 'Crosshair',
                value: config.showCenterCrosshair,
                onChanged: (v) => onConfigChanged(config.copyWith(showCenterCrosshair: v)),
              ),
              _ToggleChip(
                label: 'Message',
                value: config.showMessage,
                onChanged: (v) => onConfigChanged(config.copyWith(showMessage: v)),
              ),
              if (showProgressArc != null && onShowProgressArcChanged != null)
                _ToggleChip(
                  label: 'Progress arc',
                  value: showProgressArc!,
                  onChanged: onShowProgressArcChanged!,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _PanelLabel('Stroke', labelColor),
              Expanded(
                child: Slider(
                  value: config.strokeWidth,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: config.strokeWidth.toStringAsFixed(0),
                  onChanged: (v) => onConfigChanged(config.copyWith(strokeWidth: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }
}
