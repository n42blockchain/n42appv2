// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:get_it/get_it.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/storage/app_database.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/domain/services/mining_service_interface.dart';
import 'package:n42appv2/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42appv2/features/mining/data/services/mining_service_impl.dart';

/// Dependency Injection Container
final GetIt getIt = GetIt.instance;

/// Environment Types
enum Env { dev, staging, prod }

/// Configure Dependencies
///
/// Call this at app startup to initialize all dependencies.
Future<void> configureDependencies(Env env) async {
  // ============ Core Services ============
  
  // Storage
  getIt.registerLazySingleton<SPUtil>(() => SPUtil());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // ============ Shared Services ============
  
  // Initialize shared service locator
  await ServiceLocatorSetup.initialize();

  // Register wallet service
  final walletService = WalletServiceImpl();
  getIt.registerSingleton<WalletServiceImpl>(walletService);
  ServiceLocatorSetup.registerWalletService(walletService);

  // Register mining service
  final miningService = MiningServiceImpl();
  getIt.registerSingleton<MiningServiceImpl>(miningService);
  ServiceLocatorSetup.registerMiningService(miningService);

  // ============ Feature-specific registrations ============
  // These would be added as features are migrated
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  await ServiceLocatorSetup.reset();
}

/// Convenience accessors
SPUtil get spUtil => getIt<SPUtil>();
AppDatabase get appDatabase => getIt<AppDatabase>();
WalletServiceImpl get walletServiceImpl => getIt<WalletServiceImpl>();
MiningServiceImpl get miningServiceImpl => getIt<MiningServiceImpl>();

// Shared service accessors (through interface)
IWalletService get walletService => serviceLocator<IWalletService>();
IMiningService get miningService => serviceLocator<IMiningService>();
