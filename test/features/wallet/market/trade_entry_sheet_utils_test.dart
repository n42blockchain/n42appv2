import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/trade_entry_sheet_utils.dart';

void main() {
  group('trade entry sheet utils', () {
    test(
      'initialTradeEntryPrice preserves tiny prices instead of rounding to zero',
      () {
        expect(initialTradeEntryPrice(0.00000001234), '0.00000001');
      },
    );

    test(
      'initialTradeEntryPrice returns empty string for non-positive values',
      () {
        expect(initialTradeEntryPrice(0), isEmpty);
        expect(initialTradeEntryPrice(-1), isEmpty);
      },
    );

    test('canDismissTradeEntrySheet blocks dismiss while saving', () {
      expect(canDismissTradeEntrySheet(true), isFalse);
      expect(canDismissTradeEntrySheet(false), isTrue);
    });
  });
}
