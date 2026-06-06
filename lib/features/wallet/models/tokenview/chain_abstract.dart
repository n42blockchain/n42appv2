/// Chain basic information from TokenView /chain/info endpoint.
class ChainAbstract {
  final String coinFullName;
  final String coinShortName;
  final String? consensusMethod;
  final String? algorithm;
  final String? supply;
  final String? circulationAmount;
  final String? homePageUrl;
  final String? githubLink;
  final String? twitterLink;

  const ChainAbstract({
    required this.coinFullName,
    required this.coinShortName,
    this.consensusMethod,
    this.algorithm,
    this.supply,
    this.circulationAmount,
    this.homePageUrl,
    this.githubLink,
    this.twitterLink,
  });

  factory ChainAbstract.fromJson(Map<String, dynamic> json) {
    return ChainAbstract(
      coinFullName: (json['coinFullName'] ?? json['name'] ?? '').toString(),
      coinShortName: (json['coinShortName'] ?? json['symbol'] ?? '').toString(),
      consensusMethod: (json['consensusMethod'] ?? json['consensus'])
          ?.toString(),
      algorithm: (json['algorithm'] ?? json['hashAlgorithm'])?.toString(),
      supply: (json['supply'] ?? json['totalSupply'])?.toString(),
      circulationAmount:
          (json['circulationAmount'] ?? json['circulatingSupply'])?.toString(),
      homePageUrl: (json['homePageUrl'] ?? json['website'])?.toString(),
      githubLink: (json['githubLink'] ?? json['github'])?.toString(),
      twitterLink: (json['twitterLink'] ?? json['twitter'])?.toString(),
    );
  }
}
