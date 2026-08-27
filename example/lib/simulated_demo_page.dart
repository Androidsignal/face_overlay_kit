import 'package:face_overlay_kit/face_overlay_kit.dart';
import 'package:flutter/material.dart';

/// Every simulated scenario the demo can drive, mapped to a [FaceData]
/// value. Nothing here talks to a camera or a detector - it's just
/// canned data to prove out every overlay state.
enum DemoScenario {
  noFace('No Face', FaceData.none),
  tooFar('Too Far', FaceData(faceDetected: true, centerPosition: Offset(0.5, 0.5), width: 0.18, height: 0.18)),
  tooClose('Too Close', FaceData(faceDetected: true, centerPosition: Offset(0.5, 0.5), width: 0.75, height: 0.75)),
  movedLeft('Moved Left', FaceData(faceDetected: true, centerPosition: Offset(0.28, 0.5), width: 0.42, height: 0.42)),
  movedRight('Moved Right', FaceData(faceDetected: true, centerPosition: Offset(0.72, 0.5), width: 0.42, height: 0.42)),
  movedUp('Moved Up', FaceData(faceDetected: true, centerPosition: Offset(0.5, 0.28), width: 0.42, height: 0.42)),
  movedDown('Moved Down', FaceData(faceDetected: true, centerPosition: Offset(0.5, 0.72), width: 0.42, height: 0.42)),
  centered('Centered', FaceData(faceDetected: true, centerPosition: Offset(0.5, 0.5), width: 0.42, height: 0.42));

  const DemoScenario(this.label, this.data);

  final String label;
  final FaceData data;
}

class SimulatedDemoPage extends StatefulWidget {
  const SimulatedDemoPage({super.key});

  @override
  State<SimulatedDemoPage> createState() => _SimulatedDemoPageState();
}

class _SimulatedDemoPageState extends State<SimulatedDemoPage> {
  DemoScenario _scenario = DemoScenario.noFace;
  FaceAlignment? _lastAlignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Simulated Demo')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Stand-in for the host app's own camera preview. Proves
                  // face_overlay_kit never creates its own preview - it
                  // only ever paints on top of whatever's already there.
                  const _FakeCameraPreview(),
                  FaceOverlay(
                    faceData: _scenario.data,
                    config: const FaceOverlayConfig(
                      shape: FaceOverlayShape.oval,
                      showGuideLines: true,
                      showDirectionIndicator: true,
                    ),
                    onAlignmentChanged: (alignment) {
                      setState(() => _lastAlignment = alignment);
                    },
                  ),
                ],
              ),
            ),
            _ScenarioPicker(
              current: _scenario,
              lastAlignment: _lastAlignment,
              onChanged: (scenario) => setState(() => _scenario = scenario),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeCameraPreview extends StatelessWidget {
  const _FakeCameraPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232526), Color(0xFF414345)],
        ),
      ),
      child: Center(
        child: Text(
          'camera preview\n(owned by host app)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        ),
      ),
    );
  }
}

class _ScenarioPicker extends StatelessWidget {
  const _ScenarioPicker({
    required this.current,
    required this.lastAlignment,
    required this.onChanged,
  });

  final DemoScenario current;
  final FaceAlignment? lastAlignment;
  final ValueChanged<DemoScenario> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'onAlignmentChanged: ${lastAlignment?.name ?? '-'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final scenario in DemoScenario.values)
                ChoiceChip(
                  label: Text(scenario.label),
                  selected: scenario == current,
                  onSelected: (_) => onChanged(scenario),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
