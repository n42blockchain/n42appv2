import 'dart:convert';

import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

const Map<String, dynamic> _defaultCoinSort = {'assets': 0, 'name': -1};

Map<String, dynamic> walletInfoToBackupPayload(WalletInfo walletInfo) {
  final payload = Map<String, dynamic>.from(walletInfo.toJson());
  payload.remove('UUID');
  payload['primaryCoinType'] = _primaryCoinType(walletInfo.coinInfo);
  return payload;
}

WalletInfo walletInfoFromBackupPayload(
  Map<String, dynamic> payload, {
  required String userUUID,
}) {
  final mnemonic = _normalizeOptionalString(payload['mnemonic']);
  final privateKey = _normalizeOptionalString(payload['privateKey']);
  final watchOnly = payload['watchOnly'] == true;
  final watchAddress = _normalizeOptionalString(payload['watchAddress']) ?? '';
  final coinInfo = _resolveCoinInfo(payload, mnemonic: mnemonic);

  if (watchOnly) {
    if (watchAddress.isEmpty) {
      throw const FormatException('Backup wallet is missing watch address');
    }
  } else if ((mnemonic == null || mnemonic.isEmpty) &&
      (privateKey == null || privateKey.isEmpty)) {
    throw const FormatException('Backup wallet is missing credentials');
  }

  if (coinInfo.isEmpty) {
    throw const FormatException('Backup wallet is missing chain configuration');
  }

  final json = <String, dynamic>{
    'walletName':
        _normalizeOptionalString(payload['walletName']) ??
        _fallbackWalletName(payload),
    'mnemonic': mnemonic,
    'password': _normalizeOptionalString(payload['password']) ?? '',
    'privateKey': privateKey,
    'UUID': userUUID,
    'timestamp':
        _normalizeOptionalString(payload['timestamp']) ??
        '${DateTime.now().millisecondsSinceEpoch}',
    'coinInfo': coinInfo,
    'coinSort': _deepCopyJsonMap(payload['coinSort']) ?? _defaultCoinSort,
    'networkIndex': (payload['networkIndex'] as num?)?.toInt() ?? -1,
    'pinnedCoins': _stringList(payload['pinnedCoins']),
    'chainOrder': _stringList(payload['chainOrder']),
    'faceBinding': payload['faceBinding'] as bool?,
    'mainWallet': payload['mainWallet'] == true,
    'watchOnly': watchOnly,
    'watchAddress': watchAddress,
    if (payload['aaAccountInfo'] is Map)
      'aaAccountInfo': _deepCopyJsonMap(payload['aaAccountInfo']),
  };

  return WalletInfo.fromJson(json);
}

Map<String, dynamic> _resolveCoinInfo(
  Map<String, dynamic> payload, {
  required String? mnemonic,
}) {
  final rawCoinInfo = _deepCopyJsonMap(payload['coinInfo']);
  if (rawCoinInfo != null && rawCoinInfo.isNotEmpty) {
    return rawCoinInfo;
  }

  if (mnemonic != null && mnemonic.isNotEmpty) {
    return _deepCopyJsonMap(chainUrlMap) ?? <String, dynamic>{};
  }

  final primaryCoinType = _normalizeOptionalString(payload['primaryCoinType']);
  if (primaryCoinType != null && primaryCoinType.isNotEmpty) {
    final chainConfig = chainUrlMap[primaryCoinType];
    final copied = _deepCopyJsonValue(chainConfig);
    if (copied is Map<String, dynamic>) {
      return {primaryCoinType: copied};
    }
  }

  return <String, dynamic>{};
}

String? _primaryCoinType(Map<String, dynamic>? coinInfo) {
  if (coinInfo == null || coinInfo.isEmpty) {
    return null;
  }
  return coinInfo.keys.first;
}

String? _normalizeOptionalString(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _fallbackWalletName(Map<String, dynamic> payload) {
  final primaryCoinType = _normalizeOptionalString(payload['primaryCoinType']);
  if (primaryCoinType != null) {
    return 'Restored $primaryCoinType';
  }
  return 'Restored Wallet';
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList();
}

Map<String, dynamic>? _deepCopyJsonMap(Object? value) {
  final copied = _deepCopyJsonValue(value);
  if (copied is Map<String, dynamic>) {
    return copied;
  }
  return null;
}

dynamic _deepCopyJsonValue(Object? value) {
  if (value == null) {
    return null;
  }
  return jsonDecode(jsonEncode(value));
}
