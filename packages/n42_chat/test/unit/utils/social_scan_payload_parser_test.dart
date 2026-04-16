import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/social_scan_payload_parser.dart';

void main() {
  group('parseSocialScanPayload', () {
    test('parses Matrix user ids from custom scheme and matrix.to links', () {
      expect(
        parseSocialScanPayload('n42chat://user/@alice:example.org')?.userId,
        '@alice:example.org',
      );
      expect(
        parseSocialScanPayload(
          'https://matrix.to/#/%40bob%3Aexample.org',
        )?.userId,
        '@bob:example.org',
      );
      expect(
        parseSocialScanPayload(
          'https://matrix.to/#/%40carol%3Aexample.org?action=chat',
        )?.userId,
        '@carol:example.org',
      );
    });

    test('parses built-in mini apps from deep links and trusted urls', () {
      final byId = parseSocialScanPayload('n42chat://miniapp/n42_swap');
      expect(byId?.miniApp?.id, 'n42_swap');
      expect(byId?.miniAppLaunchUrl, isNull);

      final byUrl = parseSocialScanPayload('https://swap.n42.world');
      expect(byUrl?.miniApp?.id, 'n42_swap');
      expect(byUrl?.miniAppLaunchUrl, 'https://swap.n42.world');

      final byDeepLink = parseSocialScanPayload(
        'https://swap.n42.world/pools/eth?ref=n42',
      );
      expect(byDeepLink?.miniApp?.id, 'n42_swap');
      expect(
        byDeepLink?.miniAppLaunchUrl,
        'https://swap.n42.world/pools/eth?ref=n42',
      );

      final byTrailingSlash = parseSocialScanPayload('https://swap.n42.world/');
      expect(byTrailingSlash?.miniApp?.id, 'n42_swap');
      expect(byTrailingSlash?.miniAppLaunchUrl, 'https://swap.n42.world/');
    });

    test('rejects unsupported payloads and untrusted mini app urls', () {
      expect(parseSocialScanPayload('hello world'), isNull);
      expect(parseSocialScanPayload('http://swap.n42.world'), isNull);
      expect(parseSocialScanPayload('https://example.com'), isNull);
    });
  });
}
