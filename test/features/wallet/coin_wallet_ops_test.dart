import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_wallet_access.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

void main() {
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
