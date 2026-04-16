import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/remark_service.dart';

void main() {
  // ─────────────────────────────────────────────────
  // RemarkUpdateEvent — plain data class
  // ─────────────────────────────────────────────────

  group('RemarkUpdateEvent', () {
    test('stores userId and remark', () {
      const event = RemarkUpdateEvent(userId: '@alice:s', remark: 'My Alice');
      expect(event.userId, '@alice:s');
      expect(event.remark, 'My Alice');
    });

    test('remark defaults to null', () {
      const event = RemarkUpdateEvent(userId: '@bob:s');
      expect(event.remark, isNull);
    });

    test('supports null remark (cleared)', () {
      const event = RemarkUpdateEvent(userId: '@carol:s', remark: null);
      expect(event.remark, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // RemarkService — pure/cache-based behaviors
  //
  // The singleton's _remarkCache starts empty.
  // We only test methods that don't require GetIt
  // (getRemark, getDisplayName, getAllRemarks, onRemarkUpdated).
  // ─────────────────────────────────────────────────

  group('RemarkService.instance', () {
    test('returns a RemarkService instance', () {
      expect(RemarkService.instance, isA<RemarkService>());
    });

    test('always returns the same singleton', () {
      final a = RemarkService.instance;
      final b = RemarkService.instance;
      expect(identical(a, b), isTrue);
    });
  });

  group('RemarkService.getRemark', () {
    test('returns null for unknown userId (empty cache)', () {
      expect(RemarkService.instance.getRemark('@unknown:s'), isNull);
    });
  });

  group('RemarkService.getDisplayName', () {
    test('returns originalName when no remark exists', () {
      final name = RemarkService.instance.getDisplayName(
        '@unknown:s',
        'Alice',
      );
      expect(name, 'Alice');
    });

    test('returns originalName when remark is empty string (not in cache)', () {
      // The cache only stores non-empty remarks, so empty remark means
      // the key is absent and originalName is returned.
      final name = RemarkService.instance.getDisplayName('@new:s', 'Bob');
      expect(name, 'Bob');
    });
  });

  group('RemarkService.getAllRemarks', () {
    test('returns an empty map initially', () {
      // This assumes no other test has called setRemark (which requires GetIt).
      // Since we avoid calling setRemark in these tests, the cache stays empty.
      final remarks = RemarkService.instance.getAllRemarks();
      expect(remarks, isA<Map<String, String>>());
      // Should be a defensive copy, not the original map
      remarks['injected'] = 'value';
      expect(RemarkService.instance.getAllRemarks().containsKey('injected'), isFalse);
    });
  });

  group('RemarkService.onRemarkUpdated', () {
    test('is a broadcast stream that can be listened to multiple times', () async {
      final stream = RemarkService.instance.onRemarkUpdated;
      expect(stream, isA<Stream<RemarkUpdateEvent>>());

      // Broadcast streams support multiple listeners
      final sub1 = stream.listen((_) {});
      final sub2 = stream.listen((_) {});
      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('RemarkService.getDisplayName — priority logic', () {
    // Without direct cache manipulation, we verify the fallback behavior.
    // The remark priority: remark (non-empty) > originalName.
    test('empty originalName returns empty when no remark', () {
      final name = RemarkService.instance.getDisplayName('@user:s', '');
      expect(name, '');
    });

    test('originalName with special characters is returned as-is', () {
      final name = RemarkService.instance.getDisplayName(
        '@user:s',
        'Alice 👩‍💻',
      );
      expect(name, 'Alice 👩‍💻');
    });
  });
}
