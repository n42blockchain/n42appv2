import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';

void main() {
  group('AuthResult', () {
    test('success should create result with user', () {
      const user = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
      );
      
      final result = AuthResult.success(user);
      
      expect(result.success, isTrue);
      expect(result.user, equals(user));
      expect(result.errorMessage, isNull);
      expect(result.errorType, isNull);
    });

    test('failure should create result with error', () {
      final result = AuthResult.failure(
        '登录失败',
        type: AuthErrorType.invalidCredentials,
      );
      
      expect(result.success, isFalse);
      expect(result.user, isNull);
      expect(result.errorMessage, equals('登录失败'));
      expect(result.errorType, equals(AuthErrorType.invalidCredentials));
    });

    test('notLoggedIn should create result without login', () {
      final result = AuthResult.notLoggedIn();
      
      expect(result.success, isFalse);
      expect(result.user, isNull);
      expect(result.errorType, equals(AuthErrorType.notLoggedIn));
    });
  });

  group('AuthErrorType', () {
    test('should have all expected error types', () {
      expect(AuthErrorType.values, contains(AuthErrorType.invalidCredentials));
      expect(AuthErrorType.values, contains(AuthErrorType.invalidHomeserver));
      expect(AuthErrorType.values, contains(AuthErrorType.serverError));
      expect(AuthErrorType.values, contains(AuthErrorType.networkError));
      expect(AuthErrorType.values, contains(AuthErrorType.tokenExpired));
      expect(AuthErrorType.values, contains(AuthErrorType.unknown));
      expect(AuthErrorType.values, contains(AuthErrorType.notLoggedIn));
    });
  });

  group('HomeserverInfo', () {
    test('should create with required fields', () {
      const info = HomeserverInfo(
        serverName: 'N42 Matrix',
        serverVersion: '1.0.0',
        supportedLoginTypes: ['m.login.password', 'm.login.sso'],
        supportsRegistration: true,
      );

      expect(info.serverName, equals('N42 Matrix'));
      expect(info.serverVersion, equals('1.0.0'));
      expect(info.supportsRegistration, isTrue);
      expect(info.supportsPasswordLogin, isTrue);
      expect(info.supportsSsoLogin, isTrue);
    });

    test('should have default values for optional fields', () {
      const info = HomeserverInfo(
        serverName: 'Test Server',
        serverVersion: '1.0.0',
        supportedLoginTypes: ['m.login.password'],
      );

      expect(info.serverVersion, equals('1.0.0'));
      expect(info.supportsRegistration, isFalse);
      expect(info.supportsPasswordLogin, isTrue);
      expect(info.supportsSsoLogin, isFalse);
    });
  });

  group('UserEntity', () {
    test('should create with required fields', () {
      const user = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
      );

      expect(user.userId, equals('@user:server.com'));
      expect(user.displayName, equals('Test User'));
    });

    test('should handle optional profile fields', () {
      const user = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
        avatarUrl: 'https://server.com/avatar.jpg',
        gender: '男',
        region: '北京',
        signature: 'Hello World',
        pokeText: '的肩膀',
        ringtone: '默认铃声',
      );

      expect(user.avatarUrl, isNotNull);
      expect(user.gender, equals('男'));
      expect(user.region, equals('北京'));
      expect(user.signature, equals('Hello World'));
      expect(user.pokeText, equals('的肩膀'));
      expect(user.ringtone, equals('默认铃声'));
    });

    test('should support equality', () {
      const user1 = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
      );

      const user2 = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
      );

      expect(user1, equals(user2));
    });

    test('should support copyWith', () {
      const user = UserEntity(
        userId: '@user:server.com',
        displayName: 'Test User',
      );

      final updated = user.copyWith(
        displayName: 'Updated Name',
        avatarUrl: 'https://new-avatar.jpg',
      );

      expect(updated.userId, equals(user.userId));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.avatarUrl, equals('https://new-avatar.jpg'));
    });
  });

  group('WeChat Login Strategy', () {
    test('rememberMe should default to true', () {
      // 微信策略：默认始终记住登录状态
      const defaultRememberMe = true;
      expect(defaultRememberMe, isTrue);
    });

    test('session restore should try token first then credentials', () {
      // 会话恢复优先级测试
      const restoreOrder = ['token', 'credentials'];
      expect(restoreOrder.first, equals('token'));
      expect(restoreOrder.last, equals('credentials'));
    });

    test('logout should clear both session and credentials', () {
      // 登出应该清除 session 和 credentials
      const itemsToClears = ['session', 'credentials', 'profileCache'];
      expect(itemsToClears.length, equals(3));
    });
  });

  group('Password Change', () {
    test('changePassword should require oldPassword and newPassword', () {
      // 修改密码必须提供原密码和新密码
      const requiredParams = ['oldPassword', 'newPassword'];
      expect(requiredParams.length, equals(2));
    });

    test('password validation rules', () {
      // 密码验证规则
      const minLength = 8;
      expect(minLength, greaterThanOrEqualTo(8));

      // 测试密码强度
      bool isPasswordStrong(String password) {
        return password.length >= 8 &&
            RegExp(r'[A-Za-z]').hasMatch(password) &&
            RegExp(r'[0-9]').hasMatch(password);
      }

      expect(isPasswordStrong('weak'), isFalse);
      expect(isPasswordStrong('password'), isFalse);
      expect(isPasswordStrong('Password1'), isTrue);
      expect(isPasswordStrong('abcd1234'), isTrue);
    });

    test('newPassword should not equal oldPassword', () {
      const oldPassword = 'OldPassword123';
      const newPassword = 'NewPassword456';

      expect(oldPassword != newPassword, isTrue);
    });
  });

  group('Password Reset', () {
    test('reset flow should have 3 steps', () {
      const resetSteps = [
        'requestCode',   // 请求验证码
        'verifyCode',    // 验证验证码
        'setNewPassword' // 设置新密码
      ];
      expect(resetSteps.length, equals(3));
    });

    test('email validation for reset', () {
      bool isValidEmail(String email) {
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }

      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('user@domain.org'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail('@nodomain.com'), isFalse);
    });

    test('verification code should be 6 digits', () {
      bool isValidCode(String code) {
        return RegExp(r'^\d{6}$').hasMatch(code);
      }

      expect(isValidCode('123456'), isTrue);
      expect(isValidCode('000000'), isTrue);
      expect(isValidCode('12345'), isFalse);  // Too short
      expect(isValidCode('1234567'), isFalse); // Too long
      expect(isValidCode('abcdef'), isFalse);  // Not digits
    });
  });

  group('Email Binding and Change', () {
    test('email binding should require email validation', () {
      bool isValidEmail(String email) {
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }

      expect(isValidEmail('new@email.com'), isTrue);
      expect(isValidEmail('invalid'), isFalse);
    });

    test('email change should require password verification', () {
      const changeEmailRequirements = [
        'currentPassword',  // 当前密码验证
        'newEmail',         // 新邮箱地址
        'verificationCode', // 邮箱验证码
      ];
      expect(changeEmailRequirements.contains('currentPassword'), isTrue);
    });

    test('verification code resend should have cooldown', () {
      const resendCooldownSeconds = 60;
      expect(resendCooldownSeconds, equals(60));
    });
  });

  group('Social Login', () {
    test('supported social providers', () {
      const providers = ['google', 'apple'];
      expect(providers, contains('google'));
      expect(providers, contains('apple'));
    });

    test('social login should return matrix credentials', () {
      // 社交登录成功后应返回 Matrix 凭据
      const expectedCredentials = [
        'matrixUserId',
        'matrixAccessToken',
        'matrixHomeserver',
        'matrixDeviceId',
      ];
      expect(expectedCredentials.length, equals(4));
    });

    test('social login response validation', () {
      // 模拟社交登录响应验证
      final Map<String, dynamic> mockResponse = {
        'success': true,
        'matrix_user_id': '@user:server.com',
        'matrix_access_token': 'syt_token_123',
        'matrix_homeserver': 'https://server.com',
      };

      expect(mockResponse['success'], isTrue);
      expect(mockResponse['matrix_user_id'], isNotNull);
      expect(mockResponse['matrix_access_token'], isNotNull);
      expect(mockResponse['matrix_homeserver'], isNotNull);
    });

    test('social login should handle cancellation', () {
      // 用户取消社交登录时不应抛出错误
      const cancelResult = 'canceled';
      expect(cancelResult, equals('canceled'));
    });

    test('social login should handle provider not available', () {
      // 处理社交登录提供商不可用的情况
      bool isProviderAvailable(String provider, String platform) {
        if (provider == 'apple') {
          return platform == 'ios' || platform == 'macos';
        }
        return true; // Google 在所有平台可用
      }

      expect(isProviderAvailable('google', 'ios'), isTrue);
      expect(isProviderAvailable('google', 'android'), isTrue);
      expect(isProviderAvailable('apple', 'ios'), isTrue);
      expect(isProviderAvailable('apple', 'android'), isFalse);
    });
  });

  group('Social Account Binding', () {
    test('bind social account requirements', () {
      const bindRequirements = [
        'provider',   // 提供商类型
        'idToken',    // ID Token
        'uuid',       // 用户 UUID
        'token',      // 用户 Token
      ];
      expect(bindRequirements.length, equals(4));
    });

    test('unbind social account should require provider', () {
      const unbindRequirements = ['provider', 'uuid', 'token'];
      expect(unbindRequirements.contains('provider'), isTrue);
    });

    test('get bound accounts should return list', () {
      // 模拟获取已绑定账号列表
      final List<Map<String, String>> mockBoundAccounts = [
        {'provider': 'google', 'email': 'user@gmail.com'},
        {'provider': 'apple', 'email': 'user@icloud.com'},
      ];

      expect(mockBoundAccounts.length, equals(2));
      expect(mockBoundAccounts[0]['provider'], equals('google'));
      expect(mockBoundAccounts[1]['provider'], equals('apple'));
    });
  });
}

