// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Wallet Feature
///
/// Handles cryptocurrency wallet functionality including:
/// - Wallet creation and management
/// - Balance tracking
/// - Transactions
/// - Token management

library;

// Domain Layer
export 'domain/entities/wallet_entity.dart';
export 'domain/usecases/create_wallet.dart';
export 'domain/usecases/get_balance.dart';

// Data Layer
export 'data/services/wallet_service_impl.dart';

// TODO: Export actual implementations when files are migrated
// Data Layer
// export 'data/api/wallet_api.dart';
// export 'data/models/wallet_info.dart';
// export 'data/models/coin_model.dart';

// Presentation Layer
// export 'presentation/providers/wallet_action_provider.dart';
// export 'presentation/pages/wallet_page.dart';
