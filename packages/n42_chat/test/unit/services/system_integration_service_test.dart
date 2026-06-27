import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/system_integration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('n42.chat/system_integration');
  final List<MethodCall> nativeCalls = <MethodCall>[];
  Object? nativeReturn;

  setUp(() {
    nativeCalls.clear();
    nativeReturn = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      nativeCalls.add(call);
      return nativeReturn;
    });
  });

  // app_badge_plus 的平台通道（用于校验角标兜底）
  const badgeChannel = MethodChannel('app_badge_plus');
  final List<MethodCall> badgeCalls = <MethodCall>[];
  bool badgeSupported = true;

  setUp(() {
    badgeCalls.clear();
    badgeSupported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(badgeChannel, (MethodCall call) async {
      badgeCalls.add(call);
      if (call.method == 'isSupported') return badgeSupported;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(badgeChannel, null);
  });

  group('stableIdForTest（纯函数）', () {
    final svc = SystemIntegrationService();

    test('同输入→同 id 且为正', () {
      expect(svc.stableIdForTest('call'), svc.stableIdForTest('call'));
      expect(svc.stableIdForTest('call'), greaterThan(0));
      expect(svc.stableIdForTest('conv:!room:server'), greaterThan(0));
    });

    test('不同输入→不同 id（无平凡碰撞）', () {
      expect(svc.stableIdForTest('a'), isNot(svc.stableIdForTest('b')));
      expect(
        svc.stableIdForTest('conv:!a:s'),
        isNot(svc.stableIdForTest('conv:!b:s')),
      );
    });

    test('空串也返回正数（永不为 0）', () {
      expect(svc.stableIdForTest(''), 1);
    });
  });

  group('isSupported', () {
    test('原生 handler 确认时返回 true 并转发 capability', () async {
      nativeReturn = true;
      final svc = SystemIntegrationService();
      expect(await svc.isSupported('tray'), isTrue);
      expect(nativeCalls.single.method, 'isSupported');
      expect((nativeCalls.single.arguments as Map)['capability'], 'tray');
    });

    test('未知能力且原生未实现时返回 false', () async {
      nativeReturn = null;
      final svc = SystemIntegrationService();
      expect(await svc.isSupported('totally-unknown'), isFalse);
    });
  });

  group('原生转发 & 优雅降级', () {
    test('updateLiveActivity 原生处理时转发并短路', () async {
      nativeReturn = true;
      final svc = SystemIntegrationService();
      await svc.updateLiveActivity(id: 'call', title: 'In call', body: 'x');
      final call =
          nativeCalls.firstWhere((c) => c.method == 'updateLiveActivity');
      final args = call.arguments as Map;
      expect(args['id'], 'call');
      expect(args['title'], 'In call');
      expect(args['body'], 'x');
    });

    test('endLiveActivity 转发 id', () async {
      nativeReturn = true;
      final svc = SystemIntegrationService();
      await svc.endLiveActivity('call');
      final call =
          nativeCalls.firstWhere((c) => c.method == 'endLiveActivity');
      expect((call.arguments as Map)['id'], 'call');
    });

    test('showConversationBubble 转发 roomId/message', () async {
      nativeReturn = true;
      final svc = SystemIntegrationService();
      await svc.showConversationBubble(
        roomId: '!r:s',
        title: 'Bob',
        message: 'hi',
      );
      final call =
          nativeCalls.firstWhere((c) => c.method == 'showConversationBubble');
      final args = call.arguments as Map;
      expect(args['roomId'], '!r:s');
      expect(args['message'], 'hi');
    });

    test('setDynamicShortcuts 原生处理时转发', () async {
      nativeReturn = true;
      final svc = SystemIntegrationService();
      await svc.setDynamicShortcuts([
        {'type': 'search', 'title': 'Search'},
      ]);
      final call =
          nativeCalls.firstWhere((c) => c.method == 'setDynamicShortcuts');
      expect(call.arguments, isA<Map<dynamic, dynamic>>());
    });

    test('setTrayBadge 原生未实现时经 app_badge_plus 兜底设角标', () async {
      nativeReturn = null; // 原生未处理
      final svc = SystemIntegrationService();
      await svc.setTrayBadge(7);
      // 先查 isSupported，再 updateBadge(7)
      expect(badgeCalls.any((c) => c.method == 'isSupported'), isTrue);
      final upd = badgeCalls.firstWhere((c) => c.method == 'updateBadge');
      expect((upd.arguments as Map)['count'], 7);
    });

    test('setTrayBadge 负数被夹紧为 0（清除角标）', () async {
      nativeReturn = null;
      final svc = SystemIntegrationService();
      await svc.setTrayBadge(-5);
      final upd = badgeCalls.firstWhere((c) => c.method == 'updateBadge');
      expect((upd.arguments as Map)['count'], 0);
    });

    test('isSupported(badge) 反映 app_badge_plus 支持度', () async {
      nativeReturn = null;
      badgeSupported = true;
      final svc = SystemIntegrationService();
      expect(await svc.isSupported('badge'), isTrue);
    });

    test('原生未实现（返回 null）时各方法不抛异常', () async {
      nativeReturn = null;
      final svc = SystemIntegrationService();
      await svc.updateLiveActivity(id: 'call', title: 'In call');
      await svc.endLiveActivity('call');
      await svc.showConversationBubble(roomId: '!r:s', title: 'Bob');
      await svc.setDynamicShortcuts(const []);
      await svc.setTrayBadge(3);
      await svc.flashWindow();
      // 走到此处未抛异常即视为优雅降级成功
      expect(true, isTrue);
    });
  });
}
