// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

// Mining Feature Module
//
// This module handles all mining-related functionality:
// - Mining status and plans
// - Mining session management
// - Rewards claiming
// - Mining statistics

// Domain Layer
export 'domain/entities/mining_entity.dart';
export 'domain/repositories/mining_repository.dart';
export 'domain/usecases/start_mining.dart';

// Data Layer
export 'data/services/mining_service_impl.dart';
export 'data/repositories/mining_repository_impl.dart';

// Presentation Layer
export 'presentation/providers/mining_providers.dart';
// Pages still live in lib/src/mining_v2/ (V2 implementation, migration pending):
// export 'presentation/pages/mining_today_v2.dart';
