import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/social_auth_native_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('ai.n42.www/app_config');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SocialAuthNativeConfig.fromMap', () {
    test('normalizes empty values and build placeholders', () {
      final config = SocialAuthNativeConfig.fromMap({
        'googleClientId': r' $(N42_CHAT_GOOGLE_CLIENT_ID) ',
        'googleServerClientId': 'server-client-id',
        'twitterApiKey': '',
        'twitterApiSecret': 'null',
        'twitterRedirectUri': 'n42://auth/twitter',
        'weChatAppId': 'wx123',
        'weChatUniversalLink': '   ',
      });

      expect(config.googleClientId, isNull);
      expect(config.googleServerClientId, 'server-client-id');
      expect(config.twitterApiKey, isNull);
      expect(config.twitterApiSecret, isNull);
      expect(config.twitterRedirectUri, 'n42://auth/twitter');
      expect(config.weChatAppId, 'wx123');
      expect(config.weChatUniversalLink, isNull);
    });
  });

  group('SocialAuthNativeConfig.load', () {
    test('loads native values from method channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getSocialAuthConfig') {
              return {
                'googleClientId': 'google-client-id',
                'googleServerClientId': 'google-server-client-id',
                'twitterApiKey': 'twitter-key',
                'twitterApiSecret': 'twitter-secret',
                'twitterRedirectUri': 'n42://auth/twitter',
                'weChatAppId': 'wx123',
                'weChatUniversalLink': 'https://n42.network/app/',
              };
            }
            return null;
          });

      final config = await SocialAuthNativeConfig.load();

      expect(config.googleClientId, 'google-client-id');
      expect(config.googleServerClientId, 'google-server-client-id');
      expect(config.twitterApiKey, 'twitter-key');
      expect(config.twitterApiSecret, 'twitter-secret');
      expect(config.twitterRedirectUri, 'n42://auth/twitter');
      expect(config.weChatAppId, 'wx123');
      expect(config.weChatUniversalLink, 'https://n42.network/app/');
    });

    test('returns empty config when native call fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'unavailable');
          });

      final config = await SocialAuthNativeConfig.load();

      expect(config.googleClientId, isNull);
      expect(config.googleServerClientId, isNull);
      expect(config.twitterApiKey, isNull);
      expect(config.twitterApiSecret, isNull);
      expect(config.twitterRedirectUri, isNull);
      expect(config.weChatAppId, isNull);
      expect(config.weChatUniversalLink, isNull);
    });
  });
}
