import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_build_utils.dart';
import 'package:n42_wallet/features/wallet/models/coin_model_wallet_access.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

/// User-added EVM token metadata may have come from an outdated token
/// directory. Do not turn its cached raw balance into a display/spend amount
/// until the contract's decimals have been verified on-chain.
bool requiresEvmTokenMetadataVerification(CoinModel coin) {
  return coin.coin['blockchainType'] == 'Ethereum' &&
      coin.coin['isContract'] == true &&
      coin.coin['canEdit'] == true &&
      coin.coin['decimals_verified'] != true;
}

/// Whether a row needs a prominent balance warning.
///
/// A failed refresh for a zero-balance coin does not make the displayed value
/// stale or unsafe, so showing a warning on every such row creates a wall of
/// false alarms. Keep the warning when a non-zero cached balance is being
/// shown, or when an editable EVM token still needs on-chain metadata
/// verification.
bool shouldShowBalanceLoadWarning(CoinModel coin) {
  return coin.loadError &&
      (coin.balance != BigInt.zero ||
          requiresEvmTokenMetadataVerification(coin));
}

/// Hydrates [coin]'s balance/price/value fields from cached data in the coin map.
void applyCachedBalance(CoinModel coin) {
  if (requiresEvmTokenMetadataVerification(coin)) {
    coin.balance = BigInt.zero;
    coin.value = 0.0;
    coin.loadError = true;
    return;
  }
  try {
    if (coin.isTest) {
      coin.balance = BigInt.parse(coin.coin['balance_test']?.toString() ?? '0');
    } else {
      coin.balance = BigInt.parse(coin.coin['balance']?.toString() ?? '0');
    }
    coin.percentage = (coin.coin['percentage'] as num?)?.toDouble() ?? 0.0;
    coin.coinPrice = (coin.coin['coinPrice'] as num?)?.toDouble() ?? 0.0;
    coin.value = coin.balanceDoubleAll() * coin.coinPrice;
  } catch (e) {
    debugPrint('applyCachedBalance error: $e');
    coin.balance = BigInt.zero;
    coin.percentage = 0.0;
    coin.coinPrice = 0.0;
    coin.value = 0.0;
  }
}

Future<void> buildCoinWallet(
  CoinModel coin,
  ICoinModelWalletAccess walletAccess, {
  String pk = "",
  bool setAddress = true,
  int? walletIndex,
}) async {
  if (coin.address != null) return;

  final String coinType = coin.coin['coinType'];
  final WalletInfo info = walletIndex == null
      ? walletAccess.walletInfo
      : walletAccess.walletInfoList[walletIndex];

  if (info.watchOnly && info.watchAddress.isNotEmpty) {
    coin.address = info.watchAddress;
    coin.addressType[coin.addrType] = info.watchAddress;
    if (walletIndex == null && setAddress) {
      walletAccess.setAddress(coinType, coin.addressType);
    }
    return;
  }

  final Map<String, dynamic>? pathMap = coin.coin['path'];
  if (pathMap == null) {
    debugPrint('buildCoinWallet: path is null for $coinType');
    coin.loadError = true;
    return;
  }

  final derivation = resolveCoinModelDerivation(
    coin: coin.coin,
    addrType: coin.addrType,
    pathIndex: coin.pathIndex,
  );
  final Map<Object?, Object?> rm = await Trustdart().generateAddress(
    coinType,
    derivation.path,
    derivation.addressType,
    mnemonic: info.mnemonic ?? "",
    pk: coin.privateKey ?? "",
    isTest: coin.isTest,
  );

  for (final key in rm.keys) {
    coin.addressType[key as String] = rm[key];
  }

  final generatedAddress = rm[coin.addrType];
  if (generatedAddress == null || (generatedAddress as String).isEmpty) {
    debugPrint(
      'buildCoinWallet: Failed to generate address for $coinType (addrType: ${coin.addrType})',
    );
    coin.loadError = true;
    walletAccess.refresh();
    return;
  }

  coin.address = generatedAddress;
  if (walletIndex == null && setAddress) {
    walletAccess.setAddress(coinType, coin.addressType);
  }
}

Future<bool> fetchCoinBalance(
  CoinModel coin,
  ICoinModelWalletAccess walletAccess, {
  bool getToken = true,
}) async {
  try {
    if (coin.address == null) {
      await buildCoinWallet(coin, walletAccess);
    }
    final bool hasError = await walletAccess.getBalanceWithCoinModel(coin);
    if (hasError) {
      // Cached balances remain visible for reference, but must not be treated
      // as a current spendable balance after a failed chain read.
      coin.loadError = true;
      walletAccess.refresh();
      return false;
    }
    coin.loadError = false;
    walletAccess.calculateBalanceWidthCoinModel();
    return true;
  } catch (e) {
    debugPrint('fetchCoinBalance error: $e');
    coin.loadError = true;
    coin.isRefresh = false;
    walletAccess.refresh();
    return false;
  }
}
