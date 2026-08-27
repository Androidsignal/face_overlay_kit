## 0.0.1

- Initial release.
- `FaceData` SDK-agnostic input model, `FaceAlignment` enum, pure
  `AlignmentCalculator` logic.
- `FaceOverlayConfig` with configurable shape, colors, guide line/dot
  style, animation, tolerance, messages, and custom builders.
- `FaceOverlay` widget: animated oval/circle/rectangle/custom overlay,
  direction guides, success/error states, `onAlignmentChanged` callback.
- Example app demonstrating every alignment scenario with simulated
  face data.
- Example app: added a live camera demo (`camera` +
  `google_mlkit_face_detection`) alongside the simulated one, picked from
  a home screen. Fixed `onAlignmentChanged` being invoked mid-build in
  `FaceOverlay.initState`/`didUpdateWidget`, which could crash callers
  that call `setState` from the callback.
- `FaceOverlay.scanProgress` (`0..1`) - optional hold-still/scan-progress
  arc drawn over the border, in `FaceOverlayConfig.progressColor`.
- `FaceOverlayConfig.showCenterCrosshair` - dashed crosshair through the
  shape center, `scrimColor` - scrim tint (was hardcoded black), and
  `showMessage` - toggle for the built-in alignment text, for hosts that
  render their own instruction text outside the overlay.
- Example app: live demo restyled to a vitals-scan look (white oval,
  green progress arc, crosshair, vitals row, bottom instruction panel);
  vitals numbers are mock placeholders, not computed by this package.
- **Breaking (visual):** the shape now sizes itself off the detected
  face's own normalized width/height (`FaceOverlayConfig.
  shapeFitPadding` controls the headroom around it) instead of a fixed
  72%-of-screen size - it fits each face instead of a generic target.
  Falls back to `AlignmentTolerance.idealFaceSize` while no face is
  detected yet.
- Example app: live demo stripped down to just the adaptive oval - no
  guides, message, crosshair, or vitals UI.
- `FaceOverlayConfig.dashedBorder` - draws the shape border itself as a
  dashed line (reuses `guideLineStyle`'s dash pattern), works for any
  shape via `Path.computeMetrics`. Example: live demo now shows a white
  dashed oval border, per screenshot reference.
- `FaceOverlayConfig.shapeAspectRatio` (default `1.3`) - forces a proper
  vertical "egg" oval (height = `width * shapeAspectRatio`) instead of
  whatever aspect the detector's raw bounding box happens to report.
  Only applies to `FaceOverlayShape.oval`; set `null` to fall back to
  the raw detected aspect. `FaceOverlayPainter.shapeRectForSize` and
  `DirectionIndicatorPainter` now take the config to compute this.
- Example app: live demo no longer wraps the camera view in `SafeArea`
  (was leaving a solid black bar above it) - only the settings panel
  underneath is safe-area-padded.
- `FaceOverlaySettingsPanel` - a ready-made, fully-controlled settings
  widget shipped in the package itself (not example-only): border
  color swatches, shape picker, dashed/guide-lines/arrow/crosshair/
  message toggles, and a stroke-width slider, all editing a
  `FaceOverlayConfig` via `copyWith`. Any app using `face_overlay_kit`
  can drop it in directly. Example's live demo now uses this instead of
  its own hand-rolled controls.
