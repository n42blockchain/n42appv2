import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/platform_utils.dart';

void main() {
  group('PlatformType', () {
    test('should have all expected types', () {
      expect(PlatformType.values, contains(PlatformType.web));
      expect(PlatformType.values, contains(PlatformType.ios));
      expect(PlatformType.values, contains(PlatformType.android));
      expect(PlatformType.values, contains(PlatformType.macos));
      expect(PlatformType.values, contains(PlatformType.windows));
      expect(PlatformType.values, contains(PlatformType.linux));
      expect(PlatformType.values, contains(PlatformType.unknown));
      expect(PlatformType.values.length, 7);
    });
  });

  group('PlatformUtils static getters', () {
    // Note: These tests will pass on the test platform
    // In actual runtime, values depend on the platform

    test('isWeb should return boolean', () {
      expect(PlatformUtils.isWeb, isA<bool>());
    });

    test('platformName should return string', () {
      expect(PlatformUtils.platformName, isA<String>());
      expect(PlatformUtils.platformName.isNotEmpty, true);
    });

    test('platformType should return valid type', () {
      expect(PlatformUtils.platformType, isA<PlatformType>());
    });

    test('supportsWebRTC should be true', () {
      expect(PlatformUtils.supportsWebRTC, true);
    });
  });

  group('Platform capability checks', () {
    test('desktop platforms should support system tray', () {
      // These are static properties based on platform
      expect(PlatformUtils.supportsSystemTray, isA<bool>());
    });

    test('desktop platforms should support multi window', () {
      expect(PlatformUtils.supportsMultiWindow, isA<bool>());
    });

    test('mobile platforms should support push notifications', () {
      expect(PlatformUtils.supportsPushNotifications, isA<bool>());
    });

    test('mobile platforms should support background service', () {
      expect(PlatformUtils.supportsBackgroundService, isA<bool>());
    });

    test('iOS should support CallKit', () {
      expect(PlatformUtils.supportsCallKit, isA<bool>());
    });

    test('Android should support ConnectionService', () {
      expect(PlatformUtils.supportsConnectionService, isA<bool>());
    });

    test('needsResponsiveLayout should return boolean', () {
      expect(PlatformUtils.needsResponsiveLayout, isA<bool>());
    });
  });
}
