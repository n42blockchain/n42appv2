// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// RPC 端点配置
///
/// 集中管理区块链 RPC 端点配置
///
/// SECURITY WARNING:
/// 部分 RPC 端点使用 HTTP 而非 HTTPS，这存在中间人攻击风险。
/// 建议在生产环境中使用 HTTPS 端点或通过 VPN/代理访问。
class RpcConfig {
  RpcConfig._();

  // ==================== 测试网 RPC ====================

  /// BTC Testnet RPC
  /// TODO(production): Verify HTTPS support on BTC RPC server; revert to HTTP if not available
  static const String btcTestnetRpc = String.fromEnvironment(
    'BTC_TESTNET_RPC',
    defaultValue: 'https://198.200.30.38:18001',
  );

  // ==================== 主网 RPC ====================

  /// BTC Mainnet RPC
  /// TODO(production): Verify HTTPS support on BTC RPC server; revert to HTTP if not available
  static const String btcMainnetRpc = String.fromEnvironment(
    'BTC_MAINNET_RPC',
    defaultValue: 'https://198.200.30.34:18002',
  );

  // ==================== EVM 链 RPC ====================

  /// Ethereum Mainnet RPC
  static const String ethMainnetRpc = String.fromEnvironment(
    'ETH_RPC_URL',
    defaultValue: 'https://rpc.n42.world',
  );

  /// Ethereum Sepolia Testnet RPC
  static const String ethSepoliaRpc = 'https://eth-sepolia.public.blastapi.io';

  /// BSC Mainnet RPC
  static const String bscMainnetRpc = 'https://bsc-dataseed1.binance.org/';

  /// Polygon Mainnet RPC
  static const String polygonMainnetRpc = 'https://polygon-rpc.com';

  /// Arbitrum Mainnet RPC
  static const String arbitrumMainnetRpc = 'https://arb1.arbitrum.io/rpc';

  /// Optimism Mainnet RPC
  static const String optimismMainnetRpc = 'https://mainnet.optimism.io';

  /// Avalanche C-Chain RPC
  static const String avalancheMainnetRpc = 'https://api.avax.network/ext/bc/C/rpc';

  /// Base Mainnet RPC
  static const String baseMainnetRpc = 'https://mainnet.base.org';

  // ==================== 非 EVM 链 RPC ====================

  /// Solana Mainnet RPC
  static const String solanaMainnetRpc = 'https://api.mainnet-beta.solana.com';

  /// Tron Mainnet RPC
  static const String tronMainnetRpc = 'https://api.trongrid.io';

  // ==================== 安全检查 ====================

  /// 检查是否使用了不安全的 HTTP 连接
  static void validateSecurityInDebug() {
    if (!kDebugMode) return;

    // 所有需要检查的可配置端点（static const 支持运行时覆盖，需纳入检查）
    final checkTargets = <String, String>{
      'BTC_TESTNET_RPC': btcTestnetRpc,
      'BTC_MAINNET_RPC': btcMainnetRpc,
    };

    final insecureEntries = checkTargets.entries
        .where((e) => e.value.startsWith('http://'))
        .map((e) => '${e.key}: ${e.value}')
        .toList();

    if (insecureEntries.isNotEmpty) {
      debugPrint('⚠️ [RpcConfig] WARNING: Insecure HTTP connections detected:');
      for (final entry in insecureEntries) {
        debugPrint('   - $entry');
      }
      debugPrint('   Consider upgrading to HTTPS or using VPN/proxy');
    }
  }

  /// 检查 URL 是否安全
  static bool isSecureUrl(String url) {
    return url.startsWith('https://') || url.startsWith('wss://');
  }

  /// 获取安全的 URL（如果可能）
  /// 如果没有 HTTPS 替代方案，返回原 URL 并打印警告
  static String getSecureUrl(String url, {String? fallbackHttps}) {
    if (isSecureUrl(url)) return url;
    if (fallbackHttps != null) return fallbackHttps;

    if (kDebugMode) {
      debugPrint('⚠️ [RpcConfig] Using insecure URL: $url');
    }
    return url;
  }
}

/// 初始化 RPC 配置
void initRpcConfig() {
  _syncWalletChainRpcOverrides();
  RpcConfig.validateSecurityInDebug();
}

void _syncWalletChainRpcOverrides() {
  final eth = chainUrlMap['ETH'];
  if (eth is! Map<String, dynamic>) return;

  final baseInfo = eth['baseInfo'];
  if (baseInfo is! Map<String, dynamic>) return;

  baseInfo['service'] = RpcConfig.ethMainnetRpc;
  baseInfo['service_test'] = RpcConfig.ethSepoliaRpc;
}
