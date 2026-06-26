import 'package:equatable/equatable.dart';

/// Model for storing multi-dimensional similarity calculation results
/// between two on-chain addresses.
///
/// Each dimension (token, NFT, chain, DAO, transaction) contributes a
/// partial score; [weightedScore] combines them with domain-specific weights.
class SocialSimilarityModel extends Equatable {
  static const double tokenWeight = 0.43;
  static const double nftWeight = 0.36;
  static const double chainWeight = 0.21;

  /// First address in the comparison.
  final String addressA;

  /// Second address in the comparison.
  final String addressB;

  /// Jaccard similarity of ERC-20 token holdings (0.0 - 1.0).
  final double tokenOverlap;

  /// Jaccard similarity of NFT collection ownership (0.0 - 1.0).
  final double nftOverlap;

  /// Score based on direct transaction history (0.0 - 1.0).
  final double transactionInteraction;

  /// Jaccard similarity of chain usage (0.0 - 1.0).
  final double chainUsage;

  /// Score based on shared DAO memberships (0.0 - 1.0).
  final double daoMembership;

  /// Pre-computed total score (may be set externally or via [weightedScore]).
  final double totalScore;

  /// Token symbols shared by both addresses.
  final List<String> commonTokens;

  /// NFT contract addresses held by both addresses.
  final List<String> commonNftCollections;

  /// Chain IDs used by both addresses.
  final List<String> commonChains;

  const SocialSimilarityModel({
    required this.addressA,
    required this.addressB,
    this.tokenOverlap = 0,
    this.nftOverlap = 0,
    this.transactionInteraction = 0,
    this.chainUsage = 0,
    this.daoMembership = 0,
    this.totalScore = 0,
    this.commonTokens = const [],
    this.commonNftCollections = const [],
    this.commonChains = const [],
  });

  /// Calculate the weighted total score using domain-specific weights.
  ///
  /// Only dimensions that are actually computed contribute to the score.
  /// `transactionInteraction` and `daoMembership` are not yet implemented
  /// (always 0), so their original weights (20% and 10%) are redistributed
  /// proportionally among the three active dimensions:
  ///   Token: 0.43, NFT: 0.36, Chain: 0.21  (normalized from 0.30, 0.25, 0.15)
  double get weightedScore {
    return calculateWeightedScore(
      tokenOverlap: tokenOverlap,
      nftOverlap: nftOverlap,
      chainUsage: chainUsage,
    );
  }

  static double calculateWeightedScore({
    required double tokenOverlap,
    required double nftOverlap,
    required double chainUsage,
  }) {
    return tokenOverlap * tokenWeight +
        nftOverlap * nftWeight +
        chainUsage * chainWeight;
  }

  /// Serialize to JSON for caching or debugging.
  Map<String, dynamic> toJson() => {
    'addressA': addressA,
    'addressB': addressB,
    'tokenOverlap': tokenOverlap,
    'nftOverlap': nftOverlap,
    'transactionInteraction': transactionInteraction,
    'chainUsage': chainUsage,
    'daoMembership': daoMembership,
    'totalScore': totalScore,
    'commonTokens': commonTokens,
    'commonNftCollections': commonNftCollections,
    'commonChains': commonChains,
  };

  /// Deserialize from JSON.
  factory SocialSimilarityModel.fromJson(Map<String, dynamic> json) {
    return SocialSimilarityModel(
      addressA: json['addressA'] as String? ?? '',
      addressB: json['addressB'] as String? ?? '',
      tokenOverlap: (json['tokenOverlap'] as num?)?.toDouble() ?? 0,
      nftOverlap: (json['nftOverlap'] as num?)?.toDouble() ?? 0,
      transactionInteraction:
          (json['transactionInteraction'] as num?)?.toDouble() ?? 0,
      chainUsage: (json['chainUsage'] as num?)?.toDouble() ?? 0,
      daoMembership: (json['daoMembership'] as num?)?.toDouble() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0,
      commonTokens:
          (json['commonTokens'] as List<dynamic>?)?.cast<String>() ?? const [],
      commonNftCollections:
          (json['commonNftCollections'] as List<dynamic>?)?.cast<String>() ??
          const [],
      commonChains:
          (json['commonChains'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  @override
  List<Object?> get props => [
    addressA,
    addressB,
    tokenOverlap,
    nftOverlap,
    transactionInteraction,
    chainUsage,
    daoMembership,
    totalScore,
    commonTokens,
    commonNftCollections,
    commonChains,
  ];
}
