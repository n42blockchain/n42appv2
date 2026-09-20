import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';

class _WalletSnapshot extends Fake
    implements LegacyWalletActionProviderAdapter {
  @override
  final List<WalletInfo> walletInfoLsit = [];

  @override
  final List<CoinModel> coinModels = [];

  final addresses = <String, String>{};

  @override
  dynamic getAddress(String coinKey, {String addrType = 'legacy'}) =>
      addresses[coinKey];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final snapshot = _WalletSnapshot();
  late N42WalletBridge bridge;

  setUpAll(() => globalWapAdapter = snapshot);
  setUp(() {
    snapshot.walletInfoLsit.clear();
    snapshot.coinModels.clear();
    snapshot.addresses.clear();
    bridge = N42WalletBridge();
  });

  test(
    'disconnected wallet rejects transfer before reading coin details',
    () async {
      expect(bridge.isWalletConnected, isFalse);
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'ETH',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Wallet not connected');
    },
  );

  for (final amount in [
    '0',
    '-1',
    '',
    'not-an-amount',
    'NaN',
    'Infinity',
    '-Infinity',
    '1e9999',
  ]) {
    test(
      'connected wallet rejects invalid amount "$amount" before dispatch',
      () async {
        snapshot.walletInfoLsit.add(WalletInfo());
        final result = await bridge.requestTransfer(
          toAddress: 'unused',
          amount: amount,
          token: 'ETH',
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, 'Invalid transfer amount');
      },
    );
  }

  test(
    'unknown token fails without selecting a different available asset',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(
        CoinModel()..coin = {'coinType': 'ETH', 'miniName': 'ETH'},
      );
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'USDC',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Token USDC not found in wallet');
    },
  );

  test(
    'missing derivation path rejects matched token without ETH fallback',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(
        CoinModel()
          ..coin = {
            'coinType': 'SOL',
            'miniName': 'SOL',
            'blockchainType': 'Solana',
            'decimals': 9,
          }
          ..addrType = 'legacy',
      );
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'sol',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Missing derivation path for sol (legacy)');
    },
  );

  test(
    'balance lookup retains all decimal places and unknown assets return zero',
    () async {
      snapshot.coinModels.add(
        CoinModel()
          ..coin = {'coinType': 'ETH', 'miniName': 'USDC', 'decimals': 6}
          ..balance = BigInt.parse('9007199254740993123456'),
      );
      expect(await bridge.getBalance('usdc'), '9007199254740993.123456');
      expect(await bridge.getBalance('missing'), '0');
    },
  );

  test(
    'supported token list skips missing identity and keeps display precision',
    () async {
      snapshot.coinModels.addAll([
        CoinModel()..coin = {'miniName': 'Incomplete'},
        CoinModel()
          ..coin = {
            'coinType': 'ETH',
            'miniName': 'USDC',
            'name': 'USD Coin',
            'decimals': '6',
            'isContract': true,
          },
        CoinModel()..coin = {'coinType': 'SOL', 'decimal': 9},
      ]);
      final tokens = await bridge.getSupportedTokens();
      expect(tokens, hasLength(2));
      expect(tokens.first.symbol, 'USDC');
      expect(tokens.first.name, 'USD Coin');
      expect(tokens.first.decimals, 6);
      expect(tokens.first.isNative, isFalse);
      expect(tokens.last.symbol, 'SOL');
      expect(tokens.last.decimals, 9);
      expect(tokens.last.isNative, isTrue);
    },
  );
}
