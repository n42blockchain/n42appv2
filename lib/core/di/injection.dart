// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/storage/app_database.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42_wallet/features/mining/data/services/mining_service_impl.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_sdk.dart';
import 'package:n42_wallet/core/passkey/passkey_service.dart';

/// Dependency Injection Container (Composition Root)
///
/// This file is the DI composition root and legitimately imports feature-level
/// implementations to wire them to shared interfaces. This is an accepted
/// exception to the "core must not import features" rule.
final GetIt getIt = GetIt.instance;

/// Environment Types
enum Env { dev, staging, prod }

/// Global ProviderContainer reference (set during initialization)
ProviderContainer? _providerContainer;

/// Get the global ProviderContainer
ProviderContainer get providerContainer {
  if (_providerContainer == null) {
    throw StateError(
      'ProviderContainer not initialized. Call configureDependencies() first.',
    );
  }
  return _providerContainer!;
}

/// Register [T] with GetIt only if not already registered.
void _registerIfAbsent<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory);
  }
}

/// Register [T] as an eager singleton with GetIt only if not already registered.
void _registerSingletonIfAbsent<T extends Object>(T instance) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerSingleton<T>(instance);
  }
}

/// Configure Dependencies
///
/// Call this at app startup to initialize all dependencies.
///
/// [env] - The environment (dev, staging, prod)
/// [container] - The Riverpod ProviderContainer for bridging state
Future<void> configureDependencies(
  Env env, {
  required ProviderContainer container,
}) async {
  _providerContainer = container;

  // Core storage
  _registerIfAbsent<SPUtil>(() => SPUtil());
  _registerIfAbsent<AppDatabase>(() => AppDatabase.instance);
  _registerSingletonIfAbsent<ProviderContainer>(container);

  // Shared service locator
  await ServiceLocatorSetup.initialize();

  // Feature services
  if (!getIt.isRegistered<WalletServiceImpl>()) {
    final walletService = WalletServiceImpl(container);
    getIt.registerSingleton<WalletServiceImpl>(walletService);
    ServiceLocatorSetup.registerWalletService(walletService);
  }

  if (!getIt.isRegistered<MiningServiceImpl>()) {
    final miningService = MiningServiceImpl();
    getIt.registerSingleton<MiningServiceImpl>(miningService);
    ServiceLocatorSetup.registerMiningService(miningService);
  }

  // Wallet SDK
  _registerIfAbsent<WalletSdk>(() => WalletSdk());

  // Platform and security
  _registerIfAbsent<TokenViewApi>(() => TokenViewApi());
  _registerIfAbsent<SecureStorage>(() => SecureStorage());
  _registerIfAbsent<PasskeyService>(() => PasskeyService(getIt<SecureStorage>()));
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  await ServiceLocatorSetup.reset();
  _providerContainer = null;
}

/// Convenience accessors — only the ones with actual consumers are
/// exposed. Other services (AppDatabase / SecureStorage / DeepLinkService /
/// WalletSdk / TokenViewApi / IWalletService / IMiningService) are
/// consumed via their own Riverpod providers or instantiated inline at
/// the call site. See lib/core/providers/service_providers.dart for the
/// Riverpod surface preferred by new code.
SPUtil get spUtil => getIt<SPUtil>();
MiningServiceImpl get miningServiceImpl => getIt<MiningServiceImpl>();
