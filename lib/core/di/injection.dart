// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/mining/data/services/mining_service_impl.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';

/// Dependency Injection Container (Composition Root)
///
/// This file is the DI composition root and legitimately imports feature-level
/// implementations to wire them to shared interfaces. This is an accepted
/// exception to the "core must not import features" rule.
///
/// All cross-feature singletons live behind Riverpod providers — see
/// [walletServiceProvider] / [miningServiceProvider] in
/// `lib/core/providers/service_providers.dart` for the read side, and
/// [registerWalletService] / [registerMiningService] for the write side.

/// Environment Types
enum Env { dev, staging, prod }

/// Global ProviderContainer reference (set during initialization)
ProviderContainer? _providerContainer;

/// Concrete [MiningServiceImpl] view of the registered [IMiningService].
///
/// Exposed for [main.dart]'s post-init `attachToV2Provider` wiring, which
/// needs the concrete subclass (not the [IMiningService] interface).
/// Reads through [currentMiningService] so there is a single source of
/// truth — `configureDependencies` always registers a [MiningServiceImpl],
/// so the cast is safe.
MiningServiceImpl get miningServiceImpl {
  final svc = currentMiningService;
  if (svc is! MiningServiceImpl) {
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

  if (currentWalletService == null) {
    registerWalletService(WalletServiceImpl(container));
  }

  if (currentMiningService == null) {
    registerMiningService(MiningServiceImpl());
  }
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  resetCrossFeatureServices();
  _providerContainer = null;
}
