// Extended tests for group_album_entity — covers methods NOT in existing tests:
//   AlbumDateGroup (isToday, isYesterday, isThisWeek, displayTitle, groupByDate),
//   AlbumMonthGroup (displayTitle, groupByMonth),
//   AlbumMediaEntity (isImage, isVideo, aspectRatio, props)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_album_entity.dart';

AlbumMediaEntity _media({
  String eventId = 'ev1',
  AlbumMediaType type = AlbumMediaType.image,
  DateTime? sentAt,
  int? width,
  int? height,
}) =>
    AlbumMediaEntity(
      eventId: eventId,
      roomId: '!room:s',
      url: 'mxc://a/b',
      type: type,
      mimeType: type == AlbumMediaType.image ? 'image/jpeg' : 'video/mp4',
      size: 1024,
      senderId: '@alice:s',
      senderName: 'Alice',
      sentAt: sentAt ?? DateTime(2025, 6, 1),
      width: width,
      height: height,
    );

void main() {
  // ─────────────────────────────────────────────────
  // AlbumMediaType enum
  // ─────────────────────────────────────────────────

  group('AlbumMediaType', () {
    test('has image and video values', () {
      expect(AlbumMediaType.values, hasLength(2));
      expect(AlbumMediaType.values,
          containsAll([AlbumMediaType.image, AlbumMediaType.video]));
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumMediaEntity
  // ─────────────────────────────────────────────────

  group('AlbumMediaEntity', () {
    test('isImage / isVideo', () {
      expect(_media(type: AlbumMediaType.image).isImage, isTrue);
      expect(_media(type: AlbumMediaType.image).isVideo, isFalse);
      expect(_media(type: AlbumMediaType.video).isVideo, isTrue);
      expect(_media(type: AlbumMediaType.video).isImage, isFalse);
    });

    test('aspectRatio returns null when dimensions absent', () {
      expect(_media().aspectRatio, isNull);
    });

    test('aspectRatio computes correctly', () {
      final m = _media(width: 1280, height: 720);
      expect(m.aspectRatio, closeTo(1280 / 720, 0.001));
    });

    test('aspectRatio returns null when height is 0', () {
      final m = _media(width: 100, height: 0);
      expect(m.aspectRatio, isNull);
    });

    test('props equality', () {
      final ts = DateTime(2025, 6, 1);
      final a = _media(eventId: 'ev1', sentAt: ts);
      final b = _media(eventId: 'ev1', sentAt: ts);
      expect(a, equals(b));
    });

    test('props inequality when eventId differs', () {
      final a = _media(eventId: 'ev1');
      final b = _media(eventId: 'ev2');
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumDateGroup — date predicates
  // ─────────────────────────────────────────────────

  group('AlbumDateGroup.isToday', () {
    test('returns true for today', () {
      final today = DateTime.now();
      final group = AlbumDateGroup(
        date: DateTime(today.year, today.month, today.day),
        media: [_media()],
      );
      expect(group.isToday, isTrue);
    });

    test('returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final group = AlbumDateGroup(
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        media: [],
      );
      expect(group.isToday, isFalse);
    });
  });

  group('AlbumDateGroup.isYesterday', () {
    test('returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final group = AlbumDateGroup(
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        media: [],
      );
      expect(group.isYesterday, isTrue);
    });

    test('returns false for today', () {
      final today = DateTime.now();
      final group = AlbumDateGroup(
        date: DateTime(today.year, today.month, today.day),
        media: [],
      );
      expect(group.isYesterday, isFalse);
    });

    test('returns false for 2 days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final group = AlbumDateGroup(
        date: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day),
        media: [],
      );
      expect(group.isYesterday, isFalse);
    });
  });

  group('AlbumDateGroup.isThisWeek', () {
    test('returns true for today', () {
      final today = DateTime.now();
      final group = AlbumDateGroup(
        date: DateTime(today.year, today.month, today.day),
        media: [],
      );
      expect(group.isThisWeek, isTrue);
    });

    test('returns true for a date within the current week', () {
      final now = DateTime.now();
      // Use yesterday if not Monday, otherwise use today
      final offset = now.weekday > 1 ? 1 : 0;
      final withinWeek = now.subtract(Duration(days: offset));
      final group = AlbumDateGroup(
        date: DateTime(withinWeek.year, withinWeek.month, withinWeek.day),
        media: [],
      );
      expect(group.isThisWeek, isTrue);
    });

    test('returns false for a date far in the past', () {
      final group = AlbumDateGroup(
        date: DateTime(2020, 1, 1),
        media: [],
      );
      expect(group.isThisWeek, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumDateGroup.displayTitle
  // ─────────────────────────────────────────────────

  group('AlbumDateGroup.displayTitle', () {
    test('returns 今天 for today', () {
      final today = DateTime.now();
      final group = AlbumDateGroup(
        date: DateTime(today.year, today.month, today.day),
        media: [],
      );
      expect(group.displayTitle, '今天');
    });

    test('returns 昨天 for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final group = AlbumDateGroup(
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        media: [],
      );
      expect(group.displayTitle, '昨天');
    });

    test('returns M月D日 for same year (not today/yesterday)', () {
      final sameYear = DateTime(DateTime.now().year, 1, 5);
      final group = AlbumDateGroup(date: sameYear, media: []);
      expect(group.displayTitle, '1月5日');
    });

    test('returns Y年M月D日 for previous year', () {
      final group = AlbumDateGroup(date: DateTime(2022, 3, 10), media: []);
      expect(group.displayTitle, '2022年3月10日');
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumDateGroup.props equality
  // ─────────────────────────────────────────────────

  group('AlbumDateGroup.props', () {
    test('two identical instances are equal', () {
      final d = DateTime(2025, 6, 1);
      final a = AlbumDateGroup(date: d, media: []);
      final b = AlbumDateGroup(date: d, media: []);
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumDateGroup.groupByDate
  // ─────────────────────────────────────────────────

  group('AlbumDateGroup.groupByDate', () {
    test('returns empty for empty input', () {
      expect(AlbumDateGroup.groupByDate([]), isEmpty);
    });

    test('groups items by date and sorts descending', () {
      final media = [
        _media(eventId: 'a', sentAt: DateTime(2025, 6, 1, 10)),
        _media(eventId: 'b', sentAt: DateTime(2025, 6, 3, 12)),
        _media(eventId: 'c', sentAt: DateTime(2025, 6, 1, 15)),
      ];
      final groups = AlbumDateGroup.groupByDate(media);
      // 2 distinct dates: June 3 and June 1
      expect(groups.length, 2);
      // most recent date first
      expect(groups.first.date.day, 3);
      expect(groups.last.date.day, 1);
      // June 1 has 2 items
      expect(groups.last.media.length, 2);
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumMonthGroup.displayTitle
  // ─────────────────────────────────────────────────

  group('AlbumMonthGroup.displayTitle', () {
    test('returns N月 for current year', () {
      final now = DateTime.now();
      final group = AlbumMonthGroup(year: now.year, month: 6, media: []);
      expect(group.displayTitle, '6月');
    });

    test('returns Y年N月 for previous year', () {
      const group = AlbumMonthGroup(year: 2022, month: 11, media: []);
      expect(group.displayTitle, '2022年11月');
    });
  });

  group('AlbumMonthGroup.props', () {
    test('two identical instances are equal', () {
      const a = AlbumMonthGroup(year: 2025, month: 6, media: []);
      const b = AlbumMonthGroup(year: 2025, month: 6, media: []);
      expect(a, equals(b));
    });

    test('different month → not equal', () {
      const a = AlbumMonthGroup(year: 2025, month: 6, media: []);
      const b = AlbumMonthGroup(year: 2025, month: 7, media: []);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // AlbumMonthGroup.groupByMonth
  // ─────────────────────────────────────────────────

  group('AlbumMonthGroup.groupByMonth', () {
    test('returns empty for empty input', () {
      expect(AlbumMonthGroup.groupByMonth([]), isEmpty);
    });

    test('groups items by month and sorts descending', () {
      final media = [
        _media(eventId: 'a', sentAt: DateTime(2025, 3, 10)),
        _media(eventId: 'b', sentAt: DateTime(2025, 6, 5)),
        _media(eventId: 'c', sentAt: DateTime(2025, 3, 20)),
      ];
      final groups = AlbumMonthGroup.groupByMonth(media);
      expect(groups.length, 2);
      // Most recent month first
      expect(groups.first.month, 6);
      expect(groups.last.month, 3);
      expect(groups.last.media.length, 2);
    });
  });
}
