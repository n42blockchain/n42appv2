import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_delete_utils.dart';

void main() {
  Map<String, dynamic> nChainConfig({String addrType = 'legacy'}) {
    return {
      CoinType.N.name: {
        'addrType': addrType,
        'pathIndex': 0,
        'baseInfo': {
          'path': {addrType: "m/44'/60'/0'/0/0"},
        },
      },
    };
  }

  test(
    'walletDeletionMiningChainConfig returns null for watch-only wallets',
    () {
      final wallet = WalletInfo()..watchOnly = true;
      wallet.coinInfo = nChainConfig();

      expect(walletDeletionMiningChainConfig(wallet), isNull);
      expect(walletRequiresMiningDeletionCheck(wallet), isFalse);
    },
  );

  test(
    'walletDeletionMiningChainConfig returns null when N chain is missing',
    () {
      final wallet = WalletInfo()..coinInfo = {'ETH': {}};

      expect(walletDeletionMiningChainConfig(wallet), isNull);
      expect(walletRequiresMiningDeletionCheck(wallet), isFalse);
    },
  );

  test(
    'walletDeletionMiningChainConfig returns config when N chain is complete',
    () {
      final wallet = WalletInfo()..coinInfo = nChainConfig(addrType: 'segwit');

      final config = walletDeletionMiningChainConfig(wallet);

      expect(config, isNotNull);
      expect(config?['addrType'], 'segwit');
      expect(walletRequiresMiningDeletionCheck(wallet), isTrue);
    },
  );
}
