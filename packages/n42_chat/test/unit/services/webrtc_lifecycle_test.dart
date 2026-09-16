import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' hide CallType, CallState;
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/services/voip/webrtc_service.dart';

class _Client extends Mock implements Client {}

class _Room extends Mock implements Room {}

class _User extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Client client;
  late _Room room;
  late WebRTCService service;
  late Completer<Map<String, dynamic>> turn;
  late CachedStreamController<Event> timeline;
  late CachedStreamController<List<BasicEventWithSender>> calls;
  final nativeCalls = <String>[];

  setUp(() async {
    nativeCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('FlutterWebRTC.Method'), (
          call,
        ) async {
          nativeCalls.add(call.method);
          if (call.method == 'createVideoRenderer')
            return {'textureId': nativeCalls.length};
          if (call.method == 'createPeerConnection')
            return {'peerConnectionId': 'pc'};
          return null;
        });
    client = _Client();
    room = _Room();
    turn = Completer<Map<String, dynamic>>();
    timeline = CachedStreamController<Event>();
    calls = CachedStreamController<List<BasicEventWithSender>>();
    when(() => client.onTimelineEvent).thenReturn(timeline);
    when(() => client.onCallEvents).thenReturn(calls);
    when(() => client.userID).thenReturn('@me:hs');
    when(() => client.deviceID).thenReturn('ME');
    when(() => client.getRoomById('!room:hs')).thenReturn(room);
    when(() => room.encrypted).thenReturn(false);
    when(() => room.id).thenReturn('!room:hs');
    when(() => room.client).thenReturn(client);
    final peer = _User();
    when(() => peer.displayName).thenReturn('Peer');
    when(
      () => room.unsafeGetUserFromMemoryOrFallback('@peer:hs'),
    ).thenReturn(peer);
    when(
      () => room.sendEvent(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => r'$sent');
    when(
      () => client.request(RequestType.GET, '/client/v3/voip/turnServer'),
    ).thenAnswer((_) => turn.future);
    service = WebRTCService(client);
    await service.initialize();
  });
  tearDown(() async {
    if (!turn.isCompleted) turn.complete({'uris': <String>[]});
    await Future<void>.delayed(Duration.zero);
    await service.dispose();
    await timeline.close();
    await calls.close();
  });

  test('incoming ICE is retained while TURN lookup is still pending', () async {
    Event event(String type, Map<String, dynamic> content) => Event.fromJson({
      'event_id': '\$${type.hashCode}',
      'type': type,
      'sender': '@peer:hs',
      'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
      'content': {'call_id': 'incoming', 'version': '1', ...content},
    }, room);
    timeline.add(
      event('m.call.invite', {
        'lifetime': 60000,
        'offer': {'type': 'offer', 'sdp': 'v=0\r\nm=audio'},
      }),
    );
    await Future<void>.delayed(Duration.zero);
    expect(service.currentSession?.callId, 'incoming');
    timeline.add(
      event('m.call.candidates', {
        'candidates': [
          {'candidate': 'candidate:test', 'sdpMid': '0', 'sdpMLineIndex': 0},
        ],
      }),
    );
    await Future<void>.delayed(Duration.zero);
    turn.complete({'uris': <String>[]});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(service.state, CallState.incoming);
    expect(nativeCalls, contains('addCandidate'));
    expect(
      nativeCalls.indexOf('setRemoteDescription'),
      lessThan(nativeCalls.indexOf('addCandidate')),
    );
  });

  test(
    'system hangup cancels startup while TURN is pending and allows retry',
    () async {
      final attempt = service.startCall(
        roomId: '!room:hs',
        type: CallType.voice,
        peerId: '@peer:hs',
        peerName: 'Peer',
      );
      await Future<void>.delayed(Duration.zero);
      expect(service.isInCall, isTrue);
      await service.hangup().timeout(const Duration(seconds: 1));
      expect(service.isInCall, isFalse);
      expect(service.currentSession, isNull);
      turn.complete({'uris': <String>[]});
      expect(await attempt, isFalse);
      expect(nativeCalls, isNot(contains('createPeerConnection')));
      expect(service.isInCall, isFalse);
    },
  );
}
