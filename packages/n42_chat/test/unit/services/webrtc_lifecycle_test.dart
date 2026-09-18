import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' hide CallType, CallState, CallDirection;
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
  late Completer<Map<int, int>> permission;
  late CachedStreamController<Event> timeline;
  late CachedStreamController<List<BasicEventWithSender>> calls;
  final nativeCalls = <String>[];
  final sent = <Map<String, dynamic>>[];

  setUp(() async {
    nativeCalls.clear();
    sent.clear();
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
    permission = Completer<Map<int, int>>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (_) => permission.future,
        );
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
      () => room.sendEvent(
        any(),
        type: any(named: 'type'),
        txid: any(named: 'txid'),
        displayPendingEvent: any(named: 'displayPendingEvent'),
      ),
    ).thenAnswer((call) async {
      sent.add({
        'type': call.namedArguments[#type],
        'txid': call.namedArguments[#txid],
        'pending': call.namedArguments[#displayPendingEvent],
        ...Map<String, dynamic>.from(call.positionalArguments.first as Map),
      });
      return r'$sent';
    });
    when(
      () => client.request(RequestType.GET, '/client/v3/voip/turnServer'),
    ).thenAnswer((_) => turn.future);
    service = WebRTCService(client);
    await service.initialize();
  });
  tearDown(() async {
    if (!turn.isCompleted) turn.complete({'uris': <String>[]});
    if (!permission.isCompleted) permission.complete({7: 0, 1: 0});
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
  for (final type in [CallType.voice, CallType.video]) {
    test(
      'outgoing $type concurrent hangups publish one frozen record',
      () async {
        turn.complete({'uris': <String>[]});
        final starting = service.startCall(
          roomId: '!room:hs',
          type: type,
          peerId: '@peer:hs',
          peerName: 'Peer',
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final session = service.currentSession!;
        session.connectedTime = DateTime.now().subtract(
          const Duration(seconds: 13),
        );
        await Future.wait([service.hangup(), service.hangup()]);
        await Future<void>.delayed(Duration.zero);
        final records = sent
            .where((e) => e['msgtype'] == 'n42.call.record')
            .toList();
        expect(records, hasLength(1));
        expect(records.single['call_id'], session.callId);
        expect(records.single['duration'], 13);
        expect(
          records.single['call_type'],
          type == CallType.video ? 'video' : 'voice',
        );
        expect(records.single['txid'], 'n42_call_record_${session.callId}');
        final signals = sent
            .where((e) => e['type'] == 'm.call.hangup')
            .toList();
        expect(signals, hasLength(1));
        expect(signals.single['pending'], false);
        permission.complete({7: 0, 1: 0});
        expect(await starting, false);
      },
    );
  }

  test(
    'incoming local hangup publishes signaling but no room record',
    () async {
      timeline.add(
        Event.fromJson({
          'event_id': r'$invite',
          'type': 'm.call.invite',
          'sender': '@peer:hs',
          'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
          'content': {
            'call_id': 'incoming',
            'version': '1',
            'lifetime': 60000,
            'offer': {'type': 'offer', 'sdp': 'v=0\r\nm=audio'},
          },
        }, room),
      );
      await Future<void>.delayed(Duration.zero);
      expect(service.currentSession?.direction, CallDirection.incoming);
      service.currentSession!.connectedTime = DateTime.now().subtract(
        const Duration(seconds: 5),
      );
      await service.hangup();
      await Future<void>.delayed(Duration.zero);
      expect(sent.where((e) => e['type'] == 'm.call.hangup'), hasLength(1));
      expect(sent.where((e) => e['msgtype'] == 'n42.call.record'), isEmpty);
    },
  );

  for (final signal in ['m.call.hangup', 'm.call.reject']) {
    test(
      'remote $signal delivered twice publishes one caller record',
      () async {
        turn.complete({'uris': <String>[]});
        final starting = service.startCall(
          roomId: '!room:hs',
          type: CallType.voice,
          peerId: '@peer:hs',
          peerName: 'Peer',
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final session = service.currentSession!;
        session.connectedTime = DateTime.now().subtract(
          const Duration(seconds: 5),
        );
        final event = Event.fromJson({
          'event_id': r'$hangup',
          'type': signal,
          'sender': '@peer:hs',
          'content': {
            'call_id': session.callId,
            'version': '1',
            'reason': 'user_hangup',
          },
        }, room);
        timeline.add(event);
        timeline.add(event);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(
          sent.where((e) => e['msgtype'] == 'n42.call.record'),
          hasLength(1),
        );
        permission.complete({7: 0, 1: 0});
        expect(await starting, false);
      },
    );
  }

  test('receiver never publishes a record for remote hangup', () async {
    timeline.add(
      Event.fromJson({
        'event_id': r'$invite2',
        'type': 'm.call.invite',
        'sender': '@peer:hs',
        'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
        'content': {
          'call_id': 'incoming2',
          'version': '1',
          'lifetime': 60000,
          'offer': {'type': 'offer', 'sdp': 'v=0\r\nm=audio'},
        },
      }, room),
    );
    await Future<void>.delayed(Duration.zero);
    expect(service.currentSession?.direction, CallDirection.incoming);
    timeline.add(
      Event.fromJson({
        'event_id': r'$hangup2',
        'type': 'm.call.hangup',
        'sender': '@peer:hs',
        'content': {'call_id': 'incoming2', 'version': '1'},
      }, room),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(sent.where((e) => e['msgtype'] == 'n42.call.record'), isEmpty);
    expect(service.isInCall, false);
    turn.complete({'uris': <String>[]});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(service.isInCall, false);
    expect(nativeCalls, isNot(contains('createPeerConnection')));
  });
}
