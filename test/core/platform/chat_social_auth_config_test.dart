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

    test('empty native + empty env yields empty string slots', () {
      final config = ChatSocialAuthConfig.resolve(
        nativeConfig: const SocialAuthNativeConfig(),
      );
      expect(config.googleClientId, '');
      expect(config.googleServerClientId, '');
      expect(config.twitterApiKey, '');
      expect(config.twitterApiSecret, '');
      expect(config.weChatAppId, '');
      expect(config.googleConfigured, isFalse);
      expect(config.twitterConfigured, isFalse);
      expect(config.weChatConfigured, isFalse);
    });
  });

  // ─── Predicate contracts ──────────────────────────────────────────
  // The *Configured getters feed directly into N42ChatConfig.enableXLogin
  // flags. Each predicate gates a distinct SDK behaviour, so the truth
  // tables below pin the contract independently of the .resolve() input.

  group('googleConfigured', () {
    ChatSocialAuthConfig makeGoogle({String client = '', String server = ''}) {
      return ChatSocialAuthConfig(
        googleClientId: client,
        googleServerClientId: server,
        twitterApiKey: '',
        twitterApiSecret: '',
        twitterRedirectUri: '',
        weChatAppId: '',
        weChatUniversalLink: '',
      );
    }

    test('true when only clientId is set', () {
      expect(makeGoogle(client: 'abc').googleConfigured, isTrue);
    });

    test('true when only serverClientId is set', () {
      expect(makeGoogle(server: 'srv').googleConfigured, isTrue);
    });

    test('true when both are set', () {
      expect(makeGoogle(client: 'a', server: 'b').googleConfigured, isTrue);
    });

    test('false when neither is set', () {
      expect(makeGoogle().googleConfigured, isFalse);
    });
  });

  group('twitterConfigured', () {
    ChatSocialAuthConfig makeTw({String key = '', String secret = ''}) {
      return ChatSocialAuthConfig(
        googleClientId: '',
        googleServerClientId: '',
        twitterApiKey: key,
        twitterApiSecret: secret,
        twitterRedirectUri: '',
        weChatAppId: '',
        weChatUniversalLink: '',
      );
    }

    test('true when both apiKey AND apiSecret are set', () {
      expect(makeTw(key: 'k', secret: 's').twitterConfigured, isTrue);
    });

    test('false when only apiKey is set', () {
      expect(makeTw(key: 'k').twitterConfigured, isFalse);
    });

    test('false when only apiSecret is set', () {
      // Same as the existing "does not enable partial twitter config"
      // but covers the OTHER half of the partial — apiSecret without
      // apiKey would crash the Twitter OAuth flow exactly the same way.
      expect(makeTw(secret: 's').twitterConfigured, isFalse);
    });

    test('false when neither is set', () {
      expect(makeTw().twitterConfigured, isFalse);
    });
  });

  group('weChatConfigured', () {
    test('true when appId is set (universalLink not required)', () {
      const cfg = ChatSocialAuthConfig(
        googleClientId: '',
        googleServerClientId: '',
        twitterApiKey: '',
        twitterApiSecret: '',
        twitterRedirectUri: '',
        weChatAppId: 'wx123',
        weChatUniversalLink: '',
      );
      expect(cfg.weChatConfigured, isTrue);
    });

    test('false when appId is empty', () {
      const cfg = ChatSocialAuthConfig(
        googleClientId: '',
        googleServerClientId: '',
        twitterApiKey: '',
        twitterApiSecret: '',
        twitterRedirectUri: '',
        weChatAppId: '',
        weChatUniversalLink: 'https://x',
      );
      expect(cfg.weChatConfigured, isFalse);
    });
  });

  // ─── Platform support gates ──────────────────────────────────────
  // These directly drive the N42ChatConfig.enableGoogleLogin /
  // enableAppleLogin flags handed to n42_chat at init.

  group('supportsGoogleForCurrentPlatform', () {
    const configured = ChatSocialAuthConfig(
      googleClientId: 'abc',
      googleServerClientId: '',
      twitterApiKey: '',
      twitterApiSecret: '',
      twitterRedirectUri: '',
      weChatAppId: '',
      weChatUniversalLink: '',
    );
    const unconfigured = ChatSocialAuthConfig(
      googleClientId: '',
      googleServerClientId: '',
      twitterApiKey: '',
      twitterApiSecret: '',
      twitterRedirectUri: '',
      weChatAppId: '',
      weChatUniversalLink: '',
    );

    test('false when not configured, regardless of platform', () {
      expect(
        unconfigured.supportsGoogleForCurrentPlatform(
          isAndroid: true, isIOS: true, isMacOS: true,
        ),
        isFalse,
      );
    });

    test('true on Android', () {
      expect(
        configured.supportsGoogleForCurrentPlatform(
          isAndroid: true, isIOS: false, isMacOS: false,
        ),
        isTrue,
      );
    });

    test('true on macOS', () {
      expect(
        configured.supportsGoogleForCurrentPlatform(
          isAndroid: false, isIOS: false, isMacOS: true,
        ),
        isTrue,
      );
    });

    test('false on web / windows / linux when configured', () {
      // All three platform flags false → not on Android/iOS/macOS.
      expect(
        configured.supportsGoogleForCurrentPlatform(
          isAndroid: false, isIOS: false, isMacOS: false,
        ),
        isFalse,
      );
    });
  });

  group('supportsAppleForCurrentPlatform', () {
    const cfg = ChatSocialAuthConfig(
      googleClientId: '',
      googleServerClientId: '',
      twitterApiKey: '',
      twitterApiSecret: '',
      twitterRedirectUri: '',
      weChatAppId: '',
      weChatUniversalLink: '',
    );

    test('true on iOS', () {
      expect(
        cfg.supportsAppleForCurrentPlatform(isIOS: true, isMacOS: false),
        isTrue,
      );
    });

    test('true on macOS', () {
      expect(
        cfg.supportsAppleForCurrentPlatform(isIOS: false, isMacOS: true),
        isTrue,
      );
    });

    test('false on android / web / others', () {
      expect(
        cfg.supportsAppleForCurrentPlatform(isIOS: false, isMacOS: false),
        isFalse,
      );
    });
  });

  // ─── Diagnostics output shape ────────────────────────────────────

  group('diagnostics', () {
    const emptyCfg = ChatSocialAuthConfig(
      googleClientId: '',
      googleServerClientId: '',
      twitterApiKey: '',
      twitterApiSecret: '',
      twitterRedirectUri: '',
      weChatAppId: '',
      weChatUniversalLink: '',
    );

    test('produces exactly 5 lines (one per provider)', () {
      final lines = emptyCfg.diagnostics(
        isAndroid: false, isIOS: false, isMacOS: false,
      );
      expect(lines.length, 5);
    });

    test('every line carries the [ChatSocialAuth] prefix', () {
      final lines = emptyCfg.diagnostics(
        isAndroid: false, isIOS: false, isMacOS: false,
      );
      for (final line in lines) {
        expect(line, startsWith('[ChatSocialAuth] '));
      }
    });

    test('Facebook line is enabled only on Android', () {
      expect(
        emptyCfg
            .diagnostics(isAndroid: true, isIOS: false, isMacOS: false)
            .any((l) => l.contains('Facebook: enabled')),
        isTrue,
      );
      expect(
        emptyCfg
            .diagnostics(isAndroid: false, isIOS: true, isMacOS: false)
            .any((l) => l.contains('Facebook: disabled')),
        isTrue,
      );
      expect(
        emptyCfg
            .diagnostics(isAndroid: false, isIOS: false, isMacOS: true)
            .any((l) => l.contains('Facebook: disabled')),
        isTrue,
      );
    });

    test('Apple line follows supportsAppleForCurrentPlatform', () {
      // iOS / macOS → enabled, anything else → disabled.
      expect(
        emptyCfg
            .diagnostics(isAndroid: false, isIOS: true, isMacOS: false)
            .any((l) => l.contains('Apple: enabled')),
        isTrue,
      );
      expect(
        emptyCfg
            .diagnostics(isAndroid: true, isIOS: false, isMacOS: false)
            .any((l) => l.contains('Apple: disabled')),
        isTrue,
      );
    });
  });
}
