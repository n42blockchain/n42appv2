import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/pages/today_mining_price_utils.dart';

void main() {
  test('extractAstPriceFromMarketPayload supports nested data payloads', () {
    expect(
      extractAstPriceFromMarketPayload({
        'data': {
          'data': [
            {'coin': 'n', 'price': '1.23'},
          ],
        },
      }),
      1.23,
    );
  });

  test(
    'extractAstPriceFromMarketPayload ignores unrelated or invalid items',
    () {
      expect(
        extractAstPriceFromMarketPayload([
          {'coin': 'eth', 'price': '2000'},
          {'coin': 'n', 'price': ''},
        ]),
        0,
      );
    },
  );
}
