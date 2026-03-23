import 'package:n42_wallet/features/component/enums/coin_type.dart';

String resolveSelectedImportCoinType(Map<String, dynamic> selectChain) {
  final baseInfo = selectChain['baseInfo'];
  if (baseInfo is Map) {
    final coinType = baseInfo['coinType']?.toString().trim() ?? '';
    if (coinType.isNotEmpty) {
      return coinType;
    }

    final mKey = baseInfo['mKey']?.toString().trim() ?? '';
    if (mKey.isNotEmpty) {
      return mKey;
    }
  }

  return CoinType.N.name;
}

String extractImportedWalletAddress(Map<dynamic, dynamic> walletInfo) {
  String normalize(Object? value) {
    if (value is! String) {
      return '';
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? '' : trimmed;
  }

  final rawAddress = walletInfo['address'];
  final addressType = normalize(walletInfo['addressType']);

  if (rawAddress is String) {
    return normalize(rawAddress);
  }

  if (rawAddress is Map) {
    if (addressType.isNotEmpty) {
      final typedAddress = normalize(rawAddress[addressType]);
      if (typedAddress.isNotEmpty) {
        return typedAddress;
      }
    }

    final legacyAddress = normalize(rawAddress['legacy']);
    if (legacyAddress.isNotEmpty) {
      return legacyAddress;
    }

    for (final value in rawAddress.values) {
      final candidate = normalize(value);
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
  }

  return '';
}

String normalizeImportedPrivateKey(String privateKey) {
  return privateKey.replaceAll('\n', '').trim();
}
