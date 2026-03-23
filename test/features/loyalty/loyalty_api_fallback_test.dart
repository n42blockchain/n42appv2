import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/loyalty/api/loyalty_api.dart';

void main() {
  group('buildLoyaltyFallbackResult', () {
    test('returns error in release mode instead of fake success', () {
      final result = buildLoyaltyFallbackResult(
        isDebug: false,
        unavailableMessage: 'Referral code unavailable',
        debugData: () => {'code': 'N42-DEBUG'},
      );

      expect(result.error, isTrue);
      expect(result.data, 'Referral code unavailable');
    });

    test('returns debug fallback data in debug mode', () {
      final result = buildLoyaltyFallbackResult(
        isDebug: true,
        debugData: () => <String>['mock'],
      );

      expect(result.error, isFalse);
      expect(result.data, ['mock']);
    });
  });
}
