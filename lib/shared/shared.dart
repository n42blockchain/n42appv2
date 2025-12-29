// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Shared Layer
///
/// This barrel file exports all shared entities, interfaces, and utilities
/// that can be used across features without creating direct dependencies.

// Domain Entities
export 'domain/entities/wallet_info.dart';
export 'domain/entities/balance_info.dart';

// Service Interfaces
export 'domain/services/wallet_service_interface.dart';
export 'domain/services/mining_service_interface.dart';

// Events
export 'events/cross_feature_events.dart';

// Contracts
export 'contracts/feature_contracts.dart';

