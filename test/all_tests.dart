// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei
//
// All Tests Runner
//
// Run all tests with: flutter test test/all_tests.dart
// Or run all tests: flutter test

// Core Provider Tests
import 'core/providers/core_providers_test.dart' as core_providers_test;
import 'core/providers/theme_provider_test.dart' as theme_provider_test;
import 'core/providers/locale_provider_test.dart' as locale_provider_test;
import 'core/providers/use_new_chat_provider_test.dart' as use_new_chat_test;
import 'core/providers/screen_lock_provider_test.dart' as screen_lock_test;

// Core Security Tests
import 'core/security/device_security_test.dart' as device_security_test;
import 'core/security/secure_storage_test.dart' as secure_storage_test;
import 'core/security/security_config_test.dart' as security_config_test;

// Core Platform Tests
import 'core/platform/deep_link_service_test.dart' as deep_link_service_test;

// Core Routing Tests
import 'core/routing/deep_link_handler_test.dart' as deep_link_handler_test;

// Core Error Tests
import 'core/error/failures_test.dart' as failures_test;

// Core Network Tests
import 'core/network/api_client_test.dart' as api_client_test;

// Core Performance Tests
import 'core/performance/performance_config_test.dart' as performance_config_test;

// Core Enum Tests
import 'core/enums/coin_type_test.dart' as coin_type_test;

// Feature Tests - Wallet
import 'features/wallet/domain/usecases/create_wallet_test.dart' as create_wallet_test;
import 'features/wallet/domain/usecases/get_balance_test.dart' as get_balance_test;
import 'features/wallet/domain/usecases/send_transaction_test.dart' as send_transaction_test;
import 'features/wallet/providers/wallet_providers_test.dart' as wallet_providers_test;
import 'features/wallet/chain_config_test.dart' as chain_config_test;
import 'features/wallet/address_validation_test.dart' as address_validation_test;

// Widget Tests
import 'widget/theme_test.dart' as theme_test;
import 'widget/platform_test.dart' as platform_test;
import 'widget/chain_ui_test.dart' as chain_ui_test;

// Localization Tests
import 'l10n/localization_test.dart' as localization_test;

// Integration Tests
import 'integration/app_initialization_test.dart' as app_init_test;

// Benchmark Tests
import 'benchmark/core_business_benchmark_test.dart' as core_business_benchmark;
import 'benchmark/navigation_benchmark_test.dart' as navigation_benchmark;
import 'benchmark/startup_benchmark_test.dart' as startup_benchmark;

// Feature Tests - Gas
import 'features/gas/gas_estimate_model_test.dart' as gas_estimate_model_test;

// Feature Tests - Bridge
import 'features/bridge/bridge_model_test.dart' as bridge_model_test;

// Feature Tests - Staking
import 'features/staking/staking_model_test.dart' as staking_model_test;

// Feature Tests - Hardware Wallet
import 'features/hardware_wallet/hardware_wallet_model_test.dart' as hardware_wallet_model_test;

// Feature Tests - Batch Transfer
import 'features/batch_transfer/batch_transfer_model_test.dart' as batch_transfer_model_test;

// Feature Tests - Airdrop
import 'features/airdrop/airdrop_model_test.dart' as airdrop_model_test;

// Feature Tests - Loyalty
import 'features/loyalty/loyalty_model_test.dart' as loyalty_model_test;

void main() {
  // Core Provider Tests
  core_providers_test.main();
  theme_provider_test.main();
  locale_provider_test.main();
  use_new_chat_test.main();
  screen_lock_test.main();

  // Core Security Tests
  device_security_test.main();
  secure_storage_test.main();
  security_config_test.main();

  // Core Platform Tests
  deep_link_service_test.main();

  // Core Routing Tests
  deep_link_handler_test.main();

  // Core Error Tests
  failures_test.main();

  // Core Network Tests
  api_client_test.main();

  // Core Performance Tests
  performance_config_test.main();

  // Core Enum Tests
  coin_type_test.main();

  // Feature Tests - Wallet
  create_wallet_test.main();
  get_balance_test.main();
  send_transaction_test.main();
  wallet_providers_test.main();
  chain_config_test.main();
  address_validation_test.main();

  // Widget Tests
  theme_test.main();
  platform_test.main();
  chain_ui_test.main();

  // Localization Tests
  localization_test.main();

  // Integration Tests
  app_init_test.main();

  // Benchmark Tests
  core_business_benchmark.main();
  navigation_benchmark.main();
  startup_benchmark.main();

  // Feature Tests - New Modules
  gas_estimate_model_test.main();
  bridge_model_test.main();
  staking_model_test.main();
  hardware_wallet_model_test.main();
  batch_transfer_model_test.main();
  airdrop_model_test.main();
  loyalty_model_test.main();
}

