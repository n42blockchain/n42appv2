import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/ai_assistant/presentation/wallet_ai_snapshot_builder.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  group('buildWalletAiSnapshot', () {
    test('builds display-only assets sorted by USD value', () {
      final eth = _coin(
        miniName: 'ETH',
        name: 'Ethereum',
        coinType: 'ETH',
        rawBalance: '1000000000000000000',
        decimals: 18,
        value: 3200,
      );
      final usdc = _coin(
        miniName: 'USDC',
        name: 'USD Coin',
        coinType: 'ETH',
        rawBalance: '25000000',
        decimals: 6,
        value: 25,
        isContract: true,
      );
      final dust = _coin(
        miniName: 'DUST',
        name: 'Dust',
        coinType: 'ETH',
        rawBalance: '0',
        decimals: 18,
        value: 0,
        isContract: true,
      );

      final snapshot = buildWalletAiSnapshot(
        totalUsd: 3225,
        coins: [usdc, dust, eth],
      );

      expect(snapshot.totalUsd, 3225);
      expect(snapshot.chainName, 'Ethereum');
      expect(snapshot.assets.map((asset) => asset.symbol), ['ETH', 'USDC']);
      expect(snapshot.assets.first.balance, '1');
      expect(snapshot.assets.last.balance, '25');
    });

    test('falls back to coin type and reports multi-chain wallets', () {
      final btc = _coin(
        name: 'Bitcoin',
        coinType: 'BTC',
        rawBalance: '100000000',
        decimals: 8,
        value: 60000,
      );
      final noTicker = _coin(
        name: '',
        coinType: 'DOGE',
        rawBalance: '42',
        decimals: 0,
        value: 4.2,
      );

      final snapshot = buildWalletAiSnapshot(
        totalUsd: 60004.2,
        coins: [noTicker, btc],
      );

      expect(snapshot.chainName, 'Multi-chain');
      expect(snapshot.assets.map((asset) => asset.symbol), ['BTC', 'DOGE']);
    });

    test('keeps non-USD positive balances and skips hidden coins', () {
      final visible = _coin(
        miniName: 'N',
        name: 'N42',
        coinType: 'N',
        rawBalance: '10',
        decimals: 0,
        value: 0,
      );
      final hidden = _coin(
        miniName: 'HIDE',
        name: 'Hidden',
        coinType: 'HIDE',
        rawBalance: '100',
        decimals: 0,
        value: 100,
        showList: false,
      );

      final snapshot = buildWalletAiSnapshot(
        totalUsd: 0,
        coins: [hidden, visible],
      );

      expect(snapshot.assets.map((asset) => asset.symbol), ['N']);
      expect(snapshot.assets.single.usdValue, 0);
    });
  });
}

CoinModel _coin({
  String miniName = '',
  String name = '',
  String coinType = '',
  String rawBalance = '0',
  int decimals = 18,
  double value = 0,
  bool isContract = false,
  bool showList = true,
}) {
  final coin = CoinModel.fromMap({
    'miniName': miniName,
    'name': name,
    'coinType': coinType,
    'mKey': coinType,
    'decimals': decimals,
    'isContract': isContract,
  });
  coin.balance = BigInt.parse(rawBalance);
  coin.value = value;
  coin.showList = showList;
  return coin;
}
