import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/routing/chat_sso_utils.dart';

void main() {
  group('normalizeChatSsoHomeserver', () {
    test('normalizes valid explicit homeserver and strips trailing slash', () {
      final value = normalizeChatSsoHomeserver(' https://m.si46.world/ ');

      expect(value, 'https://m.si46.world');
    });

    test('uses fallback homeserver when explicit value is missing', () {
      final value = normalizeChatSsoHomeserver(
        '',
        fallbackHomeserver: 'https://matrix.example.com/',
      );

      expect(value, 'https://matrix.example.com');
    });

    test('rejects unsupported schemes', () {
      final value = normalizeChatSsoHomeserver('javascript:alert(1)');

      expect(value, isNull);
    });

    test('does not silently replace invalid explicit homeserver with fallback', () {
      final value = normalizeChatSsoHomeserver(
        'not-a-url',
        fallbackHomeserver: 'https://matrix.example.com',
      );

      expect(value, isNull);
    });
  });
}
