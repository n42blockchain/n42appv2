import 'dart:convert';

import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// Converts a JSON response delivered as text into its decoded structure.
/// Explorer gateways can return plain-text error pages or JSON with an
/// incorrect content type; callers should treat an undecodable response as
/// unsupported data rather than crashing a background refresh.
dynamic normalizeExplorerPayload(dynamic payload) {
  if (payload is! String) return payload;
  try {
    return jsonDecode(payload);
  } on FormatException {
    return null;
  }
}

String? explorerString(Map<String, dynamic> map, Iterable<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) {
      continue;
    }
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
  }
  return null;
}

final RegExp _integerRegExp = RegExp(r'^\d+$');
final RegExp _decimalRegExp = RegExp(r'^\d+(\.\d+)?$');

BigInt parseExplorerAmount(String? rawValue, int decimals) {
  final value = rawValue?.trim() ?? '';
  if (value.isEmpty) return BigInt.zero;
  if (_integerRegExp.hasMatch(value)) {
    return BigInt.parse(value);
  }
  if (_decimalRegExp.hasMatch(value)) {
    return ethToWeiString(value, decimals);
  }
  return BigInt.tryParse(value) ?? BigInt.zero;
}

bool hasExplorerItemContainer(dynamic payload) {
  if (payload is List<dynamic>) {
    return true;
  }
  if (payload is! Map) {
    return false;
  }

  return payload['result'] is List<dynamic> ||
      payload['items'] is List<dynamic> ||
      payload['data'] is List<dynamic>;
}

List<Map<String, dynamic>> extractExplorerItems(dynamic payload) {
  payload = normalizeExplorerPayload(payload);
  if (payload is List<dynamic>) {
    return _mapList(payload);
  }
  if (payload is! Map) {
    return const [];
  }

  final typed = Map<String, dynamic>.from(payload);

  final result = typed['result'];
  if (result is List<dynamic>) {
    return _mapList(result);
  }

  final items = typed['items'];
  if (items is List<dynamic>) {
    return _mapList(items);
  }

  final data = typed['data'];
  if (data is! List<dynamic>) {
    return const [];
  }

  final normalizedData = _mapList(data);
  final nestedTxs = <Map<String, dynamic>>[];

  for (final entry in normalizedData) {
    final txs = entry['txs'];
    if (txs is List<dynamic>) {
      nestedTxs.addAll(_mapList(txs));
    }
  }

  return nestedTxs.isNotEmpty ? nestedTxs : normalizedData;
}

List<Map<String, dynamic>> _mapList(List<dynamic> source) {
  return source
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}
