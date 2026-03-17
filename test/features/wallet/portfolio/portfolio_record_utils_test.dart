import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_record_utils.dart';

void main() {
  test(
    'portfolioRecordFromCoinModel keeps holdings with balance even when price is unavailable',
    () {
      final coin =
          CoinModel.fromMap({
              'miniName': 'ETH',
              'coinType': 'ETH',
              'name': 'Ethereum',
              'icon': '',
              'decimals': 18,
            })
            ..balance = BigInt.parse('1000000000000000000')
            ..value = 0;

      final record = portfolioRecordFromCoinModel(coin);

      expect(record, isNotNull);
      expect(record?.symbol, 'ETH');
      expect(record?.value, 0.0);
    },
  );

  test('portfolioRecordFromCoinModel excludes zero-balance holdings', () {
    final coin =
        CoinModel.fromMap({
            'miniName': 'USDT',
            'coinType': 'ETH',
            'name': 'Tether',
            'icon': '',
            'decimals': 6,
          })
          ..balance = BigInt.zero
          ..value = 12.0;

    expect(portfolioRecordFromCoinModel(coin), isNull);
  });
}
