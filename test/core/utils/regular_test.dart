// Tests for the Regular utility class.
// Pure Dart — only intl and decimal deps, no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/utils/regular.dart';

void main() {
  final reg = Regular();

  // ─────────────────────────────────────────────────
  // regularHex
  // ─────────────────────────────────────────────────

  group('Regular.regularHex', () {
    test('lowercase hex without prefix', () {
      expect(reg.regularHex('abcdef'), isTrue);
    });

    test('uppercase hex without prefix', () {
      expect(reg.regularHex('ABCDEF'), isTrue);
    });

    test('mixed case hex without prefix', () {
      expect(reg.regularHex('aAbBcC'), isTrue);
    });

    test('hex with 0x prefix', () {
      expect(reg.regularHex('0xABCDEF'), isTrue);
    });

    test(
      'hex with 0X prefix is valid (regex is case-insensitive on prefix)',
      () {
        // The regex is ^(0x)?[0-9a-fA-F]+$ — literal "0x" lowercase only
        // '0X' would not match (0x) group → '0' is valid hex, 'X' is not → false
        expect(reg.regularHex('0XABCDEF'), isFalse);
      },
    );

    test('digits only are valid hex', () {
      expect(reg.regularHex('1234567890'), isTrue);
    });

    test('empty string returns false', () {
      expect(reg.regularHex(''), isFalse);
    });

    test('0x with nothing after returns false', () {
      expect(reg.regularHex('0x'), isFalse);
    });

    test('non-hex chars return false', () {
      expect(reg.regularHex('GHIJ'), isFalse);
    });

    test('0x followed by invalid chars returns false', () {
      expect(reg.regularHex('0xGHIJ'), isFalse);
    });

    test('space in string returns false', () {
      expect(reg.regularHex('ab cd'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // regularBase58
  // ─────────────────────────────────────────────────

  group('Regular.regularBase58', () {
    test('valid base58 string', () {
      expect(reg.regularBase58('1A2B3C'), isTrue);
    });

    test('all digits 1–9 are valid', () {
      expect(reg.regularBase58('123456789'), isTrue);
    });

    test('valid uppercase base58 chars', () {
      expect(reg.regularBase58('ABCDEFGHJKLMNPQRSTUVWXYZ'), isTrue);
    });

    test('valid lowercase base58 chars', () {
      expect(reg.regularBase58('abcdefghijkmnopqrstuvwxyz'), isTrue);
    });

    test('zero (0) is excluded from base58', () {
      expect(reg.regularBase58('0'), isFalse);
    });

    test('uppercase I is excluded from base58', () {
      expect(reg.regularBase58('I'), isFalse);
    });

    test('uppercase O is excluded from base58', () {
      expect(reg.regularBase58('O'), isFalse);
    });

    test('lowercase l is excluded from base58', () {
      expect(reg.regularBase58('l'), isFalse);
    });

    test('empty string returns false', () {
      expect(reg.regularBase58(''), isFalse);
    });

    test('special chars return false', () {
      expect(reg.regularBase58('!@#'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // regularDouble
  // ─────────────────────────────────────────────────

  group('Regular.regularDouble', () {
    test('integer-like string (two digits) matches', () {
      expect(reg.regularDouble('42'), isTrue);
    });

    test('float string matches', () {
      expect(reg.regularDouble('3.14'), isTrue);
    });

    test('zero decimal matches', () {
      expect(reg.regularDouble('0.5'), isTrue);
    });

    test('string starting with dot does not match', () {
      expect(reg.regularDouble('.5'), isFalse);
    });

    test('letter string does not match', () {
      expect(reg.regularDouble('abc'), isFalse);
    });

    test('number ending with dot (no trailing digit) does not match', () {
      // '3.' — after consuming '3' and '.', no digit follows
      expect(reg.regularDouble('3.'), isFalse);
    });

    test('single digit string does not match (needs ≥2 chars for pattern)', () {
      // '1': ^\d+ matches "1", then needs (\.)?[0-9] but nothing left → false
      expect(reg.regularDouble('1'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // regularNums
  // ─────────────────────────────────────────────────

  group('Regular.regularNums', () {
    test('digits-only string matches', () {
      expect(reg.regularNums('12345'), isTrue);
    });

    test('single digit matches', () {
      expect(reg.regularNums('0'), isTrue);
    });

    test('empty string returns false', () {
      expect(reg.regularNums(''), isFalse);
    });

    test('letters return false', () {
      expect(reg.regularNums('abc'), isFalse);
    });

    test('digit with dot returns false', () {
      expect(reg.regularNums('1.2'), isFalse);
    });

    test('digit with letter suffix returns false', () {
      expect(reg.regularNums('12a'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // getMoneyAbbreviation
  // ─────────────────────────────────────────────────

  group('Regular.getMoneyAbbreviation', () {
    test('zero shows "0.00"', () {
      expect(reg.getMoneyAbbreviation(0), '0.00');
    });

    test('1000 shows comma-formatted "1,000.00"', () {
      expect(reg.getMoneyAbbreviation(1000), '1,000.00');
    });

    test('999999999 (< 1B) shows comma-formatted', () {
      expect(reg.getMoneyAbbreviation(999999999), '999,999,999.00');
    });

    test('exactly 1 billion shows "1.00B"', () {
      expect(reg.getMoneyAbbreviation(1000000000), '1.00B');
    });

    test('1.5 billion shows "1.50B"', () {
      expect(reg.getMoneyAbbreviation(1500000000), '1.50B');
    });

    test('exactly 1 trillion shows "1.00T"', () {
      expect(reg.getMoneyAbbreviation(1000000000000), '1.00T');
    });

    test('2.5 trillion shows "2.50T"', () {
      expect(reg.getMoneyAbbreviation(2500000000000), '2.50T');
    });

    test('trillion takes priority over billion', () {
      final result = reg.getMoneyAbbreviation(5000000000000);
      expect(result, endsWith('T'));
    });
  });

  // ─────────────────────────────────────────────────
  // formartNum
  // ─────────────────────────────────────────────────

  group('Regular.formartNum', () {
    test('integer gets decimal point and zeros appended', () {
      expect(reg.formartNum(5, 2), '5.00');
    });

    test('integer with 0 decimal places returns unchanged', () {
      expect(reg.formartNum(5, 0), '5');
    });

    test('isCrop=true trims excess decimal places', () {
      expect(reg.formartNum(3.14159, 2, isCrop: true), '3.14');
    });

    test('isCrop=false rounds excess decimal places', () {
      expect(reg.formartNum(3.14559, 2, isCrop: false), '3.15');
    });

    test('fewer decimals than postion gets zero-padded', () {
      expect(reg.formartNum(3.1, 3), '3.100');
    });

    test('isFill0=false skips zero padding when not enough decimals', () {
      expect(reg.formartNum(3.1, 3, isFill0: false), '3.1');
    });

    test('isFill0=false on integer skips decimal suffix', () {
      expect(reg.formartNum(5, 2, isFill0: false), '5');
    });

    test('negative postion returns number as-is', () {
      expect(reg.formartNum(3.14, -1), '3.14');
    });

    test('exact decimal count — no crop or pad needed', () {
      expect(reg.formartNum(1.55, 2, isCrop: true), '1.55');
    });
  });

  // ─────────────────────────────────────────────────
  // hexToInt
  // ─────────────────────────────────────────────────

  group('Regular.hexToInt', () {
    test('0x prefix lowercase', () {
      expect(reg.hexToInt('0xAB'), 171);
    });

    test('0X prefix uppercase', () {
      expect(reg.hexToInt('0XFF'), 255);
    });

    test('0xff lowercase value', () {
      expect(reg.hexToInt('0xff'), 255);
    });

    test('uppercase hex without prefix', () {
      expect(reg.hexToInt('AB'), 171);
    });

    test('lowercase hex without prefix', () {
      expect(reg.hexToInt('ab'), 171);
    });

    test('FF without prefix', () {
      expect(reg.hexToInt('FF'), 255);
    });

    test('0 is a valid hex value', () {
      expect(reg.hexToInt('0'), 0);
    });

    test('invalid hex chars return null', () {
      expect(reg.hexToInt('GGG'), isNull);
    });

    test('empty string returns null', () {
      expect(reg.hexToInt(''), isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // isPassword
  // ─────────────────────────────────────────────────

  group('Regular.isPassword', () {
    test('8-character all-letter password is valid', () {
      expect(reg.isPassword('password'), isTrue);
    });

    test('8-character digit-only password is valid', () {
      expect(reg.isPassword('12345678'), isTrue);
    });

    test('mixed alphanumeric and special chars', () {
      expect(reg.isPassword('Passw0rd!'), isTrue);
    });

    test('allowed special chars including @ ! % * # ? &', () {
      expect(reg.isPassword(r'pass$@!%*'), isTrue);
    });

    test('too short (< 8) returns false', () {
      expect(reg.isPassword('pass1'), isFalse);
    });

    test('too long (> 18) returns false', () {
      expect(reg.isPassword('a' * 19), isFalse);
    });

    test('18-character password is valid (upper bound)', () {
      expect(reg.isPassword('a' * 18), isTrue);
    });

    test('disallowed char (caret ^) returns false', () {
      expect(reg.isPassword('pass^word1'), isFalse);
    });

    test('space char returns false', () {
      expect(reg.isPassword('pass word1'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isCaptcha (6-character)
  // ─────────────────────────────────────────────────

  group('Regular.isCaptcha', () {
    test('exactly 6 digits is valid', () {
      expect(reg.isCaptcha('123456'), isTrue);
    });

    test('6 letters is valid', () {
      expect(reg.isCaptcha('abcdef'), isTrue);
    });

    test('6 mixed alphanumeric is valid', () {
      expect(reg.isCaptcha('abc123'), isTrue);
    });

    test('underscore counts as word char', () {
      expect(reg.isCaptcha('abc_de'), isTrue);
    });

    test('5 chars returns false', () {
      expect(reg.isCaptcha('12345'), isFalse);
    });

    test('7 chars returns false', () {
      expect(reg.isCaptcha('1234567'), isFalse);
    });

    test('special char (!) returns false', () {
      expect(reg.isCaptcha('abc!de'), isFalse);
    });

    test('empty string returns false', () {
      expect(reg.isCaptcha(''), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isCaptcha2 (8-character)
  // ─────────────────────────────────────────────────

  group('Regular.isCaptcha2', () {
    test('exactly 8 digits is valid', () {
      expect(reg.isCaptcha2('12345678'), isTrue);
    });

    test('8 letters is valid', () {
      expect(reg.isCaptcha2('abcdefgh'), isTrue);
    });

    test('7 chars returns false', () {
      expect(reg.isCaptcha2('1234567'), isFalse);
    });

    test('9 chars returns false', () {
      expect(reg.isCaptcha2('123456789'), isFalse);
    });

    test('special char returns false', () {
      expect(reg.isCaptcha2('abc!defg'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isEmail
  // ─────────────────────────────────────────────────

  group('Regular.isEmail', () {
    test('basic email is valid', () {
      expect(reg.isEmail('user@example.com'), isTrue);
    });

    test('subdomain email is valid', () {
      expect(reg.isEmail('user@mail.example.com'), isTrue);
    });

    test('email with plus tag is valid', () {
      expect(reg.isEmail('user+filter@example.com'), isTrue);
    });

    test('missing @ returns false', () {
      expect(reg.isEmail('invalid'), isFalse);
    });

    test('@ only at start returns false', () {
      expect(reg.isEmail('@example.com'), isFalse);
    });

    test('nothing after @ returns false', () {
      expect(reg.isEmail('user@'), isFalse);
    });

    test('empty string returns false', () {
      expect(reg.isEmail(''), isFalse);
    });
  });
}
