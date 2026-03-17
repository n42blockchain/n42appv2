Map<String, dynamic>? findSwapAstMarketCoin(
  Iterable<dynamic> rawItems,
  String coin,
) {
  final normalizedCoin = coin.trim().toLowerCase();
  if (normalizedCoin.isEmpty) return null;

  for (final item in rawItems) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final itemCoin = map['coin']?.toString().trim().toLowerCase() ?? '';
    if (itemCoin == normalizedCoin) {
      return map;
    }
  }
  return null;
}

double calculateSwapAstConvertedAmount({
  required String value,
  required double fromPrice,
  required double toPrice,
}) {
  final amount = double.tryParse(value);
  if (amount == null || !amount.isFinite || amount <= 0) return 0;
  if (fromPrice <= 0 || toPrice <= 0) return 0;
  return amount * (fromPrice / toPrice);
}
