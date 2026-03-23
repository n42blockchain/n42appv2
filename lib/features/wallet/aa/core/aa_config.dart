// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import '../../../../core/config/proxy_config.dart';

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

  /// Per-chain ERC-20 tokens available for ERC-20 Paymaster
  ///
  /// Addresses verified against each chain's canonical token registry.
  static const Map<String, List<ChainToken>> chainErc20Tokens = {
    'ETH': [
      ChainToken(symbol: 'USDC', address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', decimals: 6),
      ChainToken(symbol: 'USDT', address: '0xdAC17F958D2ee523a2206206994597C13D831ec7', decimals: 6),
      ChainToken(symbol: 'DAI',  address: '0x6B175474E89094C44Da98b954EedeAC495271d0F', decimals: 18),
    ],
    'BASE': [
      ChainToken(symbol: 'USDC', address: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913', decimals: 6),
      ChainToken(symbol: 'DAI',  address: '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb', decimals: 18),
    ],
    'ARB': [
      ChainToken(symbol: 'USDC', address: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831', decimals: 6),
      ChainToken(symbol: 'USDT', address: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9', decimals: 6),
      ChainToken(symbol: 'DAI',  address: '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1', decimals: 18),
    ],
    'OP': [
      ChainToken(symbol: 'USDC', address: '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85', decimals: 6),
      ChainToken(symbol: 'USDT', address: '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58', decimals: 6),
      ChainToken(symbol: 'DAI',  address: '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1', decimals: 18),
    ],
    'MATIC': [
      ChainToken(symbol: 'USDC', address: '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359', decimals: 6),
      ChainToken(symbol: 'USDT', address: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F', decimals: 6),
      ChainToken(symbol: 'DAI',  address: '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063', decimals: 18),
    ],
  };

  /// Chain ID mapping
  static const Map<String, int> chainIds = {
    'ETH': 1,
    'BASE': 8453,
    'ARB': 42161,
    'OP': 10,
    'MATIC': 137,
  };

  /// Paymaster RPC URLs — routed through server proxy (API key injected server-side)
  ///
  /// Pimlico's paymaster service is accessed via the same RPC endpoint using
  /// `pm_getPaymasterStubData` and `pm_getPaymasterData` methods.
  static final Map<String, String> paymasterUrls = {
    'ETH':   ProxyConfig.bundler('1'),
    'BASE':  ProxyConfig.bundler('8453'),
    'ARB':   ProxyConfig.bundler('42161'),
    'OP':    ProxyConfig.bundler('10'),
    'MATIC': ProxyConfig.bundler('137'),
  };

  /// Bundler URL configuration — routed through server proxy
  static final Map<String, String> bundlerUrls = {
    'ETH':   ProxyConfig.bundler('1'),
    'BASE':  ProxyConfig.bundler('8453'),
    'ARB':   ProxyConfig.bundler('42161'),
    'OP':    ProxyConfig.bundler('10'),
    'MATIC': ProxyConfig.bundler('137'),
  };

  /// Backup Bundler URLs (StackUp as fallback — also through proxy)
  @Deprecated('Bundler requests now go through server proxy with automatic failover')
  static const Map<String, String> backupBundlerUrls = {
    'ETH': 'https://api.stackup.sh/v1/node/ethereum-mainnet',
    'BASE': 'https://api.stackup.sh/v1/node/base-mainnet',
    'ARB': 'https://api.stackup.sh/v1/node/arbitrum-one',
    'OP': 'https://api.stackup.sh/v1/node/optimism-mainnet',
    'MATIC': 'https://api.stackup.sh/v1/node/polygon-mainnet',
  };

  /// Testnet configurations (v0.8) — through server proxy
  static Map<String, AAChainConfig> get testnetConfigs => {
    'SEPOLIA': AAChainConfig(
      chainId: 11155111,
      bundlerUrl: ProxyConfig.bundler('11155111'),
      entryPoint: getEntryPoint(),
      simpleAccountFactory: getSimpleAccountFactory(),
      version: defaultVersion,
    ),
    'BASE_SEPOLIA': AAChainConfig(
      chainId: 84532,
      bundlerUrl: ProxyConfig.bundler('84532'),
      entryPoint: getEntryPoint(),
      simpleAccountFactory: getSimpleAccountFactory(),
      version: defaultVersion,
    ),
    'ARB_SEPOLIA': AAChainConfig(
      chainId: 421614,
      bundlerUrl: ProxyConfig.bundler('421614'),
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
      // Backup handled server-side by proxy; no client-side fallback needed.
      paymasterUrl: paymasterUrls[symbol],
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

  /// Get Paymaster URL for the given chain symbol
  ///
  /// Returns null if the chain is not supported.
  static String? getPaymasterUrl(String chainSymbol) {
    return paymasterUrls[chainSymbol.toUpperCase()];
  }

  /// Get ERC-20 tokens available for paymaster on the given chain
  ///
  /// Returns an empty list if no tokens are configured for the chain.
  static List<ChainToken> getChainTokens(String chainSymbol) {
    return chainErc20Tokens[chainSymbol.toUpperCase()] ?? const [];
  }

  /// Bundler API key — migrated to server proxy.
  @Deprecated('API key migrated to server proxy. Use ProxyConfig.bundler() instead.')
  static String? getBundlerApiKey() => null;
}

/// ERC-20 token descriptor used in per-chain paymaster token lists
class ChainToken {
  /// Token symbol (e.g. "USDC")
  final String symbol;

  /// Checksummed contract address on the chain
  final String address;

  /// Token decimals (6 for USDC/USDT, 18 for DAI)
  final int decimals;

  const ChainToken({
    required this.symbol,
    required this.address,
    required this.decimals,
  });
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

  /// Get bundler URL (without API key in URL — supply key via Authorization header).
  ///
  /// The API key must be sent as `Authorization: Bearer <key>` header to avoid
  /// leaking it in proxy logs, browser history, and server access logs.
  ///
  /// Deprecated: use [bundlerUrl] directly and set the header on your HTTP client.
  @Deprecated('Pass apiKey via Authorization header, not URL query param')
  String getBundlerUrlWithKey(String? apiKey) {
    // API key is intentionally not appended to the URL to prevent log leakage.
    return bundlerUrl;
  }
}
