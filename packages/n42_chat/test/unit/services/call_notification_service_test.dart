import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/call_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> callkitCalls = <MethodCall>[];

  setUp(() {
    callkitCalls.clear();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_callkit_incoming'),
          (MethodCall methodCall) async {
            callkitCalls.add(methodCall);
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_callkit_incoming'),
          null,
        );
  });

  Future<void> nativeEvent(String action, String id) async {
    final done = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'flutter_callkit_incoming_events',
          const StandardMethodCodec().encodeSuccessEnvelope({
            'event': 'com.hiennv.flutter_callkit_incoming.$action',
            'body': {
              'id': id,
              'nameCaller': 'Alice',
              'extra': {'roomId': '!room:hs'},
            },
          }),
          (_) => done.complete(),
        );
    await done.future;
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'Android acceptance silences only the connected call without ending it',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      final service = CallNotificationService();
      await service.setCallConnected('answered-call');
      expect(callkitCalls.map((c) => c.method), [
        'hideCallkitIncoming',
        'callConnected',
      ]);
      expect(callkitCalls.first.arguments['id'], 'answered-call');
      expect(
        callkitCalls.any(
          (c) => c.method == 'endAllCalls' || c.method == 'endCall',
        ),
        isFalse,
      );
    },
  );

  test('system hangup emits an end action for the active call', () async {
    final service = CallNotificationService();
    await service.initialize();
    final id = await service.showOutgoingCall(
      calleeId: '@alice:hs',
      calleeName: 'Alice',
    );
    final actions = <CallAction>[];
    final sub = service.callActions.listen((event) => actions.add(event.$1));
    await nativeEvent('ACTION_CALL_ENDED', id);
    expect(actions, [CallAction.ended]);
    expect(service.currentCallId, isNull);
    await sub.cancel();
  });

  test(
    'programmatic dismissal does not hang up an accepted or subsequent call',
    () async {
      final service = CallNotificationService();
      final old = await service.showOutgoingCall(
        calleeId: '@alice:hs',
        calleeName: 'Alice',
      );
      await service.endAllCalls();
      final next = await service.showOutgoingCall(
        calleeId: '@bob:hs',
        calleeName: 'Bob',
      );
      final actions = <CallAction>[];
      final sub = service.callActions.listen((event) => actions.add(event.$1));
      await nativeEvent('ACTION_CALL_ENDED', old);
      expect(actions, isEmpty);
      expect(service.currentCallId, next);
      await nativeEvent('ACTION_CALL_ENDED', next);
      expect(actions, [CallAction.ended]);
      await sub.cancel();
    },
  );

  test(
    'native actions remain connected after dispose and reinitialize',
    () async {
      final service = CallNotificationService();
      service.dispose();
      await Future<void>.delayed(Duration.zero);
      await service.initialize();
      final id = await service.showOutgoingCall(
        calleeId: '@alice:hs',
        calleeName: 'Alice',
      );
      final actions = <CallAction>[];
      final sub = service.callActions.listen((event) => actions.add(event.$1));
      await nativeEvent('ACTION_CALL_ENDED', id);
      expect(actions, [CallAction.ended]);
      await sub.cancel();
    },
  );

  test(
    'showIncomingCall uses stored ringtone preference for CallKit params',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'n42_chat_incoming_call_ringtone':
            '{"mode":"silent","label":"Silent","sourceKey":"silent"}',
      });

      await CallNotificationService().showIncomingCall(
        callerId: '@alice:matrix.org',
        callerName: 'Alice',
      );

      expect(callkitCalls, isNotEmpty);
      final incoming = callkitCalls.firstWhere(
        (call) => call.method == 'showCallkitIncoming',
      );
      final args = incoming.arguments as Map<dynamic, dynamic>;
      final android = args['android'] as Map<dynamic, dynamic>;
      final ios = args['ios'] as Map<dynamic, dynamic>;

      expect(incoming.method, 'showCallkitIncoming');
      expect(android['ringtonePath'], 'silent');
      expect(ios['ringtonePath'], 'system_ringtone_default');
    },
  );
}
