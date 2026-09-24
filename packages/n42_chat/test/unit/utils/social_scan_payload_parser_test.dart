import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/social_scan_payload_parser.dart';

void main() {
  group('parseSocialScanPayload', () {
    test('builds a standard encoded Matrix user permalink', () {
      expect(
        buildMatrixUserPermalink('@alice:example.org'),
        'https://matrix.to/#/%40alice%3Aexample.org',
      );
    });
    test('parses Matrix user permalinks and legacy N42 user payloads', () {
      final matrix = parseSocialScanPayload(
        'https://matrix.to/#/@alice:example.org',
      );
      expect(matrix?.type, SocialScanPayloadType.matrixUser);
      expect(matrix?.userId, '@alice:example.org');

      final legacy = parseSocialScanPayload(
        'n42chat://user/@alice:example.org',
      );
      expect(legacy?.type, SocialScanPayloadType.matrixUser);
      expect(legacy?.userId, '@alice:example.org');
    });

    test('parses Matrix room, alias, and space permalinks', () {
      for (final target in [
        '!room:example.org',
        '#room:example.org',
        '!space:example.org',
      ]) {
        final payload = parseSocialScanPayload(
          'https://matrix.to/#/${Uri.encodeComponent(target)}',
        );
        expect(payload?.type, SocialScanPayloadType.matrixRoom);
        expect(payload?.roomIdOrAlias, target);
      }
    });

    test('parses an allowlisted WhatsApp Click to Chat number', () {
      final payload = parseSocialScanPayload('https://wa.me/14155552671');
      expect(payload?.type, SocialScanPayloadType.whatsappContact);
      expect(payload?.whatsappNumber, '14155552671');
      expect(payload?.externalUri.toString(), 'https://wa.me/14155552671');
    });

    test('rejects unsafe WhatsApp URL variants and invalid E.164 numbers', () {
      for (final raw in [
        'http://wa.me/14155552671',
        'https://wa.me.evil.test/14155552671',
        'https://user@wa.me/14155552671',
        'https://wa.me:443/14155552671',
        'https://wa.me/14155552671/extra',
        'https://wa.me/14155552671?text=hello',
        'https://wa.me/01234567',
        'https://wa.me/1234567',
        'https://wa.me/1234567890123456',
      ]) {
        expect(parseSocialScanPayload(raw), isNull, reason: raw);
      }
    });

    test('rejects Matrix lookalike hosts and non-HTTPS links', () {
      expect(
        parseSocialScanPayload('https://matrix.to.evil/#/@alice:example.org'),
        isNull,
      );
      expect(
        parseSocialScanPayload('http://matrix.to/#/@alice:example.org'),
        isNull,
      );
    });
  });
}
