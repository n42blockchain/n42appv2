// Native smoke coverage; homeserver responses are fixtures, not live accounts.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as native_crypto;
import 'package:integration_test/integration_test.dart';
import 'package:matrix/matrix.dart' hide CallType, CallState;
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/services/voip/webrtc_service.dart';
import 'package:vodozemac/vodozemac.dart' as crypto;

class _Client extends Mock implements Client {}

class _Room extends Mock implements Room {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native Megolm decrypts a new message on a fresh receiving session',
    (tester) async {
      await tester.runAsync(() async {
        await native_crypto.init();
        final sender = crypto.GroupSession();
        final receiver = crypto.InboundGroupSession(sender.sessionKey);
        final message = sender.encrypt('N42 new-message native smoke');
        expect(
          receiver.decrypt(message).plaintext,
          'N42 new-message native smoke',
        );
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Native encryption passed'))),
        ),
      );
      expect(find.text('Native encryption passed'), findsOneWidget);
    },
  );

  testWidgets(
    'native WebRTC renderers release on cancellation during TURN lookup',
    (tester) async {
      await tester.runAsync(() async {
        final client = _Client();
        final room = _Room();
        final events = CachedStreamController<Event>();
        final calls = CachedStreamController<List<BasicEventWithSender>>();
        final turn = Completer<Map<String, dynamic>>();
        when(() => client.userID).thenReturn('@fixture:invalid');
        when(() => client.deviceID).thenReturn('FIXTURE');
        when(() => client.onTimelineEvent).thenReturn(events);
        when(() => client.onCallEvents).thenReturn(calls);
        when(() => client.getRoomById('!fixture:invalid')).thenReturn(room);
        when(() => room.encrypted).thenReturn(false);
        when(
          () => client.request(RequestType.GET, '/client/v3/voip/turnServer'),
        ).thenAnswer((_) => turn.future);
        final service = WebRTCService(client);
        await service.initialize();
        try {
          final pending = service.startCall(
            roomId: '!fixture:invalid',
            type: CallType.voice,
            peerId: '@peer:invalid',
            peerName: 'Native fixture',
          );
          await Future<void>.delayed(const Duration(milliseconds: 30));
          expect(service.isInCall, isTrue);
          await service.hangup().timeout(const Duration(seconds: 5));
          expect(service.isInCall, isFalse);
          expect(service.currentSession, isNull);
          turn.complete({'uris': <String>[]});
          expect(await pending, isFalse);
        } finally {
          if (!turn.isCompleted) turn.complete({'uris': <String>[]});
          await service.dispose();
          await events.close();
          await calls.close();
        }
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Native call cancellation passed')),
          ),
        ),
      );
      expect(find.text('Native call cancellation passed'), findsOneWidget);
    },
  );
}
