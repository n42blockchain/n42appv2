import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/call/group_call_screen.dart';
import 'package:n42_chat/src/services/voip/livekit_service.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('renders positioned call controls without parent data errors', (
    tester,
  ) async {
    final service = LiveKitService();

    await tester.pumpWidget(
      MaterialApp(
        home: GroupCallScreen(liveKitService: service, roomName: 'Test group'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Test group'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('fits all group call controls on a narrow portrait screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = LiveKitService();
    await tester.pumpWidget(
      MaterialApp(
        home: GroupCallScreen(liveKitService: service, roomName: 'Test group'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final labels = <String>[
      'Mute',
      'Turn off video',
      'Share screen',
      'Chat',
      'Switch',
      'Leave',
    ];
    final labelRects = labels
        .map((label) => tester.getRect(find.text(label)))
        .toList();
    for (var index = 0; index < labelRects.length - 1; index++) {
      expect(
        labelRects[index].right,
        lessThanOrEqualTo(labelRects[index + 1].left),
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('restores controls without exposing hidden actions to taps', (
    tester,
  ) async {
    final service = _ConnectedCallService();
    await tester.pumpWidget(
      MaterialApp(
        home: GroupCallScreen(liveKitService: service, roomName: 'Test group'),
      ),
    );
    await tester.pump();

    expect(
      tester.getRect(find.text('Local user (Me)')).bottom,
      lessThanOrEqualTo(tester.getRect(find.byIcon(Icons.mic)).top),
    );

    await tester.pump(const Duration(seconds: 6));
    final opacityFinder = find.byType(AnimatedOpacity);
    expect(
      tester
          .widgetList<AnimatedOpacity>(opacityFinder)
          .every((widget) => widget.opacity == 0),
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('group-call-controls-restore-layer')),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<IgnorePointer>(find.byType(IgnorePointer))
          .where((widget) => widget.ignoring)
          .length,
      greaterThanOrEqualTo(2),
    );

    await tester.tap(
      find.byKey(const ValueKey('group-call-controls-restore-layer')),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester
          .widgetList<AnimatedOpacity>(opacityFinder)
          .every((widget) => widget.opacity == 1),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _ConnectedCallService extends LiveKitService {
  @override
  MeetingState get state => MeetingState.connected;

  @override
  List<MeetingParticipant> get participants => [
    MeetingParticipant(id: 'local-user', name: 'Local user', isLocal: true),
  ];
}
