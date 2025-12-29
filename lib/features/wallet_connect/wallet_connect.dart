// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// WalletConnect Feature Module
///
/// DApp connection functionality using WalletConnect protocol:
/// - Session management
/// - Transaction signing
/// - Message signing
/// - Connection approval
library wallet_connect;

// Data Layer
export 'data/models/wallet_connect_session_model.dart';

// Presentation Layer
export 'presentation/providers/wallet_connect_provider.dart';
export 'presentation/pages/wallet_connect_page.dart';

