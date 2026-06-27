import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/notification_filter_rules.dart';

void main() {
  group('evaluate', () {
    test('neutral when no rules', () {
      const rules = NotificationFilterRules();
      expect(
        rules.evaluate(body: 'anything', senderId: '@a:b'),
        NotificationFilterDecision.neutral,
      );
    });

    test('priority keyword forces priority (case-insensitive by default)', () {
      const rules = NotificationFilterRules(priorityKeywords: ['Urgent']);
      expect(
        rules.evaluate(body: 'this is URGENT now'),
        NotificationFilterDecision.priority,
      );
    });

    test('muted keyword suppresses', () {
      const rules = NotificationFilterRules(mutedKeywords: ['spam']);
      expect(
        rules.evaluate(body: 'buy spam cheap'),
        NotificationFilterDecision.muted,
      );
    });

    test('priority sender forces priority', () {
      const rules = NotificationFilterRules(prioritySenders: ['@boss:server']);
      expect(
        rules.evaluate(body: 'hi', senderId: '@boss:server'),
        NotificationFilterDecision.priority,
      );
    });

    test('priority wins over muted when both match', () {
      const rules = NotificationFilterRules(
        priorityKeywords: ['urgent'],
        mutedKeywords: ['spam'],
      );
      expect(
        rules.evaluate(body: 'urgent spam'),
        NotificationFilterDecision.priority,
      );
    });

    test('case sensitivity respected when enabled', () {
      const rules = NotificationFilterRules(
        priorityKeywords: ['Urgent'],
        caseSensitive: true,
      );
      expect(
        rules.evaluate(body: 'urgent lowercase'),
        NotificationFilterDecision.neutral,
      );
      expect(
        rules.evaluate(body: 'Urgent exact'),
        NotificationFilterDecision.priority,
      );
    });

    test('blank/whitespace keywords are ignored', () {
      const rules = NotificationFilterRules(mutedKeywords: ['   ', '']);
      expect(
        rules.evaluate(body: 'whatever'),
        NotificationFilterDecision.neutral,
      );
    });
  });

  group('json round-trip', () {
    test('encode/decode preserves rules', () {
      const rules = NotificationFilterRules(
        priorityKeywords: ['a', 'b'],
        mutedKeywords: ['c'],
        prioritySenders: ['@x:y'],
        caseSensitive: true,
      );
      final restored = NotificationFilterRules.decode(rules.encode());
      expect(restored, rules);
    });

    test('decode of null/garbage returns empty', () {
      expect(NotificationFilterRules.decode(null), NotificationFilterRules.empty);
      expect(NotificationFilterRules.decode('not json'),
          NotificationFilterRules.empty);
      expect(NotificationFilterRules.decode('  '),
          NotificationFilterRules.empty);
    });
  });

  test('isEmpty reflects presence of any rule', () {
    expect(const NotificationFilterRules().isEmpty, isTrue);
    expect(
      const NotificationFilterRules(priorityKeywords: ['x']).isEmpty,
      isFalse,
    );
  });
}
