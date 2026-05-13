// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:get_it/get_it.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';
import 'package:n42_wallet/shared/domain/services/mining_service_interface.dart';

final GetIt serviceLocator = GetIt.instance;

/// Shared service locator setup. Call during app initialization.
///
/// **For new code, prefer the Riverpod providers in
/// `lib/core/providers/service_providers.dart`:**
/// - `walletServiceProvider` returns `IWalletService?`
/// - `miningServiceProvider` returns `IMiningService?`
///
/// They read from the same GetIt singleton this class manages, so the
/// runtime behaviour is identical, but Riverpod gives you:
///   - `ProviderContainer.overrideWith(...)` for clean test isolation
///   - Automatic invalidation if a service is re-registered
///   - Type-safe access via `ref.watch` in widgets / `ref.read` in
///     callbacks / `globalProviderContainer.read` in non-widget code
///
/// This class remains the **registration entry point** (call
/// `ServiceLocatorSetup.registerWalletService` from
/// `configureDependencies`); only the read side is migrating.
class ServiceLocatorSetup {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  static void registerWalletService(IWalletService service) {
    _registerSingleton<IWalletService>(service);
  }

  static void registerMiningService(IMiningService service) {
    _registerSingleton<IMiningService>(service);
  }

  static bool get hasWalletService =>
      serviceLocator.isRegistered<IWalletService>();

  static bool get hasMiningService =>
      serviceLocator.isRegistered<IMiningService>();

  /// Prefer `walletServiceProvider` from
  /// `lib/core/providers/service_providers.dart`. Retained because the
  /// provider implementation reads through this getter.
  static IWalletService? get walletService =>
      hasWalletService ? serviceLocator<IWalletService>() : null;

  /// Prefer `miningServiceProvider` from
  /// `lib/core/providers/service_providers.dart`. See [walletService].
  static IMiningService? get miningService =>
      hasMiningService ? serviceLocator<IMiningService>() : null;

  static Future<void> reset() async {
    await serviceLocator.reset();
    _isInitialized = false;
  }

  static void _registerSingleton<T extends Object>(T instance) {
    if (serviceLocator.isRegistered<T>()) {
      serviceLocator.unregister<T>();
    }
    serviceLocator.registerSingleton<T>(instance);
  }
}

extension ServiceLocatorExtensions on GetIt {
  IWalletService get walletService => get<IWalletService>();
  IMiningService get miningService => get<IMiningService>();
}

