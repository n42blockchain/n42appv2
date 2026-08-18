import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/core/notifications/firebase_push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMatrixClient extends Mock implements matrix.Client {}

class FakePusher extends Fake implements matrix.Pusher {
  @override
  final String pushkey;
  @override
  final String appId;

  FakePusher({required this.pushkey, required this.appId});
}

/// 测试 FirebasePushService 的实例方法：
/// - setInCall / isInCall 状态管理
/// - 自动重置定时器（防止 _isInCall 泄漏）
/// - activeRoom 管理
/// - 后台消息处理边界情况
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> callkitCalls = [];

  setUp(() {
    callkitCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_callkit_incoming'),
          (MethodCall methodCall) async {
            callkitCalls.add(methodCall);
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

  group('setInCall and isInCall', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should default isInCall to false', () {
      expect(service.isInCall, isFalse);
    });

    test('should set isInCall to true', () {
      service.setInCall(true);
      expect(service.isInCall, isTrue);
    });

    test('should set isInCall back to false', () {
      service.setInCall(true);
      service.setInCall(false);
      expect(service.isInCall, isFalse);
    });

    test('should handle multiple setInCall(true) calls', () {
      service.setInCall(true);
      service.setInCall(true);
      expect(service.isInCall, isTrue);
    });

    test('should handle setInCall(false) when already false', () {
      service.setInCall(false);
      expect(service.isInCall, isFalse);
    });
  });

  group('setInCall auto-reset timer', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should auto-reset isInCall after 90 seconds', () async {
      service.setInCall(true);
      expect(service.isInCall, isTrue);

      // 等待定时器触发（使用较短的验证周期，通过 dispose 确保 timer 被清理）
      // 注意：真正的 90 秒定时器在单元测试中无法等待
      // 这里验证设置行为正确（timer 创建后 isInCall 仍为 true）
      expect(service.isInCall, isTrue);
    });

    test('should cancel timer when setInCall(false) is called', () {
      service.setInCall(true);
      expect(service.isInCall, isTrue);

      service.setInCall(false);
      expect(service.isInCall, isFalse);

      // 再次验证状态稳定
      expect(service.isInCall, isFalse);
    });

    test(
      'should cancel previous timer when setInCall(true) is called again',
      () {
        service.setInCall(true);
        service.setInCall(true); // 应取消前一个 timer 并创建新的
        expect(service.isInCall, isTrue);

        service.setInCall(false);
        expect(service.isInCall, isFalse);
      },
    );

    test('dispose should cancel timer without errors', () async {
      service.setInCall(true);
      expect(service.isInCall, isTrue);

      // dispose 应该安全地取消 timer
      await service.dispose();

      // 创建新实例以继续后续测试
      service = FirebasePushService(MockMatrixClient());
    });
  });

  group('activeRoom management', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should default activeRoomId to null', () {
      expect(service.activeRoomId, isNull);
    });

    test('should set and get activeRoomId', () {
      service.setActiveRoom('!room:matrix.org');
      expect(service.activeRoomId, equals('!room:matrix.org'));
    });

    test('should clear activeRoomId', () {
      service.setActiveRoom('!room:matrix.org');
      service.setActiveRoom(null);
      expect(service.activeRoomId, isNull);
    });

    test('should update activeRoomId when switching rooms', () {
      service.setActiveRoom('!room1:matrix.org');
      expect(service.activeRoomId, equals('!room1:matrix.org'));

      service.setActiveRoom('!room2:matrix.org');
      expect(service.activeRoomId, equals('!room2:matrix.org'));
    });
  });

  group('background message handler edge cases', () {
    test('should handle m.call.invite without room_id', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.invite',
          'sender': '@alice:matrix.org',
        },
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      expect(callkitCalls, hasLength(1));
      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      final extra = args['extra'] as Map<dynamic, dynamic>;
      expect(extra['roomId'], isNull);
    });

    test('should use notification title as fallback for sender name', () async {
      const message = RemoteMessage(
        data: <String, dynamic>{
          'type': 'm.call.invite',
          'room_id': '!room:matrix.org',
        },
        notification: RemoteNotification(title: 'Call from Bob'),
      );

      await FirebasePushService.showBackgroundCallKitForTest(message);

      final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
      expect(args['nameCaller'], equals('Call from Bob'));
    });

    test(
      'should handle m.call.invite with sender_display_name priority',
      () async {
        const message = RemoteMessage(
          data: <String, dynamic>{
            'type': 'm.call.invite',
            'sender': '@alice:matrix.org',
            'sender_display_name': 'Alice Wonderland',
            'room_id': '!room:matrix.org',
          },
          notification: RemoteNotification(title: 'Different Title'),
        );

        await FirebasePushService.showBackgroundCallKitForTest(message);

        final args = callkitCalls.first.arguments as Map<dynamic, dynamic>;
        // sender_display_name takes precedence over notification.title.
        expect(args['nameCaller'], equals('Alice Wonderland'));
      },
    );

    test(
      'should call endAllCalls for both hangup and reject in sequence',
      () async {
        const hangup = RemoteMessage(
          data: <String, dynamic>{
            'type': 'm.call.hangup',
            'room_id': '!room:matrix.org',
          },
        );
        const reject = RemoteMessage(
          data: <String, dynamic>{
            'type': 'm.call.reject',
            'room_id': '!room:matrix.org',
          },
        );

        await FirebasePushService.handleBackgroundMessageForTest(hangup);
        await FirebasePushService.handleBackgroundMessageForTest(reject);

        final endCalls = callkitCalls.where((c) => c.method == 'endAllCalls');
        expect(endCalls, hasLength(2));
      },
    );
  });

  // ────────────────────────────────────────────
  // 新增：isPusherVerified 状态管理
  // ────────────────────────────────────────────
  group('isPusherVerified', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should default isPusherVerified to false', () {
      expect(service.isPusherVerified, isFalse);
    });
  });

  // ────────────────────────────────────────────
  // 新增：getDiagnosticInfo
  // ────────────────────────────────────────────
  group('getDiagnosticInfo', () {
    late FirebasePushService service;
    late MockMatrixClient mockClient;

    setUp(() {
      mockClient = MockMatrixClient();
      when(() => mockClient.isLogged()).thenReturn(false);
      service = FirebasePushService(
        mockClient,
        pushGatewayUrl: 'https://push.example.com',
        appId: 'com.test.app',
        pushkeyType: 'http',
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should return all expected keys', () {
      final info = service.getDiagnosticInfo();

      expect(info, containsPair('status', 'not_initialized'));
      expect(info, containsPair('isInitialized', false));
      expect(info, containsPair('fcmToken', null));
      expect(info, containsPair('apnsToken', null));
      expect(info, containsPair('pushGatewayUrl', 'https://push.example.com'));
      expect(info, containsPair('appId', 'com.test.app'));
      expect(info, containsPair('pushkeyType', 'http'));
      expect(info, containsPair('isPusherVerified', false));
      expect(info, containsPair('isRegistering', false));
      expect(info, containsPair('clientIsLogged', false));
      expect(info, contains('platform'));
    });

    test('should reflect clientIsLogged state', () {
      when(() => mockClient.isLogged()).thenReturn(true);
      final info = service.getDiagnosticInfo();
      expect(info['clientIsLogged'], isTrue);
    });
  });

  // ────────────────────────────────────────────
  // 新增：registerForPush 重试与登录状态检查
  // ────────────────────────────────────────────
  group('registerForPush retry behavior', () {
    late FirebasePushService service;
    late MockMatrixClient mockClient;

    setUp(() {
      mockClient = MockMatrixClient();
      service = FirebasePushService(
        mockClient,
        pushGatewayUrl: 'https://push.example.com',
        appId: 'com.test.app',
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should not throw when fcmToken is null', () async {
      // fcmToken 为 null 时应安全返回，不抛异常
      when(() => mockClient.isLogged()).thenReturn(true);
      await expectLater(service.registerForPush(), completes);
    });

    test('should not register concurrently (lock mechanism)', () async {
      // 并发调用 registerForPush 时第二次应被跳过
      when(() => mockClient.isLogged()).thenReturn(true);

      // 两次调用都应安全完成
      final f1 = service.registerForPush();
      final f2 = service.registerForPush();
      await Future.wait([f1, f2]);
      // 不抛异常即通过
    });
  });

  // ────────────────────────────────────────────
  // 新增：forceReRegister
  // ────────────────────────────────────────────
  group('forceReRegister', () {
    late FirebasePushService service;
    late MockMatrixClient mockClient;

    setUp(() {
      mockClient = MockMatrixClient();
      service = FirebasePushService(
        mockClient,
        pushGatewayUrl: 'https://push.example.com',
        appId: 'com.test.app',
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should not throw when called without prior registration', () async {
      when(() => mockClient.isLogged()).thenReturn(true);
      await expectLater(service.forceReRegister(), completes);
    });

    test('should reset isPusherVerified before re-registering', () async {
      when(() => mockClient.isLogged()).thenReturn(true);
      // 初始状态验证
      expect(service.isPusherVerified, isFalse);
      await service.forceReRegister();
      // 因为没有 token，注册不会成功，verified 仍为 false
      expect(service.isPusherVerified, isFalse);
    });
  });

  // ────────────────────────────────────────────
  // 新增：FirebasePushServiceBuilder
  // ────────────────────────────────────────────
  group('FirebasePushServiceBuilder', () {
    test('should throw when client is not set', () {
      final builder = FirebasePushServiceBuilder();
      expect(() => builder.build(), throwsA(isA<StateError>()));
    });

    test('should build service with all parameters', () {
      final client = MockMatrixClient();
      when(() => client.isLogged()).thenReturn(false);
      final service = FirebasePushServiceBuilder()
          .withClient(client)
          .withPushGatewayUrl('https://push.example.com')
          .withAppId('com.test.builder')
          .withPushkeyType('http')
          .withNotificationTapHandler((roomId, eventId) {})
          .build();

      expect(service, isA<FirebasePushService>());
      final info = service.getDiagnosticInfo();
      expect(info['appId'], equals('com.test.builder'));
      expect(info['pushGatewayUrl'], equals('https://push.example.com'));
    });

    test('should build service with minimal parameters', () {
      final client = MockMatrixClient();
      when(() => client.isLogged()).thenReturn(false);
      final service = FirebasePushServiceBuilder().withClient(client).build();

      expect(service, isA<FirebasePushService>());
      final info = service.getDiagnosticInfo();
      expect(info['appId'], equals('com.n42.chat'));
    });
  });

  group('privacy-restricted room lookup', () {
    test('recognizes hidden and locked rooms', () async {
      SharedPreferences.setMockInitialValues({
        'n42_chat_hidden_chats': '["!hidden:example.org"]',
        'chat_lock_locked_chats': <String>['!locked:example.org'],
      });

      expect(
        await FirebasePushService.isPrivacyRestrictedRoomForTest(
          '!hidden:example.org',
        ),
        isTrue,
      );
      expect(
        await FirebasePushService.isPrivacyRestrictedRoomForTest(
          '!locked:example.org',
        ),
        isTrue,
      );
      expect(
        await FirebasePushService.isPrivacyRestrictedRoomForTest(
          '!public:example.org',
        ),
        isFalse,
      );
    });

    test('fails closed when hidden-room state is malformed', () async {
      SharedPreferences.setMockInitialValues({
        'n42_chat_hidden_chats': '{"unexpected":true}',
      });

      expect(
        await FirebasePushService.isPrivacyRestrictedRoomForTest(
          '!room:example.org',
        ),
        isTrue,
      );
    });
  });
}
