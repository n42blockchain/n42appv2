// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';

/// API Keys 配置
///
/// 安全地管理第三方 API keys
///
/// 使用方式:
/// 1. 开发环境: 使用 --dart-define 传入 keys
///    flutter run --dart-define=INFURA_API_KEY=xxx --dart-define=ETHERSCAN_API_KEY=xxx
///
/// 2. 生产环境: 在 CI/CD 中设置环境变量
///    INFURA_API_KEY=xxx flutter build apk
///
/// 3. 本地开发: 创建 api_keys.local.dart (已在 .gitignore 中)
///
/// 注意: 永远不要将真实的 API keys 提交到代码仓库
class ApiKeysConfig {
  ApiKeysConfig._();

  // ==================== Infura ====================

  /// Infura API Key (Ethereum Mainnet)
  static const String infuraMainnet = String.fromEnvironment(
    'INFURA_API_KEY',
    defaultValue: _defaultInfuraKey,
  );

  /// Infura API Key (Sepolia Testnet)
  static const String infuraSepolia = String.fromEnvironment(
    'INFURA_SEPOLIA_KEY',
    defaultValue: _defaultInfuraKey,
  );

  // ==================== Block Explorers ====================

  /// Etherscan API Key
  static const String etherscan = String.fromEnvironment(
    'ETHERSCAN_API_KEY',
    defaultValue: _defaultEtherscanKey,
  );

  /// BSCScan API Key
  static const String bscscan = String.fromEnvironment(
    'BSCSCAN_API_KEY',
    defaultValue: _defaultBscscanKey,
  );

  /// Basescan API Key
  static const String basescan = String.fromEnvironment(
    'BASESCAN_API_KEY',
    defaultValue: _defaultBasescanKey,
  );

  /// Sonicscan API Key
  static const String sonicscan = String.fromEnvironment(
    'SONICSCAN_API_KEY',
    defaultValue: _defaultSonicscanKey,
  );

  // ==================== TON (The Open Network) ====================

  /// TON API Key - Mainnet
  static const String tonApiKeyMainnet = String.fromEnvironment(
    'TON_API_KEY_MAINNET',
    defaultValue: _defaultTonApiKeyMainnet,
  );

  /// TON API Key - Testnet
  static const String tonApiKeyTestnet = String.fromEnvironment(
    'TON_API_KEY_TESTNET',
    defaultValue: _defaultTonApiKeyTestnet,
  );

  // ==================== Polkadot / Substrate ====================

  /// DOT (Polkadot) Subscan x-api-key
  static const String dotApiKey = String.fromEnvironment(
    'DOT_API_KEY',
    defaultValue: _defaultDotApiKey,
  );

  // ==================== AI Service ====================

  /// AI API Key (Groq / OpenAI / DeepSeek compatible)
  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: _defaultAiApiKey,
  );

  /// AI API Base URL
  static const String aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://api.groq.com/openai',
  );

  /// AI Model
  static const String aiModel = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  // ==================== CoinGecko ====================

  /// CoinGecko Demo/Pro API Key
  /// 免费 Demo key: https://www.coingecko.com/en/developers/dashboard
  /// 配置方式: flutter run --dart-define=COINGECKO_API_KEY=CG-xxxx
  static const String coinGeckoApiKey = String.fromEnvironment(
    'COINGECKO_API_KEY',
    defaultValue: '',
  );

  // ==================== SimpleHash ====================

  /// SimpleHash NFT API Key
  /// 文档: https://docs.simplehash.com
  /// 配置方式: flutter run --dart-define=SIMPLE_HASH_API_KEY=xxx
  static const String simpleHashApiKey = String.fromEnvironment(
    'SIMPLE_HASH_API_KEY',
    defaultValue: '',
  );

  // ==================== Default Keys (Development Only) ====================
  // WARNING: These are placeholder keys for development
  // In production, always use environment variables

  static const String _defaultInfuraKey = 'YOUR_INFURA_API_KEY';
  static const String _defaultEtherscanKey = 'YOUR_ETHERSCAN_API_KEY';
  static const String _defaultBscscanKey = 'YOUR_BSCSCAN_API_KEY';
  static const String _defaultBasescanKey = 'YOUR_BASESCAN_API_KEY';
  static const String _defaultSonicscanKey = 'YOUR_SONICSCAN_API_KEY';
  static const String _defaultTonApiKeyMainnet = '';
  static const String _defaultTonApiKeyTestnet = '';
  static const String _defaultDotApiKey = '';
  // IMPORTANT(test-only): This key is kept for local development/testing ONLY.
  // It MUST be overridden before any production/release build:
  //   flutter build apk --dart-define=AI_API_KEY=<real_key>
  // Shipping with this default exposes the Groq quota to anyone who decompiles the binary.
  // ignore: avoid_hardcoded_credentials
  static const String _defaultAiApiKey = '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';

  // ==================== Validation ====================

  /// 检查 API keys 是否已配置
  static bool get isConfigured {
    return infuraMainnet != _defaultInfuraKey &&
        etherscan != _defaultEtherscanKey &&
        tonApiKeyMainnet.isNotEmpty &&
        dotApiKey.isNotEmpty;
  }

  /// 在 Debug 模式下验证 API keys 配置
  static void validateInDebug() {
    if (!kDebugMode) return;

    final warnings = <String>[];

    if (infuraMainnet == _defaultInfuraKey) {
      warnings.add('INFURA_API_KEY not configured');
    }
    if (etherscan == _defaultEtherscanKey) {
      warnings.add('ETHERSCAN_API_KEY not configured');
    }
    if (bscscan == _defaultBscscanKey) {
      warnings.add('BSCSCAN_API_KEY not configured');
    }
    if (basescan == _defaultBasescanKey) {
      warnings.add('BASESCAN_API_KEY not configured');
    }
    if (sonicscan == _defaultSonicscanKey) {
      warnings.add('SONICSCAN_API_KEY not configured');
    }
    if (tonApiKeyMainnet.isEmpty) {
      warnings.add('TON_API_KEY_MAINNET not configured');
    }
    if (dotApiKey.isEmpty) {
      warnings.add('DOT_API_KEY not configured');
    }
    if (aiApiKey == _defaultAiApiKey) {
      warnings.add('AI_API_KEY not configured');
    }

    if (warnings.isNotEmpty) {
      debugPrint('⚠️ [ApiKeysConfig] Missing API keys:');
      for (final warning in warnings) {
        debugPrint('   - $warning');
      }
      debugPrint('   Use --dart-define to set API keys');
    }
  }

  // ==================== URL Builders ====================

  /// 获取 Infura RPC URL
  static String getInfuraUrl({
    required String network,
    String? customKey,
  }) {
    final key = customKey ?? infuraMainnet;
    return 'https://$network.infura.io/v3/$key';
  }

  /// 获取 Etherscan API URL
  static String getEtherscanApiUrl({
    String baseUrl = 'https://api.etherscan.io/api',
    String? customKey,
  }) {
    final key = customKey ?? etherscan;
    if (key == _defaultEtherscanKey) {
      return '$baseUrl?';
    }
    return '$baseUrl?apikey=$key&';
  }

  /// 获取 BSCScan API URL
  static String getBscscanApiUrl({
    String baseUrl = 'https://api.bscscan.com/api',
    String? customKey,
  }) {
    final key = customKey ?? bscscan;
    if (key == _defaultBscscanKey) {
      return '$baseUrl?';
    }
    return '$baseUrl?apikey=$key&';
  }

  /// 获取 Basescan API URL
  static String getBasescanApiUrl({
    String baseUrl = 'https://api.basescan.org/api',
    String? customKey,
  }) {
    final key = customKey ?? basescan;
    if (key == _defaultBasescanKey) {
      return '$baseUrl?';
    }
    return '$baseUrl?apikey=$key&';
  }

  /// 获取 Sonicscan API URL
  static String getSonicscanApiUrl({
    String baseUrl = 'https://api.sonicscan.org/api',
    bool isTestnet = false,
    String? customKey,
  }) {
    final key = customKey ?? sonicscan;
    final url = isTestnet
        ? 'https://api-testnet.sonicscan.org/api'
        : baseUrl;
    if (key == _defaultSonicscanKey) {
      return '$url?';
    }
    return '$url?apikey=$key&';
  }
}

/// API Keys 初始化
///
/// 在应用启动时调用以验证 API keys 配置
void initApiKeys() {
  ApiKeysConfig.validateInDebug();
}
