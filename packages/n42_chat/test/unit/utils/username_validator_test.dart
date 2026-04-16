// Tests for UsernameValidator and UsernameValidationResult.
// Pure Dart — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/username_validator.dart';

void main() {
  // ─────────────────────────────────────────────────
  // UsernameValidator.validate — invalid cases
  // ─────────────────────────────────────────────────

  group('UsernameValidator.validate — invalid', () {
    test('empty string returns invalid', () {
      final result = UsernameValidator.validate('');
      expect(result.isValid, isFalse);
      expect(result.isReserved, isFalse);
      expect(result.errorMessage, contains('empty'));
    });

    test('too short (< 3 chars) returns invalid', () {
      final result = UsernameValidator.validate('ab');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('3'));
    });

    test('single char returns invalid', () {
      final result = UsernameValidator.validate('a');
      expect(result.isValid, isFalse);
    });

    test('too long (> 30 chars) returns invalid', () {
      final result = UsernameValidator.validate('a' * 31);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('30'));
    });

    test('exactly 30 chars is valid (boundary)', () {
      // exactly 30: starts with letter, rest lowercase letters
      final result = UsernameValidator.validate('a' * 30);
      expect(result.isValid, isTrue);
    });

    test('exactly 3 chars is valid (boundary)', () {
      final result = UsernameValidator.validate('abc');
      expect(result.isValid, isTrue);
    });

    test('uppercase letters return invalid', () {
      final result = UsernameValidator.validate('Alice');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('lowercase'));
    });

    test('starts with a digit returns invalid', () {
      final result = UsernameValidator.validate('1user');
      expect(result.isValid, isFalse);
    });

    test('starts with underscore returns invalid', () {
      final result = UsernameValidator.validate('_user');
      expect(result.isValid, isFalse);
    });

    test('contains hyphen returns invalid', () {
      final result = UsernameValidator.validate('my-user');
      expect(result.isValid, isFalse);
    });

    test('contains space returns invalid', () {
      final result = UsernameValidator.validate('my user');
      expect(result.isValid, isFalse);
    });

    test('contains special chars returns invalid', () {
      final result = UsernameValidator.validate('user@name');
      expect(result.isValid, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.validate — reserved
  // ─────────────────────────────────────────────────

  group('UsernameValidator.validate — reserved', () {
    for (final name in ['admin', 'system', 'n42', 'root', 'bot', 'test', 'api', 'dev']) {
      test('"$name" returns reserved result', () {
        final result = UsernameValidator.validate(name);
        expect(result.isValid, isFalse);
        expect(result.isReserved, isTrue);
        expect(result.errorMessage, contains('reserved'));
      });
    }

    test('reserved check is exact match (not substring)', () {
      // "admins" is NOT in the reserved list, should be valid
      final result = UsernameValidator.validate('admins');
      expect(result.isReserved, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.validate — valid
  // ─────────────────────────────────────────────────

  group('UsernameValidator.validate — valid', () {
    test('simple lowercase username is valid', () {
      final result = UsernameValidator.validate('alice');
      expect(result.isValid, isTrue);
      expect(result.isReserved, isFalse);
      expect(result.errorMessage, isNull);
    });

    test('username with digits is valid', () {
      final result = UsernameValidator.validate('alice123');
      expect(result.isValid, isTrue);
    });

    test('username with underscore is valid', () {
      final result = UsernameValidator.validate('alice_bob');
      expect(result.isValid, isTrue);
    });

    test('username with underscore and digit is valid', () {
      final result = UsernameValidator.validate('user_123');
      expect(result.isValid, isTrue);
    });

    test('username starting with letter followed by underscore is valid', () {
      final result = UsernameValidator.validate('a_bc');
      expect(result.isValid, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidationResult factories
  // ─────────────────────────────────────────────────

  group('UsernameValidationResult factories', () {
    test('valid() creates a valid result with no error', () {
      final result = UsernameValidationResult.valid();
      expect(result.isValid, isTrue);
      expect(result.isReserved, isFalse);
      expect(result.errorMessage, isNull);
    });

    test('invalid() creates an invalid result with error message', () {
      final result = UsernameValidationResult.invalid('some error');
      expect(result.isValid, isFalse);
      expect(result.isReserved, isFalse);
      expect(result.errorMessage, 'some error');
    });

    test('reserved() creates an invalid, reserved result', () {
      final result = UsernameValidationResult.reserved('reserved message');
      expect(result.isValid, isFalse);
      expect(result.isReserved, isTrue);
      expect(result.errorMessage, 'reserved message');
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.normalize
  // ─────────────────────────────────────────────────

  group('UsernameValidator.normalize', () {
    test('trims leading and trailing whitespace', () {
      expect(UsernameValidator.normalize('  alice  '), 'alice');
    });

    test('converts to lowercase', () {
      expect(UsernameValidator.normalize('Alice'), 'alice');
    });

    test('both trim and lowercase', () {
      expect(UsernameValidator.normalize('  ALICE123  '), 'alice123');
    });

    test('already normalized string is unchanged', () {
      expect(UsernameValidator.normalize('alice'), 'alice');
    });

    test('empty string stays empty', () {
      expect(UsernameValidator.normalize(''), '');
    });
  });
}
