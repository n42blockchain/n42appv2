// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// N42 Wallet Features
///
/// This library exports all feature modules for the N42 Wallet application.
/// Each feature is self-contained with its own:
/// - Data layer (API, models, repositories)
/// - Domain layer (entities, usecases)
/// - Presentation layer (pages, widgets, providers)
library features;

export 'wallet/wallet.dart';
export 'chat/chat.dart';
export 'mining/mining.dart';
export 'browser/browser.dart';
export 'auth/auth.dart';
export 'wallet_connect/wallet_connect.dart';

