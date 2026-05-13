// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// Riverpod-side facade for the cross-feature service interfaces that
// historically lived behind [ServiceLocatorSetup] (which is a thin
// GetIt wrapper).
//
// Why both layers coexist:
//   - n42_wallet has a chunk of services (chat / mining / wallet) that
//     need to call into each other. Doing this through Riverpod
//     providers is the documented preference (see CLAUDE.md), and lets
//     widget tests override individual services cleanly with
//     `ProviderContainer.overrideWith(...)`.
//   - But several consumers are NOT widgets: `n42_wallet_bridge` is
//     a ChangeNotifier-mixin class, `wallet_connect_connection` is a
//     mixin on top of one, `mining_service_impl` is a plain class. They
//     have no BuildContext / WidgetRef, only `globalProviderContainer`.
//
// This file gives both populations a single surface:
//   - Widgets: `ref.watch(walletServiceProvider)` / `ref.read(...)`
//   - Non-widgets: `globalProviderContainer.read(walletServiceProvider)`
//
// The provider returns whatever `ServiceLocatorSetup` currently has
// registered (nullable to match the existing `.walletService` getter
// shape). Once all call sites use the providers, ServiceLocatorSetup
// itself can shrink to a private implementation detail.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/shared/di/service_locator.dart';
import 'package:n42_wallet/shared/domain/services/mining_service_interface.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';

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
  return ServiceLocatorSetup.walletService;
});

/// Provides the currently-registered [IMiningService], or null.
/// Same shape and override semantics as [walletServiceProvider].
final miningServiceProvider = Provider<IMiningService?>((ref) {
  return ServiceLocatorSetup.miningService;
});

/// Singleton [DeepLinkService] for the running app. Created once by the
/// provider on first read, disposed when the container disposes.
///
/// Previously fetched from GetIt; the GetIt registration is no longer
/// needed since the provider is the only consumer.
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
});
