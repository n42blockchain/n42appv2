// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// SECURITY NOTE: All API keys have been migrated to ApiKeysConfig
// which uses environment variables for secure key management.
// See: lib/core/config/api_keys_config.dart
//
// To configure API keys:
// flutter run --dart-define=ETHERSCAN_API_KEY=xxx --dart-define=BSCSCAN_API_KEY=xxx
//
// This file is kept for reference of supported chain explorer endpoints.
// DO NOT add hardcoded API keys here.

/// Chain Browser URL configuration (deprecated)
///
/// Use [ApiKeysConfig] for API key management instead.
/// Example:
/// ```dart
/// final url = ApiKeysConfig.getEtherscanApiUrl();
/// ```
