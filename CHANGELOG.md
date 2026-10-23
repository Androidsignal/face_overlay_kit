## 0.0.2

- Updated documentation in `README.md`.
- Added usage screenshots to `README.md`.

## 0.0.1

- Initial release.
- `FaceData` model, `FaceAlignment` enum, `AlignmentCalculator` logic.
- `FaceOverlayConfig` — shape, colors, guide styles, animation, tolerance, messages.
- `FaceOverlay` widget — animated overlay, direction guides, success/error states, `onAlignmentChanged`.
- `FaceOverlay.scanProgress`, `showCenterCrosshair`, `scrimColor`, `showMessage`, `dashedBorder`, `shapeAspectRatio`.
- `FaceOverlaySettingsPanel` — ready-made settings widget.
- Example app: simulated demo + live camera demo.
- Shape now sizes off the detected face itself, not a fixed screen %.
- Fixed `onAlignmentChanged` firing mid-build.
