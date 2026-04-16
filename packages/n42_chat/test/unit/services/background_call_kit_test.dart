import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:n42_chat/src/core/notifications/firebase_push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 测试后台来电 CallKit 触发逻辑
///
/// 由于 FlutterCallkitIncoming 和 FirebaseMessaging 都依赖 platform channel，
/// 这里通过拦截 MethodChannel 调用来验证行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 记录 platform channel 调用
  final List<MethodCall> callkitCalls = [];

  setUp(() {
    callkitCalls.clear();
    SharedPreferences.setMockInitialValues({});

    // 拦截 flutter_callkit_incoming 的 platform channel 调用
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_callkit_incoming'),
      (MethodCall methodCall) async {
        callkitCalls.add(methodCall);
        if (methodCall.method == 'showCallkitIncoming') {
          return null;
        }
        if (methodCall.method == 'activeCalls') {
          return <dynamic>[];
        }
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

  RemoteMessage createCallInviteMessage({
    String? sender,
    String? senderDisplayName,
    String? roomId,
    String type = 'm.call.invite',
  }) {
    return RemoteMessage(
      data: <String, dynamic>{
        'type': type,
        'sender': ?sender,
        'sender_display_name': ?senderDisplayName,
        'room_id': ?roomId,
      },
    );
  }

  group('_showBackgroundCallKit', () {
    test('should trigger CallKit with sender display name', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
        senderDisplayName: 'Alice',
        roomId: '!room123:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      expect(callkitCalls, hasLength(1));
      expect(callkitCalls.first.method, equals('showCallkitIncoming'));

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['nameCaller'], equals('Alice'));
      expect(args['handle'], equals('@alice:matrix.org'));
      expect(args['type'], equals(0)); // 默认语音
    });

    test('should fallback to sender ID when display name is missing', () async {
      final message = createCallInviteMessage(
        sender: '@bob:matrix.org',
        roomId: '!room123:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      expect(callkitCalls, hasLength(1));
      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['nameCaller'], equals('@bob:matrix.org'));
    });

    test('should fallback to "Unknown" when no sender info', () async {
      final message = createCallInviteMessage(
        roomId: '!room123:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      expect(callkitCalls, hasLength(1));
      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['nameCaller'], equals('Unknown'));
      expect(args['handle'], equals(''));
    });

    test('should include roomId and callerId in extra', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
        senderDisplayName: 'Alice',
        roomId: '!room456:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      final extra = args['extra'] as Map<dynamic, dynamic>;
      expect(extra['roomId'], equals('!room456:matrix.org'));
      expect(extra['callerId'], equals('@alice:matrix.org'));
    });

    test('should set duration to 60 seconds', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['duration'], equals(60000));
    });

    test('should generate a unique UUID for each call', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);
      await FirebasePushService.showBackgroundCallKitForTest(message);

      expect(callkitCalls, hasLength(2));
      final id1 = (callkitCalls[0].arguments as Map)['id'];
      final id2 = (callkitCalls[1].arguments as Map)['id'];
      expect(id1, isNot(equals(id2)));
    });

    test('should respect locally saved incoming-call ringtone preference', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'n42_chat_incoming_call_ringtone':
            '{"mode":"silent","label":"Silent","sourceKey":"silent"}',
      });

      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
        senderDisplayName: 'Alice',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      final android = args['android'] as Map<dynamic, dynamic>;
      final ios = args['ios'] as Map<dynamic, dynamic>;

      expect(android['ringtonePath'], equals('silent'));
      expect(ios['ringtonePath'], equals('system_ringtone_default'));
    });
  });

  group('_handleBackgroundMessage routing', () {
    test('should show CallKit for m.call.invite', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
        senderDisplayName: 'Alice',
        type: 'm.call.invite',
      );

      await FirebasePushService.handleBackgroundMessageForTest(message);

      // 应该触发 showCallkitIncoming
      final showCalls = callkitCalls.where(
        (c) => c.method == 'showCallkitIncoming',
      );
      expect(showCalls, hasLength(1));
    });

    test('should end CallKit on m.call.hangup (not show new one)', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.hangup',
          'room_id': '!room:matrix.org',
        },
      );

      await FirebasePushService.handleBackgroundMessageForTest(message);

      // 不应触发 showCallkitIncoming
      final showCalls = callkitCalls.where(
        (c) => c.method == 'showCallkitIncoming',
      );
      expect(showCalls, isEmpty);

      // 应触发 endAllCalls（结束后台来电界面）
      final endCalls = callkitCalls.where(
        (c) => c.method == 'endAllCalls',
      );
      expect(endCalls, hasLength(1));
    });

    test('should end CallKit on m.call.reject', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.reject',
          'room_id': '!room:matrix.org',
        },
      );

      await FirebasePushService.handleBackgroundMessageForTest(message);

      final showCalls = callkitCalls.where(
        (c) => c.method == 'showCallkitIncoming',
      );
      expect(showCalls, isEmpty);

      final endCalls = callkitCalls.where(
        (c) => c.method == 'endAllCalls',
      );
      expect(endCalls, hasLength(1));
    });

    test('should skip m.call.candidates without triggering CallKit', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.candidates',
          'room_id': '!room:matrix.org',
        },
      );

      await FirebasePushService.handleBackgroundMessageForTest(message);

      final showCalls = callkitCalls.where(
        (c) => c.method == 'showCallkitIncoming',
      );
      expect(showCalls, isEmpty);
    });

    test('should skip m.call.answer without triggering CallKit', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.answer',
          'room_id': '!room:matrix.org',
        },
      );

      await FirebasePushService.handleBackgroundMessageForTest(message);

      final showCalls = callkitCalls.where(
        (c) => c.method == 'showCallkitIncoming',
      );
      expect(showCalls, isEmpty);
    });
  });

  group('CallKit params platform compatibility', () {
    test('should include both Android and iOS params', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
        senderDisplayName: 'Alice',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;

      // Android 参数存在
      final android = args['android'] as Map<dynamic, dynamic>?;
      expect(android, isNotNull);
      expect(android!['isCustomNotification'], isTrue);
      expect(android['backgroundColor'], equals('#0955fa'));

      // iOS 参数存在
      final ios = args['ios'] as Map<dynamic, dynamic>?;
      expect(ios, isNotNull);
      expect(ios!['handleType'], equals('generic'));
      expect(ios['supportsVideo'], isTrue);
    });

    test('should set appName to N42 Chat', () async {
      final message = createCallInviteMessage(
        sender: '@alice:matrix.org',
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['appName'], equals('N42 Chat'));
    });
  });
}
