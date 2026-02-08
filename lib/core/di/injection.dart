// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:n42appv2/core/platform/deep_link_service.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/storage/app_database.dart';
import 'package:n42appv2/core/security/secure_storage.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/domain/services/mining_service_interface.dart';
import 'package:n42appv2/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42appv2/features/mining/data/services/mining_service_impl.dart';
import 'package:n42appv2/features/chat/data/services/chat_crypto_service_impl.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';

/// Dependency Injection Container
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
  // Store Riverpod container reference
  _providerContainer = container;

  // ============ Core Services ============

  // Storage
  if (!getIt.isRegistered<SPUtil>()) {
    getIt.registerLazySingleton<SPUtil>(() => SPUtil());
  }
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  }

  // Register ProviderContainer
  if (!getIt.isRegistered<ProviderContainer>()) {
    getIt.registerSingleton<ProviderContainer>(container);
  }

  // ============ Shared Services ============

  // Initialize shared service locator
  await ServiceLocatorSetup.initialize();

  // Register wallet service with ProviderContainer
  if (!getIt.isRegistered<WalletServiceImpl>()) {
    final walletService = WalletServiceImpl(container);
    getIt.registerSingleton<WalletServiceImpl>(walletService);
    ServiceLocatorSetup.registerWalletService(walletService);
  }

  // Register mining service
  if (!getIt.isRegistered<MiningServiceImpl>()) {
    final miningService = MiningServiceImpl();
    getIt.registerSingleton<MiningServiceImpl>(miningService);
    ServiceLocatorSetup.registerMiningService(miningService);
  }

  // Register chat crypto service
  if (!getIt.isRegistered<ChatCryptoServiceImpl>()) {
    final chatCryptoService = ChatCryptoServiceImpl(container);
    getIt.registerSingleton<ChatCryptoServiceImpl>(chatCryptoService);
    ServiceLocatorSetup.registerChatCryptoService(chatCryptoService);
  }

  // ============ Feature-specific registrations ============

  // ============ Wallet Services ============

  // Token View API - handles token/balance queries
  if (!getIt.isRegistered<TokenViewApi>()) {
    getIt.registerLazySingleton<TokenViewApi>(() => TokenViewApi());
  }

  // ============ Platform Services ============

  // Deep Link Service - handles deep link URI parsing
  if (!getIt.isRegistered<DeepLinkService>()) {
    getIt.registerLazySingleton<DeepLinkService>(() => DeepLinkService());
  }

  // ============ Security Services ============

  // Secure Storage - handles encrypted credential storage
  if (!getIt.isRegistered<SecureStorage>()) {
    getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
}

/// Reset dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  await ServiceLocatorSetup.reset();
  _providerContainer = null;
}

/// Convenience accessors - Core Services
SPUtil get spUtil => getIt<SPUtil>();
AppDatabase get appDatabase => getIt<AppDatabase>();
SecureStorage get secureStorage => getIt<SecureStorage>();
DeepLinkService get deepLinkService => getIt<DeepLinkService>();

/// Convenience accessors - Feature Services
WalletServiceImpl get walletServiceImpl => getIt<WalletServiceImpl>();
MiningServiceImpl get miningServiceImpl => getIt<MiningServiceImpl>();

/// Convenience accessors - Wallet APIs
TokenViewApi get tokenViewApi => getIt<TokenViewApi>();

// Shared service accessors (through interface)
IWalletService get walletService => serviceLocator<IWalletService>();
IMiningService get miningService => serviceLocator<IMiningService>();
