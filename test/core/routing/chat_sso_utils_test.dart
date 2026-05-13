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

    // Extended boundary tests for the chat integration contract.
    // These guard against regressions when bumping the chat ref.

    test('returns null when both inputs are null', () {
      expect(normalizeChatSsoHomeserver(null), isNull);
    });

    test('returns null for whitespace-only inputs on both sides', () {
      expect(
        normalizeChatSsoHomeserver('   ', fallbackHomeserver: '\t'),
        isNull,
      );
    });

    test('strips multiple trailing slashes', () {
      expect(
        normalizeChatSsoHomeserver('https://m.example.com///'),
        'https://m.example.com',
      );
    });

    test('keeps path segments, only strips trailing slash', () {
      expect(
        normalizeChatSsoHomeserver('https://example.com/matrix/'),
        'https://example.com/matrix',
      );
    });

    test('drops query and fragment', () {
      expect(
        normalizeChatSsoHomeserver('https://m.example.com/?foo=bar#frag'),
        'https://m.example.com',
      );
    });

    test('strips userinfo (credentials must not leak to homeserver string)', () {
      expect(
        normalizeChatSsoHomeserver('https://user:pass@m.example.com'),
        'https://m.example.com',
      );
    });

    test('lowercases scheme', () {
      expect(
        normalizeChatSsoHomeserver('HTTPS://m.example.com'),
        'https://m.example.com',
      );
    });

    test('accepts http scheme (for local/test homeservers)', () {
      expect(
        normalizeChatSsoHomeserver('http://localhost:8008'),
        'http://localhost:8008',
      );
    });

    test('rejects file:// scheme (no local-fs surface)', () {
      expect(
        normalizeChatSsoHomeserver('file:///etc/passwd'),
        isNull,
      );
    });

    test('rejects ftp:// scheme', () {
      expect(
        normalizeChatSsoHomeserver('ftp://m.example.com'),
        isNull,
      );
    });

    test('rejects URI without scheme', () {
      expect(
        normalizeChatSsoHomeserver('m.example.com'),
        isNull,
      );
    });

    test('rejects URI with scheme but empty host', () {
      expect(
        normalizeChatSsoHomeserver('https://'),
        isNull,
      );
    });

    test('preserves non-default port', () {
      expect(
        normalizeChatSsoHomeserver('https://m.example.com:8448'),
        'https://m.example.com:8448',
      );
    });

    test('prefers explicit over fallback when explicit is valid', () {
      expect(
        normalizeChatSsoHomeserver(
          'https://primary.example.com',
          fallbackHomeserver: 'https://fallback.example.com',
        ),
        'https://primary.example.com',
      );
    });
  });
}
