// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';

/// 支持 ENS 的链配置（用于域名后缀匹配与颜色展示）
class EnsChainConfig {
  final String id;
  final String name;
  final String symbol;
  final int chainId;
  final String? iconPath;
  final Color color;
  final String suffix; // ENS 域名后缀

  const EnsChainConfig({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    this.iconPath,
    required this.color,
    required this.suffix,
  });

  static const List<EnsChainConfig> supportedChains = [
    EnsChainConfig(
      id: 'n42',
      name: 'N42',
      symbol: 'N',
      chainId: 42,
      color: Color(0xFF6366F1),
      suffix: '.n42',
    ),
    EnsChainConfig(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      chainId: 1,
      color: Color(0xFF627EEA),
      suffix: '.eth',
    ),
    EnsChainConfig(
      id: 'sepolia',
      name: 'Sepolia',
      symbol: 'ETH',
      chainId: 11155111,
      color: Color(0xFF9B8AFF),
      suffix: '.eth',
    ),
    EnsChainConfig(
      id: 'base',
      name: 'Base',
      symbol: 'ETH',
      chainId: 8453,
      color: Color(0xFF0052FF),
      suffix: '.base.eth',
    ),
    EnsChainConfig(
      id: 'arbitrum',
      name: 'Arbitrum',
      symbol: 'ETH',
      chainId: 42161,
      color: Color(0xFF28A0F0),
      suffix: '.arb',
    ),
  ];

  static EnsChainConfig get defaultChain => supportedChains[1]; // Ethereum

  /// 从完整域名后缀自动推断所在链
  static EnsChainConfig fromDomainName(String name) {
    final lower = name.toLowerCase();
    // 最长后缀优先（.base.eth 比 .eth 更具体）
    final sorted = List<EnsChainConfig>.from(supportedChains)
      ..sort((a, b) => b.suffix.length.compareTo(a.suffix.length));
    for (final chain in sorted) {
      if (lower.endsWith(chain.suffix)) return chain;
    }
    return defaultChain;
  }
}
