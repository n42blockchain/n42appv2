import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';

double extractAstPriceFromMarketPayload(dynamic payload) {
  final items = extractMarketCoinItems(payload);
  for (final item in items) {
    if (item['coin']?.toString().trim().toLowerCase() != 'n') continue;
    final price = double.tryParse(item['price']?.toString() ?? '');
    if (price != null && price.isFinite && price > 0) {
      return price;
    }
  }
  return 0;
}
