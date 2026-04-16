import '../../core/services/social_graph_service.dart';
import '../../domain/entities/social/social_connection.dart';
import '../../domain/entities/social/social_profile.dart';
import '../../domain/entities/social/social_recommendation.dart';
import '../../domain/repositories/social_graph_repository.dart';
import '../../core/utils/debug_log.dart';
import '../datasources/social/debank_datasource.dart';
import '../datasources/social/on_chain_identity_datasource.dart';
import '../models/social/debank_portfolio_model.dart';
import '../models/social/social_similarity_model.dart';

/// Implementation of [ISocialGraphRepository].
///
/// Aggregates data from DeBank (portfolio/tokens), Alchemy (NFTs), and
/// on-chain identity providers (ENS, Lens, Farcaster) to build a complete
/// social profile and compute recommendations.
class SocialGraphRepositoryImpl implements ISocialGraphRepository {
  final DeBankDatasource _debank;
  final OnChainIdentityDatasource _identity;
  final SocialGraphService _graphService;

  static final _evmAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');
  static final _whitespaceRegExp = RegExp(r'\s');

  SocialGraphRepositoryImpl({
    required DeBankDatasource debank,
    required OnChainIdentityDatasource identity,
    required SocialGraphService graphService,
  }) : _debank = debank,
       _identity = identity,
       _graphService = graphService;

  bool _isValidAddress(String address) {
    if (address.isEmpty) return false;
    if (address.startsWith('0x')) {
      return address.length == 42 &&
          _evmAddressRegExp.hasMatch(address);
    }
    return address.length >= 20 && !address.contains(_whitespaceRegExp);
  }

  @override
  Future<SocialProfile> getProfile(String address) async {
    if (!_isValidAddress(address)) {
      throw ArgumentError('Invalid address: $address');
    }

    final portfolioFuture = _withFallback(
      () => _debank.getUserPortfolio(address),
      const DeBankPortfolioModel(),
      'getUserPortfolio($address)',
    );
    final chainsFuture = _withFallback(
      () => _debank.getUsedChains(address),
      const <String>[],
      'getUsedChains($address)',
    );
    final identitiesFuture = _withFallback(
      () => _identity.getReverseIdentities(address),
      const <String, String?>{},
      'getReverseIdentities($address)',
    );

    final portfolio = await portfolioFuture;
    final chains = await chainsFuture;
    final identities = await identitiesFuture;

    return SocialProfile(
      address: address,
      ensName: identities['ens'],
      lensHandle: identities['lens'],
      chains: chains,
      portfolioValueUsd: portfolio.totalUsdValue,
    );
  }

  @override
  Future<List<SocialConnection>> getConnections(String address) async {
    if (!_isValidAddress(address)) {
      throw ArgumentError('Invalid address: $address');
    }

    // Connections are derived from the recommendation engine
    final recommendations = await getRecommendations(address, limit: 50);
    final deduped = <String, SocialConnection>{};
    for (final connection in recommendations.expand((r) => r.connections)) {
      final key =
          '${connection.fromAddress.toLowerCase()}|${connection.toAddress.toLowerCase()}|${connection.type.name}';
      deduped.putIfAbsent(key, () => connection);
    }
    return deduped.values.toList(growable: false);
  }

  @override
  Future<List<SocialRecommendation>> getRecommendations(
    String address, {
    int limit = 20,
  }) async {
    if (!_isValidAddress(address)) {
      throw ArgumentError('Invalid address: $address');
    }

    return _graphService.getRecommendations(address, limit: limit);
  }

  @override
  Future<SocialSimilarityModel> calculateSimilarity(
    String addressA,
    String addressB,
  ) async {
    if (!_isValidAddress(addressA)) {
      throw ArgumentError('Invalid addressA: $addressA');
    }
    if (!_isValidAddress(addressB)) {
      throw ArgumentError('Invalid addressB: $addressB');
    }
    return _graphService.calculateSimilarity(addressA, addressB);
  }

  @override
  Future<List<SocialProfile>> searchProfiles(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return [];
    }

    if (_isValidAddress(normalizedQuery)) {
      try {
        return [await getProfile(normalizedQuery)];
      } catch (_) {
        return [SocialProfile(address: normalizedQuery)];
      }
    }

    final ensFuture = _withFallback<String?>(
      () => _identity.resolveENS(normalizedQuery),
      null,
      'resolveENS($normalizedQuery)',
    );
    final lensFuture = _withFallback<String?>(
      () => _identity.resolveLensHandle(normalizedQuery),
      null,
      'resolveLensHandle($normalizedQuery)',
    );
    final farcasterFuture = _withFallback<String?>(
      () => _identity.resolveFarcaster(normalizedQuery),
      null,
      'resolveFarcaster($normalizedQuery)',
    );
    final results = await Future.wait([ensFuture, lensFuture, farcasterFuture]);

    final profiles = <SocialProfile>[];
    final seen = <String>{};

    for (final address in results) {
      if (address != null &&
          address.isNotEmpty &&
          !seen.contains(address.toLowerCase())) {
        seen.add(address.toLowerCase());
        try {
          final profile = await getProfile(address);
          profiles.add(profile);
        } catch (_) {
          // Fall back to a minimal profile with just the address
          profiles.add(SocialProfile(address: address));
        }
      }
    }

    return profiles;
  }

  /// Release resources held by all datasources.
  void dispose() {
    _debank.dispose();
    _identity.dispose();
  }

  Future<T> _withFallback<T>(
    Future<T> Function() loader,
    T fallback,
    String label,
  ) async {
    try {
      return await loader();
    } catch (e) {
      debugLog('SocialGraphRepository: $label failed: $e');
      return fallback;
    }
  }
}
