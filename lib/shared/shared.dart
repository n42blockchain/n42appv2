// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

// Shared Layer Module
//
// Contains shared entities, services, and events used across features.
// This layer enables loose coupling between feature modules.

// Domain - Shared Entities
export 'domain/entities/wallet_info.dart';

// Domain - Service Interfaces
export 'domain/services/wallet_service_interface.dart';

// Events
export 'events/event_manager.dart';
export 'events/cross_feature_events.dart';

// Contracts
export 'contracts/feature_contracts.dart';
