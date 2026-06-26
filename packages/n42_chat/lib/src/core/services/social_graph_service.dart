import 'dart:math' as math;

import '../../data/datasources/social/alchemy_social_datasource.dart';
import '../../data/datasources/social/debank_datasource.dart';
import '../../data/models/social/social_similarity_model.dart';
import '../../domain/entities/social/social_connection.dart';
import '../../domain/entities/social/social_profile.dart';
import '../../domain/entities/social/social_recommendation.dart';

/// Service for calculating on-chain social similarity between addresses.
///
/// Uses multiple data sources (DeBank for tokens/chains, Alchemy for NFTs)
/// to compute a multi-dimensional similarity score: token overlap, NFT
/// collection overlap, chain usage, etc.
///
/// The similarity is calculated as a weighted Jaccard index across each
/// dimension, with weights reflecting the strength of each signal:
/// - Token overlap: 30%
/// - NFT collections: 25%
/// - Transaction interaction: 20%
/// - Chain usage: 15%
/// - DAO membership: 10%
class SocialGraphService {
  static const int _maxCollectionsToInspect = 5;
  static const int _maxCandidateUniverse = 200;
  static const int _maxRecommendationsToScore = 10;
  static const int _candidateScoringConcurrency = 3;

  final DeBankDatasource _debank;
  final AlchemySocialDatasource _alchemy;

  SocialGraphService({
    required DeBankDatasource debank,
    required AlchemySocialDatasource alchemy,
  }) : _debank = debank,
       _alchemy = alchemy;

  /// Calculate the multi-dimensional similarity between [addressA] and
  /// [addressB].
  ///
  /// Fetches token holdings, NFT collections, and chain usage in parallel,
  /// then computes the Jaccard index for each dimension.
  Future<SocialSimilarityModel> calculateSimilarity(
    String addressA,
    String addressB,
  ) async {
    final results = await Future.wait([
      _tokenOverlapScore(addressA, addressB),
      _nftCollectionScore(addressA, addressB),
      _chainUsageScore(addressA, addressB),
    ]);

    final tokenResult = results[0];
    final nftResult = results[1];
    final chainResult = results[2];

    return _buildSimilarityModel(
      addressA: addressA,
      addressB: addressB,
      tokenResult: tokenResult,
      nftResult: nftResult,
      chainResult: chainResult,
    );
  }

  SocialSimilarityModel _buildSimilarityModel({
    required String addressA,
    required String addressB,
    required _ScoreResult tokenResult,
    required _ScoreResult nftResult,
    required _ScoreResult chainResult,
  }) {
    final totalScore = SocialSimilarityModel.calculateWeightedScore(
      tokenOverlap: tokenResult.score,
      nftOverlap: nftResult.score,
      chainUsage: chainResult.score,
    );
    return SocialSimilarityModel(
      addressA: addressA,
      addressB: addressB,
      tokenOverlap: tokenResult.score,
      nftOverlap: nftResult.score,
      chainUsage: chainResult.score,
      totalScore: totalScore,
      commonTokens: tokenResult.items,
      commonNftCollections: nftResult.items,
      commonChains: chainResult.items,
    );
  }

  /// Get social recommendations for [address].
  ///
  /// Strategy:
  /// 1. Fetch the user's NFT collections.
  /// 2. For each collection (up to 5), fetch other owners.
  /// 3. Calculate similarity with each candidate.
  /// 4. Return the top [limit] results sorted by score.
  Future<List<SocialRecommendation>> getRecommendations(
    String address, {
    int limit = 20,
  }) async {
    // Step 1: Get user's NFT collections to discover candidate peers
    final nfts = await _safeGetUserNfts(address);
    if (nfts.isEmpty) {
      return const [];
    }
    final normalizedAddress = address.toLowerCase();
    final sourceChains = await _safeGetUsedChains(address);
    final sourceCollections = _extractCollectionAddresses(nfts);
    final sourceTokenCache = <String, Future<Set<String>>>{};

    // Step 2: Extract unique contract addresses (limit to 5 API calls)
    final contractMap = <String, String>{};
    for (final nft in nfts) {
      final contract = nft['contract']?['address'] as String?;
      if (contract == null || contract.isEmpty) continue;
      contractMap.putIfAbsent(contract.toLowerCase(), () => contract);
      if (contractMap.length >= _maxCollectionsToInspect) break;
    }
    final contracts = contractMap.values.toList(growable: false);

    // Step 3: Collect unique owners across all collections.
    // Cap to 200 entries to limit downstream API calls (each candidate
    // triggers token + NFT + chain lookups against DeBank and Alchemy).
    final candidateScores = <String, int>{};
    final ownerLists = await Future.wait(
      contracts.map(_safeGetCollectionOwners),
    );
    for (final owners in ownerLists) {
      for (final owner in owners) {
        final normalizedOwner = owner.toLowerCase();
        if (normalizedOwner == normalizedAddress) continue;
        candidateScores.update(
          normalizedOwner,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        if (candidateScores.length >= _maxCandidateUniverse) break;
      }
      if (candidateScores.length >= _maxCandidateUniverse) break;
    }

    // Step 4: Score each candidate.
    // Limit candidates to avoid excessive API calls (each candidate
    // requires ~5 API calls for similarity calculation).
    final maxCandidates = limit < _maxRecommendationsToScore
        ? limit
        : _maxRecommendationsToScore;
    final candidates = candidateScores.keys.toList()
      ..sort((a, b) {
        final scoreCompare = candidateScores[b]!.compareTo(candidateScores[a]!);
        if (scoreCompare != 0) return scoreCompare;
        return a.compareTo(b);
      });
    final recommendations =
        (await _mapWithConcurrencyLimit<String, SocialRecommendation?>(
          candidates.take(maxCandidates).toList(growable: false),
          _candidateScoringConcurrency,
          (candidate) => _buildRecommendation(
            address,
            candidate,
            sourceChains: sourceChains,
            sourceCollections: sourceCollections,
            sourceTokenCache: sourceTokenCache,
          ),
        )).whereType<SocialRecommendation>().toList();

    // Sort by similarity score descending and take the top results
    recommendations.sort(
      (a, b) => b.similarityScore.compareTo(a.similarityScore),
    );
    return recommendations.take(limit).toList();
  }

  // ---------------------------------------------------------------------------
  // Dimension scoring
  // ---------------------------------------------------------------------------

  // Each scoring method makes 2-3 API calls per invocation.
  // With N candidates, total API calls = N * ~7 (token: 3, NFT: 2, chain: 2).
  // The candidate cap in getRecommendations() keeps this bounded.

  Future<_ScoreResult> _tokenOverlapScore(String addrA, String addrB) async {
    try {
      final chainResults = await Future.wait([
        _debank.getUsedChains(addrA),
        _debank.getUsedChains(addrB),
      ]);
      final chainsA = chainResults[0];
      final chainsBSet = chainResults[1].toSet();
      final commonChains = chainsA.where(chainsBSet.contains).take(3).toList();

      if (commonChains.isEmpty) {
        return const _ScoreResult(0, []);
      }

      final symbolsA = <String>{};
      final symbolsB = <String>{};

      for (final chain in commonChains) {
        final tokenResults = await Future.wait([
          _debank.getUserTokenList(addrA, chain),
          _debank.getUserTokenList(addrB, chain),
        ]);
        symbolsA.addAll(_extractTokenSymbols(tokenResults[0]));
        symbolsB.addAll(_extractTokenSymbols(tokenResults[1]));
      }

      final common = symbolsA.intersection(symbolsB);
      final union = symbolsA.union(symbolsB);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.cast<String>().toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<List<Map<String, dynamic>>> _safeGetUserNfts(String address) async {
    try {
      return await _alchemy.getUserNFTs(address, pageSize: 50);
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> _safeGetCollectionOwners(String contract) async {
    try {
      return await _alchemy.getCollectionOwners(contract);
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> _safeGetUsedChains(String address) async {
    try {
      return await _debank.getUsedChains(address);
    } catch (_) {
      return const [];
    }
  }

  Iterable<String> _extractTokenSymbols(List<Map<String, dynamic>> tokens) {
    return tokens
        .map((token) => token['symbol'] as String?)
        .whereType<String>()
        .where((symbol) => symbol.isNotEmpty);
  }

  Set<String> _extractCollectionAddresses(List<Map<String, dynamic>> nfts) {
    return nfts
        .map((nft) => nft['contract']?['address'] as String?)
        .whereType<String>()
        .where((address) => address.isNotEmpty)
        .map((address) => address.toLowerCase())
        .toSet();
  }

  Future<_ScoreResult> _nftCollectionScore(String addrA, String addrB) async {
    try {
      final nftsA = await _alchemy.getUserNFTs(addrA, pageSize: 50);
      final nftsB = await _alchemy.getUserNFTs(addrB, pageSize: 50);

      final collectionsA = _extractCollectionAddresses(nftsA);
      final collectionsB = _extractCollectionAddresses(nftsB);

      final common = collectionsA.intersection(collectionsB);
      final union = collectionsA.union(collectionsB);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<_ScoreResult> _chainUsageScore(String addrA, String addrB) async {
    try {
      final chainsA = await _debank.getUsedChains(addrA);
      final chainsB = await _debank.getUsedChains(addrB);

      final setA = chainsA.toSet();
      final setB = chainsB.toSet();

      final common = setA.intersection(setB);
      final union = setA.union(setB);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<SocialRecommendation?> _buildRecommendation(
    String sourceAddress,
    String candidate, {
    required List<String> sourceChains,
    required Set<String> sourceCollections,
    required Map<String, Future<Set<String>>> sourceTokenCache,
  }) async {
    try {
      final similarity = await _calculateRecommendationSimilarity(
        sourceAddress,
        candidate,
        sourceChains: sourceChains,
        sourceCollections: sourceCollections,
        sourceTokenCache: sourceTokenCache,
      );
      if (similarity.totalScore <= 0.1) {
        return null;
      }

      final connections = <SocialConnection>[];

      if (similarity.commonTokens.isNotEmpty) {
        connections.add(
          SocialConnection(
            fromAddress: sourceAddress,
            toAddress: candidate,
            type: ConnectionType.commonTokens,
            strength: similarity.tokenOverlap,
            sharedItems: similarity.commonTokens,
          ),
        );
      }
      if (similarity.commonNftCollections.isNotEmpty) {
        connections.add(
          SocialConnection(
            fromAddress: sourceAddress,
            toAddress: candidate,
            type: ConnectionType.commonNfts,
            strength: similarity.nftOverlap,
            sharedItems: similarity.commonNftCollections,
          ),
        );
      }
      if (similarity.commonChains.isNotEmpty) {
        connections.add(
          SocialConnection(
            fromAddress: sourceAddress,
            toAddress: candidate,
            type: ConnectionType.commonChains,
            strength: similarity.chainUsage,
            sharedItems: similarity.commonChains,
          ),
        );
      }

      return SocialRecommendation(
        profile: SocialProfile(address: candidate),
        similarityScore: similarity.totalScore,
        connections: connections,
        reason: _buildReason(similarity),
      );
    } catch (_) {
      return null;
    }
  }

  Future<SocialSimilarityModel> _calculateRecommendationSimilarity(
    String sourceAddress,
    String candidate, {
    required List<String> sourceChains,
    required Set<String> sourceCollections,
    required Map<String, Future<Set<String>>> sourceTokenCache,
  }) async {
    final results = await Future.wait([
      _tokenOverlapScoreWithSource(
        sourceAddress,
        candidate,
        sourceChains: sourceChains,
        sourceTokenCache: sourceTokenCache,
      ),
      _nftCollectionScoreWithSource(
        candidate,
        sourceCollections: sourceCollections,
      ),
      _chainUsageScoreWithSource(candidate, sourceChains: sourceChains),
    ]);

    final tokenResult = results[0];
    final nftResult = results[1];
    final chainResult = results[2];

    return _buildSimilarityModel(
      addressA: sourceAddress,
      addressB: candidate,
      tokenResult: tokenResult,
      nftResult: nftResult,
      chainResult: chainResult,
    );
  }

  Future<_ScoreResult> _tokenOverlapScoreWithSource(
    String sourceAddress,
    String candidate, {
    required List<String> sourceChains,
    required Map<String, Future<Set<String>>> sourceTokenCache,
  }) async {
    try {
      final sourceChainSet = sourceChains.toSet();
      final candidateChains = await _debank.getUsedChains(candidate);
      final commonChains = candidateChains
          .where(sourceChainSet.contains)
          .take(3)
          .toList();

      if (commonChains.isEmpty) {
        return const _ScoreResult(0, []);
      }

      final symbolsA = <String>{};
      final symbolsB = <String>{};

      for (final chain in commonChains) {
        final tokenResults = await Future.wait([
          _getCachedSourceTokenSymbols(sourceAddress, chain, sourceTokenCache),
          _debank
              .getUserTokenList(candidate, chain)
              .then((tokens) => _extractTokenSymbols(tokens).toSet()),
        ]);
        symbolsA.addAll(tokenResults[0]);
        symbolsB.addAll(tokenResults[1]);
      }

      final common = symbolsA.intersection(symbolsB);
      final union = symbolsA.union(symbolsB);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<Set<String>> _getCachedSourceTokenSymbols(
    String sourceAddress,
    String chain,
    Map<String, Future<Set<String>>> sourceTokenCache,
  ) {
    return sourceTokenCache.putIfAbsent(chain, () async {
      final tokens = await _debank.getUserTokenList(sourceAddress, chain);
      return _extractTokenSymbols(tokens).toSet();
    });
  }

  Future<_ScoreResult> _nftCollectionScoreWithSource(
    String candidate, {
    required Set<String> sourceCollections,
  }) async {
    try {
      final candidateNfts = await _alchemy.getUserNFTs(candidate, pageSize: 50);
      final candidateCollections = _extractCollectionAddresses(candidateNfts);

      final common = sourceCollections.intersection(candidateCollections);
      final union = sourceCollections.union(candidateCollections);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<_ScoreResult> _chainUsageScoreWithSource(
    String candidate, {
    required List<String> sourceChains,
  }) async {
    try {
      final candidateChains = await _debank.getUsedChains(candidate);
      final sourceChainSet = sourceChains.toSet();
      final candidateChainSet = candidateChains.toSet();

      final common = sourceChainSet.intersection(candidateChainSet);
      final union = sourceChainSet.union(candidateChainSet);

      final score = union.isEmpty ? 0.0 : common.length / union.length;
      return _ScoreResult(score, common.toList());
    } catch (_) {
      return const _ScoreResult(0, []);
    }
  }

  Future<List<R>> _mapWithConcurrencyLimit<T, R>(
    List<T> items,
    int concurrency,
    Future<R> Function(T item) mapper,
  ) async {
    if (items.isEmpty) {
      return const [];
    }

    final results = List<R?>.filled(items.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final currentIndex = nextIndex;
        if (currentIndex >= items.length) {
          return;
        }
        nextIndex++;
        results[currentIndex] = await mapper(items[currentIndex]);
      }
    }

    final workers = List.generate(
      math.min(concurrency, items.length),
      (_) => worker(),
    );
    await Future.wait(workers);
    return results.cast<R>();
  }

  String _buildReason(SocialSimilarityModel similarity) {
    final parts = <String>[];
    if (similarity.commonTokens.isNotEmpty) {
      parts.add('${similarity.commonTokens.length} common tokens');
    }
    if (similarity.commonNftCollections.isNotEmpty) {
      parts.add(
        '${similarity.commonNftCollections.length} shared NFT collections',
      );
    }
    if (similarity.commonChains.isNotEmpty) {
      parts.add('${similarity.commonChains.length} common chains');
    }
    return parts.isEmpty ? 'On-chain activity overlap' : parts.join(', ');
  }
}

/// Internal helper for returning a score together with the matching items.
class _ScoreResult {
  final double score;
  final List<String> items;
  const _ScoreResult(this.score, this.items);
}
