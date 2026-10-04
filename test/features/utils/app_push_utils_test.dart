import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart'
    show FirebasePushService, PushDedupStore;
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/features/utils/app_push_utils.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/device_login_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _notificationChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);
const _badgeChannel = MethodChannel('flutter_new_badger');

class _Firebase extends FirebasePlatform {
  final _app = FirebaseAppPlatform(
    '[DEFAULT]',
    const FirebaseOptions(
      apiKey: 'test-key',
      appId: 'test-app',
      messagingSenderId: 'test-sender',
      projectId: 'test-project',
    ),
  );

  @override
  List<FirebaseAppPlatform> get apps => [_app];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async => _app;

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) => _app;
}

class _Messaging extends FirebaseMessagingPlatform {
  int permissionRequests = 0;
  int initialMessageRequests = 0;
  int backgroundRegistrations = 0;
  int notificationSettingsRequests = 0;
  AuthorizationStatus currentAuthorizationStatus =
      AuthorizationStatus.authorized;
  AuthorizationStatus requestedAuthorizationStatus =
      AuthorizationStatus.authorized;
  final presentations = <Map<String, bool>>[];

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {
    backgroundRegistrations++;
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    initialMessageRequests++;
    return null;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {
    presentations.add({'alert': alert, 'badge': badge, 'sound': sound});
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    permissionRequests++;
    return NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      authorizationStatus: requestedAuthorizationStatus,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    notificationSettingsRequests++;
    return NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      authorizationStatus: currentAuthorizationStatus,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messaging = _Messaging();
  final notifications = <MethodCall>[];
  final badgeCalls = <MethodCall>[];
  final unreadAtShow = <int>[];
  int? badge;

  void installChannels() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notificationChannel,
      (call) async {
        notifications.add(call);
        if (call.method == 'show') {
          unreadAtShow.add(
            app.globalProviderContainer.read(unreadCountProvider),
          );
        }
        return call.method == 'initialize' ? true : null;
      },
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(_badgeChannel, (
      call,
    ) async {
      badgeCalls.add(call);
      if (call.method == 'getBadge') return badge;
      if (call.method == 'setBadge') {
        badge = (call.arguments as Map)['count'] as int;
      }
      if (call.method == 'removeBadge') badge = null;
      return null;
    });
  }

  setUpAll(() async {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    FirebasePlatform.instance = _Firebase();
    FirebaseMessagingPlatform.instance = messaging;
    installChannels();
    await AppPushUtils.init();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer();
    notifications.clear();
    badgeCalls.clear();
    unreadAtShow.clear();
    badge = null;
    installChannels();
  });

  tearDown(() {
    app.globalProviderContainer.dispose();
  });
  tearDownAll(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _notificationChannel,
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _badgeChannel,
      null,
    );
    FirebasePushService.hostFallbackNotificationTapHandler = null;
  });

  Future<void> deliver(WidgetTester tester, RemoteMessage message) async {
    // Stream listeners and mocked platform futures complete in the real event
    // loop; no FCM/native service or wall-clock notification delay is involved.
    await tester.runAsync(() async {
      FirebaseMessagingPlatform.onMessage.add(message);
      await Future<void>.delayed(Duration.zero);
    });
  }

  RemoteMessage message(String? id, {Map<String, dynamic> data = const {}}) =>
      RemoteMessage(
        messageId: id,
        data: data,
        notification: const RemoteNotification(title: 'Title', body: 'Body'),
      );

  List<MethodCall> shows() =>
      notifications.where((c) => c.method == 'show').toList();

  testWidgets('repeated initialization keeps one foreground listener', (
    tester,
  ) async {
    await AppPushUtils.init();
    await AppPushUtils.init();
    expect(messaging.permissionRequests, 1);
    expect(messaging.initialMessageRequests, 1);
    expect(messaging.backgroundRegistrations, 1);
    expect(messaging.presentations, [
      {'alert': false, 'badge': true, 'sound': false},
    ]);
    expect(notifications, isEmpty);

    // A message without a dedup key exposes a duplicated stream subscription.
    await deliver(tester, message(null));
    expect(shows(), hasLength(1));
    expect(app.globalProviderContainer.read(unreadCountProvider), 1);
    expect(badge, 1);
  });

  testWidgets('duplicate foreground delivery counts and displays only once', (
    tester,
  ) async {
    final incoming = message('duplicate', data: {'type': 'transfer'});
    await deliver(tester, incoming);
    await deliver(tester, incoming);

    expect(app.globalProviderContainer.read(unreadCountProvider), 1);
    expect(badge, 1);
    expect(badgeCalls.where((c) => c.method == 'getBadge'), hasLength(1));
    expect(shows(), hasLength(1));
    expect(unreadAtShow, [1]);
    final payload = shows().single.arguments as Map;
    expect(payload['id'], PushDedupStore.notificationIdForKey('duplicate'));
    expect(payload['title'], 'Title');
    expect(payload['body'], 'Body');
    expect(jsonDecode(payload['payload'] as String), {'type': 'transfer'});
  });

  testWidgets(
    'distinct messages each increase unread and keep distinct notifications',
    (tester) async {
      await deliver(tester, message('first'));
      await deliver(tester, message('second'));
      expect(app.globalProviderContainer.read(unreadCountProvider), 2);
      expect(badge, 2);
      expect(unreadAtShow, [1, 2]);
      expect(
        shows().map((c) => (c.arguments as Map)['id']).toSet(),
        hasLength(2),
      );
    },
  );

  testWidgets(
    'silent foreground delivery increases unread without a notification',
    (tester) async {
      final incoming = message('silent', data: {'type': 'normal_followed'});
      await deliver(tester, incoming);
      await deliver(tester, incoming);
      expect(app.globalProviderContainer.read(unreadCountProvider), 1);
      expect(badge, 1);
      expect(shows(), isEmpty);
    },
  );

  testWidgets(
    'chat and call foreground pushes leave host unread and badge untouched',
    (tester) async {
      await deliver(
        tester,
        message('chat', data: {'room_id': '!room:example.org'}),
      );
      await deliver(tester, message('call', data: {'type': 'm.call.invite'}));
      expect(app.globalProviderContainer.read(unreadCountProvider), 0);
      expect(badgeCalls, isEmpty);
      expect(shows(), isEmpty);
    },
  );

  testWidgets(
    'data-only host pushes do not count unread or show notifications',
    (tester) async {
      await deliver(
        tester,
        const RemoteMessage(messageId: 'data-only', data: {'type': 'transfer'}),
      );
      expect(app.globalProviderContainer.read(unreadCountProvider), 0);
      expect(badgeCalls, isEmpty);
      expect(shows(), isEmpty);
    },
  );

  testWidgets('malformed local payloads are tolerated by the host fallback', (
    tester,
  ) async {
    final fallback = FirebasePushService.hostFallbackNotificationTapHandler;
    expect(fallback, isNotNull);
    for (final payload in ['', 'not-json', '[1,2]', '42', '{"type":{}}']) {
      expect(() => fallback!(payload), returnsNormally);
    }
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(app.globalProviderContainer.read(unreadCountProvider), 0);
    expect(shows(), isEmpty);
  });

  testWidgets(
    'clearBadgeOnly preserves delivered notifications and host unread',
    (tester) async {
      await deliver(tester, message('preserve'));
      AppPushUtils.clearBadgeOnly();
      await tester.pump();
      expect(badge, isNull);
      expect(app.globalProviderContainer.read(unreadCountProvider), 1);
      expect(notifications.where((c) => c.method == 'cancelAll'), isEmpty);
    },
  );

  testWidgets('removeBadgeCount also cancels local notifications', (
    tester,
  ) async {
    await deliver(tester, message('clear'));
    AppPushUtils.removeBadgeCount();
    await tester.pump();
    expect(badge, isNull);
    expect(notifications.where((c) => c.method == 'cancelAll'), hasLength(1));
  });

  testWidgets('background host pushes update badge without touching Riverpod', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await firebaseMessagingBackgroundEntrypoint(
        message('background-transfer', data: {'type': 'transfer'}),
      );
      await Future<void>.delayed(Duration.zero);
    });

    expect(app.globalProviderContainer.read(unreadCountProvider), 0);
    expect(badge, 1);
    expect(badgeCalls.map((call) => call.method), ['getBadge', 'setBadge']);
    expect(notifications, isEmpty);
  });

  testWidgets('background device login shows a stable local notification', (
    tester,
  ) async {
    const incoming = RemoteMessage(
      messageId: 'background-device-login',
      data: {
        'type': 'device_login',
        'device_id': 'other-device',
        'device_brand': 'N42',
        'device_os': 'Android',
      },
    );
    await tester.runAsync(() async {
      await firebaseMessagingBackgroundEntrypoint(incoming);
      await firebaseMessagingBackgroundEntrypoint(incoming);
      await Future<void>.delayed(Duration.zero);
    });

    final shownCalls = notifications.where((call) => call.method == 'show');
    expect(shownCalls, hasLength(1));
    final shown = shownCalls.single;
    final arguments = shown.arguments as Map;
    expect(
      arguments['id'],
      PushDedupStore.notificationIdForKey(incoming.messageId!),
    );
    expect(arguments['title'], 'New Device Login');
    expect(arguments['body'], 'Your account was logged in on N42 Android');
    expect(jsonDecode(arguments['payload'] as String), incoming.data);
    expect(app.globalProviderContainer.read(unreadCountProvider), 0);
  });

  testWidgets('permission check does not prompt an authorized user', (
    tester,
  ) async {
    final permissionRequests = messaging.permissionRequests;
    final settingsRequests = messaging.notificationSettingsRequests;
    await tester.runAsync(AppPushUtils.checkAndPromptPermission);

    expect(messaging.notificationSettingsRequests, settingsRequests + 1);
    expect(messaging.permissionRequests, permissionRequests);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'denied iOS permission retries once and waits for a host context',
    (tester) async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      messaging.currentAuthorizationStatus = AuthorizationStatus.denied;
      messaging.requestedAuthorizationStatus = AuthorizationStatus.denied;
      final permissionRequests = messaging.permissionRequests;

      try {
        await tester.runAsync(AppPushUtils.checkAndPromptPermission);
        expect(messaging.permissionRequests, permissionRequests + 1);
        expect(find.byType(AlertDialog), findsNothing);
        expect(app.globalProviderContainer.read(unreadCountProvider), 0);
      } finally {
        debugDefaultTargetPlatformOverride = previousPlatform;
        messaging.currentAuthorizationStatus = AuthorizationStatus.authorized;
        messaging.requestedAuthorizationStatus = AuthorizationStatus.authorized;
      }
    },
  );

  testWidgets('foreground device login from this device is ignored', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({'n42_device_id': 'current'});
    final events = <EventPublic>[];
    final subscription = eventBus.on<EventPublic>().listen(events.add);
    addTearDown(subscription.cancel);

    await deliver(
      tester,
      message(
        'device-login-self',
        data: {'type': 'device_login', 'device_id': 'current'},
      ),
    );

    expect(events, isEmpty);
    expect(shows(), isEmpty);
  });

  testWidgets('foreground device login from another device emits device info', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({'n42_device_id': 'current'});
    final events = <EventPublic>[];
    final subscription = eventBus.on<EventPublic>().listen(events.add);
    addTearDown(subscription.cancel);

    await deliver(
      tester,
      message(
        'device-login-other',
        data: {
          'type': 'device_login',
          'device_id': 'other',
          'device_brand': 'N42',
          'device_model': 'Phone',
          'device_os': 'iOS',
          'login_time': '2026-10-02T12:00:00Z',
        },
      ),
    );

    expect(events, hasLength(1));
    expect(events.single.type, EventPublicType.deviceLoginDetected);
    expect(
      events.single.param,
      isA<DeviceLoginInfo>()
          .having((info) => info.deviceId, 'device id', 'other')
          .having((info) => info.displayName, 'display name', 'N42 iOS')
          .having(
            (info) => info.loginTime,
            'login time',
            '2026-10-02T12:00:00Z',
          ),
    );
    expect(shows(), isEmpty);
    expect(app.globalProviderContainer.read(unreadCountProvider), 0);
  });
}
