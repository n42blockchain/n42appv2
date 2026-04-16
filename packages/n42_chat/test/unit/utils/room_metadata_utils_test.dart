import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/room_metadata_utils.dart';

void main() {
  group('buildMatrixToRoomLink', () {
    test('prefers canonical alias when available', () {
      final link = buildMatrixToRoomLink(
        roomId: '!room:matrix.org',
        canonicalAlias: '#n42:matrix.org',
      );

      expect(link, 'https://matrix.to/#/%23n42%3Amatrix.org?via=matrix.org');
    });

    test('falls back to room id and via server', () {
      final link = buildMatrixToRoomLink(roomId: '!room:matrix.org');

      expect(link, 'https://matrix.to/#/!room%3Amatrix.org?via=matrix.org');
    });
  });

  group('extractAliasLocalpart', () {
    test('returns localpart for canonical alias', () {
      expect(
        extractAliasLocalpart('#announcements:matrix.org'),
        'announcements',
      );
    });

    test('returns null for invalid aliases', () {
      expect(extractAliasLocalpart(null), isNull);
      expect(extractAliasLocalpart('!room:matrix.org'), isNull);
    });
  });

  group('hashtags', () {
    test('extractHashtagsFromTexts deduplicates and normalizes', () {
      final tags = extractHashtagsFromTexts([
        'Welcome to #N42 #crypto',
        'More about #crypto and #Matrix',
      ]);

      expect(tags, ['#n42', '#crypto', '#matrix']);
    });

    test('normalizeTopicLabels accepts plain labels', () {
      final tags = normalizeTopicLabels('Defi, Trading community');

      expect(tags, ['#defi', '#trading', '#community']);
    });
  });

  group('normalizeChannelCategory', () {
    test('trims and collapses whitespace', () {
      expect(
        normalizeChannelCategory('  Product   Updates  '),
        'Product Updates',
      );
    });

    test('returns null for blank input', () {
      expect(normalizeChannelCategory('   '), isNull);
      expect(normalizeChannelCategory(null), isNull);
    });
  });
}
