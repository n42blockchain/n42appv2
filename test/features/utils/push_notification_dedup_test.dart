// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// 宿主侧通知去重 / 本地通知点击路由的回归测试：
// - tryExtractChatRouteFromPayload：本地通知 payload 的 chat/宿主分流
//   （n42_chat 初始化前的聊天通知点击兜底依赖它）
// - PushDedupStore（n42_chat 导出）：宿主前台/后台路径按 FCM messageId
//   去重、device_login 通知 ID 稳定派生的语义契约

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart' show PushDedupStore;
import 'package:n42_wallet/features/utils/chat_push_routing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tryExtractChatRouteFromPayload', () {
    test('chat payload with room_id and event_id routes to chat', () {
      final route = tryExtractChatRouteFromPayload(
        json.encode({'room_id': '!room:m.org', 'event_id': r'$evt'}),
      );

      expect(route, isNotNull);
      expect(route!.roomId, '!room:m.org');
      expect(route.eventId, r'$evt');
    });

    test('chat payload without event_id still routes to chat', () {
      final route = tryExtractChatRouteFromPayload(
        json.encode({'room_id': '!room:m.org'}),
      );

      expect(route, isNotNull);
      expect(route!.roomId, '!room:m.org');
      expect(route.eventId, isNull);
    });

    test('host payloads (transfer / device_login) stay with host', () {
      expect(
        tryExtractChatRouteFromPayload(json.encode({'type': 'transfer'})),
        isNull,
      );
      expect(
        tryExtractChatRouteFromPayload(
          json.encode({'type': 'device_login', 'device_id': 'x'}),
        ),
        isNull,
      );
    });

    test('empty or non-string room_id stays with host', () {
      expect(
        tryExtractChatRouteFromPayload(json.encode({'room_id': ''})),
        isNull,
      );
      expect(
        tryExtractChatRouteFromPayload(json.encode({'room_id': 42})),
        isNull,
      );
    });

    test('malformed payloads are rejected without throwing', () {
      expect(tryExtractChatRouteFromPayload('not-json{{{'), isNull);
      expect(tryExtractChatRouteFromPayload('[1,2,3]'), isNull);
      expect(tryExtractChatRouteFromPayload(''), isNull);
    });
  });

  group('PushDedupStore host-side contract', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('duplicate FCM messageId is only notified once', () async {
      final store = PushDedupStore(prefsKey: 'host.test.keys');

      expect(await store.tryMarkNotified('fcm-msg-1'), isTrue);
      // FCM at-least-once 重发同一条消息 → 跳过。
      expect(await store.tryMarkNotified('fcm-msg-1'), isFalse);
    });

    test('chat event keys and host message keys do not collide', () async {
      final store = PushDedupStore(prefsKey: 'host.test.keys');

      expect(await store.tryMarkNotified(r'$matrix-event-1'), isTrue);
      expect(await store.tryMarkNotified('fcm-msg-1'), isTrue);
    });

    test('device_login notifications get distinct stable ids per event', () {
      final id1 = PushDedupStore.notificationIdForKey('fcm-login-1');
      final id2 = PushDedupStore.notificationIdForKey('fcm-login-2');

      // 不同登录事件各占一条通知（旧实现固定 'device_login'.hashCode，
      // 第二次登录会覆盖第一次的通知）。
      expect(id1, isNot(id2));
      // 同一事件重复展示则幂等覆盖。
      expect(id1, PushDedupStore.notificationIdForKey('fcm-login-1'));
      // Android 通知 ID 必须是 32 位正整数。
      for (final id in [id1, id2]) {
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThanOrEqualTo(0x7FFFFFFF));
      }
    });
  });
}
