import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/app_push_utils.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:n42_wallet/shared/utils/push_route_registry.dart';

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
  _Messaging(this.initialMessage);

  final RemoteMessage initialMessage;
  int initialMessageRequests = 0;

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {}

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    initialMessageRequests++;
    return initialMessage;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {}

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
  }) async => const NotificationSettings(
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.disabled,
    authorizationStatus: AuthorizationStatus.authorized,
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

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'routes a terminated-app notification from getInitialMessage without an opened-app event',
    (tester) async {
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (call) async => call.method == 'initialize' ? true : null,
      );

      final incoming = RemoteMessage(
        messageId: 'terminated-tap',
        data: const {
          'type': 'cold_start_test',
          'payload': 'from-initial-message',
        },
      );
      final messaging = _Messaging(incoming);
      FirebasePlatform.instance = _Firebase();
      FirebaseMessagingPlatform.instance = messaging;
      AppGlobals.userInfo = UserInfo(uuid: 'test-user');
      final handled = <Map<String, dynamic>>[];
      PushRouteRegistry.register(
        'cold_start_test',
        (_, data) => handled.add(data),
      );
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: AppGlobals.navigatorKey,
          home: const Scaffold(body: Text('home')),
        ),
      );

      await tester.runAsync(AppPushUtils.init);
      await tester.pump();

      expect(messaging.initialMessageRequests, 1);
      expect(handled, [incoming.data]);
    },
  );
}
