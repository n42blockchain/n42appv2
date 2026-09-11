import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';

void main() {
  test(
    'raw quote output uses the selected token precision and floors min output',
    () {
      final q = DexQuoteModel.fromJson(
        {'amount_out': 'wrong legacy value', 'amount_out_raw': '1234567'},
        outputDecimals: 6,
        slippageBps: 50,
      );
      expect(q.amountOut, '1.234567');
      expect(q.minAmountOut, '1.228394');
    },
  );
  test('legacy whole-number output retains fractional slippage', () {
    final q = DexQuoteModel.fromJson({'amount_out': '100'}, slippageBps: 50);
    expect(q.minAmountOut, '99.5');
  });
  test('one wei and large integers never round through floating point', () {
    expect(dexBaseUnitsToDecimal(BigInt.one, 18), '0.000000000000000001');
    expect(
      dexBaseUnitsToDecimal(BigInt.parse('9007199254740993'), 0),
      '9007199254740993',
    );
  });
  test('malformed raw amounts and unsupported precision are rejected', () {
    for (final raw in ['bad', '-1', '0']) {
      expect(
        () =>
            DexQuoteModel.fromJson({'amount_out_raw': raw}, outputDecimals: 6),
        throwsFormatException,
      );
    }
    expect(() => dexBaseUnitsToDecimal(BigInt.one, 256), throwsFormatException);
  });
}
