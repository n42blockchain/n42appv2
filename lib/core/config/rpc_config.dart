// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';

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
  /// WARNING: HTTP 连接，仅用于测试
  static const String btcTestnetRpc = String.fromEnvironment(
    'BTC_TESTNET_RPC',
    defaultValue: 'http://198.200.30.38:18001',
  );

  // ==================== 主网 RPC ====================

  /// BTC Mainnet RPC
  /// WARNING: HTTP 连接，需要升级到 HTTPS
  static const String btcMainnetRpc = String.fromEnvironment(
    'BTC_MAINNET_RPC',
    defaultValue: 'http://198.200.30.34:18002',
  );

  // ==================== 安全检查 ====================

  /// 检查是否使用了不安全的 HTTP 连接
  static void validateSecurityInDebug() {
    if (!kDebugMode) return;

    final insecureUrls = <String>[];

    if (btcTestnetRpc.startsWith('http://')) {
      insecureUrls.add('BTC_TESTNET_RPC: $btcTestnetRpc');
    }
    if (btcMainnetRpc.startsWith('http://')) {
      insecureUrls.add('BTC_MAINNET_RPC: $btcMainnetRpc');
    }

    if (insecureUrls.isNotEmpty) {
      debugPrint('⚠️ [RpcConfig] WARNING: Insecure HTTP connections detected:');
      for (final url in insecureUrls) {
        debugPrint('   - $url');
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
    if (isSecureUrl(url)) {
      return url;
    }

    if (fallbackHttps != null) {
      return fallbackHttps;
    }

    if (kDebugMode) {
      debugPrint('⚠️ [RpcConfig] Using insecure URL: $url');
    }
    return url;
  }
}

/// 初始化 RPC 配置
void initRpcConfig() {
  RpcConfig.validateSecurityInDebug();
}
