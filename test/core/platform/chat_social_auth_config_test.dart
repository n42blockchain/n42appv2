import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/chat_social_auth_config.dart';
import 'package:n42_wallet/core/platform/social_auth_native_config.dart';

void main() {
  group('ChatSocialAuthConfig.resolve', () {
    test('prefers env values over native values', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          googleClientId: 'native-google-client',
          googleServerClientId: 'native-google-server-client',
          twitterApiKey: 'native-twitter-key',
          twitterApiSecret: 'native-twitter-secret',
          twitterRedirectUri: 'native://twitter',
          weChatAppId: 'native-wx',
          weChatUniversalLink: 'https://native.example/app/',
        ),
        envGoogleClientId: 'env-google-client',
        envGoogleServerClientId: 'env-google-server-client',
        envTwitterApiKey: 'env-twitter-key',
        envTwitterApiSecret: 'env-twitter-secret',
        envTwitterRedirectUri: 'n42://auth/twitter',
        envWeChatAppId: 'env-wx',
        envWeChatUniversalLink: 'https://env.example/app/',
      );

      expect(config.googleClientId, 'env-google-client');
      expect(config.googleServerClientId, 'env-google-server-client');
      expect(config.twitterApiKey, 'env-twitter-key');
      expect(config.twitterApiSecret, 'env-twitter-secret');
      expect(config.twitterRedirectUri, 'n42://auth/twitter');
      expect(config.weChatAppId, 'env-wx');
      expect(config.weChatUniversalLink, 'https://env.example/app/');
    });

    test('falls back to native values when env values are empty', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          googleClientId: 'native-google-client',
          googleServerClientId: 'native-google-server-client',
          twitterApiKey: 'native-twitter-key',
          twitterApiSecret: 'native-twitter-secret',
          twitterRedirectUri: 'native://twitter',
          weChatAppId: 'native-wx',
          weChatUniversalLink: 'https://native.example/app/',
        ),
      );

      expect(config.googleClientId, 'native-google-client');
      expect(config.googleServerClientId, 'native-google-server-client');
      expect(config.twitterApiKey, 'native-twitter-key');
      expect(config.twitterApiSecret, 'native-twitter-secret');
      expect(config.twitterRedirectUri, 'native://twitter');
      expect(config.weChatAppId, 'native-wx');
      expect(config.weChatUniversalLink, 'https://native.example/app/');
    });

    test('uses default twitter redirect when both sources are empty', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(),
      );

      expect(config.twitterRedirectUri, 'n42://auth/twitter');
    });

    test('computes provider availability correctly', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          googleServerClientId: 'server-client-id',
          twitterApiKey: 'twitter-key',
          twitterApiSecret: 'twitter-secret',
          weChatAppId: 'wx123',
        ),
      );

      expect(config.googleConfigured, isTrue);
      expect(config.twitterConfigured, isTrue);
      expect(config.weChatConfigured, isTrue);
    });

    test('does not enable partial twitter config', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          twitterApiKey: 'twitter-key',
        ),
      );

      expect(config.twitterConfigured, isFalse);
    });

    test('supports Google on iOS when configured', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          googleServerClientId: 'server-client-id',
        ),
      );

      expect(
        config.supportsGoogleForCurrentPlatform(
          isAndroid: false,
          isIOS: true,
          isMacOS: false,
        ),
        isTrue,
      );
    });

    test('reports human-readable diagnostics', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(
          googleServerClientId: 'server-client-id',
          weChatAppId: 'wx123',
        ),
      );

      final lines = config.diagnostics(
        isAndroid: false,
        isIOS: true,
        isMacOS: false,
      );

      expect(lines, contains('[ChatSocialAuth] Google: enabled'));
      expect(lines, contains('[ChatSocialAuth] Apple: enabled'));
      expect(
        lines,
        contains(
          '[ChatSocialAuth] Twitter: disabled (missing API key / API secret)',
        ),
      );
      expect(lines, contains('[ChatSocialAuth] WeChat: enabled'));
    });
  });
}
