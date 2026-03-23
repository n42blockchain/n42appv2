// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';

/// API Keys 配置
///
/// 大部分第三方 API key 已迁移到服务端代理 (ProxyConfig)，
/// 此类仅保留仍需客户端持有的少量配置。
///
/// 已迁移到代理的 Key:
/// - Infura, Etherscan, BSCScan, Basescan, Sonicscan
/// - TON, DOT (Subscan), CoinGecko, SimpleHash
/// - MoonPay (签名已走代理)
/// - AI (Groq/OpenAI/DeepSeek)
class ApiKeysConfig {
  ApiKeysConfig._();

  // ==================== Validation ====================

  /// 在 Debug 模式下验证配置
  static void validateInDebug() {
    if (!kDebugMode) return;
    debugPrint('[ApiKeysConfig] All API keys migrated to server proxy.');
  }
}

/// API Keys 初始化
void initApiKeys() {
  ApiKeysConfig.validateInDebug();
}
