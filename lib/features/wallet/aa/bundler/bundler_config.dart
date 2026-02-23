// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import '../core/aa_config.dart';

/// Bundler service provider configuration
class BundlerConfig {
  /// Provider name
  final String name;

  /// Base URL template (use {chainId} for chain ID substitution)
  final String urlTemplate;

  /// Whether API key is required
  final bool requiresApiKey;

  /// Supported chain IDs
  final Set<int> supportedChainIds;

  /// Rate limit (requests per second)
  final int? rateLimit;

  /// Whether this provider supports sponsorship
  final bool supportsSponsorship;

  const BundlerConfig({
    required this.name,
    required this.urlTemplate,
    this.requiresApiKey = true,
    required this.supportedChainIds,
    this.rateLimit,
    this.supportsSponsorship = false,
  });

  /// Get URL for a specific chain
  String getUrl(int chainId, {String? apiKey}) {
    var url = urlTemplate.replaceAll('{chainId}', chainId.toString());
    if (apiKey != null && requiresApiKey) {
      url = '$url?apikey=$apiKey';
    }
    return url;
  }

  /// Check if chain is supported
  bool supportsChain(int chainId) => supportedChainIds.contains(chainId);
}

/// Pre-configured bundler providers
class BundlerProviders {
  BundlerProviders._();

  /// Pimlico bundler configuration
  static const pimlico = BundlerConfig(
    name: 'Pimlico',
    urlTemplate: 'https://api.pimlico.io/v2/{chainId}/rpc',
    requiresApiKey: true,
    supportedChainIds: {
      1, // Ethereum
      10, // Optimism
      137, // Polygon
      8453, // Base
      42161, // Arbitrum
      11155111, // Sepolia
      84532, // Base Sepolia
      421614, // Arbitrum Sepolia
    },
    rateLimit: 10,
    supportsSponsorship: true,
  );

  /// StackUp bundler configuration
  static const stackup = BundlerConfig(
    name: 'StackUp',
    urlTemplate: 'https://api.stackup.sh/v1/node/{chainId}',
    requiresApiKey: true,
    supportedChainIds: {
      1, // Ethereum
      10, // Optimism
      137, // Polygon
      8453, // Base
      42161, // Arbitrum
    },
    rateLimit: 5,
    supportsSponsorship: false,
  );

  /// Alchemy bundler configuration
  static const alchemy = BundlerConfig(
    name: 'Alchemy',
    urlTemplate: 'https://{network}.g.alchemy.com/v2/{apiKey}',
    requiresApiKey: true,
    supportedChainIds: {
      1, // Ethereum
      10, // Optimism
      137, // Polygon
      8453, // Base
      42161, // Arbitrum
    },
    rateLimit: 30,
    supportsSponsorship: true,
  );

  /// All available providers
  static const List<BundlerConfig> all = [pimlico, stackup, alchemy];

  /// Get provider by name
  static BundlerConfig? getByName(String name) {
    return all.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Get providers supporting a chain
  static List<BundlerConfig> getForChain(int chainId) {
    return all.where((p) => p.supportsChain(chainId)).toList();
  }
}

/// Bundler selection strategy
enum BundlerStrategy {
  /// Use primary bundler only
  primary,

  /// Use primary, fallback to backup on error
  fallback,

  /// Try multiple bundlers and use fastest response
  race,

  /// Round-robin between available bundlers
  roundRobin,
}

/// Multi-bundler configuration for redundancy
class MultiBundlerConfig {
  /// Primary bundler URL
  final String primaryUrl;

  /// Backup bundler URLs
  final List<String> backupUrls;

  /// Selection strategy
  final BundlerStrategy strategy;

  /// Entry point address
  final String entryPoint;

  /// API keys by provider name
  final Map<String, String>? apiKeys;

  const MultiBundlerConfig({
    required this.primaryUrl,
    this.backupUrls = const [],
    this.strategy = BundlerStrategy.fallback,
    required this.entryPoint,
    this.apiKeys,
  });

  /// Create from chain symbol
  factory MultiBundlerConfig.forChain(
    String chainSymbol, {
    Map<String, String>? apiKeys,
    BundlerStrategy strategy = BundlerStrategy.fallback,
  }) {
    final config = AAConfig.getChainConfig(chainSymbol);
    if (config == null) {
      throw ArgumentError('Unsupported chain: $chainSymbol');
    }

    return MultiBundlerConfig(
      primaryUrl: config.bundlerUrl,
      backupUrls: config.backupBundlerUrl != null ? [config.backupBundlerUrl!] : [],
      strategy: strategy,
      entryPoint: config.entryPoint,
      apiKeys: apiKeys,
    );
  }

  /// Get all available URLs
  List<String> get allUrls => [primaryUrl, ...backupUrls];

  /// Apply API key to URL if available
  String applyApiKey(String url, String providerName) {
    if (apiKeys == null || !apiKeys!.containsKey(providerName)) {
      return url;
    }
    return '$url?apikey=${apiKeys![providerName]}';
  }
}

/// Bundler health check result
class BundlerHealthCheck {
  /// Bundler URL
  final String url;

  /// Whether bundler is healthy
  final bool isHealthy;

  /// Response time in milliseconds
  final int responseTimeMs;

  /// Supported entry points
  final List<String>? entryPoints;

  /// Error message if unhealthy
  final String? error;

  /// Timestamp of check
  final DateTime timestamp;

  const BundlerHealthCheck({
    required this.url,
    required this.isHealthy,
    required this.responseTimeMs,
    this.entryPoints,
    this.error,
    required this.timestamp,
  });

  factory BundlerHealthCheck.healthy({
    required String url,
    required int responseTimeMs,
    List<String>? entryPoints,
  }) {
    return BundlerHealthCheck(
      url: url,
      isHealthy: true,
      responseTimeMs: responseTimeMs,
      entryPoints: entryPoints,
      timestamp: DateTime.now(),
    );
  }

  factory BundlerHealthCheck.unhealthy({
    required String url,
    required String error,
    int responseTimeMs = 0,
  }) {
    return BundlerHealthCheck(
      url: url,
      isHealthy: false,
      responseTimeMs: responseTimeMs,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    if (isHealthy) {
      return 'BundlerHealthCheck(url: $url, healthy, ${responseTimeMs}ms)';
    }
    return 'BundlerHealthCheck(url: $url, unhealthy: $error)';
  }
}
