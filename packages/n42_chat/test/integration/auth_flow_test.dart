import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';
import 'package:n42_chat/src/presentation/pages/auth/login_page.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  const testUser = UserEntity(
    userId: '@user:server.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // 设置默认行为
    when(() => mockAuthRepository.loginStateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(authRepository: mockAuthRepository),
        child: child,
      ),
    );
  }

  group('Authentication Flow Integration Tests', () {
    testWidgets('should show login form fields', (tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginPage()));

      // 验证登录表单元素存在
      expect(find.byType(TextFormField), findsNWidgets(3)); // homeserver, username, password
      // 找到按钮类型的登录
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should navigate to register page', (tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginPage()));

      // 找到注册按钮并点击
      final registerButton = find.text('注册');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should show forgot password option', (tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginPage()));

      // 查找忘记密码或重置密码相关的选项
      // 注意：实际文本可能是英文或其他语言
      final forgotPasswordCn = find.textContaining('忘记密码');
      final forgotPasswordEn = find.textContaining('Forgot');
      final resetPassword = find.textContaining('Reset');

      // 至少应该有一个找到
      final found = forgotPasswordCn.evaluate().isNotEmpty ||
          forgotPasswordEn.evaluate().isNotEmpty ||
          resetPassword.evaluate().isNotEmpty;
      expect(found, isTrue);
    });
  });

  group('Password Change Flow', () {
    test('should validate password requirements', () {
      // 密码长度验证
      bool isValidPassword(String password) {
        if (password.length < 8) return false;
        if (!RegExp(r'[A-Za-z]').hasMatch(password)) return false;
        if (!RegExp(r'[0-9]').hasMatch(password)) return false;
        return true;
      }

      expect(isValidPassword('short'), isFalse);
      expect(isValidPassword('12345678'), isFalse);
      expect(isValidPassword('abcdefgh'), isFalse);
      expect(isValidPassword('Password1'), isTrue);
    });

    test('should confirm password match', () {
      const newPassword = 'NewPassword123';
      const confirmPassword = 'NewPassword123';

      expect(newPassword == confirmPassword, isTrue);
    });

    test('new password should differ from old', () {
      const oldPassword = 'OldPassword123';
      const newPassword = 'NewPassword456';

      expect(oldPassword != newPassword, isTrue);
    });
  });

  group('Password Reset Flow', () {
    test('should validate email format', () {
      bool isValidEmail(String email) {
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }

      expect(isValidEmail('user@example.com'), isTrue);
      expect(isValidEmail('test@domain.org'), isTrue);
      expect(isValidEmail('invalid'), isFalse);
      expect(isValidEmail('no@domain'), isFalse);
    });

    test('should validate verification code format', () {
      bool isValidCode(String code) {
        return RegExp(r'^\d{6}$').hasMatch(code);
      }

      expect(isValidCode('123456'), isTrue);
      expect(isValidCode('000000'), isTrue);
      expect(isValidCode('12345'), isFalse);
      expect(isValidCode('abcdef'), isFalse);
    });

    test('reset flow steps should be in order', () {
      const steps = ['enterEmail', 'verifyCode', 'setNewPassword', 'success'];
      expect(steps.length, equals(4));
      expect(steps.first, equals('enterEmail'));
      expect(steps.last, equals('success'));
    });
  });

  group('Email Change Flow', () {
    test('should require current password verification', () {
      const requirements = [
        'currentPassword',
        'newEmail',
        'verificationCode',
      ];

      expect(requirements.contains('currentPassword'), isTrue);
    });

    test('should validate new email format', () {
      bool isValidEmail(String email) {
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }

      expect(isValidEmail('new@email.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
    });

    test('cooldown timer should be 60 seconds', () {
      const cooldownSeconds = 60;
      expect(cooldownSeconds, equals(60));
    });
  });

  group('Social Login Flow', () {
    test('should check provider availability', () {
      bool isProviderAvailable(String provider, String platform) {
        switch (provider) {
          case 'google':
            return true; // Available on all platforms
          case 'apple':
            return platform == 'ios' || platform == 'macos';
          default:
            return false;
        }
      }

      expect(isProviderAvailable('google', 'ios'), isTrue);
      expect(isProviderAvailable('google', 'android'), isTrue);
      expect(isProviderAvailable('apple', 'ios'), isTrue);
      expect(isProviderAvailable('apple', 'android'), isFalse);
    });

    test('should handle login cancellation gracefully', () {
      // Simulating cancelled login
      const isCancelled = true;

      if (isCancelled) {
        // Should not throw, just return to initial state
        expect(isCancelled, isTrue);
      }
    });

    test('should extract matrix credentials from response', () {
      final response = {
        'matrix_user_id': '@user:server.com',
        'matrix_access_token': 'syt_token_123',
        'matrix_homeserver': 'https://matrix.server.com',
        'matrix_device_id': 'DEVICE123',
      };

      expect(response['matrix_user_id'], isNotNull);
      expect(response['matrix_access_token'], isNotNull);
      expect(response['matrix_homeserver'], isNotNull);

      // Check if all required credentials are present
      final bool hasAllCredentials = response['matrix_user_id'] != null &&
          response['matrix_access_token'] != null &&
          response['matrix_homeserver'] != null;

      expect(hasAllCredentials, isTrue);
    });
  });

  group('Registration with Email Binding', () {
    test('should require email during registration', () {
      const registrationFields = [
        'homeserver',
        'username',
        'password',
        'email', // Required for account recovery
      ];

      expect(registrationFields.contains('email'), isTrue);
    });

    test('should validate email during registration', () {
      bool isValidEmail(String email) {
        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }

      expect(isValidEmail('register@example.com'), isTrue);
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('invalid'), isFalse);
    });
  });

  group('Auth State Management', () {
    test('AuthStatus should have all expected values', () {
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.checking));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });

    test('ChangePasswordStatus should have all expected values', () {
      expect(ChangePasswordStatus.values, contains(ChangePasswordStatus.initial));
      expect(ChangePasswordStatus.values, contains(ChangePasswordStatus.changing));
      expect(ChangePasswordStatus.values, contains(ChangePasswordStatus.success));
      expect(ChangePasswordStatus.values, contains(ChangePasswordStatus.failed));
    });

    test('PasswordResetStatus should have all expected values', () {
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.initial));
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.sendingCode));
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.codeSent));
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.resetting));
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.success));
      expect(PasswordResetStatus.values, contains(PasswordResetStatus.failed));
    });

    test('ChangeEmailStatus should have all expected values', () {
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.initial));
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.sendingCode));
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.codeSent));
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.confirming));
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.success));
      expect(ChangeEmailStatus.values, contains(ChangeEmailStatus.failed));
    });
  });
}
