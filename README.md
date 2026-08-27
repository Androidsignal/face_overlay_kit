# face_overlay_kit

Reusable, SDK-agnostic **face alignment overlay UI** for Flutter. Feed it face
position data from *any* source — Binah, Google ML Kit, MediaPipe, or a
custom model — and it renders a smooth, animated guided overlay: an oval (or
any shape) with direction guides that tell the user to move left / right / up
/ down / closer / farther, plus a "centered" success state.

This package contains **no face detection logic**. It never touches camera
frames. It's a pure visualization/UI toolkit that consumes position data
your app already computes.

## Install

```yaml
dependencies:
  face_overlay_kit: ^0.0.1
```

## Quick start

`face_overlay_kit` doesn't know or care which detector produced your face
data — you write a small mapper function once, and everything downstream
(alignment logic, animation, painting) is shared.

```dart
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

`FaceOverlay` stacks on top of your camera preview — pass it as `child`, or
place `FaceOverlay` in your own `Stack` above `CameraPreview`. The package
never creates a camera preview of its own.

### Mapping from your detector

**Google ML Kit (`Face`)**

```dart
FaceData mapMlKitFace(Face face, Size imageSize) {
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

**Binah / MediaPipe / custom** — same idea: normalize whatever bounding
box or landmark set you get into `0..1` and construct a `FaceData`. See
`example/lib/main.dart` for simulated data covering every scenario.

## Configuration reference

| Field | Type | Purpose |
|---|---|---|
| `shape` | `FaceOverlayShape` | `oval`, `circle`, `rectangle`, or `.custom(pathBuilder)` |
| `activeColor` / `successColor` / `errorColor` | `Color` | Border/indicator color per state |
| `strokeWidth` | `double` | Shape border width |
| `backgroundOpacity` | `double` | Scrim opacity outside the cut-out shape |
| `showGuideLines` / `showDirectionIndicator` | `bool` | Toggle guide lines / indicator dot |
| `guideLineStyle` | `GuideLineStyle` | Dash length/gap, color, stroke width, length |
| `guideDotStyle` | `GuideDotStyle` | Dot size, color, spacing from shape edge |
| `animationDuration` / `animationCurve` | `Duration` / `Curve` | Drives all lerps |
| `tolerance` | `AlignmentTolerance` | Position tolerance, min/max/ideal face size |
| `messages` | `OverlayMessages` | Per-`FaceAlignment` text, fully overridable |
| `customIndicatorBuilder` | `Widget Function(FaceAlignment)?` | Replace the built-in direction indicator |
| `successWidgetBuilder` / `errorWidgetBuilder` | `Widget Function()?` | Replace the built-in success/error content |

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
SDK's output to `FaceData` (see examples above) and everything else just
works.

## Testing

```
flutter test
```

Covers `AlignmentCalculator` (table-driven, every branch + boundary cases)
and `FaceOverlay` (color/message per alignment, `onAlignmentChanged`
transition semantics, disposal).

## Example

Run the demo app (`cd example && flutter run`) and pick a mode:

- **Live Camera Demo** (`example/lib/live_face_overlay_page.dart`) — real
  front camera feed via `camera`, real detection via
  `google_mlkit_face_detection`, mapped to `FaceData` and fed to
  `FaceOverlay`. This is the only code in the example that talks to a
  camera or a detector; swapping detectors only changes the mapping
  function in this one file.
- **Simulated Demo** (`example/lib/simulated_demo_page.dart`) — a scenario
  picker driving canned `FaceData`: no face, too far, too close, moved
  left/right/up/down, and centered → success animation, with a fake
  camera preview behind the overlay to prove there's no double camera.

The live demo needs a camera permission grant on first run (Android/iOS
prompt) and a physical device (simulators/emulators without a camera will
show a camera error).
