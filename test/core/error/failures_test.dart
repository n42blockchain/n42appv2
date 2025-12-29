import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should have correct message', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure.message, 'Server error');
    });

    test('ServerFailure should have correct statusCode', () {
      const failure = ServerFailure(statusCode: 500);
      expect(failure.statusCode, 500);
    });

    test('NetworkFailure should have default message', () {
      const failure = NetworkFailure();
      expect(failure.message, '网络连接失败');
    });

    test('TimeoutFailure should have default message', () {
      const failure = TimeoutFailure();
      expect(failure.message, '请求超时');
    });

    test('AuthFailure should have default message', () {
      const failure = AuthFailure();
      expect(failure.message, '认证失败');
    });

    test('TokenExpiredFailure should have correct message', () {
      const failure = TokenExpiredFailure();
      expect(failure.message, '登录已过期');
    });

    test('ValidationFailure should contain errors map', () {
      const failure = ValidationFailure(
        errors: {
          'email': ['Invalid email format'],
        },
      );
      expect(failure.errors, isNotNull);
      expect(failure.errors!['email'], contains('Invalid email format'));
    });

    test('Failures with same props should be equal', () {
      const failure1 = ServerFailure(message: 'Error', statusCode: 500);
      const failure2 = ServerFailure(message: 'Error', statusCode: 500);
      expect(failure1, equals(failure2));
    });

    test('Failures with different props should not be equal', () {
      const failure1 = ServerFailure(message: 'Error 1');
      const failure2 = ServerFailure(message: 'Error 2');
      expect(failure1, isNot(equals(failure2)));
    });
  });
}

