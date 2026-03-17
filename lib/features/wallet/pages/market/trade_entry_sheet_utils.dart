import 'package:n42_wallet/features/wallet/pages/market/market_price_format_utils.dart';

bool canDismissTradeEntrySheet(bool isSaving) => !isSaving;

String initialTradeEntryPrice(double currentPrice) {
  if (currentPrice <= 0) return '';
  return formatMarketPriceInput(currentPrice);
}
