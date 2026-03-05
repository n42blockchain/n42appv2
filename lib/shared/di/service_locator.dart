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

  static IWalletService? get walletService =>
      hasWalletService ? serviceLocator<IWalletService>() : null;

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

