// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 聚合代币链上配置
class ChainTokenConfig {
  final String chainSymbol;
  final String contract;
  final int decimals;
  final int chainId;
  final String rpcUrl;
  final String rules;

  const ChainTokenConfig({
    required this.chainSymbol,
    required this.contract,
    required this.decimals,
    required this.chainId,
    required this.rpcUrl,
    this.rules = 'ERC20',
  });
}

/// 聚合代币定义
class AggregatedToken {
  final String symbol;
  final String name;
  final String icon;
  final List<ChainTokenConfig> chains;

  const AggregatedToken({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.chains,
  });
}

/// 预置的聚合代币列表 - USDT 和 USDC
/// 显示顺序：在 ETH 之后
class AggregatedTokens {
  AggregatedTokens._();

  /// USDT - Tether USD 多链配置
  static const usdt = AggregatedToken(
    symbol: 'USDT',
    name: 'Tether USD',
    icon: 'https://api.n42.ai/market/v1/r/coinImage/USDT.png',
    chains: [
      // Ethereum
      ChainTokenConfig(
        chainSymbol: 'ETH',
        contract: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        decimals: 6,
        chainId: 1,
        rpcUrl: 'https://mainnet.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9',
      ),
      // BSC
      ChainTokenConfig(
        chainSymbol: 'BNB',
        contract: '0x55d398326f99059fF775485246999027B3197955',
        decimals: 18,
        chainId: 56,
        rpcUrl: 'https://bsc-dataseed1.binance.org/',
        rules: 'BEP20',
      ),
      // Polygon
      ChainTokenConfig(
        chainSymbol: 'MATIC',
        contract: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
        decimals: 6,
        chainId: 137,
        rpcUrl: 'https://polygon-rpc.com',
      ),
      // Arbitrum
      ChainTokenConfig(
        chainSymbol: 'ARB',
        contract: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
        decimals: 6,
        chainId: 42161,
        rpcUrl: 'https://arb1.arbitrum.io/rpc',
      ),
      // Optimism
      ChainTokenConfig(
        chainSymbol: 'OP',
        contract: '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58',
        decimals: 6,
        chainId: 10,
        rpcUrl: 'https://mainnet.optimism.io',
      ),
      // Avalanche
      ChainTokenConfig(
        chainSymbol: 'AVAX',
        contract: '0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7',
        decimals: 6,
        chainId: 43114,
        rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
      ),
      // Tron
      ChainTokenConfig(
        chainSymbol: 'TRX',
        contract: 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
        decimals: 6,
        chainId: 0,
        rpcUrl: 'https://api.trongrid.io',
        rules: 'TRC20',
      ),
    ],
  );

  /// USDC - USD Coin 多链配置
  static const usdc = AggregatedToken(
    symbol: 'USDC',
    name: 'USD Coin',
    icon: 'https://api.n42.ai/market/v1/r/coinImage/USDC.png',
    chains: [
      // Ethereum
      ChainTokenConfig(
        chainSymbol: 'ETH',
        contract: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
        decimals: 6,
        chainId: 1,
        rpcUrl: 'https://mainnet.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9',
      ),
      // BSC
      ChainTokenConfig(
        chainSymbol: 'BNB',
        contract: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
        decimals: 18,
        chainId: 56,
        rpcUrl: 'https://bsc-dataseed1.binance.org/',
        rules: 'BEP20',
      ),
      // Polygon
      ChainTokenConfig(
        chainSymbol: 'MATIC',
        contract: '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359',
        decimals: 6,
        chainId: 137,
        rpcUrl: 'https://polygon-rpc.com',
      ),
      // Arbitrum
      ChainTokenConfig(
        chainSymbol: 'ARB',
        contract: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
        decimals: 6,
        chainId: 42161,
        rpcUrl: 'https://arb1.arbitrum.io/rpc',
      ),
      // Optimism
      ChainTokenConfig(
        chainSymbol: 'OP',
        contract: '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85',
        decimals: 6,
        chainId: 10,
        rpcUrl: 'https://mainnet.optimism.io',
      ),
      // Avalanche
      ChainTokenConfig(
        chainSymbol: 'AVAX',
        contract: '0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E',
        decimals: 6,
        chainId: 43114,
        rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
      ),
      // Base
      ChainTokenConfig(
        chainSymbol: 'BASE',
        contract: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
        decimals: 6,
        chainId: 8453,
        rpcUrl: 'https://mainnet.base.org',
      ),
      // Solana (SPL token)
      ChainTokenConfig(
        chainSymbol: 'SOL',
        contract: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
        decimals: 6,
        chainId: 0,
        rpcUrl: 'https://api.mainnet-beta.solana.com',
        rules: 'SPL',
      ),
    ],
  );

  /// 所有聚合代币列表（按显示顺序）
  static const List<AggregatedToken> all = [usdt, usdc];

  /// 根据符号获取聚合代币
  static AggregatedToken? getBySymbol(String symbol) {
    final upperSymbol = symbol.toUpperCase();
    for (final token in all) {
      if (token.symbol == upperSymbol) {
        return token;
      }
    }
    return null;
  }
}
