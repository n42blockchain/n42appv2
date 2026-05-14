// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42_wallet/features/mining/data/services/mining_service_impl.dart';

/// Dependency Injection Container (Composition Root)
///
/// This file is the DI composition root and legitimately imports feature-level
/// implementations to wire them to shared interfaces. This is an accepted
/// exception to the "core must not import features" rule.
///
/// GetIt is being phased out — only services with active `getIt<T>()` callers
/// remain registered here (SPUtil and MiningServiceImpl). Everything else is
/// either exposed as a Riverpod provider (see
/// `lib/core/providers/service_providers.dart`) or instantiated inline at the
/// call site.
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

  // Core storage: SPUtil is consumed via the [spUtil] getter (22+ call sites
  // not yet migrated to [spUtilProvider]). AppDatabase, WalletSdk, TokenViewApi
  // and SecureStorage are no longer registered — callers instantiate them
  // directly (they are all stateless or platform-singletons).
  _registerIfAbsent<SPUtil>(() => SPUtil());

  // Shared service locator
  await ServiceLocatorSetup.initialize();

  // Feature services. The local refs are kept for the duration of this call
  // so they can be handed to [ServiceLocatorSetup]; GetIt only retains
  // MiningServiceImpl because the [miningServiceImpl] getter still has one
  // caller in main.dart for attachToV2Provider wiring.
  if (!ServiceLocatorSetup.hasWalletService) {
    ServiceLocatorSetup.registerWalletService(WalletServiceImpl(container));
  }

  if (!getIt.isRegistered<MiningServiceImpl>()) {
    final miningService = MiningServiceImpl();
    getIt.registerSingleton<MiningServiceImpl>(miningService);
    ServiceLocatorSetup.registerMiningService(miningService);
  }
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  await ServiceLocatorSetup.reset();
  _providerContainer = null;
}

/// Convenience accessors. Other services are consumed via Riverpod providers
/// or instantiated inline. See lib/core/providers/service_providers.dart for
/// the Riverpod surface preferred by new code.
SPUtil get spUtil => getIt<SPUtil>();
MiningServiceImpl get miningServiceImpl => getIt<MiningServiceImpl>();
