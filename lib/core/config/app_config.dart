// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';

/// Application Configuration
///
/// Centralized configuration management for the N42 Wallet application.
/// Contains API endpoints, environment flags, and app-wide constants.
///
/// ## Environment Management
/// - [isOnline]: Controls production vs test environment
/// - Use environment variables or build flavors in production
class AppConfig {
  AppConfig._();

  // ============ Wallet Constants ============
  
  /// Maximum wallet name length
  static const int walletNameMaxLength = 12;
  
  /// Minimum wallet password length
  static const int walletPasswordLength = 8;

  // ============ IPFS Credentials ============
  // Loaded from environment variables at build time:
  //   --dart-define=IPFS_USERNAME=xxx --dart-define=IPFS_PASSWORD=xxx
  static const String _ipfsUsername = String.fromEnvironment('IPFS_USERNAME');
  static const String _ipfsPassword = String.fromEnvironment('IPFS_PASSWORD');

  static String get ipfsUsername => _ipfsUsername;
  static String get ipfsPassword => _ipfsPassword;

  // ============ Environment Flags ============
  
  /// Whether to enable app update checking
  static bool isOpenAppUpdate = true;

  /// Use test chain for NFT (true = testnet, false = mainnet)
  static bool nftIsTestChain = false;

  /// Use mainnet for mining
  static bool isMainChainMining = true;

  /// Production environment flag
  /// 
  /// TODO: Replace with environment variable or build flavor
  /// Example: static final bool isOnline = const String.fromEnvironment('ENV') == 'production';
  static const bool isOnline = true;

  /// Test host selector (0 = test, other = main)
  static const int testHost = 0;

  // ============ API Endpoints ============
  
  static const Map<String, dynamic> apiUrl = {
    'walletName': 'N42Wallet',
    'walletamazeBrowser': 'https://www.n42.ai',
    'walletBuyHost': 'https://api-service.walletamaze.com/otc',
    'walletBuyHostV2': 'https://api.n42.ai/otc/r/onramper/url',
    
    // Market API
    'marketHost': {
      'main': 'https://api.n42.ai/market/v1',
      'test': 'http://5.78.28.90:9398/v1', // TODO(production): Replace with domain name
    },

    // NFT API
    'nftHost': {
      'main': 'https://api.n42.ai/nft-market',
      'test': 'https://5.78.28.90:9397', // TODO(production): Replace with domain name
    },

    // Activity API
    'activiteHost': {
      'main': 'https://api.n42.ai/activity/v1',
      'test': 'https://5.78.28.90:9390/v1', // TODO(production): Replace with domain name
    },

    // Mining API
    'groupMiningHost': {
      'main': 'https://api.n42.ai/activity',
      'test': 'https://5.78.28.90:9390', // TODO(production): Replace with domain name
    },

    // User Center API
    'userInfoHost': {
      'main': 'https://api.n42.ai/user',
      'test': 'https://5.78.28.90:9393', // TODO(production): Replace with domain name
    },
    
    // IPFS
    'ipfsHost': 'https://api.n42.ai',
    'ipfsAddress': 'https://api.astranet.app/ipfs/ipfs/',
    
    // Wallet/Token API
    'tokenViewUri': {
      'main': 'https://api.n42.ai/wallet/',
      'test': 'https://5.78.28.90:9492/', // TODO(production): Replace with domain name
    },

    // Exchange/Swap API
    'exchangeHost': {
      'main': 'https://api.n42.ai/swap',
      'test': 'https://5.78.28.90:9391', // TODO(production): Replace with domain name
    },
    
    // News API
    'newsHostUrl': 'https://astranet.world',
    
    // TRON API
    'tronUri': 'https://api.trongrid.io',
    
    // 1inch Swap
    'swap1inch': 'https://api.1inch.dev/',
    
    // IM (Instant Messaging) API
    'imHttpHost': {
      'main': 'https://5.161.249.184:10001', // TODO(production): Replace with domain name
      'test': 'https://5.78.28.90:9394', // TODO(production): Replace with domain name
    },

    // IM WebSocket
    // TODO(production): Upgrade ws:// to wss:// and replace IPs with domain names
    'imWsHost': {
      'main': 'ws://5.161.249.184:10002', // TODO(production): Upgrade to wss:// with domain name
      'test': 'ws://5.78.28.90:9395', // TODO(production): Upgrade to wss:// with domain name
    },
    
    // Block Explorer API
    'blockBrowserHost': {
      'main': 'https://mainnet.n42.world',
      'test': 'https://testnet.n42.world',
    },
    
    // Face API
    'face': 'https://api.n42.ai/face',

    // BTC Staking WebView URL
    // TODO: Replace with production URL when available
    'btcStaking': {
      'main': 'https://staking.n42.ai',
      'test': 'https://staking-test.n42.ai',
    },

    // CoinGecko API (for stablecoin prices)
    'coinGeckoApi': 'https://api.coingecko.com/api/v3',
  };

  // ============ Helper Methods ============
  
  /// Get API URL based on online/offline environment
  static String getApiUrlOnline(String key) {
    final endpoint = apiUrl[key];
    if (endpoint is Map) {
      return isOnline ? endpoint['main'] : endpoint['test'];
    }
    return endpoint?.toString() ?? '';
  }

  /// Get API URL based on test host setting
  static String getApiUrlTestHost(String key) {
    final endpoint = apiUrl[key];
    if (endpoint is Map) {
      return testHost == 0 ? endpoint['test'] : endpoint['main'];
    }
    return endpoint?.toString() ?? '';
  }


  // ============ Debug Helpers ============
  
  /// Check if running in debug mode
  static bool get isDebug => kDebugMode;

  /// Get current environment name
  static String get environmentName => isOnline ? 'Production' : 'Development';
}
