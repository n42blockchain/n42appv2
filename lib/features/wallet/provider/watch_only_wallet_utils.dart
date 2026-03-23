import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';

bool isWatchOnlySupportedChainConfig(dynamic chainConfig) {
  if (chainConfig is! Map) return false;
  final baseInfo = chainConfig['baseInfo'];
  if (baseInfo is! Map) return false;
  return baseInfo['blockchainType']?.toString() == BlockchainType.Ethereum.name;
}

Map<String, dynamic> buildWatchOnlyCoinInfo(Map<String, dynamic> source) {
  final result = <String, dynamic>{};
  for (final entry in source.entries) {
    if (!isWatchOnlySupportedChainConfig(entry.value)) {
      continue;
    }
    if (entry.value is Map) {
      result[entry.key] = _deepCopyMap(Map<String, dynamic>.from(entry.value));
    }
  }
  return result;
}

bool normalizeWatchOnlyWallet(
  WalletInfo wallet, {
  required Map<String, dynamic> supportedChains,
}) {
  if (!wallet.watchOnly) return false;

  final normalizedAddress = wallet.watchAddress.trim();
  final currentCoinInfo = wallet.coinInfo == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(wallet.coinInfo!);
  final normalizedCoinInfo = _mergeWatchOnlyCoinInfo(
    currentCoinInfo,
    supportedChains,
  );

  final addressChanged = wallet.watchAddress != normalizedAddress;
  final coinInfoChanged =
      jsonEncode(wallet.coinInfo ?? const <String, dynamic>{}) !=
      jsonEncode(normalizedCoinInfo);

  if (addressChanged) {
    wallet.watchAddress = normalizedAddress;
  }
  if (coinInfoChanged) {
    wallet.coinInfo = normalizedCoinInfo;
  }

  return addressChanged || coinInfoChanged;
}

Map<String, dynamic> _mergeWatchOnlyCoinInfo(
  Map<String, dynamic> currentCoinInfo,
  Map<String, dynamic> supportedChains,
) {
  final filteredCurrent = buildWatchOnlyCoinInfo(currentCoinInfo);
  final filteredSupported = buildWatchOnlyCoinInfo(supportedChains);
  final merged = <String, dynamic>{};

  for (final entry in filteredSupported.entries) {
    merged[entry.key] =
        filteredCurrent[entry.key] ??
        _deepCopyMap(entry.value as Map<String, dynamic>);
  }

  return merged;
}

Map<String, dynamic> _deepCopyMap(Map<String, dynamic> value) {
  return Map<String, dynamic>.from(
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
  );
}
