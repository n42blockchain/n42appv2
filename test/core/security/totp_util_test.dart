import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/totp_util.dart';

const secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
DateTime time(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

void main() {
  // RFC 6238 Appendix B, SHA-1 vectors reduced modulo 10^6 for this app.
  // https://www.rfc-editor.org/rfc/rfc6238.html#appendix-B
  for (final vector in <int, String>{
    59: '287082',
    1111111109: '081804',
    1111111111: '050471',
    1234567890: '005924',
    2000000000: '279037',
    20000000000: '353130',
  }.entries) {
    test('RFC 6238 SHA-1 vector at ${vector.key} seconds', () {
      expect(TotpUtil.generate(secret, at: time(vector.key)), vector.value);
      expect(
        TotpUtil.verify(secret, vector.value, at: time(vector.key)),
        isTrue,
      );
    });
  }

  test('verification accepts only the current and adjacent windows', () {
    final at = time(1234567890);
    for (final offset in [-2, -1, 0, 1, 2]) {
      final code = TotpUtil.generate(
        secret,
        at: at.add(Duration(seconds: offset * 30)),
      );
      expect(TotpUtil.verify(secret, code, at: at), offset.abs() <= 1);
    }
  });

  test('thirty-second boundary and leading zeroes are preserved', () {
    expect(TotpUtil.generate(secret, at: time(29)), '755224');
    expect(TotpUtil.generate(secret, at: time(30)), '287082');
    expect(TotpUtil.generate(secret, at: time(59)), '287082');
    expect(TotpUtil.generate(secret, at: time(60)), '359152');
    expect(TotpUtil.verify(secret, '005924', at: time(1234567890)), isTrue);
    expect(TotpUtil.verify(secret, '5924', at: time(1234567890)), isFalse);
  });

  test('invalid input is not silently sanitized into a valid secret', () {
    final code = TotpUtil.generate(secret, at: time(59));
    for (final value in [
      '',
      '====',
      '$secret!',
      '$secret ',
      ' $secret',
      'GEZD=GNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
      'A',
      'AAA',
      'AAAAAA',
      'MZ',
      'MY=',
      'MY=====',
      '$secret=',
      '$secret\n',
      'ıA',
      '密钥',
    ]) {
      expect(
        () => TotpUtil.generate(value, at: time(59)),
        throwsFormatException,
        reason: 'invalid Base32 should fail',
      );
      expect(TotpUtil.verify(value, code, at: time(59)), isFalse);
    }
  });

  test('lowercase and correctly padded Base32 remain interoperable', () {
    expect(TotpUtil.generate(secret.toLowerCase(), at: time(59)), '287082');
    for (final value in [
      'MY======',
      'MZXQ====',
      'MZXW6===',
      'MZXW6YQ=',
      'MZXW6YTB',
    ]) {
      expect(
        TotpUtil.generate(value, at: time(59)),
        TotpUtil.generate(
          value.replaceAll('=', '').toLowerCase(),
          at: time(59),
        ),
      );
    }
  });

  test(
    'non-ASCII, signed, spaced and wrong-length codes fail verification',
    () {
      for (final code in [
        '１２３４５６',
        '12345',
        '1234567',
        '-12345',
        '+12345',
        ' 287082',
        '287082 ',
        '287082\n',
        'ABCDEF',
        '',
      ]) {
        expect(TotpUtil.verify(secret, code, at: time(59)), isFalse);
      }
    },
  );

  test('epoch is supported and negative timestamps cannot be used', () {
    expect(TotpUtil.generate(secret, at: time(0)), '755224');
    expect(TotpUtil.verify(secret, '755224', at: time(0)), isTrue);
    expect(() => TotpUtil.generate(secret, at: time(-1)), throwsArgumentError);
    expect(TotpUtil.verify(secret, '755224', at: time(-1)), isFalse);
  });

  test(
    'default clock generates a code that verifies without a supplied time',
    () {
      expect(TotpUtil.verify(secret, TotpUtil.generate(secret)), isTrue);
    },
  );

  test('generated secrets use 160 bits of Base32 and produce valid codes', () {
    final generated = TotpUtil.generateSecret();
    expect(generated, matches(RegExp(r'^[A-Z2-7]{32}$')));
    final code = TotpUtil.generate(generated, at: time(59));
    expect(code, matches(RegExp(r'^[0-9]{6}$')));
    expect(TotpUtil.verify(generated, code, at: time(59)), isTrue);
  });

  test(
    'otpauth URI preserves reserved characters without query or fragment injection',
    () {
      const issuer = 'N42 / 钱包 #1? &+';
      const account = '用户+one/?#&=example@test.invalid';
      final uri = Uri.parse(
        TotpUtil.buildOtpAuthUri(
          secret: 'mzxw6===',
          account: account,
          issuer: issuer,
        ),
      );
      expect(uri.scheme, 'otpauth');
      expect(uri.host, 'totp');
      expect(uri.pathSegments, ['$issuer:$account']);
      expect(uri.fragment, isEmpty);
      expect(uri.queryParameters, {
        'secret': 'MZXW6',
        'issuer': issuer,
        'algorithm': 'SHA1',
        'digits': '6',
        'period': '30',
      });
      expect(
        () => TotpUtil.buildOtpAuthUri(secret: '', account: 'user'),
        throwsFormatException,
      );
      expect(
        Uri.parse(
          TotpUtil.buildOtpAuthUri(secret: secret, account: 'user'),
        ).queryParameters['issuer'],
        'N42 Wallet',
      );
    },
  );
}
