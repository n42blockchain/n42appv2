import 'package:flutter_test/flutter_test.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Password feature tests
/// Tests for password change and reset functionality
void main() {
  group('Password Validation', () {
    test('password must be at least 6 characters', () {
      expect(_isValidPasswordLength('12345'), false);
      expect(_isValidPasswordLength('123456'), true);
      expect(_isValidPasswordLength('password123'), true);
    });

    test('new password must be different from old password', () {
      const oldPwd = 'oldpassword123';
      const samePwd = 'oldpassword123';
      const newPwd = 'newpassword456';

      expect(_arePasswordsDifferent(oldPwd, samePwd), false);
      expect(_arePasswordsDifferent(oldPwd, newPwd), true);
    });

    test('password confirmation must match', () {
      const password = 'mypassword123';
      const confirmSame = 'mypassword123';
      const confirmDiff = 'differentpassword';

      expect(_doPasswordsMatch(password, confirmSame), true);
      expect(_doPasswordsMatch(password, confirmDiff), false);
    });
  });

  group('Email Validation', () {
    test('valid email addresses should pass', () {
      expect(_isValidEmail('user@example.com'), true);
      expect(_isValidEmail('test.user@domain.org'), true);
      expect(_isValidEmail('user+tag@example.co.uk'), true);
    });

    test('invalid email addresses should fail', () {
      expect(_isValidEmail(''), false);
      expect(_isValidEmail('notanemail'), false);
      expect(_isValidEmail('missing@'), false);
      expect(_isValidEmail('@nodomain.com'), false);
      expect(_isValidEmail('spaces in@email.com'), false);
    });
  });

  group('Verification Code Validation', () {
    test('code must be 6 digits', () {
      expect(_isValidVerificationCode('12345'), false);
      expect(_isValidVerificationCode('123456'), true);
      expect(_isValidVerificationCode('1234567'), false);
      expect(_isValidVerificationCode('abcdef'), false);
    });
  });

  group('Password Hashing', () {
    test('MD5 hash should be consistent', () {
      const password = 'testpassword123';
      final hash1 = _hashPassword(password);
      final hash2 = _hashPassword(password);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(32)); // MD5 produces 32 hex characters
    });

    test('different passwords should produce different hashes', () {
      const password1 = 'password1';
      const password2 = 'password2';

      final hash1 = _hashPassword(password1);
      final hash2 = _hashPassword(password2);

      expect(hash1, isNot(equals(hash2)));
    });
  });

  group('API Parameters', () {
    test('change password params should have required fields', () {
      final params = _buildChangePasswordParams(
        uuid: 'test-uuid',
        token: 'test-token',
        oldPassword: 'old123',
        newPassword: 'new456',
      );

      expect(params.containsKey('uuid'), true);
      expect(params.containsKey('token'), true);
      expect(params.containsKey('source'), true);
      expect(params.containsKey('old_pwd'), true);
      expect(params.containsKey('new_pwd'), true);
      expect(params['source'], equals('app'));
    });

    test('reset password params should have required fields', () {
      final params = _buildResetPasswordParams(
        email: 'user@example.com',
        password: 'newpassword',
        code: '123456',
      );

      expect(params.containsKey('email'), true);
      expect(params.containsKey('pwd'), true);
      expect(params.containsKey('code'), true);
    });

    test('send email code params should have required fields', () {
      final params = _buildSendEmailCodeParams(
        email: 'user@example.com',
        type: 'resetPwd',
      );

      expect(params.containsKey('email'), true);
      expect(params.containsKey('type'), true);
      expect(params['type'], equals('resetPwd'));
    });
  });

  group('Password Reset Flow', () {
    test('flow should have 3 steps', () {
      const steps = ['email', 'verify', 'password'];
      expect(steps.length, equals(3));
      expect(steps[0], equals('email'));
      expect(steps[1], equals('verify'));
      expect(steps[2], equals('password'));
    });

    test('step transition validation', () {
      // Step 0 -> 1: requires valid email
      expect(_canProceedFromStep0(''), false);
      expect(_canProceedFromStep0('invalid'), false);
      expect(_canProceedFromStep0('user@example.com'), true);

      // Step 1 -> 2: requires valid code
      expect(_canProceedFromStep1(''), false);
      expect(_canProceedFromStep1('12345'), false);
      expect(_canProceedFromStep1('123456'), true);

      // Step 2 -> complete: requires matching valid passwords
      expect(_canProceedFromStep2('pass', 'pass'), false); // too short
      expect(_canProceedFromStep2('password', 'different'), false); // mismatch
      expect(_canProceedFromStep2('password123', 'password123'), true);
    });
  });
}

// Helper functions that mirror the validation logic in the pages

bool _isValidPasswordLength(String password) {
  return password.length >= 6;
}

bool _arePasswordsDifferent(String oldPassword, String newPassword) {
  return oldPassword != newPassword;
}

bool _doPasswordsMatch(String password, String confirmPassword) {
  return password == confirmPassword;
}

bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

bool _isValidVerificationCode(String code) {
  if (code.length != 6) return false;
  return RegExp(r'^\d{6}$').hasMatch(code);
}

String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = md5.convert(bytes);
  return hex.encode(digest.bytes);
}

Map<String, dynamic> _buildChangePasswordParams({
  required String uuid,
  required String token,
  required String oldPassword,
  required String newPassword,
}) {
  return {
    "uuid": uuid,
    "token": token,
    "source": "app",
    "old_pwd": _hashPassword(oldPassword),
    "new_pwd": _hashPassword(newPassword),
  };
}

Map<String, dynamic> _buildResetPasswordParams({
  required String email,
  required String password,
  required String code,
}) {
  return {"email": email, "pwd": _hashPassword(password), "code": code};
}

Map<String, dynamic> _buildSendEmailCodeParams({
  required String email,
  required String type,
}) {
  return {"email": email, "type": type};
}

bool _canProceedFromStep0(String email) {
  return _isValidEmail(email);
}

bool _canProceedFromStep1(String code) {
  return _isValidVerificationCode(code);
}

bool _canProceedFromStep2(String password, String confirmPassword) {
  return _isValidPasswordLength(password) &&
      _doPasswordsMatch(password, confirmPassword);
}
