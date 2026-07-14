import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/call/group_call_screen.dart';
import 'package:n42_chat/src/services/voip/livekit_service.dart';

void main() {
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
}
