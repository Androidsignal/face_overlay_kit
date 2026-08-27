import 'package:face_overlay_kit/face_overlay_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _centeredData = FaceData(
  faceDetected: true,
  centerPosition: Offset(0.5, 0.5),
  width: 0.42,
  height: 0.42,
);

const _noFaceData = FaceData.none;

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows the noFace message and error color when no face is detected',
      (tester) async {
    const config = FaceOverlayConfig();
    await tester.pumpWidget(_wrap(
      const FaceOverlay(faceData: _noFaceData, config: config),
    ));
    await tester.pumpAndSettle();

    expect(find.text(config.messages.noFace), findsOneWidget);

    final Text textWidget = tester.widget(find.text(config.messages.noFace));
    expect(textWidget.style?.color, config.errorColor);
  });

  testWidgets('shows the centered message and success color once aligned',
      (tester) async {
    const config = FaceOverlayConfig();
    await tester.pumpWidget(_wrap(
      const FaceOverlay(faceData: _centeredData, config: config),
    ));
    await tester.pumpAndSettle();

    expect(find.text(config.messages.centered), findsOneWidget);

    final Text textWidget = tester.widget(find.text(config.messages.centered));
    expect(textWidget.style?.color, config.successColor);
  });

  testWidgets('onAlignmentChanged fires once on the initial build and once per transition',
      (tester) async {
    final List<FaceAlignment> events = [];
    const config = FaceOverlayConfig();

    await tester.pumpWidget(_wrap(
      FaceOverlay(
        faceData: _noFaceData,
        config: config,
        onAlignmentChanged: events.add,
      ),
    ));
    await tester.pumpAndSettle();
    expect(events, [FaceAlignment.noFace]);

    // Same alignment again - no new event.
    await tester.pumpWidget(_wrap(
      FaceOverlay(
        faceData: _noFaceData,
        config: config,
        onAlignmentChanged: events.add,
      ),
    ));
    await tester.pumpAndSettle();
    expect(events, [FaceAlignment.noFace]);

    // Transition to centered - exactly one new event.
    await tester.pumpWidget(_wrap(
      FaceOverlay(
        faceData: _centeredData,
        config: config,
        onAlignmentChanged: events.add,
      ),
    ));
    await tester.pumpAndSettle();
    expect(events, [FaceAlignment.noFace, FaceAlignment.centered]);
  });

  testWidgets('disposes its animation controller when removed from the tree',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const FaceOverlay(faceData: _centeredData),
    ));
    await tester.pumpAndSettle();

    // Replacing with an empty tree should tear the State (and its
    // AnimationController) down without throwing.
    await tester.pumpWidget(_wrap(const SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders custom child behind the overlay layers', (tester) async {
    await tester.pumpWidget(_wrap(
      const FaceOverlay(
        faceData: _centeredData,
        child: ColoredBox(color: Color(0xFF123456), key: Key('preview')),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('preview')), findsOneWidget);
  });
}
