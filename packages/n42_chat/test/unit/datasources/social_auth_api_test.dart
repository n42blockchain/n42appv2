import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/remote/social_auth_api.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late SocialAuthApi socialAuthApi;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    socialAuthApi = SocialAuthApi(
      baseUrl: 'https://api.test.com',
      client: mockClient,
    );
  });

  group('SocialAuthApi', () {
    group('loginWithGoogle', () {
      test('should return success response with matrix credentials', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': {
            'uuid': 'test-uuid',
            'token': 'test-token',
            'email': 'test@gmail.com',
            'nickname': 'Test User',
            'avatar': 'https://avatar.url',
            'matrix_user_id': '@test:server.com',
            'matrix_access_token': 'syt_token_123',
            'matrix_device_id': 'DEVICE123',
            'matrix_homeserver': 'https://matrix.server.com',
          },
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithGoogle(
          idToken: 'google_id_token',
          accessToken: 'google_access_token',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.matrixUserId, equals('@test:server.com'));
        expect(result.matrixAccessToken, equals('syt_token_123'));
        expect(result.matrixHomeserver, equals('https://matrix.server.com'));
        expect(result.hasMatrixCredentials, isTrue);
      });

      test('should return failure when login fails', () async {
        // Arrange
        final responseData = {
          'code': 401,
          'err': 'Invalid token',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithGoogle(
          idToken: 'invalid_token',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Invalid token'));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network error'));

        // Act
        final result = await socialAuthApi.loginWithGoogle(
          idToken: 'google_id_token',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('Network error'));
      });
    });

    group('loginWithApple', () {
      test('should return success response with matrix credentials', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': {
            'uuid': 'apple-uuid',
            'token': 'apple-token',
            'email': 'test@icloud.com',
            'matrix_user_id': '@apple:server.com',
            'matrix_access_token': 'syt_apple_token',
            'matrix_device_id': 'APPLE_DEVICE',
            'matrix_homeserver': 'https://matrix.server.com',
          },
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithApple(
          idToken: 'apple_id_token',
          authorizationCode: 'apple_auth_code',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.matrixUserId, equals('@apple:server.com'));
        expect(result.hasMatrixCredentials, isTrue);
      });

      test('should return failure when Apple login fails', () async {
        // Arrange
        final responseData = {
          'code': 403,
          'err': 'Apple account not linked',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithApple(
          idToken: 'apple_id_token',
          authorizationCode: 'apple_auth_code',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Apple account not linked'));
      });
    });

    group('loginWithFacebook', () {
      test('should return success response with matrix credentials', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': {
            'uuid': 'facebook-uuid',
            'token': 'facebook-token',
            'email': 'test@facebook.com',
            'nickname': 'Facebook User',
            'avatar': 'https://facebook.com/avatar.jpg',
            'matrix_user_id': '@facebook:server.com',
            'matrix_access_token': 'syt_facebook_token',
            'matrix_device_id': 'FB_DEVICE',
            'matrix_homeserver': 'https://matrix.server.com',
          },
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithFacebook(
          accessToken: 'facebook_access_token',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.matrixUserId, equals('@facebook:server.com'));
        expect(result.nickname, equals('Facebook User'));
        expect(result.hasMatrixCredentials, isTrue);
      });

      test('should return failure when Facebook login fails', () async {
        // Arrange
        final responseData = {
          'code': 401,
          'err': 'Invalid Facebook token',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithFacebook(
          accessToken: 'invalid_token',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Invalid Facebook token'));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network error'));

        // Act
        final result = await socialAuthApi.loginWithFacebook(
          accessToken: 'facebook_token',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('Network error'));
      });
    });

    group('loginWithTwitter', () {
      test('should return success response with matrix credentials', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': {
            'uuid': 'twitter-uuid',
            'token': 'twitter-token',
            'email': 'test@twitter.com',
            'nickname': 'Twitter User',
            'matrix_user_id': '@twitter:server.com',
            'matrix_access_token': 'syt_twitter_token',
            'matrix_device_id': 'TWITTER_DEVICE',
            'matrix_homeserver': 'https://matrix.server.com',
          },
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithTwitter(
          authToken: 'twitter_auth_token',
          authTokenSecret: 'twitter_token_secret',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.matrixUserId, equals('@twitter:server.com'));
        expect(result.hasMatrixCredentials, isTrue);
      });

      test('should return failure when Twitter login fails', () async {
        // Arrange
        final responseData = {
          'code': 401,
          'err': 'Twitter authentication failed',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithTwitter(
          authToken: 'invalid_token',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Twitter authentication failed'));
      });
    });

    group('loginWithWeChat', () {
      test('should return success response with matrix credentials', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': {
            'uuid': 'wechat-uuid',
            'token': 'wechat-token',
            'nickname': 'WeChat User',
            'avatar': 'https://wx.qlogo.cn/avatar.jpg',
            'matrix_user_id': '@wechat:server.com',
            'matrix_access_token': 'syt_wechat_token',
            'matrix_device_id': 'WECHAT_DEVICE',
            'matrix_homeserver': 'https://matrix.server.com',
          },
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithWeChat(
          code: 'wechat_auth_code',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.matrixUserId, equals('@wechat:server.com'));
        expect(result.nickname, equals('WeChat User'));
        expect(result.hasMatrixCredentials, isTrue);
      });

      test('should return failure when WeChat login fails', () async {
        // Arrange
        final responseData = {
          'code': 401,
          'err': 'Invalid WeChat code',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithWeChat(
          code: 'invalid_code',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Invalid WeChat code'));
      });

      test('should handle expired WeChat code', () async {
        // Arrange
        final responseData = {
          'code': 400,
          'err': 'WeChat code expired',
        };

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.loginWithWeChat(
          code: 'expired_code',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('WeChat code expired'));
      });
    });

    group('bindSocialAccount', () {
      test('should return true when binding succeeds', () async {
        // Arrange
        final responseData = {'code': 200};

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.bindSocialAccount(
          uuid: 'user-uuid',
          token: 'user-token',
          provider: 'google',
          idToken: 'google_id_token',
        );

        // Assert
        expect(result, isTrue);
      });

      test('should return false when binding fails', () async {
        // Arrange
        final responseData = {'code': 400, 'err': 'Account already bound'};

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.bindSocialAccount(
          uuid: 'user-uuid',
          token: 'user-token',
          provider: 'google',
          idToken: 'google_id_token',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('unbindSocialAccount', () {
      test('should return true when unbinding succeeds', () async {
        // Arrange
        final responseData = {'code': 200};

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.unbindSocialAccount(
          uuid: 'user-uuid',
          token: 'user-token',
          provider: 'google',
        );

        // Assert
        expect(result, isTrue);
      });

      test('should return false when unbinding fails', () async {
        // Arrange
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Server error'));

        // Act
        final result = await socialAuthApi.unbindSocialAccount(
          uuid: 'user-uuid',
          token: 'user-token',
          provider: 'google',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('getSocialAccounts', () {
      test('should return list of bound accounts', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': [
            {
              'provider': 'google',
              'email': 'test@gmail.com',
              'display_name': 'Google User',
              'bound_at': '2024-01-01T00:00:00Z',
            },
            {
              'provider': 'apple',
              'email': 'test@icloud.com',
              'display_name': 'Apple User',
              'bound_at': '2024-01-02T00:00:00Z',
            },
          ],
        };

        when(() => mockClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.getSocialAccounts(
          uuid: 'user-uuid',
          token: 'user-token',
        );

        // Assert
        expect(result.length, equals(2));
        expect(result[0].provider, equals('google'));
        expect(result[0].email, equals('test@gmail.com'));
        expect(result[1].provider, equals('apple'));
        expect(result[1].email, equals('test@icloud.com'));
      });

      test('should return empty list when no accounts bound', () async {
        // Arrange
        final responseData = {
          'code': 200,
          'data': [],
        };

        when(() => mockClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(responseData),
              200,
            ));

        // Act
        final result = await socialAuthApi.getSocialAccounts(
          uuid: 'user-uuid',
          token: 'user-token',
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list on error', () async {
        // Arrange
        when(() => mockClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(Exception('Network error'));

        // Act
        final result = await socialAuthApi.getSocialAccounts(
          uuid: 'user-uuid',
          token: 'user-token',
        );

        // Assert
        expect(result, isEmpty);
      });
    });
  });

  group('SocialLoginResponse', () {
    test('success factory should create successful response', () {
      final response = SocialLoginResponse.success(
        uuid: 'uuid',
        token: 'token',
        email: 'test@example.com',
        matrixUserId: '@user:server.com',
        matrixAccessToken: 'syt_token',
        matrixHomeserver: 'https://matrix.server.com',
      );

      expect(response.success, isTrue);
      expect(response.uuid, equals('uuid'));
      expect(response.matrixUserId, equals('@user:server.com'));
      expect(response.hasMatrixCredentials, isTrue);
      expect(response.error, isNull);
    });

    test('failure factory should create failed response', () {
      final response = SocialLoginResponse.failure('Login failed');

      expect(response.success, isFalse);
      expect(response.error, equals('Login failed'));
      expect(response.matrixUserId, isNull);
      expect(response.hasMatrixCredentials, isFalse);
    });

    test('hasMatrixCredentials should return false when missing fields', () {
      final response = SocialLoginResponse.success(
        uuid: 'uuid',
        token: 'token',
        email: 'test@example.com',
        matrixUserId: '@user:server.com',
        // Missing matrixAccessToken and matrixHomeserver
      );

      expect(response.hasMatrixCredentials, isFalse);
    });
  });

  group('BoundSocialAccount', () {
    test('fromJson should parse correctly', () {
      final json = {
        'provider': 'google',
        'email': 'test@gmail.com',
        'display_name': 'Test User',
        'bound_at': '2024-01-15T10:30:00Z',
      };

      final account = BoundSocialAccount.fromJson(json);

      expect(account.provider, equals('google'));
      expect(account.email, equals('test@gmail.com'));
      expect(account.displayName, equals('Test User'));
      expect(account.boundAt, isNotNull);
      expect(account.boundAt!.year, equals(2024));
    });

    test('fromJson should handle null fields', () {
      final json = {
        'provider': 'apple',
      };

      final account = BoundSocialAccount.fromJson(json);

      expect(account.provider, equals('apple'));
      expect(account.email, isNull);
      expect(account.displayName, isNull);
      expect(account.boundAt, isNull);
    });
  });
}
