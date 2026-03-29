import 'package:n42_wallet/features/wallet/models/tokenview/parse_helpers.dart';

/// Token metadata from TokenView /token/info endpoint.
class TokenMetadata {
  final String name;
  final String symbol;
  final int decimals;
  final String? totalSupply;
  final String? logoUrl;
  final String? contractAddress;

  const TokenMetadata({
    required this.name,
    required this.symbol,
    required this.decimals,
    this.totalSupply,
    this.logoUrl,
    this.contractAddress,
  });

  factory TokenMetadata.fromJson(Map<String, dynamic> json) {
    return TokenMetadata(
      name: (json['name'] ?? json['tokenName'] ?? '').toString(),
      symbol: (json['symbol'] ?? json['tokenSymbol'] ?? '').toString(),
      decimals: toIntSafe(json['decimals'] ?? json['tokenDecimal']) ?? 18,
      totalSupply: (json['totalSupply'] ?? json['total_supply'])?.toString(),
      logoUrl: (json['logoUrl'] ?? json['logo'])?.toString(),
      contractAddress:
          (json['contractAddress'] ?? json['contract'])?.toString(),
    );
  }
}
