// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Mining Feature Module
///
/// This module contains all mining-related functionality including:
/// - Mining session management
/// - Reward tracking
/// - Mining plans and subscriptions
/// - Full node management
library mining;

// Data Layer
export 'data/api/mining_api.dart';
export 'data/models/mining_model.dart';

// Domain Layer
export 'domain/entities/mining_entity.dart';
export 'domain/usecases/start_mining.dart';

// Presentation Layer
export 'presentation/providers/mining_v2_provider.dart';
export 'presentation/pages/mining_today_v2.dart';

