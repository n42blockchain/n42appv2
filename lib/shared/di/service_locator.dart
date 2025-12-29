// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:get_it/get_it.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/domain/services/mining_service_interface.dart';

/// Global Service Locator
///
/// Provides access to shared service interfaces.
/// Features register their implementations here.
final GetIt serviceLocator = GetIt.instance;

/// Service Locator Setup
///
/// Call this during app initialization to set up shared services.
class ServiceLocatorSetup {
  static bool _isInitialized = false;

  /// Initialize the service locator
  ///
  /// This should be called early in app startup.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Register lazy singletons - implementations will be registered by features
    // These are placeholder registrations that features will override
    
    _isInitialized = true;
  }

  /// Register wallet service implementation
  ///
  /// Called by Wallet feature during its initialization.
  static void registerWalletService(IWalletService service) {
    if (serviceLocator.isRegistered<IWalletService>()) {
      serviceLocator.unregister<IWalletService>();
    }
    serviceLocator.registerSingleton<IWalletService>(service);
  }

  /// Register mining service implementation
  ///
  /// Called by Mining feature during its initialization.
  static void registerMiningService(IMiningService service) {
    if (serviceLocator.isRegistered<IMiningService>()) {
      serviceLocator.unregister<IMiningService>();
    }
    serviceLocator.registerSingleton<IMiningService>(service);
  }

  /// Check if wallet service is available
  static bool get hasWalletService => 
      serviceLocator.isRegistered<IWalletService>();

  /// Check if mining service is available
  static bool get hasMiningService => 
      serviceLocator.isRegistered<IMiningService>();

  /// Get wallet service (null-safe)
  static IWalletService? get walletService {
    if (!hasWalletService) return null;
    return serviceLocator<IWalletService>();
  }

  /// Get mining service (null-safe)
  static IMiningService? get miningService {
    if (!hasMiningService) return null;
    return serviceLocator<IMiningService>();
  }

  /// Reset for testing
  static Future<void> reset() async {
    await serviceLocator.reset();
    _isInitialized = false;
  }
}

/// Convenience getters for services
extension ServiceLocatorExtensions on GetIt {
  /// Get wallet service
  IWalletService get walletService => get<IWalletService>();

  /// Get mining service
  IMiningService get miningService => get<IMiningService>();
}

