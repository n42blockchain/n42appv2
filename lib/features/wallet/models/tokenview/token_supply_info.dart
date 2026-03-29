/// Token supply data from TokenView /token/supply endpoint.
class TokenSupplyInfo {
  final String? totalSupply;
  final String? circulatingSupply;

  const TokenSupplyInfo({
    this.totalSupply,
    this.circulatingSupply,
  });

  factory TokenSupplyInfo.fromJson(Map<String, dynamic> json) {
    return TokenSupplyInfo(
      totalSupply: json['total_supply']?.toString() ?? json['totalSupply']?.toString(),
      circulatingSupply:
          json['circulating_supply']?.toString() ?? json['circulatingSupply']?.toString(),
    );
  }
}
