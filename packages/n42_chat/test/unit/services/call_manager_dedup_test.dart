import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/call_notification_service.dart';

/// 测试 CallNotificationService 的 getActiveCalls() 去重机制
///
/// CallManager._handleIncomingCall 依赖 getActiveCalls() 判断是否已有来电，
/// 这里验证 getActiveCalls 的行为以及去重判断逻辑。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CallNotificationService notificationService;
  List<dynamic> mockActiveCalls = [];

  setUp(() {
    notificationService = CallNotificationService();
    mockActiveCalls = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_callkit_incoming'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'activeCalls') {
          return mockActiveCalls;
        }
        if (methodCall.method == 'showCallkitIncoming') {
          return null;
        }
        if (methodCall.method == 'endAllCalls') {
          mockActiveCalls.clear();
          return null;
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

  group('getActiveCalls deduplication', () {
    test('should return empty list when no active calls', () async {
      final calls = await notificationService.getActiveCalls();
      expect(calls, isEmpty);
    });

    test('should return active calls when CallKit is showing', () async {
      mockActiveCalls = [
        {'id': 'test-uuid-123', 'nameCaller': 'Alice'},
      ];

      final calls = await notificationService.getActiveCalls();
      expect(calls, hasLength(1));
      expect(calls.isNotEmpty, isTrue); // 这是 CallManager 中的去重判断条件
    });

    test('dedup logic: alreadyShowing should be true when calls exist', () async {
      mockActiveCalls = [
        {'id': 'bg-push-uuid', 'nameCaller': 'Bob'},
      ];

      final activeCalls = await notificationService.getActiveCalls();
      final alreadyShowing = activeCalls.isNotEmpty;

      expect(alreadyShowing, isTrue);
    });

    test('dedup logic: alreadyShowing should be false after endAllCalls', () async {
      mockActiveCalls = [
        {'id': 'bg-push-uuid', 'nameCaller': 'Bob'},
      ];

      await notificationService.endAllCalls();

      final activeCalls = await notificationService.getActiveCalls();
      final alreadyShowing = activeCalls.isNotEmpty;

      expect(alreadyShowing, isFalse);
    });

    test('should handle null return from platform channel', () async {
      // activeCalls() 中已经处理了 null 返回值
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_callkit_incoming'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'activeCalls') {
            return null; // 模拟 platform channel 返回 null
          }
          return null;
        },
      );

      final calls = await notificationService.getActiveCalls();
      expect(calls, isEmpty);
    });
  });
}
