List<Map<String, dynamic>> extractMarketCoinItems(dynamic rawData) {
  if (rawData is List) {
    return rawData
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  if (rawData is Map) {
    final nestedData = rawData['data'];
    if (nestedData != null) {
      return extractMarketCoinItems(nestedData);
    }
    if (_looksLikeMarketCoin(rawData)) {
      return [Map<String, dynamic>.from(rawData)];
    }
  }

  return const <Map<String, dynamic>>[];
}

double parseMarketDouble(dynamic value, [double fallback = 0.0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

bool _looksLikeMarketCoin(Map<dynamic, dynamic> item) {
  return item.containsKey('coin') ||
      item.containsKey('coin_gecko_id') ||
      item.containsKey('price');
}
