// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// Riverpod facade for cross-feature service singletons (IWalletService,
// IMiningService, DeepLinkService).
//
// Why this layer exists:
//   - The wallet, mining, browser and walletconnect features need to call
//     into each other through small typed interfaces. Exposing the
//     concrete instances behind providers keeps widget tests trivially
//     overridable via `ProviderContainer.overrideWith(...)`.
//   - Non-widget consumers (`n42_wallet_bridge`, mining channel, mixin on
//     ChangeNotifier, plain Dart classes) have no `WidgetRef`, so they
//     resolve through `globalProviderContainer.read(...)`.
//
// Storage model:
//   - [walletServiceProvider] / [miningServiceProvider] read from
//     module-level `_walletService` / `_miningService` populated by
//     [registerWalletService] / [registerMiningService] during
//     `configureDependencies`. The provider caches the first read, which
//     is fine because production registers each service exactly once at
//     startup. Re-registration callers must `container.invalidate(...)`
//     the provider to pick up a new instance.
//   - [deepLinkServiceProvider] owns its own singleton.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/shared/domain/services/mining_service_interface.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

IWalletService? _walletService;
IMiningService? _miningService;

/// The currently-registered [IWalletService], or null. Mainly for
/// `configureDependencies` to gate idempotent registration; consumers
/// should resolve through [walletServiceProvider] instead.
IWalletService? get currentWalletService => _walletService;

/// The currently-registered [IMiningService], or null. See
/// [currentWalletService].
IMiningService? get currentMiningService => _miningService;

/// Register the live [IWalletService] for cross-feature consumers.
/// Called from `configureDependencies`.
void registerWalletService(IWalletService service) {
  _walletService = service;
}

/// Register the live [IMiningService] for cross-feature consumers.
/// Called from `configureDependencies`.
void registerMiningService(IMiningService service) {
  _miningService = service;
}

/// Clear both service registrations. Used by `resetDependencies` and by
/// the contract tests to keep each case isolated.
void resetCrossFeatureServices() {
  _walletService = null;
  _miningService = null;
}

/// Provides the currently-registered [IWalletService], or null when it
/// has not been registered yet (very early startup, or test harness
/// that intentionally omitted it).
///
/// **Reading from a widget**: `ref.watch(walletServiceProvider)` or
/// `ref.read(walletServiceProvider)`.
/// **Reading from a non-widget** (ChangeNotifier mixin, plain class,
/// background isolate boundary): `globalProviderContainer.read(walletServiceProvider)`.
///
/// To override in a test:
/// ```dart
/// final container = ProviderContainer(overrides: [
///   walletServiceProvider.overrideWithValue(FakeWalletService()),
/// ]);
/// ```
final walletServiceProvider = Provider<IWalletService?>((ref) {
  return _walletService;
});

/// Provides the currently-registered [IMiningService], or null.
/// Same shape and override semantics as [walletServiceProvider].
final miningServiceProvider = Provider<IMiningService?>((ref) {
  return _miningService;
});

/// Singleton [DeepLinkService] for the running app. Created once by the
/// provider on first read, disposed when the container disposes.
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
});
