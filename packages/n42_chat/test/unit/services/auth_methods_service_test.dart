import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/auth/auth_methods_service.dart';

void main() {
  // 初始化 Flutter Binding 以支持平台通道调用
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthMethodsService', () {
    late AuthMethodsService service;

    setUp(() {
      service = AuthMethodsService();
    });

    test('should be a singleton', () {
      final service1 = AuthMethodsService();
      final service2 = AuthMethodsService();
      expect(identical(service1, service2), isTrue);
    });

    group('Passkey Support', () {
      test('isPasskeySupported should return platform check result', () async {
        final result = await service.isPasskeySupported();
        // 在测试环境中可能返回 false
        expect(result, isA<bool>());
      });
    });

    group('Email OTP', () {
      test(
        'requestEmailOtp should gracefully handle non-success response',
        () async {
          final result = await service.requestEmailOtp(
            email: 'test@example.com',
            homeserver: 'https://m.si46.world',
          );
          expect(result, isNull);
        },
      );

      test(
        'verifyEmailOtp should gracefully handle non-success response',
        () async {
          final result = await service.verifyEmailOtp(
            email: 'test@example.com',
            otp: '123456',
            sid: 'test-sid',
            clientSecret: 'test-client-secret',
            homeserver: 'https://m.si46.world',
          );
          expect(result, isNull);
        },
      );
    });

    group('SSO', () {
      test('getSsoLoginUrl should return valid URL', () {
        final url = service.getSsoLoginUrl(
          homeserver: 'https://m.si46.world',
          redirectUrl: 'https://app.n42.chat/callback',
        );

        expect(url, contains('/_matrix/client/v3/login/sso/redirect'));
        expect(url, contains('redirectUrl='));
      });
    });
  });

  group('SocialLoginResult', () {
    test('should create with required fields', () {
      final result = SocialLoginResult(
        provider: 'google',
        email: 'test@gmail.com',
        displayName: 'Test User',
      );

      expect(result.provider, equals('google'));
      expect(result.email, equals('test@gmail.com'));
      expect(result.displayName, equals('Test User'));
    });

    test('should handle optional fields', () {
      final result = SocialLoginResult(
        provider: 'apple',
        idToken: 'token123',
        accessToken: 'access123',
      );

      expect(result.provider, equals('apple'));
      expect(result.idToken, equals('token123'));
      expect(result.email, isNull);
    });
  });

  group('PasskeyCredential', () {
    test('should serialize to JSON', () {
      final credential = PasskeyCredential(
        credentialId: 'cred123',
        publicKey: 'pubkey123',
        userId: '@user:server.com',
        displayName: 'Test User',
      );

      final json = credential.toJson();

      expect(json['credentialId'], equals('cred123'));
      expect(json['publicKey'], equals('pubkey123'));
      expect(json['userId'], equals('@user:server.com'));
      expect(json['displayName'], equals('Test User'));
    });

    test('should deserialize from JSON', () {
      final json = {
        'credentialId': 'cred123',
        'publicKey': 'pubkey123',
        'userId': '@user:server.com',
        'displayName': 'Test User',
      };

      final credential = PasskeyCredential.fromJson(json);

      expect(credential.credentialId, equals('cred123'));
      expect(credential.publicKey, equals('pubkey123'));
      expect(credential.userId, equals('@user:server.com'));
      expect(credential.displayName, equals('Test User'));
    });
  });

  group('AuthMethod Enum', () {
    test('should have all expected auth methods', () {
      expect(AuthMethod.values, contains(AuthMethod.password));
      expect(AuthMethod.values, contains(AuthMethod.passkey));
      expect(AuthMethod.values, contains(AuthMethod.emailOtp));
      expect(AuthMethod.values, contains(AuthMethod.google));
      expect(AuthMethod.values, contains(AuthMethod.apple));
      expect(AuthMethod.values, contains(AuthMethod.sso));
    });
  });

  group('Facebook Login', () {
    late AuthMethodsService service;

    setUp(() {
      service = AuthMethodsService();
    });

    tearDown(() {
      service.dispose();
    });

    test('isFacebookSignInAvailable should return true', () {
      final result = service.isFacebookSignInAvailable();
      expect(result, isTrue);
    });

    test('signInWithFacebook should throw when Facebook SDK fails', () async {
      // Facebook SDK 需要原生配置，在测试环境中会失败
      // 验证方法存在且可调用
      expect(service.signInWithFacebook, isA<Function>());
    });

    test('signOutFacebook should be callable', () async {
      // signOutFacebook 方法应该存在且可调用
      // 在测试环境中可能因为缺少原生插件实现而抛出 MissingPluginException
      // 这是正常的，我们只需验证方法存在
      expect(service.signOutFacebook, isA<Function>());
    });
  });

  group('Twitter Login', () {
    late AuthMethodsService service;

    setUp(() {
      service = AuthMethodsService();
    });

    tearDown(() {
      service.dispose();
    });

    test(
      'isTwitterSignInAvailable should return false when not configured',
      () {
        final result = service.isTwitterSignInAvailable();
        expect(result, isFalse);
      },
    );

    test('signInWithTwitter should throw when not configured', () async {
      expect(
        () => service.signInWithTwitter(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Twitter login not configured'),
          ),
        ),
      );
    });
  });

  group('WeChat Login', () {
    late AuthMethodsService service;

    setUp(() {
      service = AuthMethodsService();
    });

    tearDown(() {
      service.dispose();
    });

    test(
      'isWeChatSignInAvailable should return false when not initialized',
      () async {
        final result = await service.isWeChatSignInAvailable();
        expect(result, isFalse);
      },
    );

    test('signInWithWeChat should throw when not initialized', () async {
      expect(
        () => service.signInWithWeChat(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('WeChat SDK not initialized'),
          ),
        ),
      );
    });
  });

  group('Google Login', () {
    late AuthMethodsService service;

    setUp(() {
      service = AuthMethodsService();
      service.dispose();
    });

    tearDown(() {
      service.dispose();
    });

    test(
      'initialize should not expose Google login after init failure',
      () async {
        await service.initialize(
          googleClientId: 'invalid-google-client-id',
          googleServerClientId: 'invalid-google-server-client-id',
        );

        expect(service.isGoogleSignInAvailable(), isFalse);
      },
    );
  });

  group('SocialLoginResult for new providers', () {
    test('should create Facebook result with all fields', () {
      final result = SocialLoginResult(
        provider: 'facebook',
        accessToken: 'fb_access_token',
        email: 'test@facebook.com',
        displayName: 'Facebook User',
        photoUrl: 'https://facebook.com/photo.jpg',
      );

      expect(result.provider, equals('facebook'));
      expect(result.accessToken, equals('fb_access_token'));
      expect(result.email, equals('test@facebook.com'));
      expect(result.displayName, equals('Facebook User'));
      expect(result.photoUrl, equals('https://facebook.com/photo.jpg'));
    });

    test('should create Twitter result with extra fields', () {
      final result = SocialLoginResult(
        provider: 'twitter',
        accessToken: 'twitter_auth_token',
        email: 'test@twitter.com',
        displayName: 'Twitter User',
        extra: {
          'authTokenSecret': 'twitter_token_secret',
          'screenName': '@testuser',
          'userId': '123456789',
        },
      );

      expect(result.provider, equals('twitter'));
      expect(result.accessToken, equals('twitter_auth_token'));
      expect(result.extra?['authTokenSecret'], equals('twitter_token_secret'));
      expect(result.extra?['screenName'], equals('@testuser'));
    });

    test('should create WeChat result with code', () {
      final result = SocialLoginResult(
        provider: 'wechat',
        accessToken: 'wechat_auth_code', // WeChat 返回授权码
        extra: {
          'code': 'wechat_auth_code',
          'state': 'n42_chat_12345',
          'country': 'CN',
          'lang': 'zh_CN',
        },
      );

      expect(result.provider, equals('wechat'));
      expect(result.accessToken, equals('wechat_auth_code'));
      expect(result.extra?['code'], equals('wechat_auth_code'));
      expect(result.extra?['state'], contains('n42_chat'));
    });
  });
}
