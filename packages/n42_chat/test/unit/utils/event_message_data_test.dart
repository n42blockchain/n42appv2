import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/event_message_data.dart';

void main() {
  final start = DateTime.fromMillisecondsSinceEpoch(1800000000000); // fixed
  final end = start.add(const Duration(hours: 2));

  group('toContent / fromContent', () {
    test('round-trips full event', () {
      final data = EventMessageData(
        title: 'Launch',
        startsAt: start,
        endsAt: end,
        location: 'HQ',
        description: 'Quarterly launch',
      );
      final restored = EventMessageData.fromContent(data.toContent());
      expect(restored, data);
    });

    test('omits empty optional fields in content', () {
      final data = EventMessageData(title: 'Solo', startsAt: start);
      final content = data.toContent();
      expect(content.containsKey('ends_at'), isFalse);
      expect(content.containsKey('location'), isFalse);
      expect(content.containsKey('description'), isFalse);
      expect(content['title'], 'Solo');
      expect(content['starts_at'], start.millisecondsSinceEpoch);
    });

    test('fromContent returns null without title or starts_at', () {
      expect(EventMessageData.fromContent({'starts_at': 1}), isNull);
      expect(EventMessageData.fromContent({'title': 'x'}), isNull);
      expect(
        EventMessageData.fromContent({'title': '  ', 'starts_at': 1}),
        isNull,
      );
      expect(
        EventMessageData.fromContent({'title': 'x', 'starts_at': 'notint'}),
        isNull,
      );
    });
  });

  group('isPast', () {
    test('uses endsAt when present', () {
      final data = EventMessageData(title: 't', startsAt: start, endsAt: end);
      expect(data.isPast(end.add(const Duration(minutes: 1))), isTrue);
      expect(data.isPast(start.add(const Duration(minutes: 1))), isFalse);
    });

    test('falls back to startsAt when no end', () {
      final data = EventMessageData(title: 't', startsAt: start);
      expect(data.isPast(start.subtract(const Duration(minutes: 1))), isFalse);
      expect(data.isPast(start.add(const Duration(minutes: 1))), isTrue);
    });
  });

  group('toIcs', () {
    test('contains required VEVENT fields and UTC stamps', () {
      final data = EventMessageData(
        title: 'Meet',
        startsAt: start,
        endsAt: end,
        location: 'Room 1',
      );
      final ics = data.toIcs();
      expect(ics, contains('BEGIN:VCALENDAR'));
      expect(ics, contains('BEGIN:VEVENT'));
      expect(ics, contains('SUMMARY:Meet'));
      expect(ics, contains('LOCATION:Room 1'));
      expect(ics, contains('END:VEVENT'));
      expect(ics, contains(RegExp(r'DTSTART:\d{8}T\d{6}Z')));
      expect(ics, contains(RegExp(r'DTEND:\d{8}T\d{6}Z')));
    });

    test('escapes special characters', () {
      final data = EventMessageData(
        title: 'A; B, C\\D',
        startsAt: start,
      );
      final ics = data.toIcs();
      expect(ics, contains(r'SUMMARY:A\; B\, C\\D'));
    });
  });

  test('fallbackBody includes emoji, title and time', () {
    final data = EventMessageData(title: 'Party', startsAt: start);
    expect(data.fallbackBody, startsWith('📅 Party — '));
  });

  test('formatRange collapses same-day end to time only', () {
    final s = DateTime(2030, 5, 1, 9, 0);
    final e = DateTime(2030, 5, 1, 11, 30);
    expect(EventMessageData.formatRange(s, e), '2030-05-01 09:00 - 11:30');
  });
}
