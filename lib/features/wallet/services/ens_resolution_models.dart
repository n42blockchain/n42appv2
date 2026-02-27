// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';

/// 域名解析协议
enum DomainProtocol {
  /// N42 Name Service (.n42)
  n42,

  /// Ethereum Name Service (.eth / .xyz / .app / .luxe / .kred / .art)
  ens,

  /// Unstoppable Domains (.crypto / .wallet / .nft / .blockchain / .dao / …)
  unstoppableDomains,

  /// Solana Name Service (.sol)
  sns,

  unknown,
}

/// ENS 解析结果
class EnsResolutionResult {
  /// 解析是否成功
  final bool success;

  /// 解析后的地址
  final String? address;

  /// ENS 名称
  final String? ensName;

  /// 头像 URL
  final String? avatar;

  /// 错误信息
  final String? error;

  /// 来源链标签（'N42' / 'ETH' / 'UD' / 'SNS'）
  final String? sourceChain;

  /// 解析使用的协议
  final DomainProtocol protocol;

  const EnsResolutionResult({
    required this.success,
    this.address,
    this.ensName,
    this.avatar,
    this.error,
    this.sourceChain,
    this.protocol = DomainProtocol.unknown,
  });

  factory EnsResolutionResult.success({
    required String address,
    String? ensName,
    String? avatar,
    String? sourceChain,
    DomainProtocol protocol = DomainProtocol.unknown,
  }) {
    return EnsResolutionResult(
      success: true,
      address: address,
      ensName: ensName,
      avatar: avatar,
      sourceChain: sourceChain,
      protocol: protocol,
    );
  }

  factory EnsResolutionResult.failure(String error) {
    return EnsResolutionResult(
      success: false,
      error: error,
    );
  }
}

/// ENS 文本记录
class EnsTextRecords {
  final String? email;
  final String? url;
  final String? avatar;
  final String? description;
  final String? twitter;
  final String? github;
  final String? discord;
  final String? telegram;
  final Map<String, String> custom;

  const EnsTextRecords({
    this.email,
    this.url,
    this.avatar,
    this.description,
    this.twitter,
    this.github,
    this.discord,
    this.telegram,
    this.custom = const {},
  });
}

/// 域名协议检测与链映射工具
///
/// 包含各协议后缀定义、协议识别，以及 coinType → UD ticker 映射。
class EnsProtocolUtils {
  EnsProtocolUtils._();

  // ── 域名后缀 ──────────────────────────────────────────────────────────────

  /// N42 Name Service 后缀
  static const n42Suffixes = ['.n42'];

  /// Solana Name Service 后缀
  static const snsSuffixes = ['.sol'];

  /// Unstoppable Domains 后缀（截止 2025 年已发布的 TLD）
  ///
  /// 参考：https://docs.unstoppabledomains.com/getting-started/supported-domains/
  static const udSuffixes = [
    '.crypto',     // UD 首批 TLD（2019）
    '.wallet',     // 多链钱包域名（2021）
    '.bitcoin',    // Bitcoin 生态（2021）
    '.nft',        // NFT 身份（2022）
    '.blockchain', // 通用区块链（2021）
    '.dao',        // DAO 组织（2022）
    '.888',        // 吉祥数字（2022）
    '.zil',        // Zilliqa 生态（迁移到 Polygon L2）
    '.x',          // 简短域名（2023）
    '.klever',     // Klever 生态（2022）
    '.hi',         // HI 金融（2022）
    '.kresus',     // Kresus 生态（2022）
    '.manga',      // 动漫文化（2023）
    '.binanceus',  // Binance US 生态（2022）
    '.coin',       // 通用代币（2023）
    '.polygon',    // Polygon 生态（2023）
  ];

  /// 以太坊 ENS 后缀
  static const ensSuffixes = [
    '.eth',
    '.xyz',
    '.app',
    '.luxe',
    '.kred',
    '.art',
  ];

  /// 全部支持的域名后缀（用于快速判断）
  static const allSuffixes = [
    ...n42Suffixes,
    ...snsSuffixes,
    ...udSuffixes,
    ...ensSuffixes,
  ];

  // ── 协议识别 ──────────────────────────────────────────────────────────────

  /// 检查字符串是否是受支持的域名（任意协议）
  static bool isEnsName(String input) {
    final lower = input.toLowerCase().trim();
    return allSuffixes.any((s) => lower.endsWith(s));
  }

  /// 检查链是否支持域名解析
  ///
  /// - N42、EVM 兼容链：支持 N42 NS + ENS + UD
  /// - Solana：支持 SNS + UD
  static bool chainSupportsEns(String coinType) {
    if (coinType == CoinType.SOL.name) return true;
    if (coinType == CoinType.N.name) return true;
    if (coinType == CoinType.ETH.name) return true;
    const evmChains = [
      'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB',
      'CELO', 'ONE', 'CRO', 'MOVR', 'GLMR',
    ];
    return evmChains.contains(coinType);
  }

  /// 识别域名所属协议
  static DomainProtocol detectProtocol(String domainName) {
    final lower = domainName.toLowerCase().trim();
    if (n42Suffixes.any((s) => lower.endsWith(s))) return DomainProtocol.n42;
    if (snsSuffixes.any((s) => lower.endsWith(s))) return DomainProtocol.sns;
    if (udSuffixes.any((s) => lower.endsWith(s))) {
      return DomainProtocol.unstoppableDomains;
    }
    if (ensSuffixes.any((s) => lower.endsWith(s))) return DomainProtocol.ens;
    return DomainProtocol.unknown;
  }

  // ── 链映射 ────────────────────────────────────────────────────────────────

  /// 将 N42 coinType 映射到 UD ticker 符号
  ///
  /// UD 使用标准代币 ticker 来区分多链地址记录，例如：
  ///   crypto.ETH.address / crypto.BTC.address / crypto.SOL.address
  static String? coinTypeToUdTicker(String? coinType) {
    if (coinType == null) return null;
    const tickerMap = {
      'ETH': 'ETH',
      'N': 'ETH',    // N42 使用 EVM 地址格式
      'BNB': 'BNB',
      'MATIC': 'MATIC',
      'AVAX': 'AVAX',
      'FTM': 'FTM',
      'OP': 'ETH',   // Optimism 使用 ETH 地址
      'ARB': 'ETH',  // Arbitrum 使用 ETH 地址
      'SOL': 'SOL',
      'BTC': 'BTC',
      'TRX': 'TRX',
      'XRP': 'XRP',
      'CELO': 'CELO',
      'ONE': 'ONE',
      'CRO': 'CRO',
      'MOVR': 'MOVR',
      'GLMR': 'GLMR',
    };
    return tickerMap[coinType.toUpperCase()];
  }
}
