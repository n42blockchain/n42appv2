import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/loyalty/loyalty_wallet_address.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  const n42 = '0x1111111111111111111111111111111111111111';
  const ethereum = '0x2222222222222222222222222222222222222222';

  test('prefers the N42 address over list order and other EVM chains', () {
    final coins = [
      _coin('BTC', 'bc1qtest'),
      _coin('ETH', ethereum),
      _coin('N', n42),
    ];

    expect(selectLoyaltyWalletAddress(coins), n42);
  });

  test('falls back to a valid EVM address and rejects non-EVM values', () {
    expect(
      selectLoyaltyWalletAddress([
        _coin('BTC', 'bc1qtest'),
        _coin('BASE', ethereum),
      ]),
      ethereum,
    );
    expect(selectLoyaltyWalletAddress([_coin('SOL', 'solana')]), isEmpty);
  });
}

CoinModel _coin(String type, String address) {
  return CoinModel()
    ..coin = {'coinType': type}
    ..address = address;
}
