// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Wallet Feature Module
///
/// This module handles all wallet-related functionality:
/// - Wallet creation and import
/// - Balance management
/// - Transaction handling
/// - Token management
library wallet;

// Domain Layer
export 'domain/entities/wallet_entity.dart' hide ChainType;
export 'domain/repositories/wallet_repository.dart';
export 'domain/usecases/create_wallet.dart' hide ChainType;
export 'domain/usecases/get_balance.dart' hide ChainType;
export 'domain/usecases/send_transaction.dart';

// Export ChainType from a single source
export 'package:n42appv2/domain/entities/wallet.dart' show ChainType;

// Data Layer
export 'data/repositories/wallet_repository_impl.dart';
export 'data/datasources/wallet_local_datasource.dart';
export 'data/datasources/wallet_remote_datasource.dart';

// Presentation Layer - To be migrated from lib/src/wallet/
// export 'presentation/providers/wallet_action_provider.dart';
// export 'presentation/pages/wallet_page.dart';
