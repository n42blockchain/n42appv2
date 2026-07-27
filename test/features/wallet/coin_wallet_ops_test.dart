import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_wallet_access.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

void main() {
  group('editable EVM token metadata', () {
    CoinModel token({required bool verified}) {
      return CoinModel.fromMap({
        'blockchainType': 'Ethereum',
        'coinType': 'BNB',
        'isContract': true,
        'canEdit': true,
        'decimals': 6,
        'decimals_verified': verified,
        'balance': '502690',
        'coinPrice': 0.5,
        'percentage': 0.0,
      });
    }

    test('does not display an unverified cached raw balance', () {
      final coin = token(verified: false);

      applyCachedBalance(coin);

      expect(requiresEvmTokenMetadataVerification(coin), isTrue);
      expect(coin.balance, BigInt.zero);
      expect(coin.value, 0.0);
      expect(coin.loadError, isTrue);
    });

    test('uses cached balance after decimals are verified on-chain', () {
      final coin = token(verified: true);

      applyCachedBalance(coin);

      expect(requiresEvmTokenMetadataVerification(coin), isFalse);
      expect(coin.balanceStringAll(), '0.50269');
      expect(coin.value, closeTo(0.251345, 0.0000001));
      expect(coin.loadError, isFalse);
    });
  });

  group('balance load warning', () {
    test('hides transient refresh errors for a zero balance', () {
      final coin = CoinModel()..loadError = true;

      expect(shouldShowBalanceLoadWarning(coin), isFalse);
    });

    test('warns when a non-zero cached balance may be stale', () {
      final coin = CoinModel()
        ..loadError = true
        ..balance = BigInt.one;

      expect(shouldShowBalanceLoadWarning(coin), isTrue);
    });

    test('warns when editable EVM token metadata is unverified', () {
      final coin = CoinModel.fromMap({
        'blockchainType': 'Ethereum',
        'coinType': 'ETH',
        'isContract': true,
        'canEdit': true,
      })..loadError = true;

      expect(shouldShowBalanceLoadWarning(coin), isTrue);
    });

    test('does not warn after a successful refresh', () {
      final coin = CoinModel()..balance = BigInt.one;

      expect(shouldShowBalanceLoadWarning(coin), isFalse);
    });
  });

  group('fetchCoinBalance', () {
    test('keeps failed balance refresh marked as unavailable', () async {
      final coin = CoinModel()
        ..address = '0x0000000000000000000000000000000000000001';
      final wallet = _WalletAccess(hasBalanceError: true);

      final result = await fetchCoinBalance(coin, wallet);

      expect(result, isFalse);
      expect(coin.loadError, isTrue);
      expect(wallet.didRefresh, isTrue);
      expect(wallet.didCalculateBalance, isFalse);
    });

    test('clears the error only after a successful balance refresh', () async {
      final coin = CoinModel()
        ..address = '0x0000000000000000000000000000000000000001'
        ..loadError = true;
      final wallet = _WalletAccess(hasBalanceError: false);

      final result = await fetchCoinBalance(coin, wallet);

      expect(result, isTrue);
      expect(coin.loadError, isFalse);
      expect(wallet.didCalculateBalance, isTrue);
    });
  });
}

class _WalletAccess implements ICoinModelWalletAccess {
  _WalletAccess({required this.hasBalanceError});

  final bool hasBalanceError;
  bool didRefresh = false;
  bool didCalculateBalance = false;

  @override
  WalletInfo get walletInfo => throw UnimplementedError();

  @override
  List<WalletInfo> get walletInfoList => throw UnimplementedError();

  @override
  void calculateBalanceWidthCoinModel() {
    didCalculateBalance = true;
  }

  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async =>
      hasBalanceError;

  @override
  void refresh() {
    didRefresh = true;
  }

  @override
  void setAddress(String key, Map<String, dynamic> value) {}
}
