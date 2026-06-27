import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/totp.dart';

void main() {
  // RFC 6238 test seed (ASCII "12345678901234567890") as Base32.
  final rfcSecret =
      Totp.base32Encode(Uint8List.fromList(utf8.encode('12345678901234567890')));

  group('Base32 (RFC 4648)', () {
    test('round-trips arbitrary bytes', () {
      final data = Uint8List.fromList([0, 1, 2, 250, 99, 17, 200]);
      expect(Totp.base32Decode(Totp.base32Encode(data)), data);
    });

    test('known vector: "foobar" -> MZXW6YTBOI', () {
      final enc = Totp.base32Encode(Uint8List.fromList(utf8.encode('foobar')));
      expect(enc, 'MZXW6YTBOI');
    });

    test('decode is case-insensitive and ignores spaces', () {
      final a = Totp.base32Decode('mzxw6ytboi');
      final b = Totp.base32Decode('MZXW 6YTB OI');
      expect(a, b);
    });
  });

  group('TOTP RFC 6238 vectors (SHA1, 8 digits)', () {
    final cases = {
      59: '94287082',
      1111111109: '07081804',
      1111111111: '14050471',
      1234567890: '89005924',
      2000000000: '69279037',
    };
    cases.forEach((time, expected) {
      test('T=$time -> $expected', () {
        expect(
          Totp.generate(rfcSecret, unixSeconds: time, digits: 8),
          expected,
        );
      });
    });
  });

  group('verify', () {
    test('accepts the current code', () {
      const t = 1234567890;
      final code = Totp.generate(rfcSecret, unixSeconds: t);
      expect(Totp.verify(rfcSecret, code, unixSeconds: t), isTrue);
    });

    test('accepts a code from the adjacent window (clock drift)', () {
      const t = 1234567890;
      final prev = Totp.generate(rfcSecret, unixSeconds: t - 30);
      expect(
        Totp.verify(rfcSecret, prev, unixSeconds: t, window: 1),
        isTrue,
      );
    });

    test('rejects an outside-window / wrong code', () {
      const t = 1234567890;
      final far = Totp.generate(rfcSecret, unixSeconds: t - 300);
      expect(Totp.verify(rfcSecret, far, unixSeconds: t, window: 1), isFalse);
      expect(Totp.verify(rfcSecret, '000000', unixSeconds: t), isFalse);
    });

    test('rejects wrong-length input', () {
      expect(Totp.verify(rfcSecret, '1234', unixSeconds: 1), isFalse);
    });
  });

  group('randomSecret + provisioningUri', () {
    test('randomSecret is valid base32 of expected length', () {
      final s = Totp.randomSecret();
      // 20 bytes -> 32 base32 chars
      expect(s.length, 32);
      expect(RegExp(r'^[A-Z2-7]+$').hasMatch(s), isTrue);
    });

    test('provisioningUri encodes label and params', () {
      final uri = Totp.provisioningUri(
        secret: 'JBSWY3DPEHPK3PXP',
        accountName: 'alice@n42',
        issuer: 'N42 Chat',
      );
      expect(uri, startsWith('otpauth://totp/'));
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
      expect(uri, contains('issuer=N42'));
      expect(uri, contains('digits=6'));
      expect(uri, contains('period=30'));
    });
  });
}
