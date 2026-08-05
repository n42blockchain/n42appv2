import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/push_route_wiring.dart';
import 'package:n42_wallet/shared/utils/push_route_registry.dart';

void main() {
  tearDown(PushRouteRegistry.clear);

  group('PushRouteRegistry', () {
    test('register/resolve：命中已注册类型', () {
      var called = 0;
      PushRouteRegistry.register('foo', (_, _) => called++);
      final handler = PushRouteRegistry.resolve('foo');
      expect(handler, isNotNull);
      handler!(FakeContext(), const {});
      expect(called, 1);
    });

    test('resolve：未注册类型与非字符串类型返回 null', () {
      expect(PushRouteRegistry.resolve('unknown'), isNull);
      expect(PushRouteRegistry.resolve(100), isNull);
      expect(PushRouteRegistry.resolve(null), isNull);
    });

    test('同 type 重复注册以后者为准', () {
      var winner = '';
      PushRouteRegistry.register('dup', (_, _) => winner = 'first');
      PushRouteRegistry.register('dup', (_, _) => winner = 'second');
      PushRouteRegistry.resolve('dup')!(FakeContext(), const {});
      expect(winner, 'second');
    });
  });

  group('registerHostPushRoutes（composition root 接线）', () {
    test('注册了全部宿主 feature 页面路由类型', () {
      registerHostPushRoutes();
      const expected = {
        'transfer',
        'normal_transaction_failed',
        'tell_friends',
        'Tell Friends #1_normal',
        'Tell Friends #2_normal',
        'AboutSettings_normal',
        'SettingsProfile_normal',
      };
      expect(PushRouteRegistry.registeredTypes, containsAll(expected));
    });
  });
}

/// resolve/dispatch 测试不真正导航，仅需一个占位 context。
class FakeContext extends Fake implements BuildContext {}
