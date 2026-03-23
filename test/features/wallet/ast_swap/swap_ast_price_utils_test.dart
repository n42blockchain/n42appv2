import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_price_utils.dart';

void main() {
  test('findSwapAstMarketCoin matches symbol case-insensitively', () {
    final result = findSwapAstMarketCoin([
      {'coin': 'N', 'price': 1.2},
      {'coin': 'usdt', 'price': 1.0},
    ], 'n');

    expect(result, isNotNull);
    expect(result?['price'], 1.2);
  });

  test('calculateSwapAstConvertedAmount guards missing prices', () {
    expect(
      calculateSwapAstConvertedAmount(value: '12', fromPrice: 0, toPrice: 1),
      0,
    );
    expect(
      calculateSwapAstConvertedAmount(value: '12', fromPrice: 1, toPrice: 0),
      0,
    );
  });

  test('calculateSwapAstConvertedAmount converts by price ratio', () {
    expect(
      calculateSwapAstConvertedAmount(value: '10', fromPrice: 2, toPrice: 0.5),
      40,
    );
  });
}
