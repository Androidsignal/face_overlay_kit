[![dashstack_poster](https://github.com/user-attachments/assets/01150ab3-4631-48a2-8c56-5c64d0fd887b)](https://www.dashstack.tech/)

# face_overlay_kit

SDK-agnostic **face alignment overlay UI** for Flutter — feed it face
position data from *any* detector and get a smooth, animated guided
overlay back: an oval (or
any shape) with direction guides that tell the user to move left / right /
up / down / closer / farther, plus a "centered" success state.

This package contains **no face detection logic** and never touches
camera frames — it's a pure visualization/UI toolkit that consumes
position data your app already computes.

## Install

```yaml
dependencies:
  face_overlay_kit: <latest_version>
```

```
flutter pub get
```

## Quick start

`face_overlay_kit` doesn't know or care which detector produced your face
data — you write a small mapper function once, and everything downstream
(alignment logic, animation, painting) is shared.

```dart
import 'package:face_overlay_kit/face_overlay_kit.dart';

FaceOverlay(
  faceData: faceData, // your mapped FaceData
  config: FaceOverlayConfig(
    shape: FaceOverlayShape.oval,
    showGuideLines: true,
    showDirectionIndicator: true,
  ),
  onAlignmentChanged: (alignment) => print(alignment),
  child: CameraPreview(controller), // your own camera widget
)
```

`FaceOverlay` stacks on top of your camera preview — pass it as `child`,
or place `FaceOverlay` in your own `Stack` above `CameraPreview`. The
package never creates a camera preview of its own.

> **First time using this?** `FaceOverlay` alone won't detect anything —
> you still need a camera plugin and a face detector in *your* app. Read
> "Mapping from your detector" below.

## Mapping from your detector

**Example mapper**

```dart
FaceData mapDetectorFace(Face face, Size imageSize) {
  final box = face.boundingBox;
  return FaceData(
    faceDetected: true,
    boundingBox: Rect.fromLTRB(
      box.left / imageSize.width,
      box.top / imageSize.height,
      box.right / imageSize.width,
      box.bottom / imageSize.height,
    ),
    width: box.width / imageSize.width,
    height: box.height / imageSize.height,
    rotationX: face.headEulerAngleX,
    rotationY: face.headEulerAngleY,
    rotationZ: face.headEulerAngleZ,
  );
}
```

**Any other detector** — same idea: normalize whatever bounding
box or landmark set you get into `0..1` and construct a `FaceData`. See
[`example/lib/face_camera_controller.dart`](example/lib/face_camera_controller.dart)
for a full, real-camera version of this mapper, and
[`example/lib/main.dart`](example/lib/main.dart) for simulated data
covering every scenario.

## `FaceOverlay` widget

| Param | Type | Purpose |
| --- | --- | --- |
| `faceData` | `FaceData` | Latest detection result — update every frame, the overlay lerps between updates itself |
| `config` | `FaceOverlayConfig` | Visual and behavioral configuration (see below) |
| `scanProgress` | `double?` | `0..1` hold-still/scan progress arc, drawn in `config.progressColor` — you own the timing, this only draws it |
| `onAlignmentChanged` | `ValueChanged<FaceAlignment>?` | Fires once per state *transition*, not per frame |
| `child` | `Widget?` | Content painted below the overlay, e.g. your `CameraPreview` |

`FaceAlignment` (from `AlignmentCalculator.calculate`): `noFace`, `tooFar`,
`tooClose`, `left`, `right`, `top`, `bottom`, `centered`.

## `FaceOverlayConfig` reference

| Field | Type | Purpose |
| --- | --- | --- |
| `shape` | `FaceOverlayShape` | `oval`, `circle`, `rectangle`, or `.custom(pathBuilder)` |
| `activeColor` / `successColor` / `errorColor` | `Color` | Border/indicator color per state |
| `strokeWidth` | `double` | Shape border width |
| `dashedBorder` | `bool` | Draw the shape border itself as a dashed line |
| `showCenterCrosshair` | `bool` | Dashed crosshair through the shape center |
| `backgroundOpacity` / `scrimColor` | `double` / `Color` | Scrim tint and opacity outside the cut-out shape |
| `showGuideLines` / `showDirectionIndicator` | `bool` | Toggle guide lines / direction indicator dot |
| `showMessage` | `bool` | Toggle the built-in alignment text (off if you render your own) |
| `guideLineStyle` | `GuideLineStyle` | Dash length/gap, color, stroke width, length |
| `guideDotStyle` | `GuideDotStyle` | Dot size, color, spacing from shape edge |
| `shapeFitPadding` | `double` | Headroom around the detected face when sizing the shape |
| `shapeAspectRatio` | `double?` | Forces a vertical "egg" oval (`height = width * ratio`); `null` uses the raw detected aspect |
| `animationDuration` / `animationCurve` | `Duration` / `Curve` | Drives all lerps |
| `tolerance` | `AlignmentTolerance` | Position tolerance, min/max/ideal face size |
| `messages` | `OverlayMessages` | Per-`FaceAlignment` text, fully overridable |
| `customIndicatorBuilder` | `Widget Function(FaceAlignment)?` | Replace the built-in direction indicator |
| `successWidgetBuilder` / `errorWidgetBuilder` | `Widget Function()?` | Replace the built-in success/error content |

### `FaceOverlaySettingsPanel`

Don't want to build a settings UI yourself? `face_overlay_kit` ships one:
a fully-controlled panel (border color swatches, shape picker, toggle
switches, stroke-width slider) that edits a `FaceOverlayConfig` via
`copyWith` and hands the result back.

```dart
FaceOverlaySettingsPanel(
  config: _config,
  onConfigChanged: (next) => setState(() => _config = next),
)
```

## Architecture

```
FaceData (input model)
      │
      ▼
AlignmentCalculator.calculate()  ──►  FaceAlignment
      │
      ▼
OverlayAnimationController  (lerps center/scale/color/indicator offset)
      │
      ▼
FaceOverlayPainter + DirectionIndicatorPainter  ──►  FaceOverlay widget
```

- `AlignmentCalculator` is a pure function — zero Flutter widget
  dependency, fully unit-testable on its own.
- `FaceOverlay` drives repaints off a single `AnimationController`
  (`OverlayAnimationController`), not `setState` — the `CustomPainter`s
  repaint at 60 FPS without touching the rest of your widget tree.

## Adding support for a new detection SDK

Nothing to change in this package — write a mapper function from your
SDK's output to `FaceData` (see above) and everything else just works.

## Testing

```
flutter test
```

Covers `AlignmentCalculator` (table-driven, every branch + boundary cases)
and `FaceOverlay` (color/message per alignment, `onAlignmentChanged`
transition semantics, disposal).

## Example

Run the demo app (`cd example && flutter run`) and pick a mode:

- **Live Camera Demo** — real front camera feed via `camera`, real
  detection via `google_mlkit_face_detection`. All the camera/detector
  glue lives in [`FaceCameraController`](example/lib/face_camera_controller.dart)
  — an injectable `ChangeNotifier`, not tangled into the page — so
  [`live_face_overlay_page.dart`](example/lib/live_face_overlay_page.dart)
  itself is just UI wiring. Swap detectors and only the controller's
  mapper method changes.
- **Simulated Demo** (`example/lib/simulated_demo_page.dart`) — a scenario
  picker driving canned `FaceData`: no face, too far, too close, moved
  left/right/up/down, and centered → success animation, with a fake
  camera preview behind the overlay to prove there's no double camera.

The live demo needs a camera permission grant on first run (Android/iOS
prompt) and a physical device (simulators/emulators without a camera will
show a camera error).

## Troubleshooting

**Overlay never turns "centered"** — check `AlignmentTolerance` against
your detector's actual output range; most detectors' `boundingBox` is in
raw pixels, `FaceData` expects `0..1` normalized values (see the mapper
above). A un-normalized box will read as permanently "too close".

**`onAlignmentChanged` fires too often / not at all** — it fires once per
*transition*, not per frame. If `faceData` never actually changes
alignment bucket (e.g. jitter within tolerance), it won't re-fire.

**Front camera feed looks mirrored/unmirrored inconsistently** — Android's
camera plugin already mirrors the front preview for display; iOS doesn't.
Mirror manually only on iOS — see `isFrontCamera` handling in
`FaceCameraController`.

## Bugs & Credits
Report bugs and ask questions on [GitHub Issues](https://github.com/Androidsignal/face_overlay_kit/issues).
Maintained by [Dashstack Infotech, Surat](https://www.dashstack.tech/).
