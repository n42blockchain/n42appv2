// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42_wallet/features/mining/data/services/mining_service_impl.dart';

/// Dependency Injection Container (Composition Root)
///
/// This file is the DI composition root and legitimately imports feature-level
/// implementations to wire them to shared interfaces. This is an accepted
/// exception to the "core must not import features" rule.
///
/// All cross-feature singletons are now exposed through Riverpod (see
/// `lib/core/providers/service_providers.dart` and `core_providers.dart`).
/// [ServiceLocatorSetup] still holds the canonical `IWalletService` /
/// `IMiningService` instances internally (it remains a thin GetIt wrapper);
/// the providers read through it.

/// Environment Types
enum Env { dev, staging, prod }

/// Global ProviderContainer reference (set during initialization)
ProviderContainer? _providerContainer;

/// The [MiningServiceImpl] created during dependency configuration.
///
/// Exposed for [main.dart]'s post-init `attachToV2Provider` wiring — the
/// adapter has to bind after both `globalMiningInstance` and the service
/// exist, and that order is enforced by main.dart itself, not Riverpod.
MiningServiceImpl? _miningServiceImpl;
MiningServiceImpl get miningServiceImpl {
  final svc = _miningServiceImpl;
  if (svc == null) {
    throw StateError(
      'MiningServiceImpl not initialized. Call configureDependencies() first.',
    );
  }
  return svc;
}

/// Get the global ProviderContainer
ProviderContainer get providerContainer {
  if (_providerContainer == null) {
    throw StateError(
      'ProviderContainer not initialized. Call configureDependencies() first.',
    );
  }
  return _providerContainer!;
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

  // Shared service locator (initializes the GetIt singleton used internally
  // by ServiceLocatorSetup).
  await ServiceLocatorSetup.initialize();

  if (!ServiceLocatorSetup.hasWalletService) {
    ServiceLocatorSetup.registerWalletService(WalletServiceImpl(container));
  }

  if (!ServiceLocatorSetup.hasMiningService) {
    final miningService = MiningServiceImpl();
    _miningServiceImpl = miningService;
    ServiceLocatorSetup.registerMiningService(miningService);
  }
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  await ServiceLocatorSetup.reset();
  _miningServiceImpl = null;
  _providerContainer = null;
}
