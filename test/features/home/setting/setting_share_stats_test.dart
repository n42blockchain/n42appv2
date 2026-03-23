import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';

void main() {
  group('setting share stats helpers', () {
    test('parseShareStatCount falls back to zero for malformed values', () {
      expect(parseShareStatCount(12), 12);
      expect(parseShareStatCount('34'), 34);
      expect(parseShareStatCount('N/A'), 0);
      expect(parseShareStatCount(null), 0);
    });

    test('parseShareStatReward falls back to zero for malformed values', () {
      expect(parseShareStatReward(1.25), 1.25);
      expect(parseShareStatReward('2.5'), 2.5);
      expect(parseShareStatReward('oops'), 0);
      expect(parseShareStatReward(null), 0);
    });

    test('safeShareStatsRequest swallows request exceptions', () async {
      final result = await safeShareStatsRequest(
        () async => throw Exception('offline'),
      );

      expect(result, isNull);
    });
  });
}
