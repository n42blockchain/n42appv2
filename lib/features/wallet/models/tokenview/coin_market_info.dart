import 'package:n42_wallet/features/wallet/models/tokenview/parse_helpers.dart';

/// Market information for a coin from TokenView /market/info endpoint.
class CoinMarketInfo {
  final double? price;
  final double? change24h;
  final double? marketCap;
  final double? volume24h;

  const CoinMarketInfo({
    this.price,
    this.change24h,
    this.marketCap,
    this.volume24h,
  });

  factory CoinMarketInfo.fromJson(Map<String, dynamic> json) {
    return CoinMarketInfo(
      price: toDoubleSafe(json['price'] ?? json['priceUsd']),
      change24h: toDoubleSafe(json['change24h'] ?? json['priceChange24h']),
      marketCap: toDoubleSafe(json['marketCap'] ?? json['market_cap']),
      volume24h: toDoubleSafe(json['volume24h'] ?? json['vol24h']),
    );
  }
}
