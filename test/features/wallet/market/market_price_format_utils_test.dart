import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_price_format_utils.dart';

void main() {
  test(
    'formatMarketPriceDisplay avoids scientific notation for tiny prices',
    () {
      expect(formatMarketPriceDisplay(0.00000001234), '0.00000001234');
    },
  );

  test(
    'formatMarketPriceInput caps tiny prices without scientific notation',
    () {
      expect(formatMarketPriceInput(0.00000001234), '0.00000001');
    },
  );

  test(
    'formatMarketPriceDisplay preserves grouped formatting for larger prices',
    () {
      expect(formatMarketPriceDisplay(1234.5678), '1,234.57');
      expect(formatMarketPriceDisplay(12.345678), '12.3457');
    },
  );
}
