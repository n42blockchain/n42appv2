// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Authentication Feature Module
///
/// User authentication functionality including:
/// - Email/password login
/// - Registration
/// - Password recovery
/// - 2FA (Google Authenticator)
library auth;

// Data Layer
export 'data/api/login_api.dart';
export 'data/api/user_info_api.dart';

// Presentation Layer
export 'presentation/pages/login_page.dart';
export 'presentation/pages/account_create_and_reset.dart';

