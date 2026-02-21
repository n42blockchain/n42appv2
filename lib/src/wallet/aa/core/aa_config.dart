// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// EntryPoint version enum
enum EntryPointVersion {
  /// ERC-4337 v0.7 - original packed UserOperation format
  v07,

  /// ERC-4337 v0.8 - includes EIP-7702 support and gas optimizations
  v08,
}

/// ERC-4337 Account Abstraction Configuration
///
/// Contains EntryPoint addresses, Bundler URLs, and chain-specific configurations
/// for Account Abstraction functionality.
class AAConfig {
  AAConfig._();

  /// Default EntryPoint version to use
  static EntryPointVersion defaultVersion = EntryPointVersion.v08;

  /// EntryPoint v0.7 address (same across all supported chains)
  static const String entryPointV07 = '0x0000000071727De22E5E9d8BAf0edAc6f37da032';

  /// EntryPoint v0.8 address (same across all supported chains)
  /// Includes EIP-7702 support and optimized gas handling
  static const String entryPointV08 = '0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108';

  /// SimpleAccount Factory v0.7 address (same across all supported chains)
  static const String simpleAccountFactoryV07 = '0x91E60e0613810449d098b0b5Ec8b51A0FE8c8985';

  /// SimpleAccount Factory v0.8 address (same across all supported chains)
  static const String simpleAccountFactoryV08 = '0x91E60e0613810449d098b0b5Ec8b51A0FE8c8985';

  /// Simple7702Account Factory address for EIP-7702 hybrid accounts
  static const String simple7702AccountFactory = '0x7702000000000000000000000000000000000001';

  // ── Safe (Gnosis Safe v1.4.1) ─────────────────────────────────────────────

  /// SafeProxyFactory v1.4.1 — deployed at same address on all EVM chains
  static const String safeProxyFactory = '0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67';

  /// SafeL2 singleton v1.4.1 — used as mastercopy for proxy deployment
  static const String safeL2Singleton = '0x29fcB43b46531BcA003ddC8FCB67FFE91900C762';

  /// Safe CompatibilityFallbackHandler v1.4.1
  static const String safeFallbackHandler = '0xfd0732Dc9E303f09fCEf3a7388Ad10A83459Ec99';

  // ── Biconomy Nexus v1 (ERC-7579 modular) ─────────────────────────────────

  /// Biconomy Nexus v1 Factory — deployed at same address on all EVM chains
  static const String biconomyNexusFactory = '0x0000000000BBc222D4Ca2ae6c3a42b9B5E1Ca3F0';

  /// Biconomy K1 Validator (ECDSA single-owner module for Nexus)
  static const String biconomyK1Validator = '0x0000002D6DB27c52E3C11c1Cf24072004AC75cBa';

  /// Get EntryPoint address for specified version
  static String getEntryPoint({EntryPointVersion? version}) {
    final v = version ?? defaultVersion;
    return v == EntryPointVersion.v08 ? entryPointV08 : entryPointV07;
  }

  /// Get SimpleAccount Factory address for specified version
  static String getSimpleAccountFactory({EntryPointVersion? version}) {
    final v = version ?? defaultVersion;
    return v == EntryPointVersion.v08 ? simpleAccountFactoryV08 : simpleAccountFactoryV07;
  }

  /// Get Safe ProxyFactory address (same for all versions/chains)
  static String getSafeFactory() => safeProxyFactory;

  /// Get Biconomy Nexus Factory address (same for all versions/chains)
  static String getBiconomyFactory() => biconomyNexusFactory;

  /// Supported chain symbols for AA
  static const Set<String> supportedChains = {
    'ETH',
    'BASE',
    'ARB',
    'OP',
    'MATIC',
  };

  /// Chain ID mapping
  static const Map<String, int> chainIds = {
    'ETH': 1,
    'BASE': 8453,
    'ARB': 42161,
    'OP': 10,
    'MATIC': 137,
  };

  /// Bundler URL configuration (Pimlico as primary)
  static const Map<String, String> bundlerUrls = {
    'ETH': 'https://api.pimlico.io/v2/1/rpc',
    'BASE': 'https://api.pimlico.io/v2/8453/rpc',
    'ARB': 'https://api.pimlico.io/v2/42161/rpc',
    'OP': 'https://api.pimlico.io/v2/10/rpc',
    'MATIC': 'https://api.pimlico.io/v2/137/rpc',
  };

  /// Backup Bundler URLs (StackUp as fallback)
  static const Map<String, String> backupBundlerUrls = {
    'ETH': 'https://api.stackup.sh/v1/node/ethereum-mainnet',
    'BASE': 'https://api.stackup.sh/v1/node/base-mainnet',
    'ARB': 'https://api.stackup.sh/v1/node/arbitrum-one',
    'OP': 'https://api.stackup.sh/v1/node/optimism-mainnet',
    'MATIC': 'https://api.stackup.sh/v1/node/polygon-mainnet',
  };

  /// Testnet configurations (v0.8)
  static Map<String, AAChainConfig> get testnetConfigs => {
    'SEPOLIA': AAChainConfig(
      chainId: 11155111,
      bundlerUrl: 'https://api.pimlico.io/v2/11155111/rpc',
      entryPoint: getEntryPoint(),
      simpleAccountFactory: getSimpleAccountFactory(),
      version: defaultVersion,
    ),
    'BASE_SEPOLIA': AAChainConfig(
      chainId: 84532,
      bundlerUrl: 'https://api.pimlico.io/v2/84532/rpc',
      entryPoint: getEntryPoint(),
      simpleAccountFactory: getSimpleAccountFactory(),
      version: defaultVersion,
    ),
    'ARB_SEPOLIA': AAChainConfig(
      chainId: 421614,
      bundlerUrl: 'https://api.pimlico.io/v2/421614/rpc',
      entryPoint: getEntryPoint(),
      simpleAccountFactory: getSimpleAccountFactory(),
      version: defaultVersion,
    ),
  };

  /// Get testnet config for specified version
  static AAChainConfig? getTestnetConfig(String symbol, {EntryPointVersion? version}) {
    final v = version ?? defaultVersion;
    final baseConfig = testnetConfigs[symbol.toUpperCase()];
    if (baseConfig == null) return null;

    return AAChainConfig(
      chainId: baseConfig.chainId,
      bundlerUrl: baseConfig.bundlerUrl,
      entryPoint: getEntryPoint(version: v),
      simpleAccountFactory: getSimpleAccountFactory(version: v),
      version: v,
    );
  }

  /// Get chain configuration
  static AAChainConfig? getChainConfig(
    String chainSymbol, {
    bool isTestnet = false,
    EntryPointVersion? version,
  }) {
    final symbol = chainSymbol.toUpperCase();
    final v = version ?? defaultVersion;

    if (isTestnet) {
      return getTestnetConfig(symbol, version: v);
    }

    if (!supportedChains.contains(symbol)) {
      return null;
    }

    return AAChainConfig(
      chainId: chainIds[symbol]!,
      bundlerUrl: bundlerUrls[symbol]!,
      backupBundlerUrl: backupBundlerUrls[symbol],
      entryPoint: getEntryPoint(version: v),
      simpleAccountFactory: getSimpleAccountFactory(version: v),
      safeFactory: getSafeFactory(),
      biconomyFactory: getBiconomyFactory(),
      version: v,
    );
  }

  /// Check if a chain supports AA
  static bool isChainSupported(String chainSymbol) {
    return supportedChains.contains(chainSymbol.toUpperCase());
  }

  /// Bundler API key from build-time environment variable
  ///
  /// Set via: flutter build --dart-define=BUNDLER_API_KEY=your_key
  /// Or in IDE run configuration as environment variable
  static const String _bundlerApiKey = String.fromEnvironment(
    'BUNDLER_API_KEY',
    defaultValue: '',
  );

  /// Get Bundler API key for authenticated bundler requests
  ///
  /// Returns the API key if configured, null otherwise.
  /// For production deployments, set BUNDLER_API_KEY environment variable:
  /// ```
  /// flutter build --dart-define=BUNDLER_API_KEY=pk_xxx
  /// ```
  static String? getBundlerApiKey() {
    return _bundlerApiKey.isNotEmpty ? _bundlerApiKey : null;
  }
}

/// Chain-specific AA configuration
class AAChainConfig {
  final int chainId;
  final String bundlerUrl;
  final String? backupBundlerUrl;
  final String entryPoint;
  final String simpleAccountFactory;

  /// Safe ProxyFactory v1.4.1 address (null if not set)
  final String? safeFactory;

  /// Biconomy Nexus v1 Factory address (null if not set)
  final String? biconomyFactory;

  final String? paymasterUrl;
  final EntryPointVersion version;

  const AAChainConfig({
    required this.chainId,
    required this.bundlerUrl,
    this.backupBundlerUrl,
    required this.entryPoint,
    required this.simpleAccountFactory,
    this.safeFactory,
    this.biconomyFactory,
    this.paymasterUrl,
    this.version = EntryPointVersion.v08,
  });

  /// Check if this config supports EIP-7702
  bool get supportsEIP7702 => version == EntryPointVersion.v08;

  /// Get Simple7702Account factory address (only for v0.8)
  String? get simple7702AccountFactory =>
      version == EntryPointVersion.v08 ? AAConfig.simple7702AccountFactory : null;

  /// Get bundler URL with API key appended if available
  String getBundlerUrlWithKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) {
      return bundlerUrl;
    }
    return '$bundlerUrl?apikey=$apiKey';
  }
}
