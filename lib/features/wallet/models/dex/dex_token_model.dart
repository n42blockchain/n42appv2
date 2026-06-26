class DexTokenModel {
  final String address;
  final String symbol;
  final String name;
  final String logoUri;
  final int decimals;
  final String chain;

  const DexTokenModel({
    required this.address,
    required this.symbol,
    required this.name,
    required this.logoUri,
    required this.decimals,
    required this.chain,
  });

  factory DexTokenModel.fromJson(Map<String, dynamic> json) => DexTokenModel(
    address: json['address'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    name: json['name'] as String? ?? '',
    logoUri: json['logo_uri'] as String? ?? '',
    decimals: json['decimals'] as int? ?? 18,
    chain: json['chain'] as String? ?? '',
  );
}
