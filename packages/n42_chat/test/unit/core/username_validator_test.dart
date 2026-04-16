// Tests for UsernameValidator and UsernameValidationResult
// in username_validator.dart.
// Pure Dart — no platform deps.
//
// Rules:
//   - 3-30 characters
//   - starts with lowercase letter
//   - only lowercase letters, digits, underscores
//   - not in the reserved list

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/username_validator.dart';

void main() {
  // ─────────────────────────────────────────────────
  // UsernameValidationResult factories
  // ─────────────────────────────────────────────────

  group('UsernameValidationResult.valid()', () {
    test('isValid is true', () {
      expect(UsernameValidationResult.valid().isValid, isTrue);
    });

    test('isReserved is false', () {
      expect(UsernameValidationResult.valid().isReserved, isFalse);
    });

    test('errorMessage is null', () {
      expect(UsernameValidationResult.valid().errorMessage, isNull);
    });
  });

  group('UsernameValidationResult.invalid()', () {
    test('isValid is false', () {
      final r = UsernameValidationResult.invalid('too short');
      expect(r.isValid, isFalse);
    });

    test('isReserved is false', () {
      expect(UsernameValidationResult.invalid('msg').isReserved, isFalse);
    });

    test('stores errorMessage', () {
      final r = UsernameValidationResult.invalid('bad format');
      expect(r.errorMessage, 'bad format');
    });
  });

  group('UsernameValidationResult.reserved()', () {
    test('isValid is false', () {
      final r = UsernameValidationResult.reserved('reserved');
      expect(r.isValid, isFalse);
    });

    test('isReserved is true', () {
      expect(UsernameValidationResult.reserved('msg').isReserved, isTrue);
    });

    test('stores errorMessage', () {
      final r = UsernameValidationResult.reserved('This username is reserved');
      expect(r.errorMessage, 'This username is reserved');
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.validate — invalid inputs
  // ─────────────────────────────────────────────────

  group('UsernameValidator.validate — empty', () {
    test('empty string → invalid', () {
      final r = UsernameValidator.validate('');
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('empty'));
    });
  });

  group('UsernameValidator.validate — too short', () {
    test('1 char → invalid', () {
      final r = UsernameValidator.validate('a');
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('3'));
    });

    test('2 chars → invalid', () {
      final r = UsernameValidator.validate('ab');
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('3'));
    });
  });

  group('UsernameValidator.validate — too long', () {
    test('31 chars → invalid', () {
      final r = UsernameValidator.validate('a' * 31);
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('30'));
    });
  });

  group('UsernameValidator.validate — uppercase letters', () {
    test('uppercase username → invalid (must be lowercase)', () {
      final r = UsernameValidator.validate('Alice');
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('lowercase'));
    });

    test('mixed case → invalid', () {
      final r = UsernameValidator.validate('alicE');
      expect(r.isValid, isFalse);
      expect(r.errorMessage, contains('lowercase'));
    });
  });

  group('UsernameValidator.validate — pattern mismatch', () {
    test('starts with digit → invalid', () {
      final r = UsernameValidator.validate('1alice');
      expect(r.isValid, isFalse);
    });

    test('starts with underscore → invalid', () {
      final r = UsernameValidator.validate('_alice');
      expect(r.isValid, isFalse);
    });

    test('contains hyphen → invalid', () {
      final r = UsernameValidator.validate('ali-ce');
      expect(r.isValid, isFalse);
    });

    test('contains space → invalid', () {
      final r = UsernameValidator.validate('ali ce');
      expect(r.isValid, isFalse);
    });

    test('contains special chars → invalid', () {
      final r = UsernameValidator.validate('ali@ce');
      expect(r.isValid, isFalse);
    });
  });

  group('UsernameValidator.validate — reserved usernames', () {
    test('admin → reserved', () {
      final r = UsernameValidator.validate('admin');
      expect(r.isValid, isFalse);
      expect(r.isReserved, isTrue);
      expect(r.errorMessage, contains('reserved'));
    });

    test('bot → reserved', () {
      final r = UsernameValidator.validate('bot');
      expect(r.isValid, isFalse);
      expect(r.isReserved, isTrue);
    });

    test('test → reserved', () {
      final r = UsernameValidator.validate('test');
      expect(r.isValid, isFalse);
      expect(r.isReserved, isTrue);
    });

    test('n42 → reserved', () {
      final r = UsernameValidator.validate('n42');
      expect(r.isValid, isFalse);
      expect(r.isReserved, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.validate — valid inputs
  // ─────────────────────────────────────────────────

  group('UsernameValidator.validate — valid', () {
    test('3-char username starting with letter → valid', () {
      final r = UsernameValidator.validate('abc');
      expect(r.isValid, isTrue);
      expect(r.isReserved, isFalse);
      expect(r.errorMessage, isNull);
    });

    test('30-char username → valid (max length)', () {
      final r = UsernameValidator.validate('a' * 30);
      expect(r.isValid, isTrue);
    });

    test('username with digits → valid', () {
      final r = UsernameValidator.validate('alice123');
      expect(r.isValid, isTrue);
    });

    test('username with underscores → valid', () {
      final r = UsernameValidator.validate('alice_bob');
      expect(r.isValid, isTrue);
    });

    test('username with digits and underscores → valid', () {
      final r = UsernameValidator.validate('user_42_test');
      expect(r.isValid, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // UsernameValidator.normalize
  // ─────────────────────────────────────────────────

  group('UsernameValidator.normalize', () {
    test('converts to lowercase', () {
      expect(UsernameValidator.normalize('Alice'), 'alice');
    });

    test('trims whitespace', () {
      expect(UsernameValidator.normalize('  alice  '), 'alice');
    });

    test('converts uppercase and trims', () {
      expect(UsernameValidator.normalize('  ALICE  '), 'alice');
    });

    test('already lowercase unchanged', () {
      expect(UsernameValidator.normalize('alice'), 'alice');
    });

    test('empty string stays empty', () {
      expect(UsernameValidator.normalize(''), '');
    });

    test('only spaces → empty string after trim', () {
      expect(UsernameValidator.normalize('   '), '');
    });
  });
}
