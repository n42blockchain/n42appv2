import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_wallet_utils.dart';

void main() {
  Map<String, dynamic> nChainConfig() {
    return {
      CoinType.N.name: {
        'baseInfo': {
          'coinType': CoinType.N.name,
          'path': {'legacy': "m/44'/60'/0'/0/0"},
        },
        'pathIndex': 0,
      },
    };
  }

  test(
    'walletSupportsFaceBinding requires non-watch wallet with N legacy path',
    () {
      final supported = WalletInfo()..coinInfo = nChainConfig();
      final watchOnly = WalletInfo()
        ..watchOnly = true
        ..coinInfo = nChainConfig();
      final unsupported = WalletInfo()
        ..coinInfo = {
          CoinType.N.name: {
            'baseInfo': {'coinType': CoinType.N.name},
          },
        };

      expect(walletSupportsFaceBinding(supported), isTrue);
      expect(walletSupportsFaceBinding(watchOnly), isFalse);
      expect(walletSupportsFaceBinding(unsupported), isFalse);
    },
  );

  test(
    'faceBindingChainConfig returns null when N chain config is missing',
    () {
      final wallet = WalletInfo()..coinInfo = {'ETH': {}};

      expect(faceBindingChainConfig(wallet), isNull);
    },
  );
}
