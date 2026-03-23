import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/watch_only_wallet_utils.dart';

void main() {
  Map<String, dynamic> ethChain(String key) {
    return {
      'baseInfo': {'mKey': key, 'blockchainType': BlockchainType.Ethereum.name},
    };
  }

  test('buildWatchOnlyCoinInfo keeps only Ethereum-compatible chains', () {
    final result = buildWatchOnlyCoinInfo({
      'ETH': ethChain('ETH'),
      'SOL': {
        'baseInfo': {
          'mKey': 'SOL',
          'blockchainType': BlockchainType.Solana.name,
        },
      },
    });

    expect(result.keys, ['ETH']);
  });

  test(
    'normalizeWatchOnlyWallet trims address and removes unsupported chains',
    () {
      final wallet = WalletInfo(walletName: 'Watch')
        ..watchOnly = true
        ..watchAddress = ' 0xabc '
        ..coinInfo = {
          'ETH': ethChain('ETH'),
          'SOL': {
            'baseInfo': {
              'mKey': 'SOL',
              'blockchainType': BlockchainType.Solana.name,
            },
          },
        };

      final changed = normalizeWatchOnlyWallet(
        wallet,
        supportedChains: {
          'ETH': ethChain('ETH'),
          'N': ethChain(CoinType.N.name),
        },
      );

      expect(changed, isTrue);
      expect(wallet.watchAddress, '0xabc');
      expect(wallet.coinInfo?.keys.toSet(), {'ETH', 'N'});
    },
  );

  test('normalizeWatchOnlyWallet ignores regular wallets', () {
    final wallet = WalletInfo(walletName: 'Regular')
      ..watchOnly = false
      ..coinInfo = {'SOL': {}};

    expect(
      normalizeWatchOnlyWallet(
        wallet,
        supportedChains: {'ETH': ethChain('ETH')},
      ),
      isFalse,
    );
    expect(wallet.coinInfo?.keys, ['SOL']);
  });
}
