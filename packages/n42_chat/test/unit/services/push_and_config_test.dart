import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/core/notifications/firebase_push_service.dart';
import 'package:n42_chat/src/core/notifications/push_notification_service.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMatrixClient extends Mock implements matrix.Client {}

/// 测试 FirebasePushService 的推送密钥选择和通知配置：
/// 1. APNs Token 存储与 getter
/// 2. NotificationConfig 的设置 / 获取 / 默认值
/// 3. ShareKeysWith.all 枚举值存在性验证
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_callkit_incoming'),
          (MethodCall methodCall) async {
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

  // ────────────────────────────────────────────
  // 1. APNs Token getter
  // ────────────────────────────────────────────
  group('FirebasePushService iOS apnsToken getter', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test('apnsToken should default to null when service is first created', () {
      // _apnsToken 初始为 null，getter 应返回 null
      expect(service.apnsToken, isNull);
    });

    test('fcmToken should also default to null', () {
      // 确认 FCM token 也是 null（与 APNs token 行为对称）
      expect(service.fcmToken, isNull);
    });

    test('apnsToken getter should be accessible on the service instance', () {
      // 验证 apnsToken 是公开可访问的 getter（类型为 String?）
      final String? token = service.apnsToken;
      expect(token, isNull);
    });
  });

  // ────────────────────────────────────────────
  // 2. NotificationConfig 设置与默认值
  // ────────────────────────────────────────────
  group('FirebasePushService notification config', () {
    late FirebasePushService service;

    setUp(() {
      service = FirebasePushService(MockMatrixClient());
    });

    tearDown(() async {
      await service.dispose();
    });

    test(
      'setNotificationConfig should accept a custom config without errors',
      () {
        // 设置一个自定义配置，确保不抛出异常
        const config = NotificationConfig(
          enabled: false,
          showPreview: false,
          playSound: false,
          vibrate: false,
          doNotDisturb: true,
          dndStartTime: TimeOfDay(hour: 22, minute: 0),
          dndEndTime: TimeOfDay(hour: 7, minute: 0),
        );

        expect(() => service.setNotificationConfig(config), returnsNormally);
      },
    );

    test('setNotificationConfig can be called multiple times', () {
      // 多次设置配置不应出错
      service.setNotificationConfig(const NotificationConfig(enabled: false));
      service.setNotificationConfig(const NotificationConfig(enabled: true));
      service.setNotificationConfig(
        const NotificationConfig(showPreview: false, playSound: false),
      );

      // 不抛异常即通过
      expect(true, isTrue);
    });

    test('android channel id should vary with sound and vibration config', () {
      expect(
        FirebasePushService.androidMessageChannelIdForTest(
          const NotificationConfig(),
        ),
        'n42_chat_messages.default',
      );
      expect(
        FirebasePushService.androidMessageChannelIdForTest(
          const NotificationConfig(vibrate: false),
        ),
        'n42_chat_messages.sound_only',
      );
      expect(
        FirebasePushService.androidMessageChannelIdForTest(
          const NotificationConfig(playSound: false),
        ),
        'n42_chat_messages.vibrate_only',
      );
      expect(
        FirebasePushService.androidMessageChannelIdForTest(
          const NotificationConfig(playSound: false, vibrate: false),
        ),
        'n42_chat_messages.silent',
      );
    });

    test(
      'should load persisted notification config from shared preferences',
      () async {
        SharedPreferences.setMockInitialValues({
          'n42_chat_notification_settings':
              '{"enabled":false,"showPreview":false,"playSound":false,"vibrate":true,"doNotDisturb":true,"doNotDisturbStart":"22:30","doNotDisturbEnd":"07:15","privacyMode":"hidden"}',
        });

        final config =
            await FirebasePushService.loadPersistedNotificationConfigForTest();

        expect(config.enabled, isFalse);
        expect(config.showPreview, isFalse);
        expect(config.playSound, isFalse);
        expect(config.vibrate, isTrue);
        expect(config.doNotDisturb, isTrue);
        expect(config.dndStartTime, const TimeOfDay(hour: 22, minute: 30));
        expect(config.dndEndTime, const TimeOfDay(hour: 7, minute: 15));
        expect(config.privacyMode, NotificationPrivacyMode.hidden);
      },
    );
  });

  group('NotificationConfig default values', () {
    test('default config should have all features enabled', () {
      const config = NotificationConfig();

      expect(config.enabled, isTrue);
      expect(config.showPreview, isTrue);
      expect(config.playSound, isTrue);
      expect(config.vibrate, isTrue);
      expect(config.doNotDisturb, isFalse);
      expect(config.dndStartTime, isNull);
      expect(config.dndEndTime, isNull);
      expect(config.privacyMode, NotificationPrivacyMode.full);
    });

    test('default config should not be in do-not-disturb period', () {
      const config = NotificationConfig();
      expect(config.isInDoNotDisturbPeriod(), isFalse);
    });

    test('config with doNotDisturb=true but no times should not be in DND', () {
      const config = NotificationConfig(doNotDisturb: true);
      // 缺少 dndStartTime/dndEndTime 时，isInDoNotDisturbPeriod 应返回 false
      expect(config.isInDoNotDisturbPeriod(), isFalse);
    });

    test('copyWith should override only specified fields', () {
      const original = NotificationConfig();
      final modified = original.copyWith(enabled: false, playSound: false);

      expect(modified.enabled, isFalse);
      expect(modified.showPreview, isTrue); // 未修改
      expect(modified.playSound, isFalse);
      expect(modified.vibrate, isTrue); // 未修改
      expect(modified.doNotDisturb, isFalse); // 未修改
    });

    test('copyWith with no arguments should return equivalent config', () {
      const original = NotificationConfig(
        enabled: false,
        showPreview: false,
        playSound: false,
        vibrate: false,
        doNotDisturb: true,
      );
      final copied = original.copyWith();

      expect(copied.enabled, equals(original.enabled));
      expect(copied.showPreview, equals(original.showPreview));
      expect(copied.playSound, equals(original.playSound));
      expect(copied.vibrate, equals(original.vibrate));
      expect(copied.doNotDisturb, equals(original.doNotDisturb));
    });

    test('toJson should serialize all fields correctly', () {
      const config = NotificationConfig(
        enabled: true,
        showPreview: false,
        playSound: true,
        vibrate: false,
        doNotDisturb: true,
        dndStartTime: TimeOfDay(hour: 22, minute: 30),
        dndEndTime: TimeOfDay(hour: 7, minute: 0),
        privacyMode: NotificationPrivacyMode.senderOnly,
      );

      final json = config.toJson();

      expect(json['enabled'], isTrue);
      expect(json['showPreview'], isFalse);
      expect(json['playSound'], isTrue);
      expect(json['vibrate'], isFalse);
      expect(json['doNotDisturb'], isTrue);
      expect(json['dndStartTime'], equals('22:30'));
      expect(json['dndEndTime'], equals('7:0'));
      expect(json['privacyMode'], equals('senderOnly'));
    });

    test('toJson with null DND times should produce null values', () {
      const config = NotificationConfig();
      final json = config.toJson();

      expect(json['dndStartTime'], isNull);
      expect(json['dndEndTime'], isNull);
    });

    test('fromJson should deserialize all fields correctly', () {
      final json = <String, dynamic>{
        'enabled': false,
        'showPreview': false,
        'playSound': true,
        'vibrate': false,
        'doNotDisturb': true,
        'dndStartTime': '23:15',
        'dndEndTime': '6:45',
        'privacyMode': 'hidden',
      };

      final config = NotificationConfig.fromJson(json);

      expect(config.enabled, isFalse);
      expect(config.showPreview, isFalse);
      expect(config.playSound, isTrue);
      expect(config.vibrate, isFalse);
      expect(config.doNotDisturb, isTrue);
      expect(
        config.dndStartTime,
        equals(const TimeOfDay(hour: 23, minute: 15)),
      );
      expect(config.dndEndTime, equals(const TimeOfDay(hour: 6, minute: 45)));
      expect(config.privacyMode, NotificationPrivacyMode.hidden);
    });

    test('fromJson with missing keys should use defaults', () {
      final config = NotificationConfig.fromJson(<String, dynamic>{});

      expect(config.enabled, isTrue);
      expect(config.showPreview, isTrue);
      expect(config.playSound, isTrue);
      expect(config.vibrate, isTrue);
      expect(config.doNotDisturb, isFalse);
      expect(config.dndStartTime, isNull);
      expect(config.dndEndTime, isNull);
      expect(config.privacyMode, NotificationPrivacyMode.full);
    });

    test('fromJson with invalid time format should return null for times', () {
      final config = NotificationConfig.fromJson(<String, dynamic>{
        'dndStartTime': 'invalid',
        'dndEndTime': 'also-invalid',
      });

      // 无效格式 split(':') 长度不为 2 时应返回 null
      // "invalid" splits to 1 part → null
      // "also-invalid" splits to 1 part → null
      expect(config.dndStartTime, isNull);
      expect(config.dndEndTime, isNull);
    });

    test('roundtrip toJson → fromJson should preserve values', () {
      const original = NotificationConfig(
        enabled: false,
        showPreview: true,
        playSound: false,
        vibrate: true,
        doNotDisturb: true,
        dndStartTime: TimeOfDay(hour: 1, minute: 30),
        dndEndTime: TimeOfDay(hour: 8, minute: 0),
        privacyMode: NotificationPrivacyMode.hidden,
      );

      final restored = NotificationConfig.fromJson(original.toJson());

      expect(restored.enabled, equals(original.enabled));
      expect(restored.showPreview, equals(original.showPreview));
      expect(restored.playSound, equals(original.playSound));
      expect(restored.vibrate, equals(original.vibrate));
      expect(restored.doNotDisturb, equals(original.doNotDisturb));
      expect(restored.dndStartTime, equals(original.dndStartTime));
      expect(restored.dndEndTime, equals(original.dndEndTime));
      expect(restored.privacyMode, equals(original.privacyMode));
    });

    test('presentMessage hides message body in sender-only mode', () {
      const config = NotificationConfig(
        privacyMode: NotificationPrivacyMode.senderOnly,
      );

      final presentation = config.presentMessage(title: 'Alice', body: 'hello');

      expect(presentation.title, 'Alice');
      expect(presentation.body, 'You have a new message');
    });

    test('presentMessage hides sender and body in hidden mode', () {
      const config = NotificationConfig(
        privacyMode: NotificationPrivacyMode.hidden,
      );

      final presentation = config.presentMessage(title: 'Alice', body: 'hello');

      expect(presentation.title, 'N42 Chat');
      expect(presentation.body, 'You have a new message');
    });

    test('native foreground preview is disabled when preview is hidden', () {
      const config = NotificationConfig(
        showPreview: false,
        privacyMode: NotificationPrivacyMode.full,
      );

      expect(config.allowsNativeForegroundPreview, isFalse);
    });

    test('native foreground preview is disabled in sender-only mode', () {
      const config = NotificationConfig(
        privacyMode: NotificationPrivacyMode.senderOnly,
      );

      expect(config.allowsNativeForegroundPreview, isFalse);
    });
  });

  // ────────────────────────────────────────────
  // 3. ShareKeysWith.all 枚举验证
  // ────────────────────────────────────────────
  group('ShareKeysWith.all enum verification', () {
    test('ShareKeysWith.all should be a valid enum value', () {
      // 验证 matrix SDK 中 ShareKeysWith.all 枚举值可访问
      const value = matrix.ShareKeysWith.all;
      expect(value, isNotNull);
      expect(value, equals(matrix.ShareKeysWith.all));
    });

    test('ShareKeysWith should contain expected values', () {
      // 验证枚举中存在预期的值
      const values = matrix.ShareKeysWith.values;
      expect(values, contains(matrix.ShareKeysWith.all));
      expect(values, isNotEmpty);
    });

    test('ShareKeysWith.all should have correct name', () {
      const value = matrix.ShareKeysWith.all;
      expect(value.name, equals('all'));
    });
  });
}
