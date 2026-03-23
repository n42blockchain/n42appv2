import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/external_http.dart';

void main() {
  group('ExternalHttp.sanitizeUrlForLogging', () {
    test('redacts query parameter values', () {
      final sanitized = ExternalHttp.sanitizeUrlForLogging(
        'https://example.com/api?address=0xabc&token=secret',
      );

      expect(sanitized, contains('address=%5Bredacted%5D'));
      expect(sanitized, contains('token=%5Bredacted%5D'));
      expect(sanitized, isNot(contains('0xabc')));
      expect(sanitized, isNot(contains('secret')));
    });

    test('returns original url when there is no query string', () {
      const url = 'https://example.com/api/path';
      expect(ExternalHttp.sanitizeUrlForLogging(url), url);
    });
  });
}
