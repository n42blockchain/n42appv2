import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_search_utils.dart';

void main() {
  group('shouldApplyMarketSearchResponse', () {
    test('accepts only the latest matching request', () {
      expect(
        shouldApplyMarketSearchResponse(
          requestId: 3,
          activeRequestId: 3,
          requestQuery: 'bitcoin',
          activeQuery: 'bitcoin',
        ),
        isTrue,
      );
    });

    test('rejects stale request ids', () {
      expect(
        shouldApplyMarketSearchResponse(
          requestId: 2,
          activeRequestId: 3,
          requestQuery: 'bit',
          activeQuery: 'bitcoin',
        ),
        isFalse,
      );
    });

    test('rejects empty or mismatched queries', () {
      expect(
        shouldApplyMarketSearchResponse(
          requestId: 4,
          activeRequestId: 4,
          requestQuery: 'bitcoin',
          activeQuery: 'eth',
        ),
        isFalse,
      );
      expect(
        shouldApplyMarketSearchResponse(
          requestId: 5,
          activeRequestId: 5,
          requestQuery: '   ',
          activeQuery: '   ',
        ),
        isFalse,
      );
    });
  });
}
